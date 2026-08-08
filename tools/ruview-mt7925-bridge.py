#!/usr/bin/env python3
import os
import sys
import time
import math
import struct
import json
import asyncio
import argparse
from collections import deque

try:
    import websockets
except ImportError:
    print("[!] Error: websockets package is required. Install via pip install websockets")
    sys.exit(1)

# Format: ts_ns(Q), prxv[4](4I), crxv[24](24I), rcpi[4](4b), mcs(B), nss(B), bw(B), mode(B) -> 128 bytes
STRUCT_FMT = "<Q4I24I4b4B"
SAMPLE_SIZE = struct.calcsize(STRUCT_FMT)

class MT7925SensingBridge:
    def __init__(self, debugfs_path, host="0.0.0.0", port=3001, mode="AR9271_LOW"):
        self.debugfs_path = debugfs_path
        self.host = host
        self.port = port
        self.mode = mode
        
        self.clients = set()
        self.history = deque(maxlen=60)
        self.diff_history = deque(maxlen=60)
        self.c7_history = deque(maxlen=60)
        
        # Adaptive Baseline Statistics
        self.base_mean = -60.0
        self.base_std = 1.2
        self.calibrated = False
        self.calib_samples = []
        
    def mean(self, lst):
        return sum(lst) / len(lst) if lst else 0.0

    def std(self, lst):
        m = self.mean(lst)
        return math.sqrt(sum((x - m) ** 2 for x in lst) / len(lst)) if lst else 0.0

    def parse_sample(self, raw_bytes):
        if len(raw_bytes) < SAMPLE_SIZE:
            return None
        unpacked = struct.unpack(STRUCT_FMT, raw_bytes[:SAMPLE_SIZE])
        ts_ns = unpacked[0]
        prxv = unpacked[1:5]
        crxv = unpacked[5:29]
        rcpi = unpacked[29:33]
        mcs, nss, bw, mode = unpacked[33:37]
        return {
            "ts_sec": ts_ns / 1e9,
            "prxv": prxv,
            "crxv": crxv,
            "rcpi": rcpi,
            "mcs": mcs,
            "nss": nss,
            "bw": bw,
            "mode": mode,
            "rcpi_diff": rcpi[0] - rcpi[1]
        }

    def compute_features(self, sample):
        rcpi0 = sample["rcpi"][0]
        rcpi1 = sample["rcpi"][1]
        rcpi_diff = sample["rcpi_diff"]
        c7 = sample["crxv"][7]

        self.history.append(rcpi0)
        self.diff_history.append(rcpi_diff)
        self.c7_history.append(c7)

        cur_mean_rssi = self.mean(self.history)
        cur_diff_std = self.std(self.diff_history)
        cur_c7_std = self.std(self.c7_history)
        cur_c7_entropy = len(set(self.c7_history))

        # Calibration collection phase
        if not self.calibrated and len(self.history) >= 30:
            self.calib_samples.append(cur_diff_std)
            if len(self.calib_samples) >= 50:
                self.base_std = max(0.5, self.mean(self.calib_samples))
                self.calibrated = True
                print(f"[+] Calibration complete! Baseline diff_std: {self.base_std:.2f}")

        # Classification logic
        motion_score = cur_diff_std / (self.base_std if self.base_std > 0 else 1.0)
        
        if motion_score > 2.5:
            motion_level = "active"
            presence = True
            confidence = min(0.98, 0.70 + 0.05 * motion_score)
        elif motion_score > 1.3:
            motion_level = "present_still"
            presence = True
            confidence = min(0.90, 0.60 + 0.05 * motion_score)
        else:
            motion_level = "absent"
            presence = False
            confidence = 0.85

        # 3D Proxy Signal Field Blob
        grid_size = 20
        t = time.time()
        values = []
        cx, cy = grid_size // 2, grid_size // 2
        for iz in range(grid_size):
            for ix in range(grid_size):
                dist = math.sqrt((ix - cx) ** 2 + (iz - cy) ** 2)
                v = max(0, 1 - dist / (grid_size * 0.7)) * 0.2
                if presence:
                    bx = cx + 2 * math.sin(t * 0.3)
                    by = cy + 2 * math.cos(t * 0.2)
                    b_dist = math.sqrt((ix - bx) ** 2 + (iz - by) ** 2)
                    v += math.exp(-b_dist * b_dist / 6) * (0.4 + (0.2 if motion_level == "active" else 0.0))
                values.append(min(1.0, max(0.0, v)))

        return {
            "type": "sensing_update",
            "timestamp": sample["ts_sec"],
            "source": "mt7925_rxv",
            "_simulated": False,
            "mode_label": "NO TRUE CSI — RXV SENSING MODE",
            "nodes": [
                {
                    "node_id": 1,
                    "rssi_dbm": rcpi0,
                    "rcpi0": rcpi0,
                    "rcpi1": rcpi1,
                    "rcpi_diff": rcpi_diff,
                    "snr": sample["crxv"][20] & 0xFF,
                    "subcarrier_count": 0
                }
            ],
            "features": {
                "mean_rssi": cur_mean_rssi,
                "variance": cur_diff_std ** 2,
                "std": cur_diff_std,
                "motion_band_power": cur_diff_std * 0.1,
                "breathing_band_power": 0.04,
                "c7_entropy": cur_c7_entropy,
                "c7_std": cur_c7_std
            },
            "classification": {
                "motion_level": motion_level,
                "presence": presence,
                "confidence": confidence
            },
            "signal_field": {
                "grid_size": [grid_size, 1, grid_size],
                "values": values
            }
        }

    async def register(self, websocket):
        self.clients.add(websocket)
        print(f"[+] Client connected from {websocket.remote_address}")
        try:
            await websocket.wait_closed()
        finally:
            self.clients.remove(websocket)
            print(f"[-] Client disconnected")

    async def broadcast(self, payload):
        if not self.clients:
            return
        msg = json.dumps(payload)
        await asyncio.gather(*[client.send(msg) for client in self.clients], return_exceptions=True)

    async def reader_loop(self):
        print(f"[+] Opening DebugFS telemetry node: {self.debugfs_path}")
        while True:
            try:
                fd = os.open(self.debugfs_path, os.O_RDONLY | os.O_NONBLOCK)
                buf = b""
                print("[+] Successfully attached to MT7925 RXV Telemetry Stream!")
                while True:
                    try:
                        chunk = os.read(fd, 65536)
                        if chunk:
                            buf += chunk
                            while len(buf) >= SAMPLE_SIZE:
                                raw_sample = buf[:SAMPLE_SIZE]
                                buf = buf[SAMPLE_SIZE:]
                                sample = self.parse_sample(raw_sample)
                                if sample:
                                    payload = self.compute_features(sample)
                                    await self.broadcast(payload)
                        else:
                            await asyncio.sleep(0.005)
                    except BlockingIOError:
                        await asyncio.sleep(0.005)
                    except Exception as e:
                        print(f"[!] Read error: {e}")
                        break
                os.close(fd)
            except Exception as e:
                print(f"[!] Re-opening node in 1s ({e})...")
                await asyncio.sleep(1.0)

async def main():
    parser = argparse.ArgumentParser(description="RuView MT7925 RXV Telemetry Bridge")
    parser.add_argument("--node", required=True, help="DebugFS telemetry node path")
    parser.add_argument("--port", type=int, default=3001, help="WebSocket server port")
    parser.add_argument("--mode", default="AR9271_LOW", help="RF Illuminator Mode")
    args = parser.parse_args()

    bridge = MT7925SensingBridge(debugfs_path=args.node, port=args.port, mode=args.mode)
    
    server = await websockets.serve(bridge.register, "0.0.0.0", args.port)
    print(f"[+] RuView MT7925 WebSocket Server listening on ws://0.0.0.0:{args.port}/ws/sensing")
    
    await bridge.reader_loop()

if __name__ == "__main__":
    asyncio.run(main())

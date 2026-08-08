#!/usr/bin/env python3
import time
import json
import re
import asyncio
import pexpect

ROUTER_IP = "192.168.50.1"
ROUTER_PORT = 1024
ROUTER_USER = "admin"
ROUTER_PASS = "adminadmin"

class AsusRouterCollector:
    def __init__(self, host=ROUTER_IP, port=ROUTER_PORT, user=ROUTER_USER, password=ROUTER_PASS):
        self.host = host
        self.port = port
        self.user = user
        self.password = password
        self.known_clients = {}

    def exec_cmd(self, command):
        cmd_str = f'ssh -p {self.port} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null {self.user}@{self.host} "{command}"'
        try:
            child = pexpect.spawn(cmd_str)
            i = child.expect(['[pP]assword:', pexpect.EOF, pexpect.TIMEOUT], timeout=6)
            if i == 0:
                child.sendline(self.password)
                child.expect(pexpect.EOF, timeout=10)
                return child.before.decode('utf-8', errors='ignore')
        except Exception as e:
            print(f"[!] SSH Exec error: {e}")
        return ""

    def parse_leases(self):
        leases = {}
        out = self.exec_cmd("cat /var/lib/misc/dnsmasq.leases 2>/dev/null || cat /tmp/dhcp.leases 2>/dev/null")
        for line in out.splitlines():
            parts = line.strip().split()
            if len(parts) >= 4:
                ts, mac, ip, hostname = parts[0], parts[1].upper(), parts[2], parts[3]
                leases[mac] = {"ip": ip, "hostname": hostname if hostname != "*" else "Unknown"}
        return leases

    def get_associated_clients(self):
        leases = self.parse_leases()
        clients = {}

        # 2.4 GHz (eth6) & 5 GHz (eth7)
        for band_label, iface in [("2.4G", "eth6"), ("5G", "eth7")]:
            assoc_out = self.exec_cmd(f"wl -i {iface} assoclist")
            macs = re.findall(r'([0-9A-FA-F]{2}(?::[0-9A-FA-F]{2}){5})', assoc_out)
            for mac in macs:
                mac_upper = mac.upper()
                sta_out = self.exec_cmd(f"wl -i {iface} sta_info {mac_upper}")
                
                # Parse RSSI and rates
                rssi_match = re.search(r'smoothed rssi:\s*(-?\d+)', sta_out)
                tx_match = re.search(r'rate of last tx pkt:\s*(\d+)', sta_out)
                rx_match = re.search(r'rate of last rx pkt:\s*(\d+)', sta_out)
                idle_match = re.search(r'idle\s*(\d+)\s*seconds', sta_out)
                dur_match = re.search(r'in network\s*(\d+)\s*seconds', sta_out)

                rssi = int(rssi_match.group(1)) if rssi_match else -80
                tx_rate = int(tx_match.group(1)) // 1000 if tx_match else 0
                rx_rate = int(rx_match.group(1)) // 1000 if rx_match else 0
                idle_sec = int(idle_match.group(1)) if idle_match else 0
                dur_sec = int(dur_match.group(1)) if dur_match else 0

                dhcp_info = leases.get(mac_upper, {})

                clients[mac_upper] = {
                    "mac": mac_upper,
                    "ip": dhcp_info.get("ip", "Unknown"),
                    "hostname": dhcp_info.get("hostname", "Unknown"),
                    "band": band_label,
                    "interface": iface,
                    "rssi": rssi,
                    "tx_rate_mbps": tx_rate,
                    "rx_rate_mbps": rx_rate,
                    "idle_sec": idle_sec,
                    "duration_sec": dur_sec,
                    "type": "wifi",
                    "timestamp": time.time()
                }
        return clients

if __name__ == "__main__":
    collector = AsusRouterCollector()
    print("[+] Polling ASUS RT-AX86U Pro associated clients...")
    res = collector.get_associated_clients()
    print(json.dumps(res, indent=2))

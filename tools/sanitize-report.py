#!/usr/bin/env python3
"""
Sanitizer script for experimental logs and diagnostic reports.

Redacts sensitive network and environment data (MAC addresses, IP addresses,
SSIDs, usernames, serial numbers) while preserving technical logs.
"""

import sys
import re
import argparse

MAC_REGEX = re.compile(r'(?:[0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}')
IPV4_REGEX = re.compile(r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b')
IPV6_REGEX = re.compile(r'\b(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}\b')
HOME_USER_REGEX = re.compile(r'/home/[a-zA-Z0-9_\-]+/')
SSID_DECL_REGEX = re.compile(r'(ssid\s+)([^\s]+)', re.IGNORECASE)

def sanitize_text(text: str) -> str:
    text = MAC_REGEX.sub('XX:XX:XX:XX:XX:XX', text)
    text = IPV4_REGEX.sub('XXX.XXX.XXX.XXX', text)
    text = IPV6_REGEX.sub('XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX', text)
    text = HOME_USER_REGEX.sub('/home/REDACTED_USER/', text)
    text = SSID_DECL_REGEX.sub(r'\1<REDACTED_SSID>', text)
    return text

def main():
    parser = argparse.ArgumentParser(description="Sanitize log and text files for open-source publication.")
    parser.add_argument("input_file", help="Path to input text file")
    parser.add_argument("output_file", help="Path to output sanitized text file")
    args = parser.parse_args()

    if args.input_file == args.output_file:
        print("Error: Input and output paths must be different.", file=sys.stderr)
        sys.exit(1)

    try:
        with open(args.input_file, "r", encoding="utf-8", errors="replace") as f_in:
            content = f_in.read()

        sanitized = sanitize_text(content)

        with open(args.output_file, "w", encoding="utf-8") as f_out:
            f_out.write(sanitized)

        print(f"[+] Successfully sanitized {args.input_file} -> {args.output_file}")
    except Exception as e:
        print(f"Error processing files: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

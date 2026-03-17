#!/usr/bin/env python3
"""
Convert between .tosc (raw zlib) and .xml (plain text).

Usage:
    python3 tosc_convert.py decompress input.tosc output.xml
    python3 tosc_convert.py compress   input.xml  output.tosc

A .tosc file is raw zlib-compressed XML (magic bytes 78 9c).
It is NOT a zip file.
"""

import sys
import zlib


def decompress(src, dst):
    data = open(src, "rb").read()
    if data[:2] != b'\x78\x9c' and data[:2] != b'\x78\x01' and data[:2] != b'\x78\xda':
        print(f"WARNING: unexpected magic bytes {data[:2].hex()} — may not be a .tosc file")
    xml = zlib.decompress(data)
    open(dst, "wb").write(xml)
    print(f"Decompressed: {len(data):,} → {len(xml):,} bytes  →  {dst}")


def compress(src, dst):
    xml = open(src, "rb").read()
    data = zlib.compress(xml)
    open(dst, "wb").write(data)
    print(f"Compressed:   {len(xml):,} → {len(data):,} bytes  →  {dst}")
    # Verify roundtrip
    assert zlib.decompress(data) == xml, "Roundtrip check FAILED!"
    print("Roundtrip OK.")


if __name__ == "__main__":
    if len(sys.argv) != 4 or sys.argv[1] not in ("compress", "decompress"):
        print(__doc__)
        sys.exit(1)
    cmd, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
    if cmd == "decompress":
        decompress(src, dst)
    else:
        compress(src, dst)

#!/usr/bin/env python3
"""Generate the SW2SNES icon (256x256 PNG; the build converts it to sw2snes.jpg)."""
import struct, zlib, sys
from pathlib import Path

W = H = 256
px = [[(26, 29, 40)] * W for _ in range(H)]
OY = 0

def rect(x0, y0, x1, y1, c, r=0):
    y0 += OY; y1 += OY
    for y in range(max(0, y0), min(H, y1)):
        for x in range(max(0, x0), min(W, x1)):
            if r:
                cx = min(max(x, x0 + r), x1 - 1 - r); cy = min(max(y, y0 + r), y1 - 1 - r)
                if (x - cx) ** 2 + (y - cy) ** 2 > r * r: continue
            px[y][x] = c

def circle(cx, cy, r, c):
    rect(cx - r, cy - r, cx + r + 1, cy + r + 1, c, r)

# Artwork spans y 28 (title) to 206 (accent band), centred in 256.
OY = (256 - (206 - 28)) // 2 - 28
rect(18, 196, 238, 206, (228, 70, 59))
# SNES controller: light grey body with round ends
rect(16, 80, 240, 176, (200, 202, 210), 46)
# D-pad well and cross
circle(64, 128, 30, (178, 180, 190))
rect(40, 120, 88, 136, (30, 30, 34), 3)
rect(56, 104, 72, 152, (30, 30, 34), 3)
# Select / Start (slanted pills approximated as small bars)
rect(106, 132, 124, 139, (110, 112, 122), 3)
rect(132, 132, 150, 139, (110, 112, 122), 3)
# Button well and the four coloured buttons (X blue top, A red right, B yellow bottom, Y green left)
circle(192, 128, 34, (160, 150, 186))
circle(192, 106, 11, (52, 92, 196))
circle(214, 128, 11, (204, 44, 44))
circle(192, 150, 11, (232, 196, 46))
circle(170, 128, 11, (40, 150, 72))

font = {"N": ["10001", "11001", "10101", "10011", "10001"], "E": ["11111", "10000", "11110", "10000", "11111"],
        "S": ["01111", "10000", "01110", "00001", "11110"], "W": ["10001", "10001", "10101", "11011", "10001"],
        "2": ["01110", "10001", "00110", "01000", "11111"]}
def text(s, x, y, scale, c):
    for ch in s:
        g = font[ch]
        for gy, rowbits in enumerate(g):
            for gx, bit in enumerate(rowbits):
                if bit == "1": rect(x + gx * scale, y + gy * scale, x + (gx + 1) * scale, y + (gy + 1) * scale, c)
        x += (len(g[0]) + 1) * scale
text("SW2", 22, 28, 5, (154, 163, 181))
text("SNES", 118, 28, 5, (238, 241, 247))

raw = b"".join(b"\x00" + bytes(v for p in row for v in p) for row in px)
def chunk(t, d): return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
out = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parents[1] / "icon.png"
out.write_bytes(png)
print(out, len(png), "bytes")

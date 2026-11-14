# raw2png.py in.raw out.png : converts core_test's DUMP output to PNG
import sys, zlib, struct
d = open(sys.argv[1], 'rb').read()
nl = d.index(b'\n'); w, h = map(int, d[:nl].split()); px = d[nl + 1:]
raw = b''.join(b'\x00' + px[y * w * 4:(y + 1) * w * 4] for y in range(h))
def chunk(t, b): return struct.pack('>I', len(b)) + t + b + struct.pack('>I', zlib.crc32(t + b) & 0xffffffff)
open(sys.argv[2], 'wb').write(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)) + chunk(b'IDAT', zlib.compress(raw)) + chunk(b'IEND', b''))

#!/usr/bin/env python3
# code_copie_scr.py - endcoding/decoding copie_scr.sh (vice versa)
# Usage: 
#    python3 code_copie_scr.py input.xor output.sh
#    python3 code_copie_scr.py input.sh output.xor
#
# Credits:
#    https://github.com/megusta1337/Copie_scr_Decoder/

import sys

if len(sys.argv) != 3:
    print("Usage: {} <input.xor> <output.sh>".format(sys.argv[0]))
    sys.exit(2)

INPUT = sys.argv[1]
OUTPUT = sys.argv[2]

# initial seed from C code
seed = 0x001be3ac

def prng_rand():
    global seed
    r0 = seed & 0xFFFFFFFF
    # rotate right by 1 (32-bit)
    r1 = ((r0 >> 1) | ((r0 << 31) & 0xFFFFFFFF)) & 0xFFFFFFFF
    r3 = ( ((r1 >> 16) & 0xFF) + r1 ) & 0xFFFFFFFF
    r1_new = ( ((r3 >> 8) & 0xFF) << 16 ) & 0xFFFFFFFF
    r3 = (r3 - r1_new) & 0xFFFFFFFF
    seed = r3
    return r0

# advance once (as in C main)
prng_rand()

with open(INPUT, 'rb') as f_in, open(OUTPUT, 'wb') as f_out:
    while True:
        b = f_in.read(1)
        if not b:
            break
        k = prng_rand() & 0xFF
        outb = bytes([b[0] ^ k])
        f_out.write(outb)

print("Result is written to", OUTPUT)

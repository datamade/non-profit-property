import sys
import json

infile = sys.stdin.buffer
outfile = sys.stdout.buffer

for line in infile:
    if b'geometry' in line:
        if b'BLDGClass": "0"' in line:
            outfile.write(line)
    else:
        outfile.write(line)

outfile.flush()

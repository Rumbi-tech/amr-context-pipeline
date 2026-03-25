#!/usr/bin/env python3

import gzip
import os
import sys

def open_maybe_gzip(path, mode='rt'):
    if path.endswith('.gz'):
        return gzip.open(path, mode)
    return open(path, mode)

def main():
    if len(sys.argv) != 3:
        print("Usage: rename_fastq_headers.py <input.fastq.gz> <output.fastq.gz>")
        sys.exit(1)

    infile = sys.argv[1]
    outfile = sys.argv[2]
    prefix = os.path.basename(infile).replace('.fastq.gz', '').replace('.fq.gz', '').replace('.fastq', '').replace('.fq', '')

    with open_maybe_gzip(infile, 'rt') as fin, gzip.open(outfile, 'wt') as fout:
        line_num = 0
        for line in fin:
            line_num += 1
            mod = (line_num - 1) % 4

            if mod == 0:
                header = line.strip()
                if not header.startswith('@'):
                    raise ValueError(f"Invalid FASTQ header in {infile}: {header}")
                header_body = header[1:]
                fout.write(f"@{prefix}|{header_body}\n")
            elif mod == 2:
                plus = line.strip()
                fout.write("+\n")
            else:
                fout.write(line)

if __name__ == "__main__":
    main()

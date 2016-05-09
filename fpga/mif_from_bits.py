# -*- coding: utf-8 -*-
"""
From some game of life init file, generate mif

"""

import sys

HEADER = """WIDTH=20;
DEPTH=65536;

ADDRESS_RADIX=UNS;
DATA_RADIX=UNS;
CONTENT BEGIN
"""

FOOTER = """END;"""

def print_grid(grid):
    for line in grid:
        print ''.join(['.' if c == 0 else '%' for c in line])

def data_at(addr, grid):
    # For some bit grid
    # Assuming 64 word lines
    row_num = addr / 64
    start_index = (addr % 64) * 20
    if row_num >= len(grid) or start_index >= len(grid[0]):
        return 0
    else:
        bits = grid[row_num][start_index:start_index + 20]
        if len(bits) < 20:
            bits += [0] * (20 - len(bits))
        value = int(''.join([str(c) for c in bits]), 2)
        # print addr, row_num, start_index, value
        return value
        
def verify_schematic(mif_file):
    with open(mif_file, "r") as f:
        # Throw away the header
        for x in range(5):
            f.readline()
            
        grid = []
        for i in range(1024):
            grid.append([])
        rightmost_column = 0
        bottommost_row = 0
        for line in f:
            line = line.split(":")
            addr = int(line[0].strip())
            value = int((line[1].strip())[:-1])

            row = addr / 64
            bits = [int(d) for d in bin(value)[2:]]
            # Pad to 20 bits
            if len(bits) != 20:
                bits = ([0] * (20 - len(bits))) + bits
            grid[row] += bits
            
            if value != 0:
                if row > bottommost_row:
                    bottommost_row = row
                if (addr % 64) > rightmost_column:
                    rightmost_column = addr % 64

        # Trim grid to only the relevant region                    
        grid = grid[:bottommost_row + 1 ]
        right_index = rightmost_column * 20 + 20
        grid = [line[:right_index] for line in grid]

        print_grid(grid)

def main():
    if len(sys.argv) != 2:
        print "Usage: python mif_from_bits.py input_file"

    output_path = sys.argv[1] + ".mif"
    initial = []
    
    with open(sys.argv[1], "r") as bitmap:
        for line in bitmap:
            this_line = []
            for c in line.strip():
                this_line.append(int(c))
            initial.append(this_line)
    
    print_grid(initial)
    
    print "Rows:", len(initial)
    print "Cols:", len(initial[0])

    raw_input("Writing the above to "
        + sys.argv[1] + ".mif\n"
        + "Press Enter to continue or Ctrl+C to abort")
    
    with open(output_path, "w") as target:
        target.write(HEADER)
        for i in range(65536):
            to_write = data_at(i, initial)
            target.write("%d : %d;\n" % (i, to_write))
        target.write(FOOTER)
            
    verify_schematic(output_path)

    
if __name__ == "__main__":
    main()
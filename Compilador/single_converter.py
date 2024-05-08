#!/usr/bin/python3

import sys
from asm2bin import Converter

file = sys.argv[1]

def asm2bin(file):
    if file.endswith(".asm"):
            with open(file, 'r') as asm_file:
                print("daaale papa1!!")
                bin_lines = Converter.assembly(asm_file.readlines())
                print("SALIMOSS!!!")
                out_file = file.replace('asm', 'mem')
                print("daaale papa2!!")
            with open(out_file, 'w') as out_file:
                bin_lines = map(lambda x: x + '\n', bin_lines)
                out_file.writelines(bin_lines)
                print (file, 'converted to mem')
    print ("** Conversion finished **")

if __name__ == "__main__":
    asm2bin(file)
#!/usr/bin/env python

import os
import shutil

OUTPUT_FILE = "mem_init.mif"
mif_files = []

print "MIF Files:"
for f in os.listdir("."):
    if f.endswith(".mif") and not f == OUTPUT_FILE:
        mif_files.append(f)
        print len(mif_files), ") ", f[:-4]

choice = raw_input("Enter # of file to program:")
choice = int(choice) - 1

chosen_file = mif_files[choice]
os.remove(OUTPUT_FILE)
shutil.copyfile(chosen_file, OUTPUT_FILE)

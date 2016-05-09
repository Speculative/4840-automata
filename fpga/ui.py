#!/usr/bin/env python
import os

def main():
  print "Welcome to our lame tui\n"

  sof_files = []

  for f in os.listdir("./output_files/"):
      if f.endswith(".sof"):
          sof_files.append(f)
          print len(sof_files), ")",  f[:-4]

  choice = raw_input("# of sof file to program: ")
  choice = int(choice) - 1
  fname = sof_files[choice]
  callname = "quartus_pgm --mode=JTAG -o \'P;./output_files/%s\'"%fname
  
  print callname
  stream = os.popen(callname)
  stream.close()

main()

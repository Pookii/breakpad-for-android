#! /usr/bin/env python  
  
  
import os  
import sys  
  
if len(sys.argv) < 3:  
    print("please check your parameter")  
    exit(-1)  
  
soFile = sys.argv[1]  
dmpFile = sys.argv[2]  
  
print (soFile),  
print (dmpFile)  
  
symFile = soFile + ".sym"  
  
#dumple sym file  
os.system("dump_syms " + soFile  + " > " + symFile)  
  
#get directory information  
#ret = os.popen("head -n1 " + symFile).read()  
#arry = ret.strip().split(" ")  
#dirName = arry[3]  
soFileName = soFile.split("/")[-1]
symPath = "./symbols/" + soFileName.split(".")[0] + "/"  
  
#create directory  
os.system("mkdir -p " + symPath)  
os.system("mv " + symFile + " " + symPath)  

#minidump to log file  
logName = dmpFile.split(".")[0] + "_crashlog"
os.system("minidump_stackwalk " + dmpFile + " ./symbols > " + logName)
os.system("mv " + logName + " " + symPath)

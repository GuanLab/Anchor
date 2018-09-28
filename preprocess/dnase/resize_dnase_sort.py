import numpy as np
import cv2
import os
import sys

#path1='/state4/hyangl/TF_model/TF_revision/data/feature/dnase_sort/'
#path2='/state4/hyangl/TF_model/TF_revision/data/feature/dnase_sort_resize/'
path1 = sys.argv[1] # input
path2 = sys.argv[2] # output

os.system('mkdir -p ' + path2)

all_files=os.listdir(path1)
for the_file in all_files:
    print(the_file)
    x=np.loadtxt(path1 + the_file)
    y=cv2.resize(x,(1,3036304),interpolation=cv2.INTER_AREA)
    y=np.rint(y)
    np.savetxt(path2 + the_file,y,fmt='%d')

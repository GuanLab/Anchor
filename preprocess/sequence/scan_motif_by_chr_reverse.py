import os
import numpy as np
import sys
import re

the_chr=sys.argv[1]
the_tf=sys.argv[2]
dir_motif=sys.argv[3]
dir_seq=sys.argv[4]
dir_output=sys.argv[5]

os.system('mkdir -p ' + dir_output)

tf_matrix=np.loadtxt(dir_motif + the_tf,delimiter='\t',dtype='float32')
tf_matrix=np.flip(tf_matrix,0) # Here reverse motif
tf_length=tf_matrix.shape[0]

## read in one chromosome and scan;
FILE_name=dir_seq + the_chr
FILE=open(FILE_name,'r');
line = FILE.readline()
line=line.rstrip()
line=line.replace("a","A")
line=line.replace("c","C")
line=line.replace("g","G")
line=line.replace("t","T")
line=line.replace("N","A")
line=line.replace("n","A")

aline=line
aline=aline.replace("A", "0") # Here not reverse sequence, but complement A->T
aline=aline.replace("C", "0")
aline=aline.replace("G", "0")
aline=aline.replace("T", "1")
aline=np.asarray(list(aline),dtype='float32')

cline=line
cline=cline.replace("A", "0")
cline=cline.replace("C", "0")
cline=cline.replace("G", "1")
cline=cline.replace("T", "0")
cline=np.asarray(list(cline),dtype='float32')

gline=line
gline=gline.replace("A", "0")
gline=gline.replace("C", "1")
gline=gline.replace("G", "0")
gline=gline.replace("T", "0")
gline=np.asarray(list(gline),dtype='float32')

tline=line
tline=tline.replace("A", "1")
tline=tline.replace("C", "0")
tline=tline.replace("G", "0")
tline=tline.replace("T", "0")
tline=np.asarray(list(tline),dtype='float32')

chrom_matrix=np.vstack((aline, cline, gline, tline))
print(chrom_matrix.shape)

length=chrom_matrix.shape[1]
i=0;
max_length=length-20


out_file=open(dir_output + the_tf + '_' + the_chr,'w');

while (i<max_length):
	sub=chrom_matrix[:,i:(i+tf_length)]
	val=np.trace(np.dot(tf_matrix,sub))
	out_file.write('%.5f\n' % val)
	i=i+1

out_file.close()



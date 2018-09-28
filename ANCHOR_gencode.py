"""
Script for predicting genome-scale TF binding sites.
Use `ANCHOR_gencode.py -h` to see descriptions of the arguments.
"""

import argparse
import os

def get_args():
    parser = argparse.ArgumentParser(description="ANCHOR_gencode - preprocessing the gencode data",
        epilog='\n'.join(__doc__.strip().split('\n')[1:]).strip(),
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-o', '--output', default='./data/top_20', type=str,
        help='The output file (default: ./data/top_20)')
    args = parser.parse_args()
    return args

def main():
    args = get_args()

    # step15: for each genomic coordinate, calculate the 20 closest distances to a gene; 8 hours
    # 1.the gencode (e.g. gencode.v19.annotation.gtf) is required
    # (downloaded from: https://www.gencodegenes.org/releases/19.html)
    # 2.the reference file the genomic coordinates excluding blacklisted regions is needed
    # it returns a file 'top_20' - the top 20 closes distances to a gene of each coordinate under consideration
    cmd = 'perl ./preprocess/gencode/create_gene_distance_top20_uniq.pl ' + \
        args.output + ' ' + \
        './data/ref/gencode.v19.annotation.gtf ' + \
        './data/ref/test_regions.blacklistfiltered.bed' 
    os.system(cmd)   

if __name__ == '__main__':
    main()


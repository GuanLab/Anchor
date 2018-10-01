"""
Script for predicting genome-scale TF binding sites.
Use `ANCHOR.py -h` to see descriptions of the arguments.
"""

import argparse
import os

def get_args():
    parser = argparse.ArgumentParser(description="ANCHOR - predicting genome-scale TF binding sites.",
        epilog='\n'.join(__doc__.strip().split('\n')[1:]).strip(),
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-tf', '--tf', default='TAF1', nargs='+',type=str,
        help='The Trascription Factor to predict (e.g. TAF1)')
    parser.add_argument('-cell', '--cell_line', default='H1-hESC', type=str,
        help='The cell line name of the DNase-seq data')
    args = parser.parse_args()
    return args

def main():
    args = get_args()

    ## 1. Prepare DNase-seq feature
    os.system('python ANCHOR_dnase.py -cell ' + args.cell_line)

    ## 2. Prepare DNA sequence and TF motif features
    os.system('python ANCHOR_sequence.py -tf ' + args.tf)

    ## 3. Prepare gene location features
    os.system('python ANCHOR_gencode.py')

    ## 4. Make predictions
    os.system('python ANCHOR_prediction.py -tf '  + args.tf + \
        ' -cell ' + args.cell_line)


if __name__ == '__main__':
    main()


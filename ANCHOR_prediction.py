"""
Script for predicting drug synergy.
Use `ANCHOR_prediction.py -h` to see descriptions of the arguments.
"""

import argparse
import os

def get_args():
    parser = argparse.ArgumentParser(description="ANCHOR - prediction",
        epilog='\n'.join(__doc__.strip().split('\n')[1:]).strip(),
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-tf', '--tf', default='TAF1', type=str,
        help='The TF name (e.g. TAF1)')
    parser.add_argument('-cell', '--cell_line', default='H1-hESC', type=str,
        help='The cell line name (e.g. H1-hESC)')
    parser.add_argument('-i', '--input_dir', default='./data/', type=str,
        help='Directory of the features (default: ./data/)')
    parser.add_argument('-m', '--mode', default='fast', type=str,
        help='The prediction mode (fast: only use single TF sequence motif features; full: use all 13 TF sequence motif features (warning: need more prediction time!)')
    args = parser.parse_args()
    return args

def main():
    args = get_args()

    ## F: single-tf sequence motif feature; without delta-frequency feature
    cmd = 'perl ./prediction/anchor/F/prediction_F.pl ' + \
        args.tf + ' ' + \
        args.cell_line + ' ' + \
        args.input_dir
    os.system(cmd)   
    os.system('perl ./prediction/anchor/F/concatenate_prediction.pl')   
    
    ## G: single-tf sequence motif feature; with delta-frequency feature
    cmd = 'perl ./prediction/anchor/G/prediction_G.pl ' + \
        args.tf + ' ' + \
        args.cell_line + ' ' + \
        args.input_dir
    os.system(cmd)   
    os.system('perl ./prediction/anchor/G/concatenate_prediction.pl')   

    if args.mode == 'full':
        print("Full ANCHOR prediction mode (need more time):")

        ## H: multi-tf sequence motif feature; without delta-frequency feature
        print("Run model H")
        cmd = 'perl ./prediction/anchor/H/prediction_H.pl ' + \
            args.tf + ' ' + \
            args.cell_line + ' ' + \
            args.input_dir
        os.system(cmd)   
        os.system('perl ./prediction/anchor/H/concatenate_prediction.pl')   
        
        ## I: multi-tf sequence motif feature; with delta-frequency feature
        print("Run model I")
        cmd = 'perl ./prediction/anchor/I/prediction_I.pl ' + \
            args.tf + ' ' + \
            args.cell_line + ' ' + \
            args.input_dir
        os.system(cmd)   
        os.system('perl ./prediction/anchor/I/concatenate_prediction.pl')   

        print("Ensemble")
        os.system('perl ./prediction/anchor/ensemble_full.pl')

    else:
        print("Ensemble")
        os.system('perl ./prediction/anchor/ensemble_single_tf.pl')


if __name__ == '__main__':
    main()


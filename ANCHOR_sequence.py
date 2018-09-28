"""
Script for predicting genome-scale TF binding sites.
Use `ANCHOR_sequence.py -h` to see descriptions of the arguments.
"""

import argparse
import os

def get_args():
    parser = argparse.ArgumentParser(description="ANCHOR_sequence - prepare DNA sequence based features",
        epilog='\n'.join(__doc__.strip().split('\n')[1:]).strip(),
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-tf', '--tf', default='TAF1', nargs='+',type=str,
        help='TFs under consideration (e.g. TAF1 MAX')
    parser.add_argument('-motif', '--motif_dir', default='./data/motif/', type=str,
        help='Directory of the sequence motifs (e.g.: ./data/motif/TAF1)')
    parser.add_argument('-seq', '--seq_dir', default='./data/hg_genome/', type=str,
        help='Directory of the human genome sequences (e.g.: ./data/hg_genome/chr1)')
    parser.add_argument('-o', '--output', default='./data/', type=str,
        help='Directory of the output files (default: ./data/)')
    args = parser.parse_args()
    return args

def main():
    args = get_args()

    all_chr=['chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10', \
        'chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19','chr20', \
        'chr21','chr22','chrX']

    # step10.1: scan TF-motif PWMs against DNA sequences to obtain score for each position; 60-120 minutes per TF per chromosome (23 chrs!)
    for the_tf in args.tf:
        print(the_tf)
        for the_chr in all_chr:
            cmd = 'python ./preprocess/sequence/scan_motif_by_chr.py ' + \
                the_chr + ' ' + \
                the_tf + ' ' + \
                args.motif_dir + ' ' + \
                args.seq_dir + ' ' + \
                args.output + 'seq_forward/'
            os.system(cmd)   
 
    # step10.2: select top 3 scores over forward 200bp sequences; 150 minutes per cell line
    for the_tf in args.tf:
        cmd = 'perl ./preprocess/sequence/create_motif_top3_ru_forward.pl ' + \
            the_tf + ' ' + \
            args.output + 'seq_forward/ ' + \
            args.output + 'seq_forward_top3/'
        os.system(cmd)

    # step11.1: scan TF-motif PWMs against the revese-complement DNA sequences; 60-120 minutes per TF per chr
    for the_tf in args.tf:
        print(the_tf)
        for the_chr in all_chr:
            cmd = 'python ./preprocess/sequence/scan_motif_by_chr_reverse.py ' + \
                the_chr + ' ' + \
                the_tf + ' ' + \
                args.motif_dir + ' ' + \
                args.seq_dir + ' ' + \
                args.output + 'seq_reverse/'
            os.system(cmd)   

    # step11.2: select top 3 scores over reverse 200bp sequences; 150 minutes per cell line
    for the_tf in args.tf:
        cmd = 'perl ./preprocess/sequence/create_motif_top3_ru_forward.pl ' + \
            the_tf + ' ' + \
            args.output + 'seq_reverse/ ' + \
            args.output + 'seq_reverse_top3/'
        os.system(cmd)

    # step12: select the top 4 out of the top 6 = 3forward + 3reverse scores; 10 minutes per TF
    for the_tf in args.tf:
        cmd = 'perl ./preprocess/sequence/find_max_forward_reverse_top_4.pl ' + \
            args.output + 'seq_forward_top3/ ' + \
            args.output + 'seq_reverse_top3/ ' + \
            args.output + 'seq_top4/'
        os.system(cmd)

    # step13: rank the features to 0-1; 10 minutes per TF
    for the_tf in args.tf:
        cmd = 'perl ./preprocess/sequence/create_top4_rank_ru.pl ' + \
            args.output + 'seq_top4/ ' + \
            args.output + 'seq_top4_rank/'
        os.system(cmd)

    # step14: generate the 32 neighboring ranked features; 80 minutes per TF
    for the_tf in args.tf:
        cmd = 'perl ./preprocess/sequence/create_largespace_tomax_top4_rank.pl ' + \
            args.output + 'seq_top4_rank/ ' + \
            args.output + 'seq_top4_rank_largespace/'
        os.system(cmd)


if __name__ == '__main__':
    main()


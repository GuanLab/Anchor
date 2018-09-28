"""
Script for predicting drug synergy.
Use `ANCHOR_dnase.py -h` to see descriptions of the arguments.
"""

import argparse
import os

def get_args():
    parser = argparse.ArgumentParser(description="ANCHOR_dnase - preprocessing DNase-seq data",
        epilog='\n'.join(__doc__.strip().split('\n')[1:]).strip(),
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-i1', '--input1', default='./data/dnase_aln/', type=str,
        help='Directory of the input DNase-seq read alignment BAM files (default: ./data/dnase_aln/)')
    parser.add_argument('-i2', '--input2', default='./data/dnase_fold_coverage/', type=str,
        help='Directory of the input fold-enrichement signal coverage BigWig files (default: ./data/dnase_fold_coverage/)')
    parser.add_argument('-cell', '--cell_line', default='H1-hESC', type=str,
        help='The cell line name of the DNase-seq data')
    parser.add_argument('-o', '--output', default='./data/', type=str,
        help='Directory of the output files (default: ./data/)')
    args = parser.parse_args()
    return args

def main():
    args = get_args()

    # step1. convert bam to txt file; require samtools; # 16 minutes (e.g. for H1-hESC with 2 replicates)
    cmd = 'perl ./preprocess/dnase/transform_bam_to_track.pl ' + \
        args.input1 + ' ' + \
        args.output + 'dnase_track/'
    os.system(cmd)   
 
    # step2: sum raw reads from all tech/bio replicates and separate them into 23 chromsomes; 15-20 hours
    cmd = 'perl ./preprocess/dnase/create_DNase_avg_track_by_chr.pl ' + \
        args.cell_line + ' ' + \
        args.output + 'dnase_track/ ' + \
        args.output + 'dnase_track_avg/'
    os.system(cmd)

    # step3: subsample 1/1000 and rank reads of all chrs for the multi-cell quantile normalization; 12-15 minutes perl cell line
    cmd = 'perl ./preprocess/dnase/approximate_max_min_median.pl ' + \
        args.cell_line + ' ' + \
        args.output + 'dnase_track_avg/ ' + \
        args.output + 'dnase_sort/'
    os.system(cmd)

    # step4: resize to the same length as the reference; require cv2.resize; 1-2 minutes perl cell line
    cmd = 'python ./preprocess/dnase/resize_dnase_sort.py ' + \
        args.output + 'dnase_sort/ ' + \
        args.output + 'dnase_sort_resize/'
    os.system(cmd)   

    # step5: quantile normalization to the reference cell line; 100-150 minutes perl cell line
    # the outputs of step2 and step4 are needed; a reference cell line from step4 is needed
    # by default, we used liver.txt with 3036304 lines as the reference cell line
    cmd = 'perl ./preprocess/dnase/normalize_by_anchor.pl ' + \
        args.cell_line + ' ' + \
        args.output + 'dnase_track_avg/ ' + \
        args.output + 'dnase_sort_resize/ ' + \
        args.output + 'dnase_track_avg_anchor/ ' + \
        './data/ref/liver.txt'
    os.system(cmd)   

    # step6.1: generate the mean, max, min features; 200 minutes perl cell line
    # a reference file the genomic coordinates excluding blacklisted regions is needed; this file looks like this:
    # chr1  600 800
    # chr1  650 850
    # chr1  700 900
    # the blacklist can downloaded from here: https://sites.google.com/site/anshulkundaje/projects/blacklists
    cmd = 'perl ./preprocess/dnase/create_DNase_mmm.pl ' + \
        args.cell_line + ' ' + \
        args.output + 'dnase_track_avg_anchor/ ' + \
        args.output + 'anchor_bam_dnase/ ' + \
        args.output + 'anchor_bam_dnase_max_min/ ' + \
        './data/ref/test_regions.blacklistfiltered.bed'
    os.system(cmd)   

    # step6.2: generate the delta- mean feature; 40 minutes for the DNase-seq data of 13 cell lines
    # prepare the anchor_bam_dnase from multiple cell line first - the step caculate the differences across cell lines
    cmd = 'perl ./preprocess/dnase/create_DNase_diff.pl ' + \
        args.output + 'anchor_bam_dnase/ ' + \
        args.output + 'anchor_bam_dnase_diff/'
    os.system(cmd)   

    # step6.3: generate the delta- max, min features; 100 minutes for the DNase-seq data of 13 cell lines
    # prepare the anchor_bam_dnase_max_min from multiple cell line first - the step caculate the differences across cell lines
    cmd = 'perl ./preprocess/dnase/create_DNase_max_min_diff.pl ' + \
        args.output + 'anchor_bam_dnase_max_min/ ' + \
        args.output + 'anchor_bam_dnase_max_min_diff/'
    os.system(cmd)   

    # step6.4: generate the 15 neighboring mean features; 30 minutes per cell line
    cmd = 'perl ./preprocess/dnase/create_DNase_largespace.pl ' + \
        args.output + 'anchor_bam_dnase/ ' + \
        args.output + 'anchor_bam_dnase_largespace/'
    os.system(cmd)   

    # step6.5: generate the 30 neighboring max and min features; 60 minutes per cell line
    cmd = 'perl ./preprocess/dnase/create_DNase_max_min_largespace.pl ' + \
        args.output + 'anchor_bam_dnase_max_min/ ' + \
        args.output + 'anchor_bam_dnase_max_min_largespace/'
    os.system(cmd)   

    # step6.6: generate the 15 neighboring delta-mean features; 30 minutes per cell line
    cmd = 'perl ./preprocess/dnase/create_DNase_largespace.pl ' + \
        args.output + 'anchor_bam_dnase_diff/ ' + \
        args.output + 'anchor_bam_dnase_diff_largespace/'
    os.system(cmd)   

    # step6.7: generate the 30 neighboring delta-max and delta-min features; 60 minutes per cell line
    cmd = 'perl ./preprocess/dnase/create_DNase_max_min_largespace.pl ' + \
        args.output + 'anchor_bam_dnase_max_min_diff/ ' + \
        args.output + 'anchor_bam_dnase_max_min_diff_largespace/'
    os.system(cmd)   

    ## here fold-enrichement frequency feature ##

    # step7: convert fold-enrichment bigWig to txt; 2 minutes per cell line
    cmd = 'perl ./preprocess/dnase/transform_bigwig_to_txt.pl ' + \
        args.input2 + ' ' + \
        args.output + 'dnase_fold_coverage_big/'
    os.system(cmd)   

    # step8: count the number of signal occurance and ignore values to generate frequency features; 60 minutes per cell line
    # the reference file of the genomic coordinates excluding blacklisted regions is needed
    # the blacklist can downloaded from here: https://sites.google.com/site/anshulkundaje/projects/blacklists
    cmd = 'perl ./preprocess/dnase/produce_frequency.pl ' + \
        args.cell_line + ' ' + \
        args.output + 'dnase_fold_coverage_big/ ' + \
        args.output + 'frequency/ ' + \
        './data/ref/test_regions.blacklistfiltered.bed'
    os.system(cmd)   

    # step9.1: generate the frequency feature by normalizing the counting number by ranking; 2 minutes per cell line
    cmd = 'perl ./preprocess/dnase/produce_frequency_rank.pl ' + \
        args.output + 'frequency/ ' + \
        args.output + 'frequency_rank/'
    os.system(cmd)   

    # step9.2: generate the delta-frequency feature; 50 minutes for the DNase-seq data of 13 cell lines
    cmd = 'perl ./preprocess/dnase/create_frequency_diff.pl ' + \
        args.output + 'frequency_rank/ ' + \
        args.output + 'frequency_rank_diff/'
    os.system(cmd)   

    # step9.3: generate the 15 neighboring frequency features; 50 minutes per cell line
    cmd = 'perl ./preprocess/dnase/create_frequency_largespace.pl ' + \
        args.output + 'frequency_rank/ ' + \
        args.output + 'frequency_rank_largespace/'
    os.system(cmd)   

    # step9.4: generate the 15 neighboring delta- frequency features; 50 minutes per cell line
    cmd = 'perl ./preprocess/dnase/create_frequency_largespace.pl ' + \
        args.output + 'frequency_rank_diff/ ' + \
        args.output + 'frequency_rank_diff_largespace/'
    os.system(cmd)   


if __name__ == '__main__':
    main()


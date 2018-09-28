## Anchor: Trans-cell Line Prediction of Transcription Factor Binding Sites

This is the reimplementation of Yuanfang's winning algorithm in the ENCODE-DREAM *in vivo* Transcription Factor Binding Site Prediction Challenge

background: [ENCODE-DREAM](https://www.synapse.org/#!Synapse:syn6131484)

see also: [Yuanfang Guan's 1st Place Solution](https://www.synapse.org/#!Synapse:syn7104742/wiki/407367) and [Original Code](https://www.synapse.org/#!Synapse:syn7104742/files/)

Please contact (gyuanfan@umich.edu or hyangl@umich.edu) if you have any questions or suggestions.

---

## Installation
Git clone a copy of ANCHOR:

```
git clone https://github.com/GuanLab/ANCHOR.git
```
## Required dependencies
* [perl](https://www.perl.org/) (5.10.1)
* [python](https://www.python.org) (3.6.5)
* [numpy](http://www.numpy.org/) (1.13.3) It comes pre-packaged in Anaconda.
* [opencv](https://pypi.org/project/opencv-python/) (3.4.2)
* [samtools](http://www.htslib.org/) (1.1)
* [bigWigToBedGraph](https://anaconda.org/bioconda/ucsc-bigwigtobedgraph)
* [xgboost](https://github.com/dmlc/xgboost/blob/master/demo/binary_classification/README.md)

## Required input files (and the corresponding directories to put them)
**Genomic coordinates**

* ./data/ref/ genomic coordinates under consideration (e.g. [test_regions.blacklistfiltered.bed](https://www.synapse.org/#!Synapse:syn6184308))

**DNase-seq data** (e.g. [H1-hESC](https://www.encodeproject.org/experiments/ENCSR000EMU/))

* ./data/dnase_aln/ read alignemnt BAM file (one or multiple replicates)
* ./data/dnase_fold_coverage/ fold-enrichement signal coverage tracks Bigwig file

**DNA sequence and motif**

* ./data/hg_genome/ human genome sequence 
* ./data/motif/ TF motifs (e.g. [motif](http://hocomoco11.autosome.ru/downloads_v11)) 

**Gencode**

* ./data/ref/ [gencode.v19.annotation.gtf](https://www.gencodegenes.org/releases/19.html)

## Prepare features and make predictions

### 1. Prepare DNase-seq features

In this section, we preprocess DNase-seq data to perform quantile normalization across multiple cell lines and generate multiple features. For example,
```
python ANCHOR_dnase.py -cell H1-hESC
```
You can also modify the input  and output directory:
```
python ANCHOR_dnase.py -i1 DIR_OF_BAM -i2 DIR_OF_BIGWIG -cell H1-hESC -o DIR_OF_FEATURES
```
For more information, run (python ANCHOR_dnase.py -h):
```
ANCHOR_dnase - preprocessing DNase-seq data

optional arguments:
  -h, --help            show this help message and exit
  -i1 INPUT1, --input1 INPUT1
                        Directory of the input DNase-seq read alignment BAM files (default: ./data/dnase_aln/)
  -i2 INPUT2, --input2 INPUT2
                        Directory of the input fold-enrichement signal coverage BigWig files (default: ./data/dnase_fold_coverage/)
  -cell CELL_LINE, --cell_line CELL_LINE
                        The cell line name of the DNase-seq data
  -o OUTPUT, --output OUTPUT
                        Directory of the output files (default: ./data/)
```
### 2. Prepare DNA sequence and TF motif features

In this section, we scan TF motifs across human DNA geonome sequence to generate multiple features. For example,
```
python ANCHOR_sequence.py -tf TAF1
```
You can also modify the input  and output directory:
```
python ANCHOR_sequence.py -tf TAF1 -motif DIR_OF_MOTIF -seq DIR_OF_SEQUENCE -o DIR_OF_FEATURES
```
For more information, run (python ANCHOR_sequence.py -h):
```
ANCHOR_sequence - prepare DNA sequence based features

optional arguments:
  -h, --help            show this help message and exit
  -tf TF [TF ...], --tf TF [TF ...]
                        TFs under consideration (e.g. TAF1 MAX
  -motif MOTIF_DIR, --motif_dir MOTIF_DIR
                        Directory of the sequence motifs (e.g.: ./data/motif/TAF1)
  -seq SEQ_DIR, --seq_dir SEQ_DIR
                        Directory of the human genome sequences (e.g.: ./data/hg_genome/chr1)
  -o OUTPUT, --output OUTPUT
                        Directory of the output files (default: ./data/)
```

### 3. Prepare gene location features
In this section, we calculate the top 20 closest distances to a gene for each genomic coordinates (e.g. chr1 600 800). For example,
```
python ANCHOR_gencode.py
```
You can also modify the output file:
```
python ANCHOR_gencode.py -o DIR_OF_FEATURES
```
For more information, run (python ANCHOR_gencode.py -h):
```
ANCHOR_gencode - preprocessing the gencode data

optional arguments:
  -h, --help            show this help message and exit
  -o OUTPUT, --output OUTPUT
                        The output file (default: ./data/top_20)
```

### 4. Make predictions

In this section, we make predictions using all the features generated in sections 1-3. First, unzip the pre-trained xgboost models:
```
cd model/anchor/
unzip F.zip
unzip G.zip
unzip H.zip
unzip I.zip
cd ../../
```
Then you can run ANCHOR predictions by:
```
python ANCHOR_prediction.py -tf TAF1 -cell H1-hESC
```
There are two modes (about the sequence feature): 

(1) in the "fast" mode, only query TF's sequence features are used 

(2) in the "full" mode, multiple TF's sequence features are used 

The "full" mode has better performance but requires much more time. You can active full mode by: 
```
python ANCHOR_prediction.py -tf TAF1 -cell H1-hESC -m full
```
For more information, run (python ANCHOR_prediction.py -h):
```
ANCHOR - prediction

optional arguments:
  -h, --help            show this help message and exit
  -tf TF, --tf TF       The TF name (e.g. TAF1)
  -cell CELL_LINE, --cell_line CELL_LINE
                        The cell line name (e.g. H1-hESC)
  -i INPUT_DIR, --input_dir INPUT_DIR
                        Directory of the features (default: ./data/)
  -m MODE, --mode MODE  The prediction mode (fast: only use single TF sequence motif features; full: use all 13 TF sequence motif features (warning: need more prediction time!)
```
The final predictions are saved here:
```
./prediction/anchor/final/
```
---
---
## Preprocessing Details
ANCHOR preprocessing has many steps and requires a lot of time and space, since the original input data themselves are very large.

For experienced users, the code of each step is available and you may run them individually without the ANCHOR_XXX.py interface.

The description and runtime of each step is listed below:

### section1: the DNase-seq features

**step1**. convert bam to txt file; require samtools; # 15-30 minutes perl cell line
```
perl ./preprocess/dnase/transform_bam_to_track.pl ./data/dnase_aln/ ./data/dnase_track/  
```

**step2**: sum raw reads from all tech/bio replicates and separate them into 23 chromsomes; 15-20 hours perl cell line
```
perl ccreate_DNase_avg_track_by_chr.pl H1-hESC ./data/dnase_track/ ./data/dnase_track_avg/
```

**step3**: subsample 1/1000 and rank reads of all chrs for the multi-cell quantile normalization; 30-60 minutes perl cell line
```
perl ./preprocess/dnase/approximate_max_min_median.pl H1-hESC ./data/dnase_track_avg/ ./data/dnase_sort/
```

**step4**: resize to the same length as the reference; require cv2.resize; 1-2 minutes perl cell line
```
python ./preprocess/dnase/resize_dnase_sort.py ./data/dnase_sort/ ./data/dnase_sort_resize/
```

**step5**: quantile normalization to the reference cell line; 100-150 minutes perl cell line

the outputs of step2 and step4 are needed; a reference cell line from step4 is needed; by default, we used liver.txt with 3036304 lines as the reference cell line
```
perl ./preprocess/dnase/normalize_by_anchor.pl H1-hESC ./data/dnase_track_avg/ ./data/dnase_sort_resize/ ./data/dnase_track_avg_anchor/ ./data/ref/liver.txt
```

**step6.1**: generate the mean, max, min features; 150 minutes perl cell line

a reference file the genomic coordinates excluding blacklisted regions is needed; this file looks like this:
```
chr1  600 800
chr1  650 850
chr1  700 900
```
the blacklist can downloaded from here: https://sites.google.com/site/anshulkundaje/projects/blacklists
```
perl ./preprocess/dnase/create_DNase_mmm.pl H1-hESC ./data/dnase_track_avg_anchor/ ./data/anchor_bam_dnase/ ./data/anchor_bam_dnase_max_min/ ./data/ref/test_regions.blacklistfiltered.bed
```

**step6.2**: generate the delta- mean feature; 40 minutes for the DNase-seq data of 13 cell lines

prepare the anchor_bam_dnase from multiple cell line first - the step caculate the differences across cell lines
```
perl ./preprocess/dnase/create_DNase_diff.pl ./data/anchor_bam_dnase/ ./data/anchor_bam_dnase_diff/
```

**step6.3**: generate the delta- max, min features; 100 minutes for the DNase-seq data of 13 cell lines

prepare the anchor_bam_dnase_max_min from multiple cell line first - the step caculate the differences across cell lines
```
perl ./preprocess/dnase/create_DNase_max_min_diff.pl ./data/anchor_bam_dnase_max_min/ ./data/anchor_bam_dnase_max_min_diff/
```

**step6.4**: generate the 15 neighboring mean features; 30 minutes per cell line
```
perl ./preprocess/dnase/create_DNase_largespace.pl ./data/anchor_bam_dnase/ ./data/anchor_bam_dnase_largespace/ 
```

**step6.5**: generate the 30 neighboring max and min features; 60 minutes per cell line
```
perl ./preprocess/dnase/create_DNase_max_min_largespace.pl ./data/anchor_bam_dnase_max_min/ ./data/anchor_bam_dnase_max_min_largespace/
```

**step6.6**: generate the 15 neighboring delta-mean features; 30 minutes per cell line
```
perl ./preprocess/dnase/create_DNase_largespace.pl ./data/anchor_bam_dnase_diff/ ./data/anchor_bam_dnase_diff_largespace/
```

**step6.7**: generate the 30 neighboring delta-max and delta-min features; 60 minutes per cell line
```
perl ./preprocess/dnase/create_DNase_max_min_largespace.pl ./data/anchor_bam_dnase_max_min_diff/ ./data/anchor_bam_dnase_max_min_diff_largespace/
```

from here fold-enrichement frequency feature :watermelon:

**step7**: convert fold-enrichment bigWig to txt; 2 minutes per cell line
```
perl ./preprocess/dnase/transform_bigwig_to_txt.pl ./data/dnase_fold_coverage/ ./data/dnase_fold_coverage_big/
```

**step8**: count the number of signal occurance and ignore values to generate frequency features # 60 minutes per cell line

the reference file of the genomic coordinates excluding blacklisted regions is needed
```
perl ./preprocess/dnase/produce_frequency.pl H1-hESC ./data/dnase_fold_coverage_big/ ./data/frequency/ ./data/ref/test_regions.blacklistfiltered.bed
```
 
**step9.1**: generate the frequency feature by normalizing the counting number by ranking # 2 minutes per cell line
```
perl ./preprocess/dnase/produce_frequency_rank.pl ./data/frequency/ ./data/frequency_rank/
```

**step9.2**: generate the delta-frequency feature; 50 minutes for the DNase-seq data of 13 cell lines
```
perl ./preprocess/dnase/create_frequency_diff.pl ./data/frequency_rank/ ./data/frequency_rank_diff/
```

**step9.3**: generate the 15 neighboring frequency features; 50 minutes per cell line
```
perl ./preprocess/dnase/create_frequency_largespace.pl ./data/frequency_rank/ ./data/frequency_rank_largespace/
```

**step9.4**: generate the 15 neighboring delta- frequency features; 50 minutes per cell line
```
perl ./preprocess/dnase/create_frequency_largespace.pl ./data/frequency_rank_diff/ ./data/frequency_rank_diff_largespace/
```

### section2: sequence motif feature

**step10.1**: scan TF-motif PWMs against DNA sequences to obtain score for each position; 60-120 minutes per TF per chromosome (23 chrs!)
```
python ./preprocess/sequence/scan_motif_by_chr.py chr13 TAF1 ./data/motif/ ./data/hg_genome/ ./data/seq_forward/
```

**step10.2**: select top 3 scores over forward 200bp sequences; 150 minutes per TF
```
perl ./preprocess/sequence/create_motif_top3_ru_forward.pl TAF1 ./data/seq_forward/ ./data/seq_forward_top3/ ./data/ref/test_regions.blacklistfiltered.bed
```

**step11.1**: scan TF-motif PWMs against reverse-complement DNA sequences to obtain score for each position; 60-120 minutes per TF per chromosome (23 chrs!)
```
python ./preprocess/sequence/scan_motif_by_chr_reverse.py chr13 TAF1 ./data/motif/ ./data/hg_genome/ ./data/seq_reverse/
```

**step11.2**: select top 3 scores over reverse 200bp sequences; 150 minutes per TF
```
perl ./preprocess/sequence/create_motif_top3_ru_forward.pl TAF1 ./data/seq_reverse/ ./data/seq_reverse_top3/ ./data/ref/test_regions.blacklistfiltered.bed
```

**step12**: select the top 4 out of the 6 scores; 10 minues per TF; 10 minutes per TF
```
perl ./preprocess/sequence/find_max_forward_reverse_top_4.pl ./data/seq_forward_top3/ ./data/seq_reverse_top3/ ./data/seq_top4/
```

**step13**: rank the features to 0-1; 10 minutes per TF
```
perl ./preprocess/sequence/create_top4_rank_ru.pl ./data/seq_top4/ ./data/seq_top4_rank/
```

**step14**: generate the neighboring ranked features; 80 minutes per TF
```
perl ./preprocess/sequence/create_largespace_tomax_top4_rank.pl ./data/seq_top4_rank/ ./data/seq_top4_rank_largespace/
```

### section3: distance to the closest genes 

**step15**: for each genomic coordinate, calculate the 20 closest distances to a gene; 8 hours

(1) the gencode (e.g. gencode.v19.annotation.gtf) is required (downloaded from: https://www.gencodegenes.org/releases/19.html)

(2) the reference file the genomic coordinates excluding blacklisted regions is needed

(3) it returns a file 'top_20' - the top 20 closes distances to a gene of each coordinate under consideration
```
perl ./preprocess/gencode/create_gene_distance_top20_uniq.pl ./data/top_20 ./data/ref/gencode.v19.annotation.gtf ./data/ref/test_regions.blacklistfiltered.bed
```






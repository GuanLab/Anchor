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

### 0. Run ANCHOR, Run

Once the required input files are put in the correpsonding directories, ANCHOR is ready to go:
```
python ANCHOR.py -tf TAF1 -cell H1-hESC 
```
The prediction results are saved here:
```
./prediction/anchor/final/
```
This is the one-line-to-run version. Since the genomic data themselves are large, it takes a lot of time (the estimated time for one TF-cell line pair is 5.5 days).

---
---

ANCHOR has 4 major sections and 15 major steps. 
* 1. Prepare DNase-seq features (35 hours per cell line)
* 2. Prepare DNA sequence and TF motif features (75 hours per TF)
* 3. Prepare gene location features (8 hours; you only need to run this once)
* 4. Make predictions ('fast' mode 9 hours or 'full' mode 36 hours per TF-cell line pair; it needs input features from section 1-3)

If you want to run the 4 major sections separately (e.g. in parallel), you can follow the examples below.

If you want to learn more about the details and run steps invidually, see here: [15 steps](https://github.com/Hongyang449/ANCHOR/blob/master/DETAILS.md)

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




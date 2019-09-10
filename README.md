## Anchor: Trans-cell Type Prediction of Transcription Factor Binding Sites

This is the package of Yuanfang's winning algorithm in the ENCODE-DREAM *in vivo* Transcription Factor Binding Site Prediction Challenge

background: [ENCODE-DREAM](https://www.synapse.org/#!Synapse:syn6131484)

see also: [Yuanfang Guan's 1st Place Solution](https://www.synapse.org/#!Synapse:syn7104742/wiki/407367) and [Original Code](https://www.synapse.org/#!Synapse:syn7104742/files/)

Please contact (gyuanfan@umich.edu or hyangl@umich.edu) if you have any questions or suggestions.

---

## Installation
Git clone a copy of ANCHOR:

```
git clone https://github.com/GuanLab/Anchor.git
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

* ./data/ref/[gencode.v19.annotation.gtf](https://www.gencodegenes.org/human/release_19.html)
it can also be downloaded from this here:
ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19/gencode.v19.annotation.gtf.gz

## Prepare features and make predictions

Once the required input files are put in the correpsonding directories, ANCHOR is ready to go:
```
python ANCHOR.py -tf TAF1 -cell H1-hESC 
```
The prediction results are saved here:
```
./prediction/anchor/final/
```
This is the one-line-to-run version. The implemetation details of feature generation and binding site prediction (with step-by-step explanation and example code) can be found here: [DETAILS](https://github.com/Hongyang449/ANCHOR/blob/master/DETAILS.md)



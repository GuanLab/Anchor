#!/usr/bin/perl

# the challenge data: one cell line, one bigWig
# this version downloaded from ENCODe: one cell line, two bigWig corresponding to two replicates
# also some difference at the border; it may not change the results
# DNASE.A549.fc.signal.txt <==
# chr1    0       10271   0
# chr1    10271   10421   0.71994
# chr1    10421   10435   0
# wgEncodeUwDnaseWi38RawRep1.txt <==
# chr1    10084   10164   1
# chr1    10164   10264   2
# chr1    10264   10344   1

$cell=$ARGV[0]; # cell line
$path1=$ARGV[1]; # input raw read
$path2=$ARGV[2]; # output location
$file=$ARGV[3]; # all the genomic coordiates under consideration

system "mkdir -p $path2";

@mat=glob "${path1}*${cell}*txt";

#foreach $gggg (@mat){
#    print "${gggg}\n";
#}
#die;

#$file="/state2/hyangl/TF_model/TF_revision/data/ref/test_regions.blacklistfiltered.bed";
open NEW, ">${path2}$cell" or die;
open OLD, "$file" or die;
while ($line=<OLD>){
	chomp $line;
	@table=split "\t", $line;
	$chr=$table[0];
	$start=$table[1];
	$end=$table[2];
	if ($chr eq $old_chr){}else{
		@feature=();
                foreach $gggg (@mat){
#                        print "$gggg\n";
        		open G, "$gggg" or die;
        		while ($line=<G>){
        			chomp $line;
        			@table=split "\t", $line;
        			if ($table[0] eq $chr){
        				$i=int($table[1]/50)*50;
        				$table[2]=int($table[2]/50)*50+50;
        				while ($i<$table[2]){
        					$feature[$i]++;
        					$i=$i+50;
        				}
        			}
        		}
        		close G;
                }
		$old_chr=$chr;
		
	}
	if (defined $feature[$start]){
		print NEW "$feature[$start]\n";
	}else{
		print NEW "0\n";
	}
}
close OLD;
close NEW;


	


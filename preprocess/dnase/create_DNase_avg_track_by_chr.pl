#!/usr/bin/perl

@chr_all=('chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19',
    'chr2','chr20','chr22','chr3','chr4','chr5','chr6','chr7','chr9','chrX','chr1','chr8','chr21');

#$chr_id=$ARGV[0];
$cell=$ARGV[0]; # cell line 
$path1=$ARGV[1]; # input raw read
$path2=$ARGV[2]; # output location

@mat=glob "${path1}*${cell}*"; # in case there are multiple replicates
system "mkdir -p $path2"; # output: location for the txt file

foreach $chr_id (@chr_all){

    print "$chr_id\n";

    foreach $gggg (@mat){
    	open OLD, "$gggg" or die;
    	while ($line=<OLD>){
    		chomp $line;
    		@table=split "\t", $line;
    		$chr=$table[0];
    		$start=$table[1];
    		$avg=$table[2];
    		if ($chr_id eq $chr){
    				$all_avg[$start]+=$avg;
    				$start++;
    			if ($start>$max){
    				$max=$start;
    			}
    		}
    	}
    	close OLD;
    }

    open NEW, ">${path2}${cell}_${chr_id}.txt" or die;
    $i=1;
    while ($i<$max){
    	if ($all_avg[$i]>0){
    		$val=$all_avg[$i];
    		print NEW "$i";
    		print NEW "\t$val\n";
    	}
    	$i++;
    }
    close NEW;
}	


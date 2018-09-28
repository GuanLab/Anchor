#!/usr/bin/perl

$cell=$ARGV[0]; # cell line 
$path1=$ARGV[1]; # input raw read
$path2=$ARGV[2]; # output location mean
$path3=$ARGV[3]; # output location max min
$file=$ARGV[4]; # all the genomic coordiates under consideration

system "mkdir -p $path2";
system "mkdir -p $path3";

#$file="/state2/hyangl/TF_model/TF_revision/data/ref/test_regions.blacklistfiltered.bed";

open NEW1, ">${path2}$cell" or die;
open NEW2, ">${path3}$cell" or die;

open OLD, "$file" or die;
while ($line=<OLD>){
	chomp $line;
	@table=split "\t", $line;
	$chr=$table[0];
	$start=$table[1];
	$end=$table[2];
	if (($cell eq $old_cell) && ($chr eq $old_chr)){}else{
		@feature=();
		print "$cell\t$chr\n";
			$cell_tmp=$cell;
	#	if ($cell =~/IM/){
	#		$cell_tmp=~s/-//g;
	#	}
		open G, "${path1}${cell_tmp}_${chr}.txt" or die;
		while ($line=<G>){
			chomp $line;
			@table=split "\t", $line;
			$i=$table[0];
			$feature[$i]=$table[1];
		}
		close G;
		$old_chr=$chr;
		$old_cell=$cell;
	}

	$c=0;
	$t=0;
        $max=-100;
        $min=99999999999999;

	$i=$start;
	while ($i<$end){
		$t+=$feature[$i];
		$c++;
                if ($feature[$i]<$min){
                        $min=$feature[$i];
                }    
                if ($feature[$i]>$max){
                        $max=$feature[$i];
                }    
		$i++;
	}

	$avg=$t/$c;
	$avg=int(10000*$avg)/10000;
	print NEW1 "$avg\n";

        if ($max eq ""){
                $max=0; 
        }    
        if ($min eq ""){
                $min=0; 
        }    
        $max=int($max*10000)/10000;
        $min=int($min*10000)/10000;
        print NEW2 "$max\t$min\n";

}
close OLD;
close NEW1;
close NEW2;

	


#!/usr/bin/perl
#

#@mat=("ATF2","CTCF","E2F1","EGR1","FOXA1","FOXA2","GABPA","HNF4A","JUND","MAX","NANOG","REST","TAF1");
#system "rm -rf tf_forward_ru_top3";
#system "mkdir tf_forward_ru_top3";

$tf=$ARGV[0];
$path1=$ARGV[1];
$path2=$ARGV[2];
$file=$ARGV[3];

system "mkdir -p $path2";

#$file="../../annotations/test_regions.blacklistfiltered.bed";
#foreach $tf (@mat){
	#open NEW, ">tf_forward_ru_top3/$tf" or die;
	open NEW, ">$path2/$tf" or die;
	open OLD, "$file" or die;

	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		$chr=$table[0];
		$start=$table[1];
		$end=$table[2];
		if (($tf eq $old_tf) && ($chr eq $old_chr)){}else{
			@feature=();
			print "${tf}_${chr}\n";
			#open G, "/state3/gyuanfan/ru_by_chrom_forward/${tf}_${chr}" or die;
			open G, "$path1/${tf}_${chr}" or die;
			$i=0;
			while ($line=<G>){
				chomp $line;
				$feature[$i]=$line;
				$i++;
			}
			close G;
			$old_chr=$chr;
			$old_tf=$tf;
			
		}

		@hat=();
		$i=$start-5;
		while ($i<$end){
			push @hat, $feature[$i];
			$i++;
		}
		@hat=sort{$b<=>$a}@hat;
		print NEW "$hat[0]\t$hat[1]\t$hat[2]\n";
	}
	close OLD;
	close NEW;
#}

	


#!/usr/bin/perl

## creating training and test samples from ChIPseq data
## input file format:
#chr     start   end     H1-hESC HepG2   K562    A549
#chr10   600     800     U       U       U       U
#chr10   650     850     U       U       U       U
#chr10   700     900     U       U       U       U

srand(3.14); # PARAMETER: change the seed and sample different lines
# e.g. change the seed for F,G,H,I models

$tf=$ARGV[0];
$path1='./data/chipseq/'; # input chipseq directory
$path2='./train/sample/'; # output director

system "mkdir -p ${path2}${tf}";

@mat=glob "${path1}${tf}*";

foreach $file (@mat){
	open INPUT, "$file" or die;
	$line=<INPUT>;
	chomp $line;
	@header=split "\t", $line;
	shift @header;
	shift @header;
	shift @header;
	foreach $cell (@header){
		open $cell, ">${path2}${tf}/F.${tf}.${cell}.tab" or die;
	}
	while($line=<INPUT>){
		chomp $line;
		@tmp=split "\t", $line;
		$chr=shift @tmp;
		$start=shift @tmp;
		$end=shift @tmp;
		foreach $cell (@header){
			$val=shift @tmp; # exclude "Ambiguous" peaks, result in different number of rows in tf_cell files
			if($val eq "U"){
				$rand=rand(300); # subsample 1/300
				if($rand<1){
					print $cell "$chr\t$start\t$end\t0\n";
				}
			}
			if($val eq "B"){
				print $cell "$chr\t$start\t$end\t1\n";
			}
		}
	}
	close INPUT;
	foreach $cell (@header){
		close $cell;
	}
}

	
	

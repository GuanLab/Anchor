#!/usr/bin/perl
#
$output=$ARGV[0];
$ref1=$ARGV[1];
$ref2=$ARGV[2];

#open REF, "/home/gyuanfan/2017/TF/data/raw/annotations/gencode.v19.annotation.gtf" or die;
open REF, $ref1 or die;
while ($line=<REF>){
	chomp $line;
	if ($line=~/^#/){}else{
		@table=split "\t", $line;
		if ($table[2] eq "gene"){
			if ($table[6] eq "+"){
				if (exists $ref_pos{$table[0]}){
					$ref_pos{$table[0]}.="\t$table[3]";
				}else{
					$ref_pos{$table[0]}=$table[3];
				}
			}
			if ($table[6] eq "-"){
				if (exists $ref_neg{$table[0]}){
					$ref_neg{$table[0]}.="\t$table[4]";
				}else{
					$ref_neg{$table[0]}=$table[4];
				}
			}
		}
	}
}
close REF;


## sort all pos for chromosomes;
@all_chr=keys %ref_pos;
foreach $chr (@all_chr){
	@table=split "\t", $ref_pos{$chr};
	@table=sort{$a<=>$b}@table;
	$aaa=shift @table;
	$ref_pos{$chr}=$aaa;
	foreach $aaa (@table){
		$ref_pos{$chr}.="\t$aaa";
	}
}

@all_chr=keys %ref_neg;
foreach $chr (@all_chr){
	@table=split "\t", $ref_neg{$chr};
	@table=sort{$b<=>$a}@table;
	$aaa=shift @table;
	$ref_neg{$chr}=$aaa;
	foreach $aaa (@table){
		$ref_neg{$chr}.="\t$aaa";
	}
}




#$file="../../annotations/test_regions.blacklistfiltered.bed";
$file=$ref2;

	#open NEW, ">/state4/gyuanfan/TF_model/data/top_20" or die;
	open NEW, ">$output" or die;
	open OLD, $file or die;
	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		print NEW "$table[0]\t$table[1]\t$table[2]";
		$mid=($table[1]+$table[2])/2;
		if ($table[0] eq $old){
		}else{
			$old=$table[0];
			@pos_array=split "\t", $ref_pos{$table[0]};
			@neg_array=split "\t", $ref_neg{$table[0]};
		}
		@diff=();
		%hash_diff=();

		$n=scalar (@pos_array);
		$i=0;
		while ($i<$n){
			$ppp=$pos_array[$i];
			if ($ppp>$mid){
				$ddd=$ppp-$mid;
				push @diff, $ddd;
				$hash_diff{$ddd}=0;
				goto AAA;
			}
			$i++;
		}
		AAA:$i++;
		$kkk=0;
		while ($kkk<20){
			if (defined $pos_array[$i]){
				$ddd=$pos_array[$i]-$mid;
			}else{
				goto CCC;
			}
			if (exists $hash_diff{$ddd}){}else{
				$hash_diff{$ddd}=0;
				push @diff, $ddd;
				$kkk++;
			}
			$i++;
		}

		CCC:;
		
		$n=scalar (@neg_array);
		$i=0;
		while ($i<$n){
			$ppp=$neg_array[$i];
			if ($ppp<$mid){
				$ddd=$mid-$ppp;
				push @diff, $ddd;
				goto BBB;
			}
			$i++;
		}
		BBB:$i++;
		$kkk=0;
		while ($kkk<20){
			if (defined $neg_array[$i]){
				$ddd=$mid-$neg_array[$i];
			}else{
				goto DDD;
			}
			if (exists $hash_diff{$ddd}){}else{
				$hash_diff{$ddd}=0;
				push @diff, $ddd;
				$kkk++;
			}
			$i++;
		}


		DDD:;

		@diff=sort{$a<=>$b}@diff;



		$i=0;
		while ($i<20){
			print NEW "\t$diff[$i]";
			$i++;
		}
		print NEW "\n";
			
	}
	close NEW;
	close OLD;

		
				

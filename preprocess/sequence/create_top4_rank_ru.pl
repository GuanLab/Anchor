#!/usr/bin/perl
#

$dir_input=$ARGV[0];
$dir_output=$ARGV[1];

@mat=glob "$dir_input/*";
system "mkdir -p $dir_output";

#system "rm -rf /state4/gyuanfan/TF_model/data/tf_ru_max_top4_rank";
#system "mkdir /state4/gyuanfan/TF_model/data/tf_ru_max_top4_rank";
#@mat=glob "/state4/gyuanfan/TF_model/data/tf_ru_max_top4/*";


foreach $file (@mat){
	%count_val=0;
	$total=0;
	open OLD, "$file" or die;
	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		foreach $aaa (@table){
			$count_val{$aaa}++;
			$total++;
		}
	}
	close OLD;
	
	@all_vals=keys %count_val;
	@all_vals=sort{$a<=>$b}@all_vals;
	$ref_num=0;

	%map=();
	$old=0;
	foreach $vvv (@all_vals){
		$ref_num+=$old;
		$ref_num+=($count_val{$vvv}/2);
		$old=($count_val{$vvv}/2);
		$map{$vvv}=$ref_num/$total;
	}
	open OLD, "$file" or die;
	$new=$file;
	@t=split '/', $file;
	$name=pop @t;
	#open NEW, ">/state4/gyuanfan/TF_model/data/tf_ru_max_top4_rank/$name";
	open NEW, ">$dir_output/$name";
	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		$aaa=shift @table;
		printf NEW "%.5f", $map{$aaa};
		foreach $aaa (@table){
			printf NEW "\t%.5f", $map{$aaa};
		}
		print NEW "\n";
	}
	close OLD;
	close NEW;
}

	
	
		
	


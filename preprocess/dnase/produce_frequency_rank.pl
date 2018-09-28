#!/usr/bin/perl

$path1=$ARGV[0]; # input raw read
$path2=$ARGV[1]; # output location

system "mkdir -p $path2";

@mat=glob "${path1}*";

foreach $file (@mat){
	%count_val=0;
	$total=0;
	open OLD, "$file" or die;
	while ($line=<OLD>){
		chomp $line;
		$count_val{$line}++;
		$total++;
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
	open NEW, ">${path2}$name";
	while ($line=<OLD>){
		chomp $line;
		print NEW "$map{$line}\n";
	}
	close OLD;
	close NEW;
}

	
	
		
	


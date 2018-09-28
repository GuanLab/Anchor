#!/usr/bin/perl

$cell=$ARGV[0]; # cell line 
$path1=$ARGV[1]; # input raw read
$path2=$ARGV[2]; # output location

@mat=glob "${path1}*${cell}*";
system "mkdir -p $path2";

$length=3036303386;
$ratio=1000;
$total_sample=$length/$ratio;
@all=();
foreach $file (@mat){
	open OLD, "$file" or die;
	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		$r=rand($ratio);
		if ($r<1){
			push @all, $table[1];
		}
	}
	close OLD;
}

$default=0;
$n=scalar (@all);
$i=$n;
while ($i<$total_sample){
	push @all,$default;
	$i++;
}


@all=sort{$a<=>$b}@all;
open NEW, ">${path2}${cell}.txt" or die;
foreach $aaa (@all){
	print NEW "$aaa\n";
}


#!/usr/bin/perl

$cell=$ARGV[0]; # cell line
$path1=$ARGV[1]; # input raw read
$path2=$ARGV[2]; # input subsampled dnase folder
$path3=$ARGV[3]; # output location
$liver=$ARGV[4]; # the reference cell line

@mat=glob "${path1}*${cell}*";
system "mkdir -p $path3";

open REF, "${path2}${cell}.txt" or die;
#open LIVER, "/state2/hyangl/TF_model/TF_revision/data/ref/liver.txt" or die;
open LIVER, "$liver" or die;
%map=();
%count=();
@liver_all=();
while ($ref=<REF>){
	chomp $ref;
	$liver=<LIVER>;
	chomp $liver;
	$map{$ref}+=$liver;
	$count{$ref}++;
	push @liver_all, $liver;
}

@all=keys %map;
foreach $aaa (@all){
	$map{$aaa}=$map{$aaa}/$count{$aaa};
}
@all=sort{$b<=>$a}@all;

@liver_all=sort{$a<=>$b}@liver_all;
$norm=$liver_all[int(scalar(@liver_all)*0.9)];
close REF;
close LIVER;

foreach $file (@mat){
	@t=split '/', $file;
	$name=pop @t;
		
	open OLD, "$file" or die;
	open NEW, ">${path3}${name}" or die;
	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		if (exists $map{$table[1]}){
			$new_table=$map{$table[1]};
		}else{
			$last=$all[0];
			$first=$all[1];
			if ($table[1]>$last){

				$u=($table[1]-$last)*($map{$last}-$map{$first});
                                $d=($last-$first);
                                $new_table=$map{$last}+$u/$d;	
			}else{
				foreach $aaa (@all){
					if ($table[1]>$aaa){
						$first=$aaa;
						goto AAA;
					}else{
						$last=$aaa;
					}
				}
				AAA:$u=($table[1]-$first)*($map{$last}-$map{$first});
				$d=($last-$first);
				$new_table=$map{$first}+$u/$d;
				
				
			}
		}
						
				
		$val=log(1+$new_table/$norm);
		$val= sprintf "%.4f", $val;
		print NEW "$table[0]\t$val\n";				
	}
	close OLD;
	close NEW;
}

		
	

	
	

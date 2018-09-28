#!/usr/bin/perl


$path1=$ARGV[0]; # input raw read
$path2=$ARGV[1]; # output location

system "mkdir -p $path2";

@mat=glob "${path1}*";


foreach $file (@mat){
	$i=0;
	open OLD, "$file" or die;
	while ($line=<OLD>){
		chomp $line;
		$ref[$i]+=$line;
		$i++;
	}
	close OLD;
	$count++;
}

foreach $file (@mat){
	@t=split '/', $file;
	$name=pop @t;
	$i=0;
	open OLD, "$file" or die;
	open NEW, ">${path2}$name" or die;
	while ($line=<OLD>){
		chomp $line;
		$avg=$ref[$i]/$count;
		$val=$line-$avg;
		print NEW "$val\n";
		$i++;
	}
	close OLD;
	close NEW;
}

	

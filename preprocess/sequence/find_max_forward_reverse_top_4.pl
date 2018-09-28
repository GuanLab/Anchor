#!/usr/bin/perl
#

$dir_input1=$ARGV[0];
$dir_input2=$ARGV[1];
$dir_output=$ARGV[2];

#@mat=glob "/state4/gyuanfan/TF_model/data/tf_reverse_ru_top3/*";
@mat=glob "$dir_input1/*";

#system "mkdir /state4/gyuanfan/TF_model/data/tf_ru_max_top4/";
system "mkdir -p $dir_output";

foreach $file1 (@mat){
#	$file2=$file1;
#	$file2=~s/reverse/forward/g;
        @table=split "/", $file1;
        $tf=pop @table;
        $file2="$dir_input2/$tf";

	#$new=$file1;
	#$new=~s/tf_reverse_ru_top3/tf_ru_max_top4/g;
        $new="$dir_output/$tf";

	open OLD1, "$file1" or die;
	open OLD2, "$file2" or die;
	open NEW, ">$new" or die;

	while ($line1=<OLD1>){
		chomp $line1;
		@table1=split "\t", $line1;
		$line2=<OLD2>;
		chomp $line2;
		@table2=split "\t", $line2;
		push @table1, @table2;
	
		@all=sort{$b<=>$a}@table1;
		print NEW "$all[0]\t$all[1]\t$all[2]\t$all[3]\n";

	
	}
	close OLD1;
	close OLD2;
	close NEW;
}

		

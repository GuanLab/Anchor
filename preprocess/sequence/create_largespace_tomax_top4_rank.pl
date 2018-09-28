#!/usr/bin/perl
#
#
#@mat=glob "/state4/gyuanfan/TF_model/data/tf_ru_max_top4_rank/*";
#system "mkdir /state4/gyuanfan/TF_model/data/tf_ru_max_top4_rank_largespace";

$dir_input=$ARGV[0];
$dir_output=$ARGV[1];

@mat=glob "$dir_input/*";
system "mkdir -p $dir_output";

foreach $file (@mat){
	open OLD, "$file" or die;
	@all1=();
	@all2=();
	@all3=();
	@all4=();
	while ($line=<OLD>){
		chomp $line;
		@table=split "\t", $line;
		push @all1, $table[0];
		push @all2, $table[1];
		push @all3, $table[2];
		push @all4, $table[3];
	}
	close OLD;
	@t=split '/', $file;
	$name=pop @t;

	#open NEW, ">/state4/gyuanfan/TF_model/data/tf_ru_max_top4_rank_largespace/$name" or die;
	open NEW, ">$dir_output/$name" or die;

	$i=0;
	foreach $aaa (@all1){
		printf NEW "%.4f", $aaa;
		$j=1;
		while ($j<15){
			$max=-100;
			if ($all1[$i-$j]>$max){
				$max=$all1[$i-$j];
			}
			if ($all1[$i+$j]>$max){
				$max=$all1[$i+$j];
			}
			printf NEW "\t%.4f", $max;
			$j++;
			$j++;
		}


		printf NEW "\t%.4f", $all2[$i];
		$j=1;
		while ($j<15){
			$max=-100;
			if ($all2[$i-$j]>$max){
				$max=$all2[$i-$j];
			}
			if ($all2[$i+$j]>$max){
				$max=$all2[$i+$j];
			}
			printf NEW "\t%.4f", $max;
			$j++;
			$j++;
		}


		printf NEW "\t%.4f", $all3[$i];
		$j=1;
		while ($j<15){
			$max=-100;
			if ($all3[$i-$j]>$max){
				$max=$all3[$i-$j];
			}
			if ($all3[$i+$j]>$max){
				$max=$all3[$i+$j];
			}
			printf NEW "\t%.4f", $max;
			$j++;
			$j++;
		}


		printf NEW "\t%.4f", $all4[$i];
		$j=1;
		while ($j<15){
			$max=-100;
			if ($all4[$i-$j]>$max){
				$max=$all4[$i-$j];
			}
			if ($all4[$i+$j]>$max){
				$max=$all4[$i+$j];
			}
			printf NEW "\t%.4f", $max;
			$j++;
			$j++;
		}

		print NEW "\n";
		$i++;
	}
	close NEW;
		
}

		

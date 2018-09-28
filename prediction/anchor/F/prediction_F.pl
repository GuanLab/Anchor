#!/usr/bin/perl

# make predictions 

$the_tf=$ARGV[0]; # query TF
$the_cell=$ARGV[1]; # query cell line
$path1=$ARGV[2]; # path to the feature directory
#$path2=$ARGV[3]; # output directory 
$path2="./prediction/anchor/"; # need to fix this, otherwise need to change xgtree.conf

$path_output="${path2}F/separated/"; # PARAMETER
$path_scratch="${path2}F/";  # PARAMETER
system "mkdir -p $path_output";

@model_dir1=glob "./model/anchor/F/*set1_eva"; # PARAMETER: F/G/H/I
@model_dir2=glob "./model/anchor/F/*set2_eva"; # PARAMETER

@tf_feature=glob ("${path1}/seq_top4_rank_largespace/$the_tf"); # PARAMETER: FG "xxx/$the_tf" HI "xxx/*"

@cell_feature=("${path1}anchor_bam_dnase_largespace/", # PARAMETER
    "${path1}anchor_bam_dnase_diff_largespace/",
    "${path1}anchor_bam_dnase_max_min_largespace/",
    "${path1}anchor_bam_dnase_max_min_diff_largespace/",
    "${path1}frequency_rank_largespace/");

$rna_feature="${path1}/top_20";  # 60519747 lines, including index

## prediction ##
$the_file="${the_tf}_${the_cell}";
print "$the_tf\t$the_cell\n";

open INDEX, "$rna_feature" or die;
$num=0; # index for all feature files
foreach $the_feature (@tf_feature){
    $name='INPUT'.$num;
    open $name, "$the_feature" or die; 
    $num++;
}
foreach $the_path (@cell_feature){
    $name='INPUT'.$num;
    open $name, "$the_path$the_cell" or die; 
    $num++;
}

$lll_i=0;
$file_i=0;

while ($line=<INDEX>){
    chomp $line;
    @table=split "\t", $line;
    shift @table;
    shift @table;
    shift @table;

    $additional='';
    $i=21;
    foreach $val (@table){
        $additional.=" $i:$val";
        $i++;
    }
    $j=0;
    while($j<$num){
        $name='INPUT'.$j;
        $line1=<$name>;
        chomp $line1;
        @table1=split "\t", $line1;
        foreach $val (@table1){
            $additional.=" $i:$val";
            $i++;
        }
        $j++;
    }

    if (($lll_i%1000000)==0){ # make prediction of every 1,000,000 lines
        close NEW; # I think if test.dat too big, xgboost cannot accept it due to limited memory
        @pred=();
        $count=0;
        if ($file_i>0){
        foreach $dir (@model_dir1){
            @t=split '/', $dir;
            $model_name=pop @t;
            @pair=split '_', $model_name;
            $tf1=$pair[0];
            $cell1=$pair[1]; # training cell

            if($the_tf eq $tf1){ # use prediction from best models of all other cell lines
                if (($the_cell eq $cell1) ){print "$cell1\t$the_cell\texcluded\n";}else{
                    $perf=0;
                    $model="${dir}/the_model";
                    system "cp $model ${path_scratch}";
                    system "xgboost ${path_scratch}xgtree.conf task=pred model_in=${path_scratch}the_model";
                    open OLD, "${path_scratch}output.dat" or die;
                    $i=0;
                    while ($line=<OLD>){
                        chomp $line;
                        $pred[$i]+=$line;
                        $i++;
                    }
                    close OLD;
                    $count++;
                }
            }
        }
        
        
        $imax=$i;
        open PRED, ">${path_output}${file_i}_${the_file}_set1_model" or die;
        $i=0;
        while ($i<$imax){
            $val=$pred[$i]/$count;
            print PRED"$val\n";
            $i++;
        }
        close PRED;

        @pred=();
        $count=0;
        foreach $dir (@model_dir2){
            @t=split '/', $dir;
            $model_name=pop @t;
            @pair=split '_', $model_name;
            $tf1=$pair[0];
            $cell1=$pair[1]; # training cell

            if($the_tf eq $tf1){
                if (($the_cell eq $cell1) ){}else{
                    $perf=0;
                    $model="${dir}/the_model";
                    system "cp $model ${path_scratch}";
                    system "xgboost ${path_scratch}xgtree.conf task=pred model_in=${path_scratch}the_model";
                    open OLD, "${path_scratch}output.dat" or die;
                    $i=0;
                    while ($line=<OLD>){
                        chomp $line;
                        $pred[$i]+=$line;
                        $i++;
                    }
                    close OLD;
                    $count++;
                }
            }
        }
        
        
        $imax=$i;
        open PRED, ">${path_output}${file_i}_${the_file}_set2_model" or die;
        $i=0;
        while ($i<$imax){
            $val=$pred[$i]/$count;
            print PRED"$val\n";
            $i++;
        }
        close PRED;
        } # if ($file_i>0)
        open NEW, ">${path_scratch}test.dat" or die;

        $file_i++;
    } # if (($lll_i%1000000)==0)
    print NEW "0";
    print NEW "$additional\n";
    $lll_i++;
            
} # while ($line=<INDEX>)
close NEW; # make prediction of the rest less than 1,000,000 lines
@pred=();
$count=0;
foreach $dir (@model_dir1){
    @t=split '/', $dir;
            $model_name=pop @t;
            @pair=split '_', $model_name;
            $tf1=$pair[0];
    $cell1=$pair[1]; # training cell

    if($the_tf eq $tf1){
        if (($the_cell eq $cell1) ){}else{
            $perf=0;
            $model="${dir}/the_model"; 
            system "cp $model ${path_scratch}";
            system "xgboost ${path_scratch}xgtree.conf task=pred model_in=${path_scratch}the_model";
            open OLD, "${path_scratch}output.dat" or die;
            $i=0;
            while ($line=<OLD>){
                chomp $line;
                $pred[$i]+=$line;
                $i++;
            }
            close OLD;
            $count++;
        }
    }
}


$imax=$i;
open PRED, ">${path_output}${file_i}_${the_file}_set1_model" or die;
$i=0;
while ($i<$imax){
    $val=$pred[$i]/$count;
    print PRED "$val\n";
    $i++;
}
close PRED;

@pred=();
$count=0;
foreach $dir (@model_dir2){
    @t=split '/', $dir;
    $model_name=pop @t;
    @pair=split '_', $model_name;
    $tf1=$pair[0];
    $cell1=$pair[1]; # training cell

    if($the_tf eq $tf1){
        if (($the_cell eq $cell1) ){print "$the_cell\t$cell1\texcluded\n";}else{
            $perf=0;
            $model="${dir}/the_model";
            system "cp $model ${path_scratch}";
            system "xgboost ${path_scratch}xgtree.conf task=pred model_in=${path_scratch}the_model";
            open OLD, "${path_scratch}output.dat" or die;
            $i=0;
            while ($line=<OLD>){
                chomp $line;
                $pred[$i]+=$line;
                $i++;
            }
            close OLD;
            $count++;
        }
    }
}
            
$imax=$i;
open PRED, ">${path_output}${file_i}_${the_file}_set2_model" or die;
$i=0;
while ($i<$imax){
    $val=$pred[$i]/$count;
    print PRED "$val\n";
    $i++;
}
close PRED;
$j=0;
while($j<$num){
    $name="INPUT".$j;
    close $name;
    $j++;
}



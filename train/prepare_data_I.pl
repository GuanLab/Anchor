#!/usr/bin/perl

## prepare training & test data

$the_tf=$ARGV[0]; # training TF
$path1='/state2/hyangl/TF_model/data/feature/'; # path to the feature directory
$path2='./data/chipseq/'; # path to the chipseq directory 
$path3='./train/sample/'; # path to the sample directory 
$path4='./train/train_test/I/'; # output directory PARAMETER 

system "mkdir -p $path4";

@tf_feature=glob ("${path1}tf_ru_max_top4_rank_largespace/*"); # PARAMETER: FG "xxx/$the_tf" HI "xxx/*"

@cell_feature=("${path1}anchor_bam_DNAse_largespace/", # PARAMETER
    "${path1}anchor_bam_DNAse_diff_largespace/",
    "${path1}anchor_bam_DNAse_max_min_largespace/",
    "${path1}anchor_bam_DNAse_max_min_diff_largespace/",
    "${path1}orange_rank_largespace/",
    "${path1}orange_rank_diff_largespace/");

$rna_feature="${path1}top_20";  # 60519747 lines, including index


#########
#$the_tf=$ARGV[0]; # training TF
#$path1='./data/'; # path to the feature directory
#$path2='./data/chipseq/'; # path to the chipseq directory 
#$path3='./train/sample/'; # path to the sample directory 
#$path4='./train/train_test/I/'; # output directory PARAMETER 
#
#system "mkdir -p $path4";
#
#@tf_feature=glob ("${path1}seq_top4_rank_largespace/*"); # PARAMETER: FG "xxx/$the_tf" HI "xxx/*"
#
#@cell_feature=("${path1}anchor_bam_dnase_largespace/", # PARAMETER
#    "${path1}anchor_bam_dnase_diff_largespace/",
#    "${path1}anchor_bam_dnase_max_min_largespace/",
#    "${path1}anchor_bam_dnase_max_min_diff_largespace/",
#    "${path1}frequency_rank_largespace/",
#    "${path1}frequency_rank_diff_largespace/");
#
#$rna_feature="${path1}top_20";  # 60519747 lines, including index
########

%chr_set1=(); # index for set1 and set2 chr
open INDEX_SET1, "./data/index/ind_chr_set1.txt" or die;
while($line=<INDEX_SET1>){
    chomp $line;
    $chr_set1{$line}=0;
}
close INDEX_SET1;


system "mkdir -p ${path4}${the_tf}";
@tmp=glob "${path2}${the_tf}*"; # collect names of all cell types for target tf
open TMP, "$tmp[0]" or die;
$line=<TMP>;
chomp $line;
@list= split "\t", $line;
shift @list;
shift @list;
shift @list;
close TMP;

foreach $cell (@list){
    open SAMPLE, "${path3}${the_tf}/F.${the_tf}.${cell}.tab" or die; # a subset of all data; chr and start are the coordinates
    %target=(); # if exists/defined target{$chr}{$start}
    while($line=<SAMPLE>){
        chomp $line;
        @tmp=split "\t", $line;
        $chr=shift @tmp;
        $start=shift @tmp;
        shift @tmp;
        $y=shift @tmp;
        $target{$chr}{$start}=$y;
    }
    close SAMPLE;

    open INDEX, "$rna_feature" or die;
    $num=0; # index for all feature files
    foreach $file (@cell_feature){
        $name="INPUT".$num;
        open $name, "${file}${cell}" or die;
        $num++;
    }
    foreach $file (@tf_feature){
        $name="INPUT".$num;
        open $name, "${file}" or die;
        $num++;
    }

    open OUTPUT1, ">${path4}${the_tf}/${the_tf}.${cell}.set1" or die;
    open OUTPUT2, ">${path4}${the_tf}/${the_tf}.${cell}.set2" or die;
    while($line=<INDEX>){
        chomp $line;
        @rna=split "\t", $line;
        $chr=shift @rna;
        $start=shift @rna;
        shift @rna;
        if(defined $target{$chr}{$start}){ # if this line is target
            if(exists $chr_set1{$chr}){ # save data as set 1 or set 2
                $file="OUTPUT1";
            }else{
                $file="OUTPUT2"
            }
            print $file "$target{$chr}{$start}"; # print y in the 1st column
            $j=21;
            foreach $x (@rna){ # print rna feature
                print $file " $j:$x";
                $j++;
            }
            $i=0;
            while($i<$num){ # print all other features
                $name="INPUT".$i;
                $line=<$name>;
                chomp $line;
                @tmp=split "\t",$line;
                foreach $x (@tmp){
                    print $file " $j:$x";
                    $j++;
                }
                $i++;
            }
            print $file "\n";
        }else{ # if this line is not target, skip it
            $i=0;
            while($i<$num){
                $name="INPUT".$i;
                <$name>;
                $i++;
            }
        }
    }
    close OUTPUT1;
    close OUTPUT2;
    close INDEX;
    $i=0;
    while($i<$num){
        $name="INPUT".$i;
        close $name;
        $i++;
    }
}



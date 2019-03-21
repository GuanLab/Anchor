#!/usr/bin/perl

## train model

$the_tf=$ARGV[0]; # training TF
$path1='../train_test/H/'; # path to the data directory
$path2='../../data/chipseq/'; # path to the chipseq directory 
$path3='../../model/anchor/H_all/'; # output directory 

system "mkdir -p $path3";

@tmp=glob "${path2}${the_tf}*"; # collect names of all cell lines for target tf
open TMP, "$tmp[0]" or die;
$line=<TMP>;
chomp $line;
@list= split "\t", $line;
shift @list;
shift @list;
shift @list;
close TMP;

$num_cell=scalar(@list);
$i=0;
while($i<$num_cell){
    $train=$list[$i];
    if($i eq $num_cell-1){
        $test=$list[0];
    }else{
        $test=$list[$i+1];
    }
    $i++;

    system "cp ${path1}${the_tf}/${the_tf}.${train}.set1 train.dat"; # train on chr set 1 of cell_train
    system "cp ${path1}${the_tf}/${the_tf}.${test}.set2 test.dat";   # test on chr set 2 of cell_test
    system "xgboost xgtree.conf";
    @all_config=glob "*model";
    system "cut -f 1 -d ' ' test.dat>test_gs.dat";
    foreach $model (@all_config){
        system "xgboost xgtree.conf task=pred model_in=$model";
        system "python evaluation.py";
        system "mv auc.txt ${model}.auc.txt";
        system "mv auprc.txt ${model}.auprc.txt";
    }
    system "mkdir ${path3}${the_tf}_${train}_${test}_set1_eva";
    system "mv *model ${path3}${the_tf}_${train}_${test}_set1_eva/";
    system "mv *auc.txt ${path3}${the_tf}_${train}_${test}_set1_eva/";
    system "mv *auprc.txt ${path3}${the_tf}_${train}_${test}_set1_eva/";

    system "cp ${path1}${the_tf}/${the_tf}.${train}.set2 train.dat"; # train on chr set 2 of cell_train
    system "cp ${path1}${the_tf}/${the_tf}.${test}.set1 test.dat";   # test on chr set 1 of cell_test
    system "xgboost xgtree.conf";
    @all_config=glob "*model";
    system "cut -f 1 -d ' ' test.dat>test_gs.dat";
    foreach $model (@all_config){
        system "xgboost xgtree.conf task=pred model_in=$model";
        system "python evaluation.py";
        system "mv auc.txt ${model}.auc.txt";
        system "mv auprc.txt ${model}.auprc.txt";
    }
    system "mkdir ${path3}${the_tf}_${train}_${test}_set2_eva";
    system "mv *model ${path3}${the_tf}_${train}_${test}_set2_eva/";
    system "mv *auc.txt ${path3}${the_tf}_${train}_${test}_set2_eva/";
    system "mv *auprc.txt ${path3}${the_tf}_${train}_${test}_set2_eva/";
}


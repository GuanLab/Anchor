#!/usr/bin/perl


$path1="./model/anchor/I_all/";

@model_dir=glob "${path1}*";

foreach $the_dir (@model_dir){
    print "$the_dir\n";
    $new_dir=$the_dir;
    $new_dir=~s/_all//g;
    print "$new_dir\n";
    system "mkdir -p $new_dir";
    $perf=0;
    $model='';
    @all_models=glob "$the_dir/*auprc.txt";
    foreach $the_model (@all_models){
        open OLD, "$the_model" or die;
        $line=<OLD>;
        if ($line>$perf){
            $perf=$line;
            $model=$the_model;
        }
    }
    print "$model\n";
    $model=~s/\.auprc\.txt//g;
    system "cp $model ${new_dir}/the_model"
}






$path1=$ARGV[0];
$path2=$ARGV[1];

@mat=glob "$path1*bigwig"; # input: location of the bam file
system "mkdir -p $path2"; # output: location for the txt file

foreach $file (@mat){
	@t=split '/', $file;
	$name=pop @t;
        print "$name\n";
	system "bigWigToBedGraph $file ${path2}${name}.txt";
}


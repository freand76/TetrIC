die "\n### Useage: merge.pl file1 file2 file3 -o outfile\n\n" if ( $#ARGV<2 );

my %infilehash = ();
my $outfilename = "";
my $outfile = "";
my $i = 0;

while (defined ($par = shift @ARGV)) {
	if ($par eq "-o") {
		$outfilename = shift @ARGV;
		die "\n### Garbage in inputline\n\n" if (defined ($par = shift @ARGV))
	}
	else {
		$infilehash{$i} = $par;
		$i++;
	}
}

die "\n### No outfile\n\n" if ($outfilename eq "");

open( ULF, "> $outfilename" ) || die "\n### Could not open output\n\n";
select ULF;

foreach my $file (keys %infilehash) {
	open( INF, "< $infilehash{$file}" ) || die "\n### Could not open input file!\n\n";
	my $replace = $infilehash{$file};
	$replace =~ s/\..+/_label/;
	while (<INF>) {
    	    my $origline = $_;
    	    $origline =~ s/LccLabel/$replace/;
    	    print $origline;
	}
	close(INF);
}
close(ULF);

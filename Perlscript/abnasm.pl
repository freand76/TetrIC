#!/usr/bin/perl -w

# $Id: asm,v 1.5 2002/07/02 09:01:12 abn Exp $

# Tiny M*PS Assembler.  (C) Anders Berkeman 2002.
# Primary for TetrIC monolithic video game consol chip.
# Might be useful in other unexpected places.
# Thanks to Martin Nilsson, Mathias Johansson and
# the rest of the TetrIC nerds

# The assembler is a simple two-pass design, implemented
# in three actual passes.
# The passes are
#   1.  Macro expansion, syntax checking and label
#       collecting. Macro definitions are stored
#       and expanded where initiated.  In the future,
#       source file inclusion will be put here.
#   2.  Hex file generation from known labels and
#       syntax verified source.
#   3.  Generation of bit file.
#
# Pass 2 and 3 are straightforward to merge, but
# code is easier to read by keeping them separate.

# For reference on syntax etc, see "code.s" included in tarball.

# translation hash
my %transhash = ();

# all labels and symbols stored here...
my %labelhash = ();

# storage for macros.  Implemented as a hash of pointers to
# arrays containing lines of macro text.
my %macrohash = ();

# simple mapping from regname to register number in decimal
my %reghash = ( "ZERO",  0,  "AT",  1,  "V0",  2,  "V1",  3,  "A0",  4,  "A1",  5,  "A2",  6,  "A3",  7,
                  "T0",  8,  "T1",  9,  "T2", 10,  "T3", 11,  "T4", 12,  "T5", 13,  "T6", 14,  "T7", 15,
                  "S0", 16,  "S1", 17,  "S2", 18,  "S3", 19,  "S4", 20,  "S5", 21,  "S6", 22,  "S7", 23,
		  "T8", 24,  "T9", 25,  "K0", 26,  "K1", 27,  "GP", 28,  "SP", 29,  "FP", 30,  "RA", 31,
		  "S8", 30,
		# Some TetrIC-specific aliases
		 "SFX", 26, "GFX", 27,
		 "LUT", 28, "SCR", 30,
		 
		 "r0", 0, "R1", 1, "R2", 2, "R3", 3, "R4", 4, "R5", 5, "R6", 6, "R7", 7, 
		 "R8", 8, "R9", 9, "R10", 10, "R11", 11, "R12", 12, "R13", 13, "R14", 14, "R15", 15, 
		 "R16", 16, "R17", 17, "R18", 18, "R19", 19, "R20", 20, "R21", 21, "R22", 22, "R23", 23, 
		 "R24", 24, "R25", 25, "R26", 26, "R27", 27, "R28", 28, "R29", 29, "R30", 30, "R31", 31
	      );

# Syntax for the instrhash:
# 1. All is capitals.
# 2. First four chars in data field is parser info.
#    Letters are read from left to right and correspond
#    to expected arguments to mnemonic in source file.
#    S,T,D   register
#    H        5 bit immediate (SHAMT << 6)
#    I       16 bit immediate
#    B       16 bit branch immediate
#    J       26 bit immediate
#    Space terminates parsing.
# 3. Rest of data field is the instruction code in "ascii-hex".
my %instrhash = (
		 "ADD",   "DST 00000020",    "ADDU",  "DST 00000021",
		 "ADDI",  "TSI 20000000",    "ADDIU", "TSI 24000000",
		 "AND",   "DST 00000024",    "ANDI",  "TSI 30000000",
		 "NOR",   "DST 00000027",    "OR",    "DST 00000025",
		 "ORI",   "TSI 34000000",    "SLLV",  "DTS 00000004",
                 "SRAV",  "DTS 00000007",    "SRLV",  "DTS 00000006",
		 "SUB",   "DST 00000022",    "SUBU",  "DST 00000023",
		 "XOR",   "DST 00000026",    "XORI",  "TSI 38000000",
		 "LUI",   "TI  3C000000",    "SLT",   "DST 0000002A",
		 "SLTU",  "DST 0000002B",    "SLTI",  "TSI 28000000",
		 "SLTIU", "TSI 2C000000",    "BEQ",   "STB 10000000",
		 "BGE",   "STB 04000000",    "BGT",   "STB 1C000000",
		 "BNE",   "STB 14000000",    "J",     "J   08000000",
		 "JAL",   "J   0C000000",    "JALR",  "SD  00000009",
		 "JR",    "S   00000008",    "LW",    "TIS 8C000000",
		 "SW",    "TIS AC000000",
		 # tetric project specific
		 "SLL",   "DSH 00000000", # should be DTH in real MIPS!
		 "SRA",   "DSH 00000003", # should be DTH in real MIPS!
		 "SRL",   "DSH 00000002", # should be DTH in real MIPS!
		 "MFC0",  "D   40000000",    "MFC1",  "DT  44000000",
		 "MFC2",  "D   48000000",    "MFC3",  "D   4C000000",
		 # aliases Mathias/Torbjörn/abn/mni
		 "CLR",   "D   00000025", # based on or
		 "NOP",   "    00000000",
		 "MOV",   "DT  00000025", # based on or
		 "MOVI",  "TI  20000000", # based on addi -> sign extend
		 "MOVIU", "TI  34000000", # based on ori, no sign extend
		 "NOT",   "DT  00000027", # based on nor (rd:= $0 nor rt)
		 "NEG",   "DT  00000022", # based on sub (rd:= $0-rt)
		 "BEQZ",  "SB  10000000", # based on Bxx with rt=$0
		 "BGEZ",  "SB  04000000",
		 "BGTZ",  "SB  1C000000",
		 "BNEZ",  "SB  14000000",
		 "B",     "B   10000000", # unconditional branch (beq $0,$0,offset)
		);

# A hash with possible directives.
# Either a "code-mnemonic" is an instruction or a directive.
# NOTE that hash-value is reserved for future use!
my %directivehash = (
                     ".DC",           "I  ",  ".ORG",       "I  ",
                     ".END",          "   ",  ".MACRO",     "   ",
                     ".FILE",         "NI ",  ".PAD",       "II ",
                     ".ENDMACRO",     "   ",  "=",          "I  ",
                     ".EQU",          "I  ",
                     ".TRANSTAB",     "   ",  ".TRANSLATE", "   ",
		     ".TRANSOFF",     "   ",  ".TR",        "NN ",
		     ".ASCII",        "I  "
		    );

# location of S,T and D fields of an instructions.
my %stdhash = ( "S", 21,  "T", 16,  "D", 11 );


my $namei; my $name0; my $name1; my $name2; my $name3;

die "\n### One input filename required!\n\n" if ( $#ARGV!=0 );
$namei = $ARGV[0];
( $name1 = $namei ) =~ s/\..+/.1/;
( $name2 = $namei ) =~ s/\..+/.2/;
( $name3 = $namei ) =~ s/\..+/.bin/;


#####################################################
# PASS 1 - parse and macroexpand                    #
#####################################################
{
  open( INF, "< $namei" ) || die "\n### Could not open input file!\n\n";
  open( ULF, "> $name1" ) || die "\n### Could not open list file!\n\n";
  select ULF;

  my $macroname = "";
  my $macroeatmode = 0;
  my $macrobarfmode = 0;
  my $transtabmode = 0;
  my $translatemode = 0;
  my @macrotext = "";
  my @macro_argtemplate = ();
  my @macro_arguments = ();
  my %macro_transarg = ();
  my $labeldealtwith = 0;
  my $lineno = 0;
  my $rawline = "";
  my $pc = 0;
  my $beginoflinepc = 0;
  my ($label, $command, $args) = ("", "", "" );

 LINE: while (1) {

    ($label, $command, $args) = ("", "", "" );
    # get a new line
    if( $macrobarfmode ) {
      $rawline = shift @macrotext;
      unless( defined $rawline ) {
	$macrobarfmode = 0;
	$rawline = <INF>;
	last LINE unless defined $rawline;
	$lineno++;
      }
    } else {
      $rawline = <INF>;
      last LINE unless defined $rawline;
      $lineno++;
    }

    #remove comments and special characters
    $rawline =~ s/#.*$//;
    $rawline =~ s/;.*$//;

    # if macro, do translations
    if( $macrobarfmode ) {
      foreach my $arg (keys %macro_transarg) {
	$rawline =~ s/$arg/$macro_transarg{$arg}/g;
      }
    }

    # if translate mode, do translations
    if( $translatemode ) {
      foreach my $arg (keys %transhash) {
	$rawline =~ s/$arg/$transhash{$arg}/g;
      }
    }



    # split it and keep zero length fields
    my @sptline = split(/[\s,()]+/, $rawline);

    # new line if this one is empty
    next LINE if ( $rawline =~ /^\s*$/ );

    # store label for later use - remove postcolon
    $label = uc shift @sptline;
    $label =~ s/:$//;
    die "$namei:$lineno: Label redefined at line $lineno" if (defined $labelhash{$label} );
    $labeldealtwith = 0;
    $beginoflinepc = $pc;

    # check for command
    $command = uc shift @sptline;
	if ($command eq "LW") {
		my @mysptline = @sptline;
		my $arga = uc shift @mysptline;
		my $argb = uc shift @mysptline;
		my $argc = uc shift @mysptline;
		my $tempargb = $argb;
		$tempargb =~ s/^.//;
		my $tempargc = $argc;
		$tempargc =~ s/^.//;
		print "$tempargc\n";
		print "\$$tempargc\n";
		
		if (defined $reghash{$tempargb}) {
			@sptline = ($arga,0,$argb);
		}
		elsif ((not defined $reghash{$tempargc}) and (not isnum($tempargc))) {
			@sptline = ($arga,$argb,"\$zero");
			
		}
	}
	elsif ($command eq "SW") {
		my @mysptline = @sptline;
		my $arga = uc shift @mysptline;
		my $argb = uc shift @mysptline;
		my $argc = uc shift @mysptline;		
		my $tempargb = $argb;
		$tempargb =~ s/^.//;
		my $tempargc = $argc;
		$tempargc =~ s/^.//;
		if (defined $reghash{$tempargb}) {
			@sptline = ($arga,0,$argb);
		}
		elsif ((not defined $reghash{$tempargc}) and (not isnum($tempargc))) {
			@sptline = ($arga,$argb,"\$zero");
		}
	}

    if( $command eq "" ) {
      # no command here, prevent from entering the last else{},
      # which is reserved for the unknown directive/command/macro.
    }
    elsif( defined $directivehash{$command} ) {
      # is a directive
    DIRECTIVE: {
	# "HARD" directives - affects assembly passes
	# note that parsing is skipped if in macroeatmode.
	# only looking for .MACRO and .ENDMACRO.
	if( $command eq ".MACRO" ) {
	  ( $macroeatmode ) && die "$namei:$lineno: Macro in macro at line $lineno";
	  $macroeatmode = 1;
	  $macroname = uc shift @sptline;
	  push( @{$macrohash{$macroname}}, "@sptline\n" );
	  next LINE;
	}
	if( $command eq ".ENDMACRO" ) {
	  ( $macroeatmode ) || die "$namei:$lineno: Not defining macro at line $lineno";
	  $macroeatmode = 0;
	  $macroname = "";
	  next LINE;
	}
	last DIRECTIVE if ( $macroeatmode );

	if( $command eq ".TRANSTAB" ) {
	  ( $transtabmode || $translatemode ) && die "$namei:$lineno: Already in translate phase at line $lineno";
	  %transhash = ();
	  $transtabmode = 1;
	  $translatemode = 0;
	  next LINE;
	}
	if( $command eq ".TRANSLATE" ) {
	  ( $transtabmode ) || die "$namei:$lineno: Should get to TRANSLATE from TRANSTAB at line $lineno";
	  $transtabmode = 0;
	  $translatemode = 1;
	  # print out a nice comment about translations
	  $args = "; __TR "; $command = "";
	  foreach my $key (keys %transhash ) {
	    $args .= "[$key->$transhash{$key}] ";
	  }
	  pass1write();
	  next LINE;
	}
	if( $command eq ".TRANSOFF" ) {
	  ( $transtabmode || $translatemode ) || die "$namei:$lineno: Not translating at line $lineno";
	  $transtabmode = 0;
	  $translatemode = 0;
	  next LINE;
	}
	if( $command eq ".TR" ) {
	  ( $transtabmode ) || die "$namei:$lineno: Not translating at line $lineno";
	  $transhash{$sptline[0]} = $sptline[1];
	  next LINE;
	}
	if( $command eq ".EQU" || $command eq "=" ) {
	  $labeldealtwith = 1;
	  my $value = shift @sptline;
	  die "$namei:$lineno: Bogus assignment at line $lineno" if (( $label eq "" ) || ( $value eq "" ));
	  $labelhash{$label} = getvalue($value, \%labelhash, $lineno);
	  next LINE;
	}
	if( $command eq ".END" ) {
	  last LINE;
	}
	# "SOFTER" directives - remains after this pass
	if( $command eq ".DC" ) {
	  # special case label on dc line
	  unless( $label eq "" ) {
	    $labelhash{$label}=todec($pc);
	    $labeldealtwith = 1;
	  }
	  my $i = 0;
	  while ( defined ( my $data = shift @sptline ) ) {
	    if ( $i++ % 4 == 3 ) {
	      pass1write();
	      $args = "";
	      $label = "";
	    }
	    $args .= " " . $data;
	    $pc++;
	  }
	  last DIRECTIVE;
	}
	if( $command eq ".ASCII" ) {
	  # special case label on ascii line
	  unless( $label eq "" ) {
	    $labelhash{$label}=todec($pc);
	    $labeldealtwith = 1;
	  }
	  my $rightpos = rindex $rawline,"\"";
	  my $leftpos = rindex $rawline,"\"",$rightpos-1;
	  my $asciistring = substr($rawline,$leftpos,$rightpos-$leftpos+1);
	  my $asciilength = length $asciistring;
	  $args = $asciistring;
	  pass1write();
	  $pc = $pc + int(($asciilength-2) / 4) + 1;
	  next LINE; 
# 	  last DIRECTIVE;
	}	
	if( $command eq ".ORG" ) {
	  # Set pc to absolute value in dec, hex or oct.
	  my $pcval = shift @sptline;
	  $pc = getvalue($pcval, \%labelhash, $lineno);
	  $args = " " . hex8($pc);
	  # special case label on org line
	  unless( $label eq "" ) {
	    $labelhash{$label}=todec($pc);
	    $labeldealtwith = 1;
	  }
	  last DIRECTIVE;
	}
	if( $command eq ".PAD" ) {
	  # pad with data
	  my $length = shift @sptline;
	  my $value  = shift @sptline;
	  die "$namei:$lineno: Missing args at line $lineno" unless defined $value and defined $length;
	  $args .= " $length $value";
	  $pc += getvalue($length, \%labelhash, $lineno) ;
	  last DIRECTIVE;
	}
	if( $command eq ".FILE" ) {
	  my $fname  = shift @sptline;
	  my $length = shift @sptline;
	  die "$namei:$lineno: Missing args at line $lineno" unless defined $fname and defined $length;
	  $fname =~ s/"//g; #"
	  $args .= " $fname $length";
	  $pc += getvalue($length, \%labelhash, $lineno) ;
	  last DIRECTIVE;
	}
      }
    }
    elsif( defined $macrohash{$command} ) {
      if( not $macroeatmode ) {
	# is a previously stored macro
	$macrobarfmode = 1;
	@macrotext = @{$macrohash{$command}};
	chomp( @macro_argtemplate = split( /\s/, shift @macrotext) );
	@macro_arguments = @sptline;
	# create argument translation table
	%macro_transarg = ();
	foreach my $arg (@macro_argtemplate) {
	  $macro_transarg{$arg} = shift @macro_arguments;
	}
	# print out a nice comment about how macro was instantiated
	$args = "; $command "; $command = "";
	foreach my $arg (keys %macro_transarg) {
	  $args .= " [$arg->$macro_transarg{$arg}]";
	}
	pass1write();
	# special case label on macro inst line
	unless( $label eq "" ) {
	  $labelhash{$label}=todec($pc);
	  $labeldealtwith = 1;
	}
	next LINE;
      }
    }
    elsif( defined (my $code = $instrhash{$command}) ) {
      # is a vanilla instruction, check the arguments
      if( not $macroeatmode ) {
	$args = "";
	my $i=0;
	while ( (my $subcode = substr( $code, $i++, 1)) ne " " ) {
	  ###
	  if ( $subcode =~ /^[STD]$/ ) {
	    die "$namei:$lineno: Missing arg at line $lineno" unless defined (my $arg = shift @sptline);
	    $arg = uc $arg;
	    die "$namei:$lineno: Typo arg at line $lineno" unless ((substr($arg,0,1) eq "\$") or (substr($arg,0,1) eq "R"));
	    # starts with a \$, r or R, remove it:
	    $arg =~ s/^.//;
	    my $outreg = "";
	    if( defined($reghash{$arg}) ) {
	      # was a special register name - translate
	      $outreg =  $reghash{$arg};
	    } else {
	      $arg = lc $arg ;
	      my $argdec = todec($arg);
	      die "$namei:$lineno: Bogus arg at line $lineno" if( $argdec<0 || $argdec>=32 );
	      # was ordinary number in hex,dec,oct
	      $outreg = $argdec;
	    }
	    $args .= " " . chr(36) . $outreg;
	  }
	  ###
	  elsif ( $subcode =~ /^[IBJH]$/ ) {
	    # Any immediate.  Label or numberic
	    die "$namei:$lineno: Missing arg at line $lineno" unless defined (my $arg = shift @sptline);
	    $arg = uc $arg unless isnum($arg);
	    $args .= " $arg";
	  }
	}
	$pc++;
      }
    } else {
      die "$namei:$lineno: Unknown command at line $lineno";
    }

    if( $macroeatmode ) {
      push( @{$macrohash{$macroname}}, $rawline );
      next LINE;
    }

    pass1write();

    if( not $labeldealtwith ) {
      $labeldealtwith = 0;
      $labelhash{$label}=todec($beginoflinepc) unless $label eq "";
    }
  }

  ($label, $command, $args ) = ("", ".END", "" );
  pass1write();


  print "-------------------------------------\n";
  foreach my $macro ( keys %macrohash ) {
    print "MACRO\t$macro\nargs:\t";
    print @{$macrohash{$macro}}, "\n\n";
  }
  print "-------------------------------------\n";
  foreach my $const ( sort keys %labelhash ) {
    print prettyp("$const",32), " = ", hex8($labelhash{$const})," = ";
    printf("%10d\n", $labelhash{$const});
  }


sub pass1write{
  print prettyp("$lineno",  6 ), prettyp("$label",  16 );
  print prettyp("$command", 8 ), prettyp("$args",   16 ), "\n";
}



}

#####################################################
# PASS 2 - convert to hexcode                       #
#####################################################
{
  close(INF); close(ULF);
  open( INF, "< $name1" ) or die "\n### Could not read back listling file!\n";
  open( UHF, "> $name2" ) || die "\n### Could not open bin file!\n\n";
  select UHF ;

  my $pc = 0;
  my $rawline;
  my $origline;

  while (<INF>) {
    my ($lineno, $command, $args ) = ( "", "", "" );
    # pre-process line
    chomp;
    my $origline = $_;
    s/;.*$//; # rm comments
    s/#.*$//;
    # inte så snyggt - labeln försvinner!!!
    s/^(......)\w+/$1/; # rm label
    s/[\t ,]+/ /g;   # rm multiple whitespace
    next if /^\s*$/;
    my @line = split;
    ( $lineno, $command, @line ) =  @line;
    next unless defined $command;

    if( defined $directivehash{$command} ) {
      if( $command eq ".ORG" ) {
	my $org = shift @line;
	my $filler = todec($org)-$pc;
	die "$namei:$lineno: ORGing to self or backwards $lineno" if( $filler<0 );
	print "\n", hex8($pc), "  /0x00000000 ", prettyp("$filler/",7), "; ",
	  prettyp($lineno,6), prettyp($command,6), " ", $org  if ($filler > 0 );
	$pc = todec($org);
      }
      ###
      elsif( $command eq ".PAD" ) {
	my $length = getvalue(shift @line, \%labelhash, $lineno) ;
	my $data   = getvalue(shift @line, \%labelhash, $lineno) ;
	print hex8($pc), "  ";
	print "/", hex8($data), " ", prettyp("$length/",7), "; ",
	  prettyp($lineno,6), prettyp($command,6), " ", prettyp($length,6), hex8($data);
	$pc += todec($length);
      }
      ###
      elsif( $command eq ".DC" ) {
	my $first = 1;
	while( defined( my $data = shift @line) ) {
	  print "\n" unless $first; $first = 0;
	  my $outdata = hex8( getvalue( $data, \%labelhash, $lineno ) );
	  print hex8($pc), "  $outdata";
	  $args .= " $outdata";
	  $pc++;
	}
	print "         ; ", prettyp($lineno, 6), prettyp($command,6), $args;
      }
      elsif( $command eq ".ASCII" ) {
	my $first = 1;
	
        my $rightpos = rindex $origline,"\"";
	my $leftpos = rindex $origline,"\"",$rightpos-1;
	my $asciistring = substr($origline,$leftpos+1,$rightpos-$leftpos-1);
	my $asciilength = length $asciistring;

	my $char = " ";
	
	my $data = $asciistring;
	my $i = 0;
	
	while (length $data > 0) {
		if ( $i % 4 == 0 ) {
			print "\n" unless $first; $first = 0;
			print hex8($pc);
			print "  0x";
			$pc++;
		}
		$i++;
		$char = substr($data,0,1);
		$data = substr($data,1,(length $data)-1);
		my $outdata = hex2no0x(ord($char));
		print $outdata;
		#my $ch1 = substr($char,0,1);
		#my $ch2 = substr($char,1,1);
		#my $ch3 = substr($char,2,1);
		#my $ch4 = substr($char,3,1);
		#my $outdata = hex8(ord($ch1)*256*256*256+ord($ch2)*256*256+ord($ch3)*256+ord($ch4));
		#$args .= $char;
	}
	if ($i % 4 == 0) {
	  print "\n";
	  my $outdata = hex8(0);
	  print hex8($pc), "  $outdata";
	  $pc++; 	
	}
	else {
	  $i = $i % 4;
	  while($i % 4 != 0) {
		print hex2no0x(0);
		$i++;	
	  }	
	}
	print "         ; ", prettyp($lineno, 6), prettyp($command,6), $args;
      }
      ###
      elsif( $command eq ".FILE" ) {
	print "\n", hex8($pc);
	my $fname  = shift @line;
	my $length = getvalue(shift @line, \%labelhash, $lineno);
	print " " x 21, "; ", prettyp($lineno, 6), prettyp($command,6), "$fname ", hex8($length);
	$pc += $length;
      }
      elsif( $command eq ".END" ) {
	last;
      }
    } else {
      # is instruction
      my $code = $instrhash{$command};
      my $pars = substr($code,0,4);
      my $base = substr($code,4,8);
      my $bin = hex($base);

      my $i=0;
      while( (my $subcode = substr($pars,$i,1)) ne " " ) {
	my $arg = shift @line;
	###
	if( $subcode =~ /^[STD]$/ ) {
	  $arg =~ s/^\$//;
	  $arg = todec($arg);
	  $bin |= $arg << ($stdhash{$subcode}) ;
	  $arg =~ s/^(.)$/0$1/;
	  $args .= " \$$arg";
	}
	###
	elsif( $subcode =~ /^[IJBH]$/ ) {
	  my $isrelbranch = 0;
	  $isrelbranch = 1 unless isnum( $arg );
	  $arg = getvalue( $arg, \%labelhash, $lineno );
	  $arg = ($arg - $pc - 1) if( $subcode eq "B" and  $isrelbranch);  # pc-relative if branch and label
	  # truncate according to IJBH, and generate warnings if appropriate
	WSWITCH: {
	    if( $subcode =~ /^[IB]$/ ) {
	      print STDERR "$namei:$lineno: # Integer arg exceeds 16 bits at line $lineno\n" if ( $arg<-32768 or $arg>65535 );
	      $arg &= 0xffff;
	      $args .= " " . hex4($arg);
	      last WSWITCH;
	    }
	    if( $subcode eq "J" ) {
	      print STDERR "$namei:$lineno: # Integer arg exceeds 26 bits at line $lineno\n" if ( $arg<0 or $arg>0x03ffffff );
	      $arg &= 0x03ffffff;
	      $args .= " " . hex8($arg);
	      last WSWITCH;
	    }
	    if( $subcode eq "H" ) {
	      print STDERR "$namei:$lineno: # SHAMT exceeds 5 bits at line $lineno\n" if ( $arg<0 or $arg>0x1f );
	      $arg = ($arg & 0x1f) << 6;
	      $args .= " " . hex2($arg);
	      last WSWITCH;
	    }
	  }
	  $bin |= $arg ;
	}
	$i++;
      }
      print hex8($pc), "  ", hex8($bin), "         ; ";
      print prettyp("$lineno",  6 ), prettyp("$command", 6 ), prettyp("$args",   16 );
      $pc++;
    }
    print "\n";
  }
} # end PASS 2



#####################################################
# PASS 3 - Conv to bin                              #
#####################################################
{
  close(INF) ; close(UHF);
  open( IHF, "< $name2" ) || die "\n### Could not open hex file!\n\n";
  open( UHF, "> $name3" ) || die "\n### Could not open bin file!\n\n";
  binmode( UHF ); #mjh: prevent nasty 0x0d insertion on winDos platform
  select UHF ;

  while(<IHF>) {
    next if /^\s*$/;
    s/^............//; # remove initial $pc count
    if( /\.FILE/ ){
      @_ = split /\s+/;
      my ($filename, $length) = ( $_[4], todec($_[5]) );
      open( TF, "<$filename" ) or die "\nCould not find incbin file $filename\n";
      binmode( TF );
      my $filecnt = 0;
      while( 1 ) {
	last if $filecnt >= 4*$length;
	my $cnt = read( TF, my $data, 1 );
	$data = pack("H2",0) if $cnt == 0;
	$filecnt++;
	print $data;
      }
      close TF;
    } elsif( /^\// ) {
      s/\///g; # rm slashes
      my ($data, $amount) = split ;
      $data =~ s/0[xX]//;
      for(my $i=0 ; $i<$amount ; $i++ ) {
	print pack("H8", $data);
      }
    } else {
      s/\s.*$//;  # rm everything after space
      s/0[xX]//;  # rm initial "0x"
      print pack("H8", $_);
    }
  }
  close(IHF); close(UHF);
} # end pass 3

exit 0;






sub todec{
  my $tmp = $_[0];
  $tmp = oct($tmp) if $tmp =~ /^0/;
  $tmp = ord(substr($tmp,1,1)) if $tmp =~ /^\'/;
  
  return $tmp;
}

sub isnum{
  my $tmp = $_[0];
  $tmp =~ s/\.[LH]$//; # strip for ending with .L or .H
  return 1 if $tmp =~ /^0[0-7]*$/;            # octal or zero
  return 1 if $tmp =~ /^[-]?[1-9][0-9]*$/;    # decimal - may be negative
  return 1 if $tmp =~ /^0x[A-Fa-f0-9]+$/;     # hex
  return 1 if $tmp =~ /^0b[0-1]+$/;           # bin
  return 1 if $tmp =~ /^0b[0-1]+$/;           # bin
  return 1 if $tmp =~ /^\'/;		      #ASCII
  return 0;
}

sub hex8{
  my $tmp = sprintf("%8x",$_[0]);
  $tmp =~ s/ /0/g;
  $tmp = "0x$tmp";
  return $tmp;
}

sub hex4{
  my $tmp = sprintf("%4x",$_[0]);
  $tmp =~ s/ /0/g;
  $tmp =~ s/.*(....)$/$1/; # save last 4 chars only (if number negative!)
  $tmp = "0x$tmp";
  return $tmp;
}

sub hex2{
  my $tmp = sprintf("%2x",$_[0]);
  $tmp =~ s/ /0/g;
  $tmp =~ s/.*(..)$/$1/; # save last 2 chars only (if number negative!)
  $tmp = "0x$tmp";
  return $tmp;
}

sub hex2no0x{
  my $tmp = sprintf("%2x",$_[0]);
  $tmp =~ s/ /0/g;
  $tmp =~ s/.*(..)$/$1/; # save last 2 chars only (if number negative!)
  $tmp = "$tmp";
  return $tmp;
}


sub prettyp{
  my ($string, $len) = @_;
  if( $len > length($string) ) {
    return $string . " " x ($len-length($string));
  } else {
    return $string . " ";
  }
}

sub evaluate{
	my ($data , $lineno) = @_;
	# Fredrik Begin
	$data =~ s/[\[]/(/g;	#turns [ to (
	$data =~ s/[\]]/)/g;	#turns ] to )
	my $tempdata = $data;	
	$tempdata =~ s/[()\+\-\*\/\^\~\|\&]/ /g; #removes not and or +-*/ xor not or and to replace labels with numbers
	my @temphash = split(/ /, $tempdata);	#split expression
		while ( defined ( my $label = shift @temphash ) ) {
 			if ($label eq "") {
 			}
 			elsif (isnum($label)) {
 			}
 			elsif (defined $labelhash{uc $label}) {
 				$data =~ s/$label/$labelhash{uc $label}/g;	# replace label with number
 			}
 			else {
 				die "$namei:$lineno: Label \"$label\" not defined at line $lineno";
 			};
		};
	$data = int(eval(lc $data)); #evaluates expression (does not check if expression is OK)
	  		 	     #it cannot handle ()
	return $data;		     # return value		
	# Fredrik End
}

sub getvalue{
  my ($val, $labelhashref, $lineno) = @_;
  # solve for .L/.H
  my $lohi = "0";
  $lohi = "L" if ( $val =~ /\.L$/ );
  $lohi = "H" if ( $val =~ /\.H$/ );
  # remove .L or .H if exists
  $val =~ s/\.[LH]$//;
  unless( isnum($val) ) {
    $val = evaluate ($val,$lineno);    
  }
  $val = todec($val);
  if ( $lohi eq "0" ) {
    # do nothing
  } elsif( $lohi eq "L" ) {
    $val &= 0xffff;
  } elsif( $lohi eq "H" ) {
    $val = ($val >> 16) & 0xffff;
  }
  return $val;
}

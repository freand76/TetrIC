## TetrIC makefile
## Map your working directory to X:
## Have a subdirectory Perlscript whwre merge.pl and abnasm.pl is stored

# Perl
	PERL = perl

# Compiler
	CC = lcc -Wo-lccdir=$(LCCPATH) -Wf-target=mips/irix -S

# Path to perl scripts (abnasm.pl, merge.pl)
	SCRIPTPATH = ../Perlscript

# Assembler
	AS = $(PERL) $(SCRIPTPATH)/abnasm.pl

# Filemerge
	MERGE = $(PERL) $(SCRIPTPATH)/merge.pl

# Delete
	RM = rm -f

# Serial Send
	SERIAL = serial

# Target filename (.s .1 .2 .bin)

	TARGET = TetrIC

# Assembler files written by user

	MACRO	=	../TLib/Macro.s

	STARTUP	=	Startup.s

	ORIGASM =	../TLib/Math.s	\
			../TLib/Joy.s \
			../TLib/Text.s \
			../TLib/Gfx.s \
			../TLib/Sound.s \
			Game.s \
			Intro.s \
			ViewHigh.s \
			Vector.s \
			FXMusic.s \
			ModeSwitch.s \
			EnterHigh.s \
			Stars.s \
			ScrollText.s \
			HighScoreList.s \
			Bars.s \
			BootLoad.s

# Assembler files created by lcc
	LCCASM =

 # Standard make (all)
all: $(TARGET).s $(TARGET).bin

# Make all and send file over serial port to bootloader
send:	all
	cp $(TARGET).bin $(TARGET).send
	echo SLUT >> $(TARGET).send
	$(SERIAL) -c 1 -f $(TARGET).send

# make clean removes .asm files from lcc and Target files
clean:
	$(RM) $(TARGET).* $(LCCASM)

# What to do with .c files
%asm : %c
	$(CC) $<

# What to do with .s files
%bin : %s
	$(AS) $<

# How to merge target file
$(TARGET).s :
	cat $(MACRO) $(STARTUP) $(LCCASM) $(ORIGASM) > $(TARGET).s

###### dependecies, add any dependencies you need here ###################
$(TARGET).s : $(STARTUP) $(LCCASM) $(ORIGASM)
$(TARGET).bin : $(TARGET).s

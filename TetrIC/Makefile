## TetrIC makefile
## Have a subdirectory Perlscript where abnasm.pl is stored

OBJDIR = .build
PERL = perl
SCRIPTPATH = $(PWD)/../Perlscript
AS = $(PERL) $(SCRIPTPATH)/abnasm.pl
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

 # Standard make (all)
all: $(OBJDIR) $(TARGET).s $(OBJDIR)/$(TARGET).bin $(OBJDIR)/$(TARGET).send

$(OBJDIR):
	mkdir -p $(OBJDIR)

# Make all and send file over serial port to bootloader
send:	all
	cp $(TARGET).bin $(TARGET).send
	echo SLUT >> $(TARGET).send
	$(SERIAL) -c 1 -f $(TARGET).send

# make clean removes .asm files from lcc and Target files
clean:
	rm -rf $(OBJDIR)

# What to do with .s files
$(OBJDIR)/$(TARGET).bin : $(TARGET).s
	$(AS) $^
	mv $(TARGET)* $(OBJDIR)/.

$(OBJDIR)/$(TARGET).send : $(OBJDIR)/$(TARGET).bin
	cp $< $@
	echo SLUT >> $@

# How to merge target file
$(TARGET).s : $(MACRO) $(STARTUP) $(ORIGASM)
	cat $^ > $@



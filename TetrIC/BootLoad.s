	.MACRO NOP10	; a nice little 10 nop macro
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	.ENDMACRO

BLOCK_STARTPOS = 125
BLOCK_TOP = 20

BootLoadStart:				; It all starts here
	nop
	nop

InitGfxBox:

	movi	$s1,1		; Wait before it is safe to write gfxbox
	mfc1	$s2,$s1
WaitSafe1:
	mfc1	$s3,$s1
	beq	$s2,$s3,WaitSafe1
	nop
	nop
	nop

	_LI	$gfx,GfxBase		; Initiate GfxPointer
	_LI	$s2, BOOTLOADER_LOGO	; Show address 0 and forward on screen
	movi	$s3, 1536	; RowLLength
	movi	$s4, 113	; Hsync length
	movi	$s5, 56		; Esync length
	movi	$s6, 654	; Vsync length
	movi	$s7, 850	; Leftpos
	movi	$s8, 15		; Pixwidth
	sw	$s2, GFX_SCRADDR($gfx)
	sw	$s3, GFX_ROWLENGTH($gfx)
	movi	$s2, 8		; 8 pixels wide
	movi	$s3, 20		; 20 Rows high
	movi	$s4, BLOCK_STARTPOS+BLOCK_TOP
	sw	$s4, GFX_HSYNC($gfx)
	sw	$s5, GFX_ESYNC($gfx)
	sw	$s6, GFX_VSYNC($gfx)
	sw	$s7, GFX_LEFTPOS($gfx)
	sw	$s8, GFX_PIXREAD($gfx)
	sw	$s2, GFX_WIDTH($gfx)
	sw	$s3, GFX_HEIGHT($gfx)
	sw	$s4, GFX_TOPPOS($gfx)


CopyToHighMem:
	_LI	$s1,BOOTLOADER_START	; This is where the bootloader is
	_LI	$s2,BOOTLOADER_ADDR	; This is where it goes
	movi	$s3,BOOTLOADER_SIZE	; This is the size
CopyToHighMem_Loop:
	lw	$s4,0($s1)		; Read word from memory
	addi	$s1,$s1,1			; Next read address
	nop
	nop
	nop
	sw	$s4,0($s2)		; Write word to high memory
	addi	$s2,$s2,1			; Next write address
	addi	$s3,$s3,-1		; Decrease word counter
	bnez	$s3,CopyToHighMem_Loop	; Are there any bytes left ?
	nop
	nop
	nop

	j	BOOTLOADER_ADDR		; Jump to high mem bootloader
	nop
	nop
	nop

BOOTLOADER_START:		; This is the start address of the bootloader

#GreenMem:
#	_LI	$s1,0x07e007e0	; A nice and clear green color

	_LI	$s4,BootLogo
	movi	$s2,0		; Start at address 0
	movi	$s3,160		; And 1024 words forward
Green_loop:
	lw	$s1,0($s4)
	addi	$s4,$s4,1
	nop
	nop
	nop
	nop
	nop
	sw	$s1,0($s2)	; Write nice grren color to mem
	addi	$s2,$s2,1		; Next address
	bne	$s2,$s3,Green_loop; And loop 'til we are done
	nop
	nop
	nop

	movi	$s1,1		; Wait before it is safe to write gfxbox
	mfc1	$s2,$s1
WaitSafe2:
	mfc1	$s3,$s1
	beq	$s2,$s3,WaitSafe2
	nop
	nop
	nop

	movi	$t0,1
	mfc1	$a0,$t0
	movi	$a1,BLOCK_STARTPOS
	movi	$a2,1
SetAddressPointer:
	movi	$s1,0		; $s1 = Startaddress for memfill
	_LI	$s2,0x534c5554	; $s2 = Word to end transmission (SLUT)
InitWord:
	movi	$s3,4		; $s3 = NofBytes
	clr	$s4		; $s4 = WordResult
InitByte:
	clr	$s5		; $s5 = ByteResult
	movi	$s6,9		; $s6 = Nofbits
WaitForStartBit:
	mfc2	$t0		; Read port
	movi	$t1,0x40	; Mask word
	and	$t0,$t0,$t1	; Mask out bit
	bnez	$t0,WaitForStartBit
	nop
	nop
	nop

	clr	$t2
	movi	$t0,1
	mfc1	$t1,$t0
	_BEQ	$t1,$a0,SameFrame
	addi	$t0,$a1,BLOCK_TOP
	mov	$a0,$t1
	mov	$t2,$a2
	sw	$t0,GFX_TOPPOS($gfx)
SameFrame:
	add	$a1,$a1,$t2
	andi	$t0,$a1,0xff
	slti	$t0,$t0,1
	sll	$t1,$t0,31
	sra	$t1,$t1,31
	xor	$a2,$a2,$t1
	add	$a2,$a2,$t0
	and	$t2,$a2,$t1
	add	$a1,$a1,$t2

# 115200 bps
# 24Mhz = 24000000 Hz
# 24000000 / 115200 = 208 clk / bit
# Wait for start bit
# while (not done)
#	Wait 1.5 bit time (312 clk)
#	for (k=1;k=9;k++)
#		Sample bit
#		Wait 1.0 bit time (208 clk)
#	end for
# end while


WaitHalfBit:	; 0.5 bittime wait = 104 clk = about 100 nops
	NOP10	; 10 nops
	NOP10	; 20 nops
	NOP10	; 30 nops
	NOP10	; 40 nops
	NOP10	; 50 nops
	NOP10	; 60 nops
	NOP10	; 70 nops
	NOP10	; 80 nops
	NOP10	; 90 nops
	NOP10	; 100 nops

WaitOneBit:	; 1 bittime wait = 208 clk = about 200 nops
	NOP10	; 10 nops
	NOP10	; 20 nops
	NOP10	; 30 nops
	NOP10	; 40 nops
	NOP10	; 50 nops
	NOP10	; 60 nops
	NOP10	; 70 nops
	NOP10	; 80 nops
	NOP10	; 90 nops
	NOP10	; 100 nops
	NOP10	; 110 nops
	NOP10	; 120 nops
	NOP10	; 130 nops
	NOP10	; 140 nops
	NOP10	; 150 nops
	NOP10	; 160 nops
	NOP10	; 170 nops
	NOP10	; 180 nops
	NOP10	; 190 nops
	NOP10	; 200 nops

Sample:
	mfc2	$t0			; Read port
	movi	$t1,0x40		; Write mask
	and	$t0,$t0,$t1		; Mask bit value
	sll	$t0,$t0,25		; LSB in high byte
	srl	$s5,$s5,1		; Shift byte result right
	or	$s5,$s5,$t0		; Or current bit value

	addi	$s6,$s6,-1		; Dec NofBits
	bnez	$s6,WaitOneBit		; Last Bit in Byte ?
	nop
	nop
	nop

	sll	$s5,$s5,1			; Skip stop bit
	srl	$s5,$s5,24		; Shift to low byte
	sll	$s4,$s4,8			; Shift word result left
	or	$s4,$s4,$s5		; Or current byte value

	addi	$s3,$s3,-1		; Dec NofBytes
	bnez	$s3,InitByte		; Last Byte in Word ?
	nop
	nop
	nop

	sw	$s4,0($s1)		; Store Word
	addi	$s1,$s1,1			; Add Address pointer
	bne	$s4,$s2,InitWord		; Last word in transmission ?
	nop
	nop
	nop

TurnOnGfx:
	movi	$s1,1			; Wait before it is safe to write gfxbox
	mfc1	$s2,$s1
WaitSafe3:
	mfc1	$s3,$s1
	beq	$s2,$s3,WaitSafe3
	nop
	nop
	nop

	movi	$s2, 3			; Reset Pixread
	movi	$s3, 320		; Reset Width
	movi	$s4, 256		; Reset Height
	sw	$s2, GFX_PIXREAD($gfx)
	sw	$s3, GFX_WIDTH($gfx)
	sw	$s4, GFX_HEIGHT($gfx)

JumpToZero:
	j	0			; Jump to address 0
	nop
	nop
	nop
	nop
	nop

BootLogo:	.dc	0x00010001,0x00010001,0x00010001,0x00010001
		.dc	0x00020002,0x00020002,0x00020002,0x00020002
		.dc	0x00030003,0x00030003,0x00030003,0x00030003
		.dc	0x00040004,0x00040004,0x00040004,0x00040004
		.dc	0x00080008,0x00080008,0x00080008,0x00080008
		.dc	0x000c000c,0x000c000c,0x000c000c,0x000c000c
		.dc	0x00100010,0x00100010,0x00100010,0x00100010
		.dc	0x00140014,0x00140014,0x00140014,0x00140014
		.dc	0x00180018,0x00180018,0x00180018,0x00180018
		.dc	0x001c001c,0x001c001c,0x001c001c,0x001c001c
		.dc	0x001e001e,0x001e001e,0x001e001e,0x001e001e
		.dc	0x001a001a,0x001a001a,0x001a001a,0x001a001a
		.dc	0x00160016,0x00160016,0x00160016,0x00160016
		.dc	0x00120012,0x00120012,0x00120012,0x00120012
		.dc	0x000e000e,0x000e000e,0x000e000e,0x000e000e
		.dc	0x000a000a,0x000a000a,0x000a000a,0x000a000a
		.dc	0x00060006,0x00060006,0x00060006,0x00060006
		.dc	0x00040004,0x00040004,0x00040004,0x00040004
		.dc	0x00020002,0x00020002,0x00020002,0x00020002
		.dc	0x00010001,0x00010001,0x00010001,0x00010001

BOOTLOADER_END:

MEMEND_ADDR = 0x40000
BOOTLOADER_SIZE = BOOTLOADER_END-BOOTLOADER_START
BOOTLOADER_ADDR = MEMEND_ADDR-BOOTLOADER_SIZE
BOOTLOADER_LOGO = BOOTLOADER_ADDR-BOOTLOADER_START+BootLogo

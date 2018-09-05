
################
# Memory usage #
################

RAM_START 	= 0x20000
RAM_END		= 0x3ffff
SCR_SIZE	= 320*256/2
BKG_SIZE	= 80*160/2
SCORE_SIZE	= 48*92/2
EMPTYMOD_SIZE	= 413

StackPointer	= RAM_END
ScreenLow    	= RAM_START			; 160kB
ScreenHigh   	= ScreenLow+SCR_SIZE		; 160kB
BoardBKG	= ScreenHigh+SCR_SIZE		; 25kB
NextPieceBKG	= BoardBKG+BKG_SIZE		; 8kB
StatBKG		= NextPieceBKG+SCORE_SIZE	; 8kB
ScoreBKG	= StatBKG+SCORE_SIZE		; 8kB
SilentMod	= ScoreBKG+SCORE_SIZE		; 1.6kB
TempMem		= SilentMod+EMPTYMOD_SIZE	; 512kB-160kB-160kB-25kB-3*8kb-1.6kB=141kB
SfxBase		= 0x400000
GfxBase	     	= 0x600000

######################
# Global Definitions #
######################

FADE_UP = 0
FADE_DOWN = 1

##############
# Code start #
##############

start:	
	nop
	nop	
	_LI	$sp,StackPointer		; Initiate StackPointer
	_LI	$gfx,GfxBase			; Initiate GfxPointer

	_LI	$a0,ScreenLow			; Setup Doublebuffer
	_LI	$a1,ScreenHigh	
	_JAL	SetupDoubleBuffer
	
	_JAL	Bars
	_BEQZ	$v0,NoBootLoad
	_J	BootLoadStart
NoBootLoad:
	_JAL	GetWorkScreen
	mov	$a0,$v0
	_JAL	ClearScreen
	
	_JAL	WaitNextFrame
	
	_JAL	GetWorkScreen
	mov	$a0,$v0
	_JAL	ClearScreen

	movi	$a0,25
	_JAL	WaitFrames

	_JAL	WaitNextFrameNoSwap		
	movi	$t0, 1536
	_SW	$t0, GFX_ROWLENGTH($gfx)
	movi	$t0, 113	
	_SW	$t0, GFX_HSYNC($gfx)
	movi	$t0, 56
	_SW	$t0, GFX_ESYNC($gfx)
	movi	$t0, 654
	_SW	$t0, GFX_VSYNC($gfx)
	movi	$t0, 30
	_SW	$t0, GFX_TOPPOS($gfx)
	movi	$t0, 250
	_SW	$t0, GFX_LEFTPOS($gfx)
	movi	$t0, 320
	_SW	$t0, GFX_WIDTH($gfx)
	movi	$t0, 4
	_SW	$t0, GFX_PIXREAD($gfx)

	_JAL	InitSound	
			
	_J	PreMain

Error:	_J	Error

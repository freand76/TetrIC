
Bars:	
	PUSH	$ra
	
	_JAL	WaitNextFrame
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
	movi	$t0, 128		; 8 pixels wide
	_SW	$t0, GFX_WIDTH($gfx)
	movi	$t0, 10	; Read data every 15 clk
	_SW	$t0, GFX_PIXREAD($gfx)

	_LI	$t0,JoyRepeatWait
	_LI	$t1,0x000000			; Filter = 0, RepeatVal = 0, Accelerate = 0
	nop
	nop
	sw	$t1,JOY_UP($t0)
	sw	$t1,JOY_LEFT($t0)
	sw	$t1,JOY_RIGHT($t0)
	sw	$t1,JOY_DOWN($t0)
	sw	$t1,JOY_BUTA($t0)
	sw	$t1,JOY_BUTB($t0)
	sw	$t1,JOY_BUTC($t0)
	sw	$t1,JOY_START($t0)

BarsLoop:
	_JAL	WaitNextFrameNoSwap
	_JAL	ClearBarsScreen
	_JAL	DrawBars
	_JAL	CheckJoystick
	
	mov	$t0,$v0
	clr	$v0
	movi	$t1,0xa0	; Left + ButC
	_BNE	$t0,$t1,BarsLoop_NoSpecial
	movi	$v0,1
BarsLoop_NoSpecial:
	andi	$t0,$t0,0xd2
	_BEQZ	$t0,BarsLoop
	
	POP	$ra
	_RTS
	
ClearBarsScreen:
	PUSH	$ra
	_JAL	GetActiveScreen
	mov	$t1,$v0
	movi	$t0,256
ClearBarsScreen_RowLoop:
	movi	$t2,8
ClearBarsScreen_ColLoop:
	sw	$zero,0($t1)
	sw	$zero,1($t1)
	sw	$zero,2($t1)
	sw	$zero,3($t1)
	sw	$zero,4($t1)
	sw	$zero,5($t1)
	sw	$zero,6($t1)
	sw	$zero,7($t1)
	addi	$t1,$t1,8
	addi	$t2,$t2,-1
	_BNEZ	$t2,ClearBarsScreen_ColLoop
	addi	$t0,$t0,-1
	_BNEZ	$t0,ClearBarsScreen_RowLoop
	POP	$ra
	_RTS
	
	
DrawBars:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s4
	PUSH	$s5
	PUSH	$s6
	PUSH	$s7
	
	_LI	$s0,BarList
	_LDA	$s1,BarAngle	
	addi	$s1,$s1,BAR_ANGLE_DELTA
	_STA	$s1,BarAngle

	_LI	$s0,BarZ
	movi	$s7,NOF_BARS
DrawBars_GetZ:
	mov	$a0,$s1
	_JAL	Sin
	_SW	$v0,0($s0)
	addi	$s1,$s1,ANGLE_BETWEEN_BAR
	addi	$s0,$s0,1
	addi	$s7,$s7,-1
	_BNEZ	$s7,DrawBars_GetZ
	
	lui	$s6,0x7fff
	movi	$s7,NOF_BARS	
DrawBars_Loop:
	clr	$t0
	_LDA	$t1,BarAngle
	mov	$t2,$s6
	_LI	$t3,BarZ
	clr	$s4
	clr	$s5
DrawBars_FindMin:
	_LW	$t9,0($t3)
	slt	$t8,$t9,$t2
	_BEQZ	$t8,DrawBars_NotSmaller
	mov	$t2,$t9 ; min in t2
	mov	$s4,$t0	; pos in s4
	mov	$s5,$t1 ; angle in s5
DrawBars_NotSmaller:
	addi	$t1,$t1,ANGLE_BETWEEN_BAR
	addi	$t3,$t3,1
	addi	$t0,$t0,1
	movi	$t9,NOF_BARS
	_BNE	$t0,$t9,DrawBars_FindMin

	movi	$t0,NOF_BARS/2
	_BNE	$t0,$s7,DrawBars_NotMiddle
	_JAL	DrawMiddleBar
DrawBars_NotMiddle:
	mov	$a0,$s5
	_JAL	Cos
	sra	$t0,$v0,10
	addi	$a1,$t0,128
	_LDO	$a0,BarList,$s4
	_STO	$s6,BarZ,$s4
	_JAL	DrawBar
	
	addi	$s7,$s7,-1
	_BNEZ	$s7,DrawBars_Loop

	POP	$s7
	POP	$s6
	POP	$s5
	POP	$s4
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS
	

DrawBar:
	PUSH	$ra
	_JAL	GetActiveScreen
	mov	$t0,$v0
	addi	$t1,$a1,-8
	sll	$t1,$t1,6
	add	$t0,$t0,$t1
	mov	$t1,$a0
	
	_LI	$t2,0b00100001000001000010000100000100
	and	$t2,$t2,$a0
	_LI	$t3,0b00001000010000010000100001000001
	and	$t3,$t3,$a0
	movi	$t9,16
DrawBar_Loop:
	_SW	$t2,0($t0)
	sw	$t2,1($t0)
	sw	$t2,2($t0)
	sw	$t2,3($t0)
	sw	$t2,4($t0)
	sw	$t2,5($t0)
	sw	$t2,6($t0)
	sw	$t2,7($t0)
	sw	$t2,8($t0)
	sw	$t2,9($t0)
	sw	$t2,10($t0)
	sw	$t2,11($t0)
	sw	$t2,12($t0)
	sw	$t2,13($t0)
	sw	$t2,14($t0)
	sw	$t2,15($t0)
	sw	$t2,16($t0)
	sw	$t2,17($t0)
	sw	$t2,18($t0)
	sw	$t2,19($t0)
	sw	$t2,20($t0)
	sw	$t2,21($t0)
	sw	$t2,22($t0)
	sw	$t2,23($t0)
	sw	$t2,24($t0)
	sw	$t2,25($t0)
	sw	$t2,26($t0)
	sw	$t2,27($t0)
	sw	$t2,28($t0)
	sw	$t2,29($t0)
	sw	$t2,30($t0)
	sw	$t2,31($t0)
	sw	$t2,32($t0)
	sw	$t2,33($t0)
	sw	$t2,34($t0)
	sw	$t2,35($t0)
	sw	$t2,36($t0)
	sw	$t2,37($t0)
	sw	$t2,38($t0)
	sw	$t2,39($t0)
	sw	$t2,40($t0)
	sw	$t2,41($t0)
	sw	$t2,42($t0)
	sw	$t2,43($t0)
	sw	$t2,44($t0)
	sw	$t2,45($t0)
	sw	$t2,46($t0)
	sw	$t2,47($t0)
	sw	$t2,48($t0)
	sw	$t2,49($t0)
	sw	$t2,50($t0)
	sw	$t2,51($t0)
	sw	$t2,52($t0)
	sw	$t2,53($t0)
	sw	$t2,54($t0)
	sw	$t2,55($t0)
	sw	$t2,56($t0)
	sw	$t2,57($t0)
	sw	$t2,58($t0)
	sw	$t2,59($t0)
	sw	$t2,60($t0)
	sw	$t2,61($t0)
	sw	$t2,62($t0)
	sw	$t2,63($t0)
	add	$t2,$t2,$t3
	addi	$t0,$t0,64
	addi	$t1,$t1,1
	addi	$t9,$t9,-1
	andi	$t8,$t9,7
	_BNEZ	$t8,DrawBar_Loop
	neg	$t3,$t3
	_BNEZ	$t9,DrawBar_Loop

	POP	$ra
	_RTS

DrawMiddleBar:
	PUSH	$ra
	_JAL	GetActiveScreen
	mov	$t0,$v0
	addi	$t0,$t0,112*64
	clr	$t2
	_LI	$t3,0b00001000010000010000100001000001
	movi	$t9,32
DrawMiddleBar_Loop:
	_SW	$t2,0($t0)
	sw	$t2,1($t0)
	sw	$t2,2($t0)
	sw	$t2,3($t0)
	sw	$t2,4($t0)
	sw	$t2,5($t0)
	sw	$t2,6($t0)
	sw	$t2,7($t0)
	sw	$t2,8($t0)
	sw	$t2,9($t0)
	sw	$t2,10($t0)
	sw	$t2,11($t0)
	sw	$t2,12($t0)
	sw	$t2,13($t0)
	sw	$t2,14($t0)
	sw	$t2,15($t0)
	sw	$t2,16($t0)
	sw	$t2,17($t0)
	sw	$t2,18($t0)
	sw	$t2,19($t0)
	sw	$t2,20($t0)
	sw	$t2,21($t0)
	sw	$t2,22($t0)
	sw	$t2,23($t0)
	sw	$t2,24($t0)
	sw	$t2,25($t0)
	sw	$t2,26($t0)
	sw	$t2,27($t0)
	sw	$t2,28($t0)
	sw	$t2,29($t0)
	sw	$t2,30($t0)
	sw	$t2,31($t0)
	sw	$t2,32($t0)
	sw	$t2,33($t0)
	sw	$t2,34($t0)
	sw	$t2,35($t0)
	sw	$t2,36($t0)
	sw	$t2,37($t0)
	sw	$t2,38($t0)
	sw	$t2,39($t0)
	sw	$t2,40($t0)
	sw	$t2,41($t0)
	sw	$t2,42($t0)
	sw	$t2,43($t0)
	sw	$t2,44($t0)
	sw	$t2,45($t0)
	sw	$t2,46($t0)
	sw	$t2,47($t0)
	sw	$t2,48($t0)
	sw	$t2,49($t0)
	sw	$t2,50($t0)
	sw	$t2,51($t0)
	sw	$t2,52($t0)
	sw	$t2,53($t0)
	sw	$t2,54($t0)
	sw	$t2,55($t0)
	sw	$t2,56($t0)
	sw	$t2,57($t0)
	sw	$t2,58($t0)
	sw	$t2,59($t0)
	sw	$t2,60($t0)
	sw	$t2,61($t0)
	sw	$t2,62($t0)
	sw	$t2,63($t0)
	
	add	$t2,$t2,$t3
	addi	$t0,$t0,64
	addi	$t1,$t1,2
	addi	$t9,$t9,-1
	andi	$t8,$t9,15
	_BNEZ	$t8,DrawMiddleBar_Loop
	neg	$t3,$t3
	_BNEZ	$t9,DrawMiddleBar_Loop
	POP	$ra
	_RTS

NOF_BARS = 7

BarList:	.dc	0xf800f800,0xffe0ffe0,0x07e007e0
		.dc	0x07ff07ff,0x001f001f,0xf81ff81f
		.dc	0x7fff7fff
		
BarZ:		.pad	NOF_BARS,0
	
BAR_ANGLE_DELTA = -0x100

ANGLE_BETWEEN_BAR = 0x10000/NOF_BARS

BarAngle:	.dc	0


#############
# M A C R O #
#############
	
	; load immidiate 32-bit integer
	.macro li @reg0,@Imm0
	lui	@reg0, @Imm0.H
	ori	@reg0, @reg0, @Imm0.L
	.endmacro
	
	; load immidiate 32-bit integer
	.macro _LI @reg0,@Imm0
	lui	@reg0, @Imm0.H
	ori	@reg0, @reg0, @Imm0.L
	.endmacro

	; pop register from stack
	.macro POP @reg0
	lw	@reg0, 0($sp)
	nop
	addi	$sp,$sp, 1   # post-increment
	.endmacro

	; pop register to stack
	.macro PUSH @reg0
	addi	$sp,$sp, -1   # pre-decrement
	nop
	sw	@reg0, 0($sp)
	.endmacro

	; safe branch
	.macro _B @Imm0
	b	@Imm0
	nop
	nop
	nop
	.endmacro

	; safe bne
	.macro _BNE @reg0,@reg1,@Imm0
	bne	@reg0,@reg1,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe bnez
	.macro _BNEZ @reg0,@Imm0
	bnez	@reg0,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe bgt
	.macro _BGT @reg0,@reg1,@Imm0
	bgt	@reg0,@reg1,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe bgtz
	.macro _BGTZ @reg0,@Imm0
	bgtz	@reg0,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe bge
	.macro _BGE @reg0,@reg1,@Imm0
	bge	@reg0,@reg1,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe bgez
	.macro _BGEZ @reg0,@Imm0
	bgez	@reg0,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe beq
	.macro _BEQ @reg0,@reg1,@Imm0
	beq	@reg0,@reg1,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe beqz
	.macro _BEQZ @reg0,@Imm0
	beqz	@reg0,@Imm0
	nop
	nop
	nop
	.endmacro

	; safe jump
	.macro _J @Imm0
	j	@Imm0
	nop
	.endmacro

	; safe jump and link
	.macro _JAL @Imm0
 	jal	@Imm0
	nop
	.endmacro

	; safe jump register
	.macro _JR @Reg0
	jr	@Reg0
	nop
	nop
	nop
	.endmacro

	; safe jump and link register
	.macro _JALR @Reg0,@Reg1
	jalr	@Reg0,@Reg1
	nop
	nop
	nop
	.endmacro

	; safe return from subroutine
	.macro _RTS
	jr	$ra
	nop
	nop
	nop
	.endmacro

	; safe load word instruction
	.macro _LW @reg0,@Imm0(@reg1)
	lw	@reg0,@Imm0(@reg1)
	nop
	.endmacro

	; safe store word instruction
	.macro _SW @reg0,@Imm0(@reg1)
	nop
	nop
	sw	@reg0,@Imm0(@reg1)
	.endmacro

	; load register from address
	.macro	_LDA @reg0,@Imm0
	lui	$at, @Imm0.H
	ori	$at, $at, @Imm0.L
	lw	@reg0,0($at)
	nop
	.endmacro
	
	; store register to address
	.macro	_STA @reg0,@Imm0
	lui	$at, @Imm0.H
	ori	$at, $at, @Imm0.L
	sw	@reg0,0($at)
	.endmacro

	; load register from address with offset from register
	.macro	_LDO @reg0,@Imm0,@reg1
	lui	$at, @Imm0.H
	ori	$at, $at, @Imm0.L
	add	$at,$at,@reg1
	lw	@reg0,0($at)
	nop
	.endmacro
	
	; store register to address with offset from register
	.macro	_STO @reg0,@Imm0,@reg1
	lui	$at, @Imm0.H
	ori	$at, $at, @Imm0.L
	add	$at,$at,@reg1
	sw	@reg0,0($at)
	.endmacro
		GAME_MUSIC = 0

BEAT_TARGETVOL = 32

StartMusic:
	; a0 - 0 = silent , 1 = music
	; a1 - MUSICINDEX

	_LI	$t0,0x77775555			; High volume for samples and lower for module
	_SW	$t0,SFX_MASTERVOL($sfx)

	; ModuleIndex
	movi	$t0,0
	_SW	$t0,SFX_SONGSTATUS($sfx)	; stop current song
	
	_LI	$t0,SilentMod
	_BEQZ	$a0,StartMusic_Silent

	_LDA	$t1,Music_State
	_BEQZ	$t1,StartMusic_Silent

	_LI	$t0,TetricMod			; game music
StartMusic_Silent:
	_SW	$t0,SFX_OFFSET($sfx)		; offset to song
	
	movi	$t0,SONG_LOOP|SONG_PLAY
	_SW	$t0,SFX_SONGSTATUS($sfx)	; start playing (even if silent)
	
	_RTS
	
FX_MENU_CHANGEROW = 0
FX_MENU_CHANGEVALUE = 1
FX_MENU_BUTTON = 2
FX_ENTERHIGH_MOVE = 3
FX_ENTERHIGH_BUTTON = 4
FX_GAME_CHANGELEVEL = 5
FX_GAME_DROP = 6
FX_GAME_QUAD = 7
FX_GAME_ROTATE = 8
FX_GAME_ROW = 9
FX_GAME_WARNING = 10
FX_GAMEOVER_LAUGH = 11

SampleList:	.dc	MenuChangeRow
		.dc	MenuChangeValue
		.dc	MenuButton
		.dc	MenuChangeValue
		.dc	EnterHighButton
		.dc	GameChangeLevel
		.dc	GameDrop
		.dc	GameQuad
		.dc	GameRotate
		.dc	GameRow
		.dc	GameWarning
		.dc	GameOverLaugh

BeatVolume:		.dc	0
BeatTargetVolume:	.dc	0

FX_State:	.dc	1
Music_State:	.dc	1

EnableFX:
	_STA	$a0,FX_State
	_RTS

EnableMusic:
	clr	$t0
	_STA	$a0,Music_State
	_BEQZ	$a0,EnableMusic_Off
	movi	$t0,BEAT_TARGETVOL
EnableMusic_Off:
	_STA	$t0,BeatTargetVolume
	_RTS

PlaySampleCh1:
	; play a sample 11.025kHz
	; a0 - sample index
	
	_LDA	$t0,FX_State
	_BEQZ	$t0,PlaySample_NoFX

	movi	$t5,11025			; sample frequency
	_LDO	$t0,SampleList,$a0
	_LW	$t1,0($t0)
	_LW	$t2,1($t0)
	_LW	$t3,2($t0)
	_LW	$t4,3($t0)
	_LW	$t6,4($t0)
	sw	$zero,SFX_FX0_END($sfx)
	sw	$zero,SFX_FX1_END($sfx)
	sw	$t3,SFX_FX0_LSTART($sfx)
	sw	$t3,SFX_FX1_LSTART($sfx)
	sw	$t4,SFX_FX0_LEND($sfx)
	sw	$t4,SFX_FX1_LEND($sfx)
	sw	$t5,SFX_FX0_FREQ($sfx)
	sw	$t5,SFX_FX1_FREQ($sfx)
	sw	$t1,SFX_FX0_START($sfx)
	sw	$t1,SFX_FX1_START($sfx)
	sw	$t2,SFX_FX0_END($sfx)
	sw	$t2,SFX_FX1_END($sfx)
	sw	$t6,SFX_FX0_VOL($sfx)
	sw	$t6,SFX_FX1_VOL($sfx)
	_RTS
		
PlaySampleCh2:
	; play a sample 11.025kHz
	; a0 - sample index

	_LDA	$t0,FX_State
	_BEQZ	$t0,PlaySample_NoFX

	movi	$t5,11025			; sample frequency
	_LDO	$t0,SampleList,$a0
	_LW	$t1,0($t0)
	_LW	$t2,1($t0)
	_LW	$t3,2($t0)
	_LW	$t4,3($t0)
	_LW	$t6,4($t0)
	sw	$zero,SFX_FX2_END($sfx)
	sw	$zero,SFX_FX3_END($sfx)
	sw	$t3,SFX_FX2_LSTART($sfx)
	sw	$t3,SFX_FX3_LSTART($sfx)
	sw	$t4,SFX_FX2_LEND($sfx)
	sw	$t4,SFX_FX3_LEND($sfx)
	sw	$t5,SFX_FX2_FREQ($sfx)
	sw	$t5,SFX_FX3_FREQ($sfx)
	sw	$t1,SFX_FX2_START($sfx)
	sw	$t1,SFX_FX3_START($sfx)
	sw	$t2,SFX_FX2_END($sfx)
	sw	$t2,SFX_FX3_END($sfx)
	sw	$t6,SFX_FX2_VOL($sfx)
	sw	$t6,SFX_FX3_VOL($sfx)
PlaySample_NoFX:
	_RTS


PlayBeat:
	; play the beat in FX channel 1
	PUSH	$ra
	_LDA	$t0,BeatTargetVolume
	_BNEZ	$t0,PlayBeat_NoBeat		; already playing
	
	movi	$a0,0				; silent during intro
	_JAL	StartMusic
	

	_LI	$t0,Beat
	_LW	$t1,0($t0)
	_LW	$t2,1($t0)
	_LW	$t3,2($t0)
	_LW	$t4,3($t0)
	movi	$t5,11025			; sample frequency
	sw	$zero,SFX_FX2_END($sfx)
	sw	$zero,SFX_FX3_END($sfx)
	sw	$t5,SFX_FX2_FREQ($sfx)
	sw	$t5,SFX_FX3_FREQ($sfx)
	sw	$t1,SFX_FX2_START($sfx)
	sw	$t1,SFX_FX3_START($sfx)
	sw	$t3,SFX_FX2_LSTART($sfx)
	sw	$t3,SFX_FX3_LSTART($sfx)
	sw	$t4,SFX_FX2_LEND($sfx)
	sw	$t4,SFX_FX3_LEND($sfx)
	sw	$t2,SFX_FX2_END($sfx)
	sw	$t2,SFX_FX3_END($sfx)
	sw	$zero,SFX_FX2_VOL($sfx)
	sw	$zero,SFX_FX3_VOL($sfx)
	_STA	$zero,BeatVolume
		
	clr	$t0
	_LDA	$t1,Music_State
	_BEQZ	$t1,PlayBeat_Silent
	movi	$t0,BEAT_TARGETVOL
PlayBeat_Silent:
	_STA	$t0,BeatTargetVolume
PlayBeat_NoBeat:
	POP	$ra
	_RTS

FadeBeat:
	PUSH	$ra
	_JAL	GetFrameCount
	sll	$t0,$v0,30
	_BNEZ	$t0,FadeBeat_DontFade
	
	_LDA	$t0,BeatVolume
	_LDA	$t1,BeatTargetVolume
	slt	$t2,$t0,$t1
	add	$t0,$t0,$t2
	slt	$t2,$t1,$t0
	sub	$t0,$t0,$t2
	_STA	$t0,BeatVolume
	sw	$t0,SFX_FX2_VOL($sfx)
	sw	$t0,SFX_FX3_VOL($sfx)
FadeBeat_DontFade:
	POP	$ra
	_RTS

StopBeat:
	_STA	$zero,BeatTargetVolume
	_RTS

StopAllSamples:
	sw	$zero,SFX_FX0_END($sfx)
	sw	$zero,SFX_FX1_END($sfx)
	sw	$zero,SFX_FX2_END($sfx)
	sw	$zero,SFX_FX3_END($sfx)
	_RTS
		
StopSample:
	; a0 - channel (0  or 1)
	_BNEZ	$a0,StopSample_ChannelTwo
StopSample_ChannelOne:
	sw	$zero,SFX_FX0_END($sfx)
	sw	$zero,SFX_FX1_END($sfx)
	_RTS
StopSample_ChannelTwo:
	sw	$zero,SFX_FX2_END($sfx)
	sw	$zero,SFX_FX3_END($sfx)
	_RTS

Beat:
	.dc	Beat_Data
	.dc	Beat_End
	.dc	Beat_Data
	.dc	Beat_End	
Beat_Data:	.file	Data/snd_beat.raw 8590
Beat_End:

MenuChangeRow:
	.dc	MenuChangeRow_Data
	.dc	MenuChangeRow_End
	.dc	0
	.dc	0
	.dc	16
	
MenuChangeRow_Data:	.file	Data/snd_menu_changerow.raw 227
MenuChangeRow_End:

MenuChangeValue:
	.dc	MenuChangeValue_Data
	.dc	MenuChangeValue_End
	.dc	0
	.dc	0
	.dc	32
	
MenuChangeValue_Data:	.file	Data/snd_menu_changevalue.raw 166
MenuChangeValue_End:

MenuButton:
	.dc	MenuButton_Data
	.dc	MenuButton_End
	.dc	0
	.dc	0
	.dc	64
	
MenuButton_Data:	.file	Data/snd_menu_button.raw 373
MenuButton_End:

EnterHighButton:
	.dc	EnterHighButton_Data
	.dc	EnterHighButton_End
	.dc	0
	.dc	0
	.dc	64
	
EnterHighButton_Data:	.file	Data/snd_enterhigh_button.raw 161
EnterHighButton_End:

GameChangeLevel:
	.dc	GameChangeLevel_Data
	.dc	GameChangeLevel_End
	.dc	0
	.dc	0
	.dc	64
	
GameChangeLevel_Data:	.file	Data/snd_game_changelevel.raw 1193
GameChangeLevel_End:

GameDrop:
	.dc	GameDrop_Data
	.dc	GameDrop_End
	.dc	0
	.dc	0
	.dc	20
	
GameDrop_Data:		.file	Data/snd_game_drop.raw 1346
GameDrop_End:

GameQuad:
	.dc	GameQuad_Data
	.dc	GameQuad_End
	.dc	0
	.dc	0
	.dc	64
	
GameQuad_Data:		.file	Data/snd_game_quad.raw 6292
GameQuad_End:

GameRotate:
	.dc	GameRotate_Data
	.dc	GameRotate_End
	.dc	0
	.dc	0
	.dc	40
	
GameRotate_Data:	.file	Data/snd_game_rotate.raw 589
GameRotate_End:

GameRow:
	.dc	GameRow_Data
	.dc	GameRow_End
	.dc	0
	.dc	0
	.dc	48
	
GameRow_Data:		.file	Data/snd_game_row.raw 2304
GameRow_End:

GameWarning:
	.dc	GameWarning_Data
	.dc	GameWarning_End
	.dc	0
	.dc	0
	.dc	64
	
GameWarning_Data:	.file	Data/snd_game_warning.raw 2424
GameWarning_End:

GameOverLaugh:
	.dc	GameOverLaugh_Data
	.dc	GameOverLaugh_End
	.dc	0
	.dc	0
	.dc	64
	
GameOverLaugh_Data:	.file	Data/snd_gameover_laugh.raw 11025
GameOverLaugh_End:

TetricMod:		.file	Data/mod_gamemusic.raw 49395################
# Game Control #
################

StartGame:
	PUSH	$ra
	_JAL	StopAllSamples
	
	movi	$a0,1				; game music or no music
	_JAL	StartMusic

	
	_JAL	GetStartLevel
	_LI	$t0,Level			
	_SW	$v0,0($t0)			; Store to Level
	
	_JAL	GetShowNextPiece
	_LI	$t0,ShowNextPiece
	_SW	$v0,0($t0)			; Store to ShowNextPiece	
	
	_JAL	GetStartHeight
	mov	$a0,$v0				; Get StartHeight
	_JAL	InitBoard			; Init Board

	_LI	$t0,JoyRepeatWait
	; LEFT, RIGHT , SOFTDROP , ROTATE
	_LI	$t1,0x000800	; Filter = 00, RepeatVal = 08, Accelerate = 0
	; DOWN
	_LI	$t2,0x05ff00	; Filter = 05, RepeatVal = ff, Accelerate = 0
	nop	
	sw	$t1,JOY_UP($t0)
	sw	$t1,JOY_LEFT($t0)
	sw	$t1,JOY_RIGHT($t0)
	sw	$t1,JOY_BUTA($t0)
	sw	$t1,JOY_BUTB($t0)
	sw	$t1,JOY_BUTC($t0)
	sw	$t1,JOY_START($t0)
	sw	$t2,JOY_DOWN($t0)
	
	_JAL	DrawGameBackground		; Draw background
	
	_LI	$t0,Score	
	_SW	$zero,0($t0)			; Clear Score
	_LI	$t0,LineCount
	_SW	$zero,0($t0)			; Clear number of lines
	_LI	$t0,GameOver
	_SW	$zero,0($t0)	
		
	movi	$a0,20				; Draw 20 Rows
	movi	$a1,0				; DeltaY = 0
	_JAL	DrawBoard			; Draw Playfield
	_JAL	GetRandomPiece			; Get First Piece	
	
	_LI	$t0,Stat			
	sw	$zero,0($t0)			; Clear Stat 
	sw	$zero,1($t0)			; Clear Stat
	sw	$zero,2($t0)			; Clear Stat
	sw	$zero,3($t0)			; Clear Stat
	sw	$zero,4($t0)			; Clear Stat
	sw	$zero,5($t0)			; Clear Stat
	sw	$zero,6($t0)			; Clear Stat
	
	_JAL	GetRandomPiece			; Get Next Piece	
	_JAL	DrawCurrentPiece		; Draw Current Piece
	_JAL	DrawNextPiece			; Draw Current Piece

StartGame_Loop:
	_JAL	TetrisFrame
	_BEQZ	$v0,StartGame_Loop

	movi	$a0,FX_GAMEOVER_LAUGH
	_JAL	PlaySampleCh1

	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	DrawBoard			; Draw Board
	_JAL	DrawCurrentPiece		; Draw Piece at new X,Y 
	_JAL	DrawNextPiece			; Draw NextPiece if cheat mode on 
	_JAL	DrawStat			; Draw Statistics
	_JAL	DrawScore			; Print Score, Lines, Level

	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	DrawBoard			; Draw Board
	_JAL	DrawCurrentPiece		; Draw Piece at new X,Y 
	_JAL	DrawNextPiece			; Draw NextPiece if cheat mode on 
	_JAL	DrawStat			; Draw Statistics
	_JAL	DrawScore			; Print Score, Lines, Level

	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	WaitGameNextFrame		; Wait for next frame

	movi	$a0,FX_GAMEOVER_LAUGH
	_JAL	PlaySampleCh2

	_JAL	PrintGameOver			; Print GameOver and wait for button
	_JAL	ScreenFadeOut			; Fadeout screen
	
	POP	$ra				
	_RTS	
	

GameOver_Txt:	.ascii	"G A M E  O V E R";

GAMEOVER_X = 160-128
GAMEOVER_Y = 120
	
PrintGameOver:
	PUSH	$ra
	PUSH	$s0
	
	_LI	$a0,GameOver_Txt
	movi	$a1,GAMEOVER_X
	movi	$a2,GAMEOVER_Y
	movi	$a3,0xffff
	_JAL	PrintLargeString
	_JAL	WaitNextFrame
	movi	$a0,50
	_JAL	WaitFrames
PrintGameOver_Loop:
	movi	$s0,50
PrintGameOver_InnerLoop:
	_JAL	WaitNextFrameNoSwap
	_JAL	CheckButton
	_BNEZ	$v0,PrintGameOver_Done
	addi	$s0,$s0,-1
	_BNEZ	$s0,PrintGameOver_InnerLoop
	_JAL	WaitNextFrame
	_J	PrintGameOver_Loop
	
PrintGameOver_Done:
	POP	$s0
	POP	$ra
	_RTS

GameOver:	.dc	0

TetrisFrame:
	PUSH	$ra
	_JAL	WaitGameNextFrame		; Wait for next frame
	_JAL	PieceFall			; Gravity on the TetrisBlock
	movi	$a0,20				; Draw 20 Rows
	movi	$a1,0				; DeltaY = 0
	_JAL	DrawBoard			; Draw Board
	_JAL	DrawCurrentPiece		; Draw Piece at new X,Y 
	_JAL	DrawNextPiece			; Draw NextPiece if cheat mode on 
	_JAL	DrawStat			; Draw Statistics
	_JAL	DrawScore			; Print Score, Lines, Level
	_JAL	CheckWarning			; If high play warning
	_JAL	GameJoystick			; Read JoyStick	
	_LI	$t0,GameOver
	_LW	$v0,0($t0)
	POP	$ra
	_RTS

WaitGameNextFrame:
	PUSH	$ra
	
	_JAL	WaitNextFrame
	_JAL	ShakeBoard
 
	POP	$ra
	_RTS
	
GameJoystick:
	PUSH	$ra				; Store to stack
	PUSH	$s0
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	_JAL	CheckJoystick
	mov	$s0,$v0
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameUp			; Check LSB
	_JAL 	SoftDrop			; Move Down
noGameUp:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noButA			; Check LSB
	_JAL	RotateCCW
noButA:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameDown			; Check LSB
	_JAL	HardDrop
noGameDown:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameRight			; Check LSB
	_JAL 	MoveRight			; MoveRight 
noGameRight:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameButB			; Check LSB
	_JAL	RotateCW
noGameButB:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameLeft			; Check LSB
	_JAL 	MoveLeft			; MoveLeft
noGameLeft:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameStart			; Check LSB
	; Start
noGameStart:
	andi	$t0,$s0,1			; LSB to t0
	srl	$s0,$s0,1			; Shift out LSB
	_BEQZ	$t0,noGameButC			; Check LSB
	_JAL	RotateCCW
noGameButC:
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$s0				; Get from stack
	POP	$ra	
	_RTS				; Return from subroutine

###################
# TetrIC Game Snd #
###################

WARNING_TIME = 100

WarningCount:	.dc	WARNING_TIME

CheckWarning:
	PUSH	$ra

	clr	$t0			; Default no piece
	_LI	$t1,Tetris_Board	; Get Board
	addi	$t1,$t1,13		; Not visible top roof

	movi	$t9,8			; Check the top 5 rows
CheckWarning_RowLoop:
	movi	$t8,10
CheckWarning_ColLoop:	
	_LW	$t2,0($t1)
	_BEQZ	$t2,CheckWarning_NotSet
	addi	$t0,$t0,1
CheckWarning_NotSet:
	addi	$t1,$t1,1
	addi	$t8,$t8,-1
	_BNEZ	$t8,CheckWarning_ColLoop
	addi	$t1,$t1,2	
	addi	$t9,$t9,-1
	_BNEZ	$t9,CheckWarning_RowLoop

	slti	$t1,$t0,10

	_BNEZ	$t1,CheckWarning_NoWarning	

	_LDA	$t0,WarningCount
	movi	$t1,WARNING_TIME
	_BNE	$t0,$t1,CheckWarning_NoSound
	
	movi	$a0,FX_GAME_WARNING
	_JAL	PlaySampleCh2

CheckWarning_NoSound:
	_LDA	$t0,WarningCount
	addi	$t0,$t0,-1
	_STA	$t0,WarningCount
	_BNEZ	$t0,CheckWarning_Exit
CheckWarning_NoWarning:	
	movi	$t0,WARNING_TIME
	_STA	$t0,WarningCount
CheckWarning_Exit:
	POP	$ra
	_RTS
	
	
###################
# TetrIC Game Gfx #
###################

DrawGameBackground:
	PUSH	$ra
	PUSH	$a0		; Function input
	PUSH	$a1		; Function input
	PUSH	$a2		; Function input
	_LI	$a0,TetrisPal	; Expand palette
	_LI	$a1,TempMem
	_JAL	ExpandPalette
	_LI	$a0,TetrisPic	; Draw background in first bufffer
	_JAL	GetWorkScreen
	mov	$a1,$v0
	_LI	$a2,TempMem
	_JAL	ExpandPicture
	_JAL	WaitGameNextFrame	; Swap Buffers
	_LI	$a0,TetrisPic	; Draw background in second bufffer
	_JAL	GetWorkScreen
	mov	$a1,$v0
	_LI	$a2,TempMem
	_JAL	ExpandPicture
	_LI	$a0,TempMem	; Shade palette (Make it darker)
	_JAL	ShadePalette
	_LI	$a0,TetrisPic	; Draw Board Background
	_LI	$a1,BoardBKG
	_LI	$a2,TempMem
	_JAL	ExpandBoardBkg

	_LI	$a0,TetrisPal	; Expand palette
	_LI	$a1,TempMem
	_JAL	ExpandPalette
	_LI	$a0,TempMem	; Grey palette (Make it darker)
	_JAL	GreyPalette

	_LI	$a0,TetrisPic	; Draw Board Background
	_LI	$a1,NextPieceBKG
	_LI	$a2,TempMem
	_JAL	ExpandNextPieceBkg
	_LI	$a1,StatBKG
	_JAL	ExpandStatBkg
	_LI	$a1,ScoreBKG
	_JAL	ExpandScoreBkg
	
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS
		
ExpandPalette:
	; Expands a 256*16 bits (512 byte) palette to 256*32 bits (Zero in high 16 bits)
	mov	$t0,$a0		; Packed palette pointer
	mov	$t1,$a1		; Expanded palette pointer
	movi	$t2,128		; Count
	moviu	$t3,0xffff	; Mask
ExpandPal_Loop:
	_LW	$t4,0($t0)	; Load 32 bits
	srl	$t5,$t4,16	; Mask 16 high bits
	_SW	$t5,0($t1)	; Store color
	addi	$t1,$t1,1	; Add 1 to expanded palette pointer
	and	$t4,$t4,$t3	; Mask 16 Low bits
	_SW	$t4,0($t1)	; Store color
	addi	$t1,$t1,1	; Add 1 to expanded palette pointer
	addi	$t0,$t0,1	; Add 1 to packed palette pointer
	addi	$t2,$t2,-1	; Count--
	_BNEZ	$t2,ExpandPal_Loop
	_RTS

ExpandPicture:
	; Fix Background from 8 bit palette colorto 16 bit color
	mov	$t0,$a0		; Pointer to Image
	mov	$t1,$a1		; Poiter to Screen
	mov	$t2,$a2		; Pointer to Palette
	movi	$t3,20480	; 20480 words = 320*256/4
ExpandPic_RowLoop:
	_LW	$t5,0($t0)	; Load word (4 bytes = 4 pixels)
	movi	$t4,2		; Byte counter
ExpandPic_ByteLoop:
	srl	$t6,$t5,24	; Get leftmost byte
	add	$t7,$t2,$t6	; Add to palette pointer
	_LW	$t8,0($t7)	; Get palette value
	sll	$t9,$t8,16	; Left pixel in word
	sll	$t5,$t5,8	; Shift out used byte
	srl	$t6,$t5,24	; Get leftmost byte
	add	$t7,$t2,$t6	; Add to palette pointer
	_LW	$t8,0($t7)	; Get palette value
	or	$t9,$t9,$t8	; Right pixel in word
	sll	$t5,$t5,8	; SHift out used byte
	_SW	$t9,0($t1)	; Store 2 pixels (2*16 bits)
	addi	$t1,$t1,1	; Add 1 to screen pointer
	addi	$t4,$t4,-1	; bytecount--
	_BNEZ	$t4,ExpandPic_ByteLoop
	addi	$t0,$t0,1	; Add 1 to image pointer
	addi	$t3,$t3,-1	; wordcount--
	_BNEZ	$t3,ExpandPic_RowLoop
	_RTS
	
ShadePalette:
	; Shades the 256 color palette to half the value for each color
	mov	$t0,$a0			; Palette pointer
	movi	$t1,256			; Color counter (256 colors)
	moviu	$t2,0b1111011111011110	; And Mask
ShadePal_Loop:
	_LW	$t3,0($t0)		; Get color value
	and	$t3,$t3,$t2		; And with mask (remove LSB for each color)
	srl	$t3,$t3,1		; Shift word 1 bit right (half the color values)
	_SW	$t3,0($t0)		; Store color value
	addi	$t0,$t0,1		; Add 1 to palette pointer
	addi	$t1,$t1,-1		; Color--
	_BNEZ	$t1,ShadePal_Loop	; Are we done ?
	_RTS

GreyPalette:
	; Shades the 256 color palette to half the value for each color
	mov	$t0,$a0			; Palette pointer
	movi	$t1,256			; Color counter (256 colors)
GreyPal_Loop:
	_LW	$t3,0($t0)		; Get color value
	sll	$t4,$t3,27
	srl	$t4,$t4,27
	sll	$t5,$t3,21
	srl	$t5,$t5,27
	sll	$t6,$t3,16
	srl	$t6,$t6,27
	add	$t4,$t4,$t5
	add	$t4,$t4,$t6
	srl	$t4,$t4,2
	sll	$t5,$t4,6
	or	$t4,$t4,$t5
	sll	$t5,$t5,5
	or	$t4,$t4,$t5
	_SW	$t4,0($t0)		; Store color value
	addi	$t0,$t0,1		; Add 1 to palette pointer
	addi	$t1,$t1,-1		; Color--
	_BNEZ	$t1,GreyPal_Loop	; Are we done ?
	_RTS
	
ExpandBoardBkg:
	; Fix Board Background from 8 bit palette colorto 16 bit color
	PUSH	$s0	; Row counter
	PUSH	$s1	; Col Counter
	PUSH	$s2	; Byte counter
	mov	$t0,$a0	; Pointer to Image
	mov	$t1,$a1	; Pointer to Screen
	mov	$t2,$a2 ; Pointer to palette
	movi	$t3,[BOARD_LEFT+8]
	srl	$t4,$t3,2	; / 4 for x pos (4 pixels / byte)
	add	$t0,$t0,$t4
	movi	$t3,[BOARD_TOP+8]
	sll	$t4,$t3,4	; * 16
	add	$t0,$t0,$t4
	sll	$t4,$t3,6	; * 64
	add	$t0,$t0,$t4     ; = * 80 (80 words / row)
	movi	$s0,160		; Row counter
Copy_To_BoardBKG_Loop	
	movi	$s1,20		; Col Counter
Copy_To_BoardBKG_RowLoop
	_LW	$t3,0($t0)	; Get word
	addi	$t0,$t0,1	; Add 1 to Image pointer
	movi	$s2,2		; Byte counter
Copy_To_BoardBKG_ByteLoop:
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	sll	$t7,$t6,16	; Left pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	or	$t7,$t7,$t6	; Right pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	_SW	$t7,0($t1)	; Store Pixel (2*16bits)
	addi	$t1,$t1,1	; Add 1 to Screen pointer
	addi	$s2,$s2,-1	; Byte--
	_BNEZ	$s2,Copy_To_BoardBKG_ByteLoop
	addi	$s1,$s1,-1	; Col --
	_BNEZ	$s1,Copy_To_BoardBKG_RowLoop
	addi	$t0,$t0,60	; Add rest of row
	addi	$s0,$s0,-1	; Row --
	_BNEZ	$s0,Copy_To_BoardBKG_Loop
 	POP	$s2
 	POP	$s1
 	POP	$s0
 	_RTS

ExpandNextPieceBkg:
	; Fix Board Background from 8 bit palette colorto 16 bit color
	PUSH	$s0	; Row counter
	PUSH	$s1	; Col Counter
	PUSH	$s2	; Byte counter
	mov	$t0,$a0	; Pointer to Image
	mov	$t1,$a1	; Pointer to Screen
	mov	$t2,$a2 ; Pointer to palette
	movi	$t3,NEXTPIECE_LEFT
	srl	$t4,$t3,2	; / 4 for x pos (4 pixels / byte)
	add	$t0,$t0,$t4
	movi	$t3,NEXTPIECE_TOP
	sll	$t4,$t3,4	; * 16
	add	$t0,$t0,$t4
	sll	$t4,$t3,6	; * 64
	add	$t0,$t0,$t4     ; = * 80 (80 words / row)
	movi	$s0,48		; Row counter
Copy_To_NPBKG_Loop	
	movi	$s1,23		; Col Counter
Copy_To_NPBKG_RowLoop
	_LW	$t3,0($t0)	; Get word
	addi	$t0,$t0,1	; Add 1 to Image pointer
	movi	$s2,2		; Byte counter
Copy_To_NPBKG_ByteLoop:
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	sll	$t7,$t6,16	; Left pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	or	$t7,$t7,$t6	; Right pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	_SW	$t7,0($t1)	; Store Pixel (2*16bits)
	addi	$t1,$t1,1	; Add 1 to Screen pointer
	addi	$s2,$s2,-1	; Byte--
	_BNEZ	$s2,Copy_To_NPBKG_ByteLoop
	addi	$s1,$s1,-1	; Col --
	_BNEZ	$s1,Copy_To_NPBKG_RowLoop
	addi	$t0,$t0,57	; Add rest of row
	addi	$s0,$s0,-1	; Row --
	_BNEZ	$s0,Copy_To_NPBKG_Loop
 	POP	$s2
 	POP	$s1
 	POP	$s0
 	_RTS

ExpandStatBkg:
	; Fix Board Background from 8 bit palette colorto 16 bit color
	PUSH	$s0	; Row counter
	PUSH	$s1	; Col Counter
	PUSH	$s2	; Byte counter
	mov	$t0,$a0	; Pointer to Image
	mov	$t1,$a1	; Pointer to Screen
	mov	$t2,$a2 ; Pointer to palette
	movi	$t3,STAT_LEFT
	srl	$t4,$t3,2	; / 4 for x pos (4 pixels / byte)
	add	$t0,$t0,$t4
	movi	$t3,STAT_TOP
	sll	$t4,$t3,4	; * 16
	add	$t0,$t0,$t4
	sll	$t4,$t3,6	; * 64
	add	$t0,$t0,$t4     ; = * 80 (80 words / row)
	movi	$s0,48		; Row counter
Copy_To_StatBKG_Loop	
	movi	$s1,23		; Col Counter
Copy_To_StatBKG_RowLoop
	_LW	$t3,0($t0)	; Get word
	addi	$t0,$t0,1	; Add 1 to Image pointer
	movi	$s2,2		; Byte counter
Copy_To_StatBKG_ByteLoop:
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	sll	$t7,$t6,16	; Left pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	or	$t7,$t7,$t6	; Right pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	_SW	$t7,0($t1)	; Store Pixel (2*16bits)
	addi	$t1,$t1,1	; Add 1 to Screen pointer
	addi	$s2,$s2,-1	; Byte--
	_BNEZ	$s2,Copy_To_StatBKG_ByteLoop
	addi	$s1,$s1,-1	; Col --
	_BNEZ	$s1,Copy_To_StatBKG_RowLoop
	addi	$t0,$t0,57	; Add rest of row
	addi	$s0,$s0,-1	; Row --
	_BNEZ	$s0,Copy_To_StatBKG_Loop
 	POP	$s2
 	POP	$s1
 	POP	$s0
 	_RTS

ExpandScoreBkg:
	; Fix Board Background from 8 bit palette colorto 16 bit color
	PUSH	$s0	; Row counter
	PUSH	$s1	; Col Counter
	PUSH	$s2	; Byte counter
	mov	$t0,$a0	; Pointer to Image
	mov	$t1,$a1	; Pointer to Screen
	mov	$t2,$a2 ; Pointer to palette
	movi	$t3,SCORE_LEFT
	srl	$t4,$t3,2	; / 4 for x pos (4 pixels / byte)
	add	$t0,$t0,$t4
	movi	$t3,SCORE_TOP
	sll	$t4,$t3,4	; * 16
	add	$t0,$t0,$t4
	sll	$t4,$t3,6	; * 64
	add	$t0,$t0,$t4     ; = * 80 (80 words / row)
	movi	$s0,48		; Row counter
Copy_To_ScoreBKG_Loop	
	movi	$s1,23		; Col Counter
Copy_To_ScoreBKG_RowLoop
	_LW	$t3,0($t0)	; Get word
	addi	$t0,$t0,1	; Add 1 to Image pointer
	movi	$s2,2		; Byte counter
Copy_To_ScoreBKG_ByteLoop:
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	sll	$t7,$t6,16	; Left pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	srl	$t4,$t3,24	; Get leftmost byte
	add	$t5,$t2,$t4	; Add to palette pointer
	_LW	$t6,0($t5)	; Get palette value
	or	$t7,$t7,$t6	; Right pixel in word
	sll	$t3,$t3,8	; Shift out used byte
	_SW	$t7,0($t1)	; Store Pixel (2*16bits)
	addi	$t1,$t1,1	; Add 1 to Screen pointer
	addi	$s2,$s2,-1	; Byte--
	_BNEZ	$s2,Copy_To_ScoreBKG_ByteLoop
	addi	$s1,$s1,-1	; Col --
	_BNEZ	$s1,Copy_To_ScoreBKG_RowLoop
	addi	$t0,$t0,57	; Add rest of row
	addi	$s0,$s0,-1	; Row --
	_BNEZ	$s0,Copy_To_ScoreBKG_Loop
 	POP	$s2
 	POP	$s1
 	POP	$s0
 	_RTS
 	
QuadGfx:
	PUSH	$ra
	PUSH	$a0	; Input to DrawBoard
	PUSH	$a1	; Input to DrawBoard, FixTopLines
	PUSH	$s0	; Delta accumulator
	PUSH	$s1	; Total accumulator
	PUSH	$s2	; Number of Lines
	_LI	$t0,RemoveRow_Array	; Get RemoveRow array
	_LW	$s2,3($t0)		; Get Top Row
	movi	$s0,0			; Start with zero delta
	movi	$s1,0			; Start with zero total
QuadGfx_Loop:
	_JAL	WaitGameNextFrame		; WaitGameNextFrame
	mov	$a0,$s1			; Set DeltaY
	_JAL	FixTopLines		; FixTopLines
	mov	$a0,$s2			; Set Number of Lines
	mov	$a1,$s1			; Set DeltaY
	_JAL 	DrawBoard		; DrawBoard
	addi	$s0,$s0,1		; Add one to delta 
	srl	$t0,$s0,2		; Half the speed (low gravity)
	add	$s1,$s1,$t0		; Add delta to total
	slti	$t0,$s1,32		; Is it above 32
	_BNEZ	$t0,QuadGfx_Loop	; If not, continue
	_JAL	WaitGameNextFrame		; WaitGameNextFrame
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS

FixTopLines:
	; a0 = Number of Lines to fix in top
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	_BEQZ	$a0,FixTopLine_NoTopLine
	_LI	$s0,BoardBKG
	_JAL	GetWorkScreen
	mov	$s1,$v0
	movi	$t0,[BOARD_LEFT+8]
	srl	$t0,$t0,1		; X / 2
	add	$s1,$s1,$t0		; add X offset
	movi	$t0,[BOARD_TOP+8]
	sll	$t1,$t0,7		; Y * 128
	add	$s1,$s1,$t1
	sll	$t1,$t0,5		; Y * 32
	add	$s1,$s1,$t1
	mov	$t9,$a0			; RowCount
FixTopLines_RowLoop:
	movi	$t8,10			; ColCount
FixTopLines_ColLoop:
	lw	$t0,0($s0)		; Load
	nop
	lw	$t1,1($s0)
	nop
	lw	$t2,2($s0)
	nop
	lw	$t3,3($s0)
	nop
	sw	$t0,0($s1)		; Store
	sw	$t1,1($s1)		
	sw	$t2,2($s1)		
	sw	$t3,3($s1)		
	addi	$s0,$s0,4		; Add BKG pointer
	addi	$s1,$s1,4		; Add Workscreen pointer
	addi	$t8,$t8,-1		; Dec ColCount
	_BNEZ	$t8,FixTopLines_ColLoop ; Col Count = 0 ? No, ColLoop
	addi	$s1,$s1,120		; Add rest of line
	addi	$t9,$t9,-1		; Dec RowCount
	_BNEZ	$t9,FixTopLines_RowLoop	; Row Count = 0 ? No, RowLoop
FixTopLine_NoTopLine:
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS				; Return from subroutine	
	
RemoveRowsGfx:
	; a0 = Number of Rows
	PUSH	$ra
	PUSH	$a0	; Input to DrawBoard & FadeRow
	PUSH	$a1	; Input to DrawBoard
	PUSH	$s0	; Array pointer
	PUSH	$s1	; Row counter
	PUSH	$s2	; Number of rows
	PUSH	$s3	; Fadeorder counter
	PUSH	$s4	; Done flag
	movi	$s3,1		; Set fadeorder counter (start fade with first row only)
	sll	$s3,$s3,3	; Multiply by 4 (4 frames between fadestart for one line to fade start for next)
	mov	$s2,$a0		; Number of rows
	sll	$s2,$s2,3	; Multiply by 4 (4 frames between fadestart for one line to fade start for next)
	
	movi	$a0,20		; Draw 20 Rows
	movi	$a1,0		; DeltaY = 0
	_JAL	DrawBoard	; Draw board
	
	_JAL	WaitGameNextFrame
	movi	$a0,20		; Draw 20 Rows
	movi	$a1,0		; DeltaY = 0
	_JAL	DrawBoard	; Draw board
	
RemoveRowsGfx_Loop:
	_JAL	WaitGameNextFrame
	_LI	$s0,RemoveRow_Array
	clr	$s1		; Clear row counter
	clr	$s4		; Clear done flags
RemoveRowsGfx_RowLoop:
	_LW	$a0,0($s0)	; Get row nbr to fade
	_JAL	FadeRow		; And do it
	or	$s4,$s4,$v0	; Are we done
	addi	$s0,$s0,1	; Next row
	addi	$s1,$s1,1	; Row = Row +1
	slt	$t0,$s3,$s2	; Fadeorder counter less than rows ?
	add	$s3,$s3,$t0	; If yes, then Add one
	srl	$t0,$s3,3	; Divide by 4 to get rownbr
	_BNE	$s1,$t0,RemoveRowsGfx_RowLoop	; Are we done
	_BNEZ	$s4,RemoveRowsGfx_Loop		; Are we done
	POP	$s4
	POP	$s3
	POP	$s2	
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS

FadeRow:
	; a0 = Row
	PUSH	$ra
	PUSH	$a0	; Input FadeDown
	PUSH	$a1	; Input Fade Down
	PUSH	$s0	; WorkScreen
	PUSH	$s1	; Board Bkg
	PUSH	$s2	; Done Flag
	PUSH	$s3	; Row Counter
	PUSH	$s4	; Col Counter
	_JAL	GetActiveScreen
	mov	$s0,$v0
	movi	$t0,[BOARD_LEFT+8]
	srl	$t1,$t0,1	; / 2
	add	$s0,$s0,$t1
	movi	$t0,[BOARD_TOP+8]
	sll	$t1,$t0,5	; * 32
	add	$s0,$s0,$t1
	sll	$t1,$t0,7	; * 128
	add	$s0,$s0,$t1
	mov	$t0,$a0
	sll	$t0,$t0,3	; * 8
	sll	$t1,$t0,5	; * 32
	add	$s0,$s0,$t1
	sll	$t1,$t0,7	; * 128
	add	$s0,$s0,$t1
	_LI	$s1,BoardBkg
	mov	$t0,$a0
	sll	$t0,$t0,3	; * 8
	sll	$t1,$t0,3	; * 8
	add	$s1,$s1,$t1
	sll	$t1,$t0,5	; * 32
	add	$s1,$s1,$t1
	clr	$s2
	movi	$s3,8
FadeRow_Rowloop:
	movi	$s4,40
FadeRow_ColLoop:
	_LW	$a0,0($s0)	; Source color
	_LW	$a1,0($s1)	; Destination color
	_JAL	FadeDown	; And Fade
	_SW	$v0,0($s0)
	or	$s2,$s2,$v1
	addi	$s0,$s0,1
	addi	$s1,$s1,1
	addi	$s4,$s4,-1
	_BNEZ	$s4,FadeRow_ColLoop
	addi	$s0,$s0,120
	addi	$s3,$s3,-1
	_BNEZ	$s3,FadeRow_RowLoop
	mov	$v0,$s2
	POP	$s4
	POP	$s3
	POP	$s2	
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS

BOARD_TOP = 40
BOARD_LEFT = 112

DrawBoard:
	; a0 = StopRow
	; a1 = DeltaY
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	mov	$s2,$a0			; Set number of rows	
	_LI	$s0,Tetris_Board
	movi	$a0,BOARD_LEFT
	addi	$a1,$a1,BOARD_TOP	; Add DeltaY to BoardTop
	addi	$s0,$s0,12		; Skip first row
	addi	$a0,$a0,8		; Begin x+8
	addi	$a1,$a1,8		; Begin y+8
DrawBoard_RowLoop:
	addi	$s0,$s0,1		; Skip first col
	movi	$s1,10			; Set number of cols
DrawBoard_ColLoop:
	_LW	$a2,0($s0)
	_BNEZ	$a2,DrawBoard_ColorBox
	_JAL	CopyBox
	_J	DrawBoard_TestDone
DrawBoard_ColorBox:	
	_JAL	DrawPieceBox		; DrawBox with texture
DrawBoard_TestDone:		
	addi	$s0,$s0,1		
	addi	$a0,$a0,8		; Add 8 to X
	addi	$s1,$s1,-1		; Decrease col counter
	_BNEZ	$s1,DrawBoard_ColLoop
	addi	$s0,$s0,1		; Skip last col
	addi	$a0,$a0,-80		; Sub 80 from X
	addi	$a1,$a1,8		; Add 8 to Y
	addi	$s2,$s2,-1		; Decrease row counter
	_BNEZ	$s2,DrawBoard_RowLoop
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS

NEXTPIECE_LEFT = 208
NEXTPIECE_TOP  = 48
NEXTPIECE_WIDTH = 92
NEXTPIECE_HEIGHT = 48

DrawNextPiece:
	PUSH	$ra			; Store to stack
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$a3
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4

	_JAL	GetWorkScreen
	mov	$t0,$v0
	addiu	$t0,$t0,NEXTPIECE_TOP*160+NEXTPIECE_LEFT/2
	_LI	$t1,NextPieceBKG
	movi	$t9,48
DrawNextPiece_Copy_Bkg_Row_Loop:
	movi	$t8,9
DrawNextPiece_Copy_Bkg_Col_Loop:
	
	_LW	$t2,0($t1)
	_LW	$t3,1($t1)
	_LW	$t4,2($t1)
	_LW	$t5,3($t1)
	_LW	$t6,4($t1)
	
	_SW	$t2,0($t0)
	_SW	$t3,1($t0)
	_SW	$t4,2($t0)
	_SW	$t5,3($t0)
	_SW	$t6,4($t0)

	addi	$t0,$t0,5
	addi	$t1,$t1,5
	addi	$t8,$t8,-1
	_BNEZ	$t8,DrawNextPiece_Copy_Bkg_Col_Loop
	addi	$t0,$t0,115
	addi	$t1,$t1,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,DrawNextPiece_Copy_Bkg_Row_Loop
	
	_LI	$a0,NextPiece_Txt
	movi	$a1,NEXTPIECE_LEFT+4
	movi	$a2,NEXTPIECE_TOP
	movi	$a3,0xffff
	_JAL	PrintString
	
	_LI	$t0,ShowNextPiece	
	_LW	$t1,0($t0)		; Should we show next piece ?
	_BEQZ	$t1,DontShowNextPiece	; No, then dont do it !
	_LI	$t0,NextPieceNumber	
	_LW	$t1,0($t0)		; Get Next piece number
	_LI	$t2,Piece_Array		
	add	$t2,$t2,$t1
	_LW	$s2,0($t2)		; And the corresponding piece data
	movi	$s0,0			; X = 0 
	movi	$s1,0			; Y = 0 
	_LW	$a2,PIECE_COLOR($s2)	; Color	
	_LW	$s3,PIECE_HORDIFF($s2)	; Hordiff
	_LW	$s4,PIECE_VERDIFF($s2)	; Verdiff
DrawNextPiece_Loop:
	_LW	$t0,0($s2)		; 
	_BEQZ	$t0,NextPiece_BitNotSet	; Is bit set ? No, BitNotSet
	mov	$a0,$s0			; a0 = X Count
	sll	$a0,$a0,3		; a0 = a0 * 8
	addi	$a0,$a0,NEXTPIECE_LEFT+29	; a0 = a0 + LeftPos+29
	add	$a0,$a0,$s3		; Horisontal slide for different pieces
	mov	$a1,$s1			; a1 = Y Count
	sll	$a1,$a1,3		; a1 = a1 * 8
	addi	$a1,$a1,NEXTPIECE_TOP+16;  a1 = a1 + TopPos + 16
	add	$a1,$a1,$s4		; Vertical slide for different pieces
	_JAL	DrawPieceBox		; DrawBox
NextPiece_BitNotSet:
	addi	$s2,$s2,1		; Piece Address++
	addi	$s0,$s0,1		; X = X + 1
	andi	$s0,$s0,0x0003		; X = X & 0x0003
	_BNEZ	$s0,DrawNextPiece_Loop	; X = 0 ? No, PieceLoop
	addi	$s1,$s1,1		; Y = Y + 1
	andi	$s1,$s1,0x0003		; Y = Y & 0x0003
	_BNEZ	$s1,DrawNextPiece_Loop	; Y = 0 ? No, PieceLoop 
DontShowNextPiece:		
	POP	$s4			; Get from stack
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a3
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS				; Return from subroutine


STAT_LEFT = 208
STAT_TOP  = 104
STAT_HEIGHT = 48
STAT_WIDTH = 92

DrawStat:
	PUSH	$ra			; Store to stack
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$a3
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s7

	_JAL	GetWorkScreen
	mov	$t0,$v0
	addiu	$t0,$t0,STAT_TOP*160+STAT_LEFT/2
	_LI	$t1,StatBKG
	movi	$t9,48
DrawStat_Copy_Bkg_Row_Loop:
	movi	$t8,9
DrawStat_Copy_Bkg_Col_Loop:
	
	_LW	$t2,0($t1)
	_LW	$t3,1($t1)
	_LW	$t4,2($t1)
	_LW	$t5,3($t1)
	_LW	$t6,4($t1)
	
	_SW	$t2,0($t0)
	_SW	$t3,1($t0)
	_SW	$t4,2($t0)
	_SW	$t5,3($t0)
	_SW	$t6,4($t0)

	addi	$t0,$t0,5
	addi	$t1,$t1,5
	addi	$t8,$t8,-1
	_BNEZ	$t8,DrawStat_Copy_Bkg_Col_Loop
	addi	$t0,$t0,115
	addi	$t1,$t1,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,DrawStat_Copy_Bkg_Row_Loop

	_LI	$a0,Statistics_Txt
	movi	$a1,STAT_LEFT+4
	movi	$a2,STAT_TOP
	movi	$a3,0xffff
	_JAL	PrintString

	movi	$t9,6
	_LI	$t0,Stat
	_LW	$s1,0($t0)
DrawStat_FindMax_Loop:
	addi	$t0,$t0,1
	addi	$t9,$t9,-1
	_LW	$t1,0($t0)
	slt	$t2,$t1,$s1
	_BNEZ	$t2,DrawStat_NoMax
	mov	$s1,$t1
DrawStat_NoMax:
	_BNEZ	$t9,DrawStat_FindMax_Loop

	_LI	$s0,Stat
	movi	$s2,4
	movi	$s7,7
DrawStat_Loop:
	_LW	$a0,0($s0)		; Current Count in $a0
	_LW	$a3,7($s0)		; Current Color in $a3
	_BEQZ	$a0,DrawStat_NoStat	; No bar if no pieces
	sll	$a0,$a0,5
	mov	$a1,$s1
	_JAL	Divu16
	_BEQZ	$v0,DrawStat_NoStat	; No bar if no pieces

	mov	$a0,$v0
	movi	$a1,STAT_LEFT
	add	$a1,$a1,$s2
	movi	$a2,STAT_TOP+STAT_HEIGHT
	_JAL 	DrawStatBar
		
DrawStat_NoStat:
	addi	$s0,$s0,1
	addi	$s2,$s2,12
	addi	$s7,$s7,-1
	_BNEZ	$s7,DrawStat_Loop
	
	POP	$s7			; Get from stack
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a3
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS				; Return from subroutine
	
DrawStatBar:
	PUSH	$ra
	
	_JAL	GetWorkScreen
	mov	$t1,$v0

	srl	$t2,$a1,1
	add	$t1,$t1,$t2

	sll	$t2,$a2,5	; * 32
	add	$t1,$t1,$t2
	sll	$t2,$a2,7	; * 128
	add	$t1,$t1,$t2
	
	sll	$t2,$a3,16
	srl	$t3,$t2,16
	or	$t8,$t3,$t2
	
	mov	$t9,$a0
DrawStatBar_Loop:
	_SW	$t8,0($t1)
	_SW	$t8,1($t1)
	_SW	$t8,2($t1)
	_SW	$t8,3($t1)

	addi	$t1,$t1,-160
	addi	$t9,$t9,-1
	_BNEZ	$t9,DrawStatBar_Loop
	
	POP	$ra
	_RTS

SCORE_LEFT = 208
SCORE_TOP  = 160
SCORE_WIDTH = 92
SCORE_TXTHEIGHT = 16

DrawScore:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$a3

	_JAL	GetWorkScreen
	mov	$t0,$v0
	addiu	$t0,$t0,SCORE_TOP*160+SCORE_LEFT/2
	_LI	$t1,ScoreBKG
	movi	$t9,48
DrawScore_Copy_Bkg_Row_Loop:
	movi	$t8,9
DrawScore_Copy_Bkg_Col_Loop:
	
	_LW	$t2,0($t1)
	_LW	$t3,1($t1)
	_LW	$t4,2($t1)
	_LW	$t5,3($t1)
	_LW	$t6,4($t1)
	
	_SW	$t2,0($t0)
	_SW	$t3,1($t0)
	_SW	$t4,2($t0)
	_SW	$t5,3($t0)
	_SW	$t6,4($t0)

	addi	$t0,$t0,5
	addi	$t1,$t1,5
	addi	$t8,$t8,-1
	_BNEZ	$t8,DrawScore_Copy_Bkg_Col_Loop
	addi	$t0,$t0,115
	addi	$t1,$t1,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,DrawScore_Copy_Bkg_Row_Loop

	_LI	$a0,Score_Txt
	movi	$a1,SCORE_LEFT
	movi	$a2,SCORE_TOP
	movi	$a3,0xffff
	_JAL	PrintString

	_LI	$t0,Score
	_LW	$a0,0($t0)
	movi	$a1,SCORE_LEFT+SCORE_WIDTH-4
	movi	$a2,SCORE_TOP
	movi	$a3,0xffff
	_JAL	PrintNumber16

	_LI	$a0,Lines_Txt
	movi	$a1,SCORE_LEFT
	movi	$a2,SCORE_TOP+SCORE_TXTHEIGHT
	movi	$a3,0xffff
	_JAL	PrintString
	
	_LI	$t0,LineCount
	_LW	$a0,0($t0)
	movi	$a1,SCORE_LEFT+SCORE_WIDTH-4
	movi	$a2,SCORE_TOP+SCORE_TXTHEIGHT
	movi	$a3,0xffff
	_JAL	PrintNumber16

	_LI	$a0,Level_Txt
	movi	$a1,SCORE_LEFT
	movi	$a2,SCORE_TOP+SCORE_TXTHEIGHT*2
	movi	$a3,0xffff
	_JAL	PrintString
	
	_LI	$t0,Level
	_LW	$a0,0($t0)
	movi	$a1,SCORE_LEFT+SCORE_WIDTH-4
	movi	$a2,SCORE_TOP+SCORE_TXTHEIGHT*2
	movi	$a3,0xffff
	_JAL	PrintNumber16
	POP	$a3
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS

DrawCurrentPiece:
	; a0 = X pos
	; a1 = Y Pos
	PUSH	$ra			; Store to stack
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	_LI	$t0,Piece_Pos
	_LW	$s0,0($t0)
	_LW	$s1,1($t0)
	_LI	$s2,Current_Piece	; Piece address
	movi	$s3,0			; X = 0 
	movi	$s4,0			; Y = 0 
PieceLoop:
	_LW	$t0,0($s2)		; 
	_BEQZ	$t0,BitNotSet		; Is bit set ? No, BitNotSet
	mov	$a0,$s3			; a0 = X Count
	add	$a0,$a0,$s0		; a0 = a0 + X pos
	sll	$a0,$a0,3		; a0 = a0 * 8
	addi	$a0,$a0,BOARD_LEFT	; a0 = a0 + LeftPos
	mov	$a1,$s4			; s1 = Y Count
	add	$a1,$a1,$s1		; s0 = s0 + Y pos
	sll	$a1,$a1,3		; s1 = s1 * 8
	addi	$a1,$a1,BOARD_TOP	; s0 = s0 + TopPos
	_LI	$t0,Current_Piece_Color
	_LW	$a2,0($t0)		; s2 = Color
	_JAL	DrawPieceBox		; DrawBox
BitNotSet:
	addi	$s2,$s2,1		; Piece Address++
	addi	$s3,$s3,1		; X = X + 1
	andi	$s3,$s3,0x0003		; X = X & 0x0003
	_BNEZ	$s3,PieceLoop 		; X = 0 ? No, PieceLoop
	addi	$s4,$s4,1		; Y = Y + 1
	andi	$s4,$s4,0x0003		; Y = Y & 0x0003
	_BNEZ	$s4,PieceLoop		; Y = 0 ? No, PieceLoop 	
	POP	$s4			; Get from stack
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS				; Return from subroutine

DrawBox:
	; a0 = x pos
	; a1 = y pos
	; a2 = color
	PUSH	$ra
	
	_JAL	GetWorkScreen
	mov	$t1,$v0
	srl	$t0,$a0,1		; X / 2
	add	$t1,$t1,$t0		; add X offset
	sll	$t3,$a2,16
	or	$t3,$t3,$a2
	sll	$t0,$a1,7		; Y * 128
	add	$t1,$t1,$t0
	sll	$t0,$a1,5		; Y * 32
	add	$t1,$t1,$t0
	movi	$t2,8			; RowCount = 8
DrawBox_Loop:
	sw	$t3,0($t1)		; Two pixels  X + 0 , X + 1 
	sw	$t3,1($t1)		; Two pixels  X + 2 , X + 3 
	sw	$t3,2($t1)		; Two pixels  X + 4 , X + 5 
	sw	$t3,3($t1)		; Two pixels  X + 6 , X + 7 
	addi	$t1,$t1,160		; Add one row
	addi	$t2,$t2,-1		; Dec RowCount
	_BNEZ	$t2,DrawBox_Loop	; Row Count = 0 ? No, BoxLoop
	
	POP	$ra
	_RTS				; Return from subroutine

CopyBox:
	; a0 = x pos
	; a1 = y pos
	; a2 = color
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	_LI	$t1,BoardBKG
	addi	$s0,$a0,-[BOARD_LEFT+8]
	addi	$s1,$a1,-[BOARD_TOP+8]
	srl	$t0,$s0,1		; X / 2
	add	$t1,$t1,$t0		; add X offset
	sll	$t0,$s1,5		; Y * 32
	add	$t1,$t1,$t0
	sll	$t0,$s1,3		; Y * 8
	add	$s0,$t1,$t0
	_JAL	GetWorkScreen
	mov	$t1,$v0
	srl	$t0,$a0,1		; X / 2
	add	$t1,$t1,$t0		; add X offset
	sll	$t0,$a1,7		; Y * 128
	add	$t1,$t1,$t0
	sll	$t0,$a1,5		; Y * 32
	add	$s1,$t1,$t0
	movi	$t9,8			; RowCount = 8
CopyBox_Loop:
	lw	$t0,0($s0)
	nop
	lw	$t1,1($s0)
	nop
	lw	$t2,2($s0)
	nop
	lw	$t3,3($s0)
	nop
	sw	$t0,0($s1)		; Two pixels  X + 0 , X + 1 
	sw	$t1,1($s1)		; Two pixels  X + 2 , X + 3 
	sw	$t2,2($s1)		; Two pixels  X + 4 , X + 5 
	sw	$t3,3($s1)		; Two pixels  X + 6 , X + 7 
	addi	$s0,$s0,40		
	addi	$s1,$s1,160		; Add one row
	addi	$t9,$t9,-1		; Dec RowCount
	_BNEZ	$t9,CopyBox_Loop	; Row Count = 0 ? No, BoxLoop
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS				; Return from subroutine

DrawPieceBox:
	; a0 = X pos
	; a1 = Y Pos
	; a2 = TextureData
	PUSH	$ra
	
	_JAL	GetWorkScreen
	mov	$t1,$v0
	srl	$t0,$a0,1		; X / 2
	add	$t1,$t1,$t0		; add X offset
	sll	$t0,$a1,7		; Y * 128
	add	$t1,$t1,$t0
	sll	$t0,$a1,5		; Y * 32
	add	$t6,$t1,$t0		; screenpointer in t6
	mov	$t7,$a2			; mappingpointer in t7
	movi	$t8,8			; RowCount = 8	
DrawPieceBox_Loop:
	lw	$t0,0($t7)
	nop
	lw	$t1,1($t7)
	nop
	lw	$t2,2($t7)
	nop
	lw	$t3,3($t7)
	nop
	sw	$t0,0($t6)		; Two pixels  X + 0 , X + 1 
	sw	$t1,1($t6)		; Two pixels  X + 2 , X + 3 
	sw	$t2,2($t6)		; Two pixels  X + 4 , X + 5 
	sw	$t3,3($t6)		; Two pixels  X + 6 , X + 7 
	addi	$t6,$t6,160		; Add one row
	addi	$t7,$t7,4		; Add one row
	addi	$t8,$t8,-1		; Dec RowCount
	_BNEZ	$t8,DrawPieceBox_Loop	; Row Count = 0 ? No, BoxLoop	
	
	POP	$ra
	_RTS				; Return from subroutine

ClearBox:
	; a0 - Start Address
	; a1 = BoxWidtht
	; a2 = ScreenWidth
	; a3 = BoxHeight
	mov	$t0,$a0
	mov	$t2,$a2
	sub	$t2,$t2,$a1
	mov	$t3,$a3
ClearBox_RowLoop:
	mov	$t1,$a1
ClearBox_ColLoop:
	sw	$zero,0($t0)
	addi	$t0,$t0,1
	addi	$t1,$t1,-1
	_BNEZ	$t1,ClearBox_ColLoop
	add	$t0,$t0,$t2
	addi	$t3,$t3,-1
	_BNEZ	$t3,ClearBox_RowLoop
	_RTS

####################
# TetrIC Functions #
####################
	
GetScore:
	_LI	$t0,Score
	_LW	$v0,0($t0)
	_RTS
	
GetLevel:
	_LI	$t0,Level
	_LW	$v0,0($t0)
	_RTS
	
InitBoard:
	; a0 = starthieght
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	
	_LI	$t0,Tetris_Board		; Get Board pointer
	addi	$t0,$t0,13			; Add top row and left col
	
	movi	$t1,20				; 20 rows to clear
ClearBoard_Loop:
	_SW	$zero,0($t0)
	_SW	$zero,1($t0)
	_SW	$zero,2($t0)
	_SW	$zero,3($t0)
	_SW	$zero,4($t0)
	_SW	$zero,5($t0)
	_SW	$zero,6($t0)
	_SW	$zero,7($t0)
	_SW	$zero,8($t0)
	_SW	$zero,9($t0)
	addi	$t0,$t0,12			; Next row
	addi	$t1,$t1,-1			; Row=Row-1
	_BNEZ	$t1,ClearBoard_Loop		; Are we done ?
	
	_BEQZ	$a0,InitBoard_Done		; Do we have a startheight ?
	mov	$s0,$a0

	_LI	$s2,Tetris_Board		; Get baord pointer
	addi	$s2,$s2,12*20+1			; And point at the bottom row
StartHeight_Loop:
	_JAL	Rnd				; Get random number
	mov	$a0,$v0				; Number of filled blocks in this row
	movi	$a1,6
	_JAL	Divu16
	mov	$s1,$v1
	addi	$s1,$s1,3			; s1 = Rnd(3,8)
RowFill_Loop:
	_JAL	Rnd				; Get random number
	mov	$a0,$v0				; Which block in row to be filled
	movi	$a1,10
	_JAL	Divu16
	mov	$s3,$v1				; s3 = Rnd(0,9)
	add	$s3,$s3,$s2			
	_LW	$t1,0($s3)			; Is this one set already ?
	_BNEZ	$t1,RowFill_Loop		; Yes, get new rnadom value

	_JAL	Rnd				; Get random number
	mov	$a0,$v0				; Which block to fill with
	movi	$a1,7
	_JAL	Divu16
	_LI	$t0,BlockPointer_Array		; Rnd(0,6)
	add	$t0,$t0,$v1
	_LW	$t1,0($t0)			; Get block pointer
	_SW	$t1,0($s3)			; Store in board
	
	addi	$s1,$s1,-1			; Fill=Fill-1
	_BNEZ	$s1,RowFill_Loop		; Are we done ?
	
	addi	$s2,$s2,-12			; One row up in board
	addi	$s0,$s0,-1			; Row=Row-1
	_BNEZ	$s0,StartHeight_Loop		; Are we done ?

InitBoard_Done:
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS
	
AddScore:
	_LI	$t0,Score			; Get Score
	_LW	$t1,0($t0)
	
	movi	$t4,20				

	_LI	$t2,Piece_Pos			; DropHeight Points (1 * DropHeight)
	_LW	$t3,1($t2)			; 
	sub	$t4,$t4,$t3

	_LI	$t2,Current_Piece_ScoreDiff
	_LW	$t3,0($t2)
	sub	$t4,$t4,$t3
	
	_LI	$t2,Level			; Level Points (3 * Level)
	_LW	$t3,0($t2)			; 1 * Level
	sll	$t2,$t3,1			; + 2 * Level 
	add	$t3,$t3,$t2			; = 3 * Level
	add	$t4,$t4,$t3
	
	_LI	$t2,ShowNextPiece
	_LW	$t3,0($t2)
	_BNEZ	$t3,CheatModeOn
	addi	$t4,$t4,5			; Cheat Mode OFF Points (5)
CheatModeOn:					; 
	add	$t1,$t1,$t4	
	_SW	$t1,0($t0)
	
	_RTS

CheckLevel:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	PUSH	$s1
	
	_LI	$t0,LineCount
	_LW	$t1,0($t0)
	
	_LI	$s0,Level
	_LW	$s1,0($s0)
	
	movi	$t0,9
	_BEQ	$t0,$s1,NoHigherLevel
	
	mov	$a0,$t1
	movi	$a1,10
	_JAL	Divu16		; _JAL Divu8
	
	_BGE	$s1,$v0,NoHigherLevel
	
	_BEQZ	$v1,NoHigherLevel
	
	addi	$s1,$s1,1
	_SW	$s1,0($s0)
	
	movi	$a0,FX_GAME_CHANGELEVEL
	_JAL	PlaySampleCh2

NoHigherLevel:
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS
	
	
RemoveFullRows:
	PUSH	$ra
	PUSH	$a0
	PUSH	$s0
	PUSH	$s1
	
	_LI	$s0,RemoveRow_Array
	
	clr	$s1
	
	movi	$a0,20
RowLoop:
	addi	$a0,$a0,-1
	_JAL	TestRow
	_BEQZ	$v0,NotThisRow
	
	_SW	$a0,0($s0)
	addi	$s0,$s0,1
	addi	$s1,$s1,1
NotThisRow:	
	_BNEZ	$a0,RowLoop
	
	_BEQZ	$s1,NoFullRows

	movi	$a0,FX_GAME_ROW
	_JAL	PlaySampleCh1

	mov	$a0,$s1
	_JAL	RemoveRowsGfx

	_LI	$t0,LineCount	; Add one line to linecount
	_LW	$t1,0($t0)
	add	$t1,$t1,$s1
	_SW	$t1,0($t0)

	movi	$t0,4
	_BNE	$t0,$s1,NoQuadEffect
	
	_JAL	TestWeight		; Test weight above quad
	_BEQZ	$v0,NoQuadEffect	; Zero ? Then ther is nothing to see
	mov	$s0,$v0			; Store weigt result
	_JAL	QuadGfx			; Drop slowly
	
	movi	$a0,FX_GAME_QUAD
	_JAL	PlaySampleCh1

	slti	$t0,$s0,8		; Less than eight in weight ?
	_BNEZ	$t0,NoQuadEffect	; Then dont shake
	_LI	$t0,ShakePointer	; And shake some
	_SW	$zero,0($t0)
NoQuadEffect:
	mov	$a0,$s1
	_JAL	RemoveRows	
	
NoFullRows:
	POP	$s1
	POP	$s0
	POP	$a0
	POP	$ra
	_RTS

TestWeight:
	clr	$v0			; Default Not Enough weight
	
	_LI	$t0,Tetris_Board	; Get Board
	addi	$t0,$t0,13		; Not visible top roof
	
	_LI	$t1,RemoveRow_Array
	_LW	$t9,3($t1)		; Last Row Number
	_BEQZ	$t9,TestWeight_NoWeight
TestWeight_RowLoop:
	movi	$t8,10
TestWeight_ColLoop:	
	_LW	$t1,0($t0)
	_BEQZ	$t1,TestWeight_NotSet
	addi	$v0,$v0,1
TestWeight_NotSet:
	addi	$t0,$t0,1
	addi	$t8,$t8,-1
	_BNEZ	$t8,TestWeight_ColLoop
	addi	$t0,$t0,2	
	addi	$t9,$t9,-1
	_BNEZ	$t9,TestWeight_RowLoop
TestWeight_NoWeight:	
	_RTS
	
ShakeBoard:
	_LI	$t0,ShakeSin
	_LI	$t1,ShakePointer
	_LW	$t2,0($t1)
	slti	$t3,$t2,63
	add	$t2,$t2,$t3
	_SW	$t2,0($t1)
	add	$t0,$t0,$t2
	_LW	$t1,0($t0)
	addi	$t1,$t1,30
	_SW	$t1,GFX_TOPPOS($gfx)
	_RTS
	
TestRow:
	movi	$v0,0			; Default not full

	_LI	$t0,Tetris_Board	; Get Board
	addi	$t0,$t0,12		; Not visible top roof
	sll	$t1,$a0,3		; Row * 12
	add	$t0,$t0,$t1		;
	sll	$t1,$a0,2		;
	add	$t0,$t0,$t1		;
	addi	$t0,$t0,1		; Not first col
	
	movi	$t1,10			; Check next 10 
TestRowLoop:
	_LW	$t2,0($t0)		; What is this ?
	_BEQZ	$t2,TestRowExit		; Zero ? Not full
	
	addi	$t0,$t0,1		; Next
	addi	$t1,$t1,-1		; And less to go
	
	_BNEZ	$t1,TestRowLoop		; Are we done ?
	
	movi	$v0,1			; Return 1 for full
	
TestRowExit:
	_RTS

RemoveRows:
	; a0 = number of rows to disappear
	_LI	$t0,RemoveRow_Array
	clr	$t9
RemoveRows_RowLoop:
	_LW	$t2,0($t0)		; Get First Row to dissapear
	add	$t2,$t2,$t9		; Subtract already removed rows
RemoveRows_CopyLoop:
	_LI	$t1,Tetris_Board	; Get board
	addi	$t1,$t1,13		; Not first row
	addi	$t2,$t2,-1		; Row - 1
	sll	$t3,$t2,3		; Row * 8
	add	$t1,$t1,$t3
	sll	$t3,$t2,2		; Row * 4
	add	$t1,$t1,$t3		; = Row * 12

	movi	$t8,10			; 10 pieces
RemoveRows_LineLoop:
	_LW	$t3,0($t1)		; Copy from the row above
	_SW	$t3,12($t1)		; And store on this row
	addi	$t1,$t1,1		; Next piece
	addi	$t8,$t8,-1		; One less to go
	_BNEZ	$t8,RemoveRows_LineLoop	; Are we done with this line
	_BNEZ	$t2,RemoveRows_CopyLoop ; Are we done with this Block ?

	_LI	$t1,Tetris_Board	; Get Board
	addi	$t1,$t1,13		; Not first row
	movi	$t8,10			; 10 pieces
RemoveRows_TopLoop:
	sw	$zero,0($t1)		; Store zeros in the top row
	addi	$t1,$t1,1		; Next piece
	addi	$t8,$t8,-1		; one less to go
	_BNEZ	$t8,RemoveRows_TopLoop	; Are we done with the top line 

	addi	$t0,$t0,1			; Next Rows to delete
	addi	$t9,$t9,1			; Rows + 1
	_BNE	$t9,$a0,RemoveRows_RowLoop	; Are we done with all rows

RemoveRows_Done:
	_RTS
	
SetFallSpeed:
	_LI	$t0,Level_FallSpeed_Array
	_LI	$t1,Level
	_LW	$t2,0($t1)
	add	$t0,$t0,$t2
	_LW	$t1,0($t0)
	_LI	$t0,FallSpeed
	_SW	$t1,0($t0)
	_RTS

PieceFall:
	PUSH	$ra
	PUSH	$s0
	
	_LI	$s0,FallSpeed
	_LW	$t0,0($s0)
	addi	$t0,$t0,-1
	_SW	$t0,0($s0)
	_BNEZ	$t0,PieceFallExit
	_JAL	SetFallSpeed
	
	_JAL	DropOne
	_BNEZ	$v0,PieceFallExit

	_JAL	AddScore
	_JAL	PutDownPiece

PieceFallExit:
	POP	$s0
	POP	$ra
	
	_RTS
	
DropOne:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$s0
	
	_LI	$s0,Piece_Pos	
	_LW	$a1,0($s0)
	_LW	$a2,1($s0)
	addi	$a2,$a2,1
	_SW	$a2,1($s0)
	
	_LI	$a0,Current_Piece
	_JAL	TestPiece
	_BNEZ	$v0,DropExit
	addi	$a2,$a2,-1
	_SW	$a2,1($s0)

DropExit:
	POP	$s0
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS				; Return from subroutine
	
PutDownPiece:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	
	_LI	$s0,Piece_Pos
	_LW	$t0,0($s0)
	_LW	$t1,1($s0)

	_LI	$s0,Current_Piece
	
	_LI	$s1,Tetris_Board
	add	$s1,$s1,$t0
	sll	$t2,$t1,3
	add	$s1,$s1,$t2
	sll	$t2,$t1,2
	add	$s1,$s1,$t2

	_LI	$t0,Current_Piece_color	;Get Current Piece Color
	_LW	$t1,0($t0)
	
	movi	$s2,4
PutDown_OuterLoop:
	movi	$s3,4
PutDown_InnerLoop:
	_LW	$t0,0($s0)
	_BEQZ	$t0,PutDown_BitNotSet
	_SW	$t1,0($s1)
PutDown_BitNotSet:
	addi	$s0,$s0,1
	addi	$s1,$s1,1
	
	addi	$s3,$s3,-1
	_BNEZ	$s3,PutDown_InnerLoop
	
	addi	$s1,$s1,8
	
	addi	$s2,$s2,-1
	_BNEZ	$s2,PutDown_OuterLoop

	_JAL	RemoveFullRows
	_JAL	CheckLevel

	_JAL	GetRandomPiece
	_BNEZ	$v0,PutDownExit
	
	_LI	$t0,GameOver
	movi	$t1,1
	_SW	$t1,0($t0)
PutDownExit:
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	
	_RTS				; Return from subroutine


TestPiece:
	; a0 = TestPiece
	; a1 = Test X Pos
	; a2 = Test Y Pos
	; v0 = 0 if Fail, 1 if OK
		
	movi	$v0,0
	mov	$t0,$a0
	
	_LI	$t1,Tetris_Board
	add	$t1,$t1,$a1
	sll	$t2,$a2,3
	add	$t1,$t1,$t2
	sll	$t2,$a2,2
	add	$t1,$t1,$t2
	
	movi	$t2,4
Test_OuterLoop:
	movi	$t3,4
Test_InnerLoop:
	_LW	$t6,0($t0)
	_LW	$t5,0($t1)
	_BEQZ	$t5,Test_BitNotSet

	_BNEZ	$t6,Test_Exit

Test_BitNotSet:
	addi	$t0,$t0,1
	addi	$t1,$t1,1
	
	addi	$t3,$t3,-1
	_BNEZ	$t3,Test_InnerLoop
	
	addi	$t1,$t1,8
	
	addi	$t2,$t2,-1
	_BNEZ	$t2,Test_OuterLoop
	movi	$v0,1
	
Test_Exit:
	_RTS				; Return from subroutine
	
GetRandomPiece:
	PUSH	$ra			; Store to stack
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	PUSH	$s1
	
	_JAL	SetFallSpeed		; Initiate fallspeed

	_JAL	Rnd			; Get Random number
	mov	$a0,$v0			; Next Piece
	movi	$a1,7
	_JAL	Divu16			; Rnd(0,6)

	# Debug
	# movi	$v1,1 ; Only red ones
	
	_LI	$t0,NextPieceNumber		
	_LW	$t1,0($t0)		; Get ThisPieceNumber
	_SW	$v1,0($t0)		; Store NextPieceNumber

	_LI	$t2,Stat
	add	$t2,$t2,$t1		; Get current piece
	_LW	$t3,0($t2)	
	addi	$t3,$t3,1		; Add 1 to the current piece count
	_SW	$t3,0($t2)	
	
	_LI	$s0,Piece_Array		; Piece Array address
	add	$s0,$s0,$t1		
	_LW	$a0,0($s0)		; Get Piece pointer
	_LI	$a1,Current_Piece	; Current Pice address Destination Piece 
	_JAL	CopyPiece		; Copy Piece t0,t1,t2,t3 

	_LI	$t1,Current_Piece_Size		; Calc Piece start pos X
	_LW	$t0,0($t1)			; Get Piece width
	srl	$t0,$t0,1			; (Width / 2)
	neg	$t0,$t0				; - (Width / 2)
	addi	$t0,$t0,5			; 5 - (Width / 2)
	addi	$t0,$t0,1			; 1 + 5 - (Width / 2)
	_LI	$t2,Current_Piece_StartDiff	; Calc Piece start pos Y
	_LW	$t1,0($t2)			; Get Piece startheight
	_LI	$s0,Piece_Pos			; Write to piece position
	_SW	$t0,0($s0)			
	_SW	$t1,1($s0)
	
	_LI	$a0,Current_Piece	; Current Piece address Destination Piece 	
	mov	$a1,$t0
	mov	$a2,$t1
	_JAL	TestPiece
	
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	
	_RTS				; Return from subroutine
	
CopyPiece:
	; a0 = Source Piece
	; a1 = Destination Piece
	
	PUSH 	$a0
	PUSH 	$a1
	PUSH	$s0
	PUSH	$s1
	
	movi	$s0,PIECE_SIZETOTAL	; Copy the size of a Piece struct
CopyLoop:
	_LW	$s1,0($a0)		; Load from source
	addi	$a0,$a0,1		; Inc source adddress
	_SW	$s1,0($a1) 		; Store to destination
	addi	$a1,$a1,1		; Inc destination address
	
	addi	$s0,$s0,-1		; Dec words to copy
	_BNEZ	$s0,CopyLoop		; Finished ? CopyLoop
	
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	
	_RTS				; Return from subroutine

SoftDrop:
	PUSH	$ra
	_JAL	SetFallSpeed
	
	_JAL	DropOne			; Gravity on the TetrisBlock
	_BNEZ	$v0,SoftDropExit
	_JAL	AddScore
	_JAL	PutDownPiece
SoftDropExit:
	POP	$ra
	_RTS				; Return from subroutine

HardDrop:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$s0

	movi	$a0,FX_GAME_DROP
	_JAL	PlaySampleCh1

	_JAL	AddScore
	_JAL	SetFallSpeed	
DropLoop:
	_JAL	DropOne
	_BNEZ	$v0,DropLoop
	_JAL	PutDownPiece

	POP	$s0
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS				; Return from subroutine

MoveLeft:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$s0
	
	_LI	$s0,Piece_Pos	
	_LW	$a1,0($s0)
	_LW	$a2,1($s0)
	addi	$a1,$a1,-1
	
	_LI	$a0,Current_Piece
	_JAL	TestPiece
	_BEQZ	$v0,MoveLeft_NotOK
	
	_SW	$a1,0($s0)
MoveLeft_NotOK:
	POP	$s0
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS				; Return from subroutine

MoveRight:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2
	PUSH	$s0
	
	_LI	$s0,Piece_Pos	
	_LW	$a1,0($s0)
	_LW	$a2,1($s0)
	addi	$a1,$a1,1
	
	_LI	$a0,Current_Piece
	_JAL	TestPiece
	_BEQZ	$v0,MoveRight_NotOK
	
	_SW	$a1,0($s0)
MoveRight_NotOK:
	POP	$s0
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS				; Return from subroutine

RotateCW:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2

	_JAL	RotatePiece_CW
	
	_LI	$a0,Temp_Piece
	_LI	$t0,Piece_Pos	
	_LW	$a1,0($t0)
	_LW	$a2,1($t0)
	
	_JAL	TestPiece
	_BEQZ	$v0,RotateCW_NotOK

	_LI	$a0,Temp_Piece
	_LI	$a1,Current_Piece
	_JAL	CopyPiece
	
	movi	$a0,FX_GAME_ROTATE
	_JAL	PlaySampleCh1

RotateCW_NotOK:
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS				; Return from subroutine
	
RotateCCW:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$a2

	_JAL	RotatePiece_CCW
	
	_LI	$a0,Temp_Piece
	_LI	$t0,Piece_Pos	
	_LW	$a1,0($t0)
	_LW	$a2,1($t0)
	
	_JAL	TestPiece
	_BEQZ	$v0,RotateCCW_NotOK

	_LI	$a0,Temp_Piece
	_LI	$a1,Current_Piece
	_JAL	CopyPiece

	movi	$a0,FX_GAME_ROTATE
	_JAL	PlaySampleCh1
	
RotateCCW_NotOK:
	POP	$a2
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS				; Return from subroutine

PrepareRotate:
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	
	_LI	$s0,Current_Piece_ExtraData
	_LI	$s1,Temp_Piece_ExtraData
	movi	$s2,PIECE_SIZEEXTRADATA
PrepareRotate_Loop:
	_LW	$t0,0($s0)
	_SW	$t0,0($s1)
	addi	$s0,$s0,1
	addi	$s1,$s1,1
	addi	$s2,$s2,-1
	_BNEZ	$s2,PrepareRotate_Loop
	
	_LI	$s0,Current_Piece_ScoreDiff	; Rotate ScoreDiff
	_LI	$s1,Temp_Piece_ScoreDiff
	
	_LW	$t0,1($s0)
	_SW	$t0,0($s1)
	_LW	$t0,0($s0)
	_SW	$t0,1($s1)

	_LI	$s0,Current_Piece_Size		; Rotate PieceSize
	_LI	$s1,Temp_Piece_Size
	
	_LW	$t0,0($s0)
	_SW	$t0,1($s1)
	_LW	$t0,1($s0)
	_SW	$t0,0($s1)

	POP	$s2	
	POP	$s1
	POP	$s0

	_RTS

RotatePiece_CW:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	
	_JAL	PrepareRotate
	
	_LI	$s0,Current_Piece_Size		; Get Piece height
	_LW	$t0,1($s0)
	mov	$s2,$t0
	
	_LI	$s0,Temp_Piece
	movi	$s3,16
Clear_Temp_CW:
	_SW	$zero,0($s0)
	addi	$s0,$s0,1
	addi	$s3,$s3,-1
	_BNEZ	$s3,Clear_Temp_CW

	; for (x=4;x=0,--x) {
	;   for (y=height,y=0,--y) {
	;     temp_piece(hieght-y-1,x) = current_piece(x,y)
	;   }
	; }

	movi	$s3,4		; X=4
Col_Loop_CW:
	mov	$s4,$s2		; Y=Height
	addi	$s3,$s3,-1	; --X
Row_Loop_CW:
	addi	$s4,$s4,-1	; --Y

	_LI	$s0,Current_Piece
	_LI	$s1,Temp_Piece
	
				; Current_Piece(x,y)
	add	$s0,$s0,$s3	; add X
	sll	$t0,$s4,2	; 4 * Y
	add	$s0,$s0,$t0	; add 4 * Y
	
				; Temp_Piece(height-y-1,x)
	mov	$t0,$s2		; Height	
	sub	$t0,$t0,$s4	; -Y
	addi	$t0,$t0,-1	; -1
	add	$s1,$s1,$t0	; Add Height-Y-1
	sll	$t0,$s3,2	; 4 * X
	add	$s1,$s1,$t0	; Add 4 * X
	
	_LW	$t0,0($s0)
	_SW	$t0,0($s1)
	
	_BNEZ	$s4,Row_Loop_CW
	_BNEZ	$s3,Col_Loop_CW

	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	
	_RTS				; Return from subroutine
	
RotatePiece_CCW:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	
	_JAL	PrepareRotate
	
	_LI	$s0,Current_Piece_Size	; Get Piece width
	_LW	$t0,0($s0)
	mov	$s2,$t0
	
	_LI	$s0,Temp_Piece
	movi	$s3,16
	
Clear_Temp_CCW:
	_SW	$zero,0($s0)
	addi	$s0,$s0,1
	addi	$s3,$s3,-1
	_BNEZ	$s3,Clear_Temp_CCW

	; for (x=width;x=0,--x) {
	;   for (y=4,y=0,--y) {
	;     temp_piece(y,height-x-1) = current_piece(x,y)
	;   }
	; }

	mov	$s3,$s2		; X=width
Col_Loop_CCW:
	movi	$s4,4		; Y=4
	addi	$s3,$s3,-1	; --X
Row_Loop_CCW:
	addi	$s4,$s4,-1	; --Y

	_LI	$s0,Current_Piece
	_LI	$s1,Temp_Piece
	
				; Current_Piece(x,y)
	add	$s0,$s0,$s3	; add X
	sll	$t0,$s4,2	; 4 * Y
	add	$s0,$s0,$t0	; add 4 * Y
	
				; Temp_Piece(y,width-x-1)
	add	$s1,$s1,$s4	; add Y	
	mov	$t0,$s2		; width
	sub	$t0,$t0,$s3	; -X
	addi	$t0,$t0,-1	; -1
	sll	$t0,$t0,2	; 4*(width-X-1)
	add	$s1,$s1,$t0	; add 4*(width-X-1)
	
	_LW	$t0,0($s0)
	_SW	$t0,0($s1)
	
	_BNEZ	$s4,Row_Loop_CCW
	_BNEZ	$s3,Col_Loop_CCW

	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	
	_RTS				; Return from subroutine

###############
# TetrIC DATA #
###############

Stat:			.dc	0,0,0,0,0,0,0
			.dc	0x029c,0xe1c0,0x067c,0xe031,0xaf20,0x072a,0xdba0 
			
FallSpeed:		.dc	0
Score:			.dc	0
LineCount:		.dc	0
Level:			.dc	0
NextPieceNumber:	.dc	0
ShowNextPiece:		.dc	0
RemoveRow_Array:	.dc	0,0,0,0

Level_FallSpeed_Array:	.dc	25,23,20,18,15,13,10,8,6,4 ; 25,23,20,18,15,13,10,8,5,3
BlockPointer_Array:	.dc	BlockGfx1,BlockGfx2,BlockGfx7,BlockGfx5,BlockGfx6,BlockGfx3,BlockGfx4

Piece_Pos:		.dc	0,0

Current_Piece: 		.dc	0,0,0,0
			.dc	0,0,0,0
			.dc	0,0,0,0
			.dc	0,0,0,0
Current_Piece_Size:	.dc	0,0
Current_Piece_ScoreDiff: 	.dc	0,0
Current_Piece_ExtraData:
Current_Piece_StartDiff:	.dc	0
Current_Piece_Color:	.dc	0
	
Temp_Piece:		.dc	0,0,0,0
			.dc	0,0,0,0
			.dc	0,0,0,0
			.dc	0,0,0,0
Temp_Piece_Size:	.dc	0,0
Temp_Piece_ScoreDiff:	.dc	0,0
Temp_Piece_ExtraData:
Temp_Piece_StartDiff:	.dc	0
Temp_Piece_Color:	.dc	0
	
Piece_Array:
	.dc	PieceO,PieceI,PieceZ,PieceS,PieceL,PieceJ,PieceT

PIECE_DATA = 0			; The 4x4 matrix that describes the piece
PIECE_SIZE = 16			; 4x4 = 16
PIECE_SCOREDIFF = 18		; Scorediff position in array
PIECE_STARTDIFF = 20		; Startdiff position in array
PIECE_COLOR = 21		; PieceColor position in array
PIECE_HORDIFF = 22		; Horizontal slide for showing nextpiece 
PIECE_VERDIFF = 23		; Vertical slide for showing nextpiece 
PIECE_SIZETOTAL = 24		; The total size of the array
PIECE_SIZEEXTRADATA = 2		; SCOREDIFF and STARTDIFF size
	
PieceO:
	.dc	1,1,0,0
	.dc	1,1,0,0
	.dc	0,0,0,0
	.dc	0,0,0,0
	
	.dc	2,2
	.dc	0,0
	.dc	1
	.dc	BlockGfx2
	.dc	8,8
	
PieceI:
	.dc	0,0,0,0
	.dc	1,1,1,1
	.dc	0,0,0,0
	.dc	0,0,0,0
	
	.dc	4,3
	.dc	1,1
	.dc	0
	.dc	BlockGfx1
	.dc	0,4

PieceZ:
	.dc	1,1,0,0
	.dc	0,1,1,0
	.dc	0,0,0,0
	.dc	0,0,0,0
	
	.dc	3,2
	.dc	0,1
	.dc	1
	.dc	BlockGfx4
	.dc	4,8
	
PieceS:
	.dc	0,1,1,0
	.dc	1,1,0,0
	.dc	0,0,0,0
	.dc	0,0,0,0
	
	.dc	3,2
	.dc	0,1
	.dc	1
	.dc	BlockGfx5
	.dc	4,8
	
PieceL:
	.dc	0,0,0,0
	.dc	1,1,1,0
	.dc	1,0,0,0
	.dc	0,0,0,0
	
	.dc	3,3
	.dc	1,1
	.dc	0
	.dc	BlockGfx6
	.dc	4,0
	
PieceJ:
	.dc	0,0,0,0
	.dc	1,1,1,0
	.dc	0,0,1,0
	.dc	0,0,0,0
	
	.dc	3,3
	.dc	1,1
	.dc	0
	.dc	BlockGfx3
	.dc	4,0
	
PieceT:
	.dc	0,0,0,0
	.dc	1,1,1,0
	.dc	0,1,0,0
	.dc	0,0,0,0
	
	.dc	3,3
	.dc	1,1
	.dc	0
	.dc	BlockGfx7
	.dc	4,0
	
Tetris_Board:
	.dc	1,1,1,1,1,1,1,1,1,1,1,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,0,0,0,0,0,0,0,0,0,0,1
	.dc	1,1,1,1,1,1,1,1,1,1,1,1

########
# Text #
########

NextPiece_Txt:	.ascii	"Next Piece"
Statistics_Txt:	.ascii	"Statistics"
Score_Txt:	.ascii	"Score"
Lines_Txt:	.ascii	"Lines"
Level_Txt:	.ascii	"Level"

#################
# Stolen Blocks #
#################

BlockGfx1:	.file	Data/img_blockred.raw 32
BlockGfx2:	.file	Data/img_blockblue.raw 32
BlockGfx3:	.file	Data/img_blockgreen.raw 32
BlockGfx4:	.file	Data/img_blockcyan.raw 32
BlockGfx5:	.file	Data/img_blockpink.raw 32
BlockGfx6:	.file	Data/img_blockyellow.raw 32 
BlockGfx7:	.file	Data/img_blockorange.raw 32

##############
# Background #
##############

TetrisPic:	.file	Data/img_kremlin320x256x8c.raw 20480
TetrisPal	.file	Data/img_Kremlin320x256x8c.pal 128

##############
# ShakeTable #
##############

ShakeSin:	.file	Data/data_ShakeSin.raw 64
ShakePointer:	.dc	63

###################
# Sound Registers #
###################
	
SFX_OFFSET 	= 0
SFX_LUT 	= 1
SFX_CHANSTATUS	= 2
SFX_SONGSTATUS 	= 3
SFX_FX0_START	= 4
SFX_FX1_START	= 5
SFX_FX2_START	= 6
SFX_FX3_START	= 7
SFX_FX0_VOL	= 8
SFX_FX1_VOL	= 9
SFX_FX2_VOL	= 10
SFX_FX3_VOL	= 11
SFX_FX0_END	= 12
SFX_FX1_END	= 13
SFX_FX2_END	= 14
SFX_FX3_END	= 15
SFX_FX0_LSTART	= 16
SFX_FX1_LSTART	= 17
SFX_FX2_LSTART	= 18
SFX_FX3_LSTART	= 19
SFX_FX0_LEND	= 20
SFX_FX1_LEND	= 21
SFX_FX2_LEND	= 22
SFX_FX3_LEND	= 23
SFX_FX0_FREQ	= 24
SFX_FX1_FREQ	= 25
SFX_FX2_FREQ	= 26
SFX_FX3_FREQ	= 27
SFX_WAITCLK	= 28
SFX_STEPCLK	= 29
SFX_MUXSEL	= 31
SFX_SONGLEN	= 32
SFX_SONGPOS	= 33
SFX_PATROW	= 34
SFX_PATADDR	= 35
SFX_CURPAT	= 36
SFX_MASTERVOL	= 37

SONG_PLAY = 0x01
SONG_LOOP = 0x04

###################
# Sound Functions #
###################

EMPTYMODSIZE = 413

CreateEmptyMod:
	; $a0 = ptr to 413 word buffer
	mov	$t0, $a0
	moviu	$t1, 413
C_E_clearloop:
	sw	$zero, 0($t0)
	addiu	$t0, $t0, 1
	addi	$t1, $t1, -1
	_BNEZ	$t1, C_E_clearloop
	moviu	$t0, 16		;make instr.1 a short silent sample, vol 0, no loop
	_SW	$t0, 0($a0)
	moviu	$t0, 64
	_SW	$t0, 1($a0)
	_LI	$t0, 0x01040000
	_SW	$t0, 124($a0)	;set songinfo
	_LI	$t0, 0x0AF40F06	;instrument 1, note 756, SetSpeed 6
	_SW	$t0, 157($a0)
	_SW	$t0, 158($a0)
	_SW	$t0, 159($a0)
	_SW	$t0, 160($a0)
	_RTS

InitSound:
	PUSH	$ra
	_LI	$a0,SilentMod
	_JAL	CreateEmptyMod

	_LI	$sfx,SfxBase
	_LI	$t0,Lut-108
	_SW	$t0,SFX_LUT($sfx)
	_LI	$t0,480000
	_SW	$t0,SFX_WAITCLK($sfx)
	movi	$t0,732
	_SW	$t0,SFX_STEPCLK($sfx)
	POP	$ra
	_RTS


#########
# Music #
#########

Lut:		.file	../TLib/Data/Lut.raw	800	


StartViewHigh:
	PUSH	$ra
	_JAL	PlayBeat
	
	_JAL	WaitNextFrame
	_JAL	InitStars
	
StartViewHighFromEnterHigh:
	_JAL	ColorTitleInit
	
	_STA	$zero,HighScoreListTextColor
	moviu	$t0,0xffff
	_STA	$t0,HighScoreListTargetColor
StartViewHigh_Loop:
	_JAL	Rnd
	_JAL	ViewHighFrame
	_JAL	CheckButton
	_BEQZ	$v0,StartViewHigh_Loop

	sw	$zero,HighScoreListTargetColor
	
	movi	$t0,NOF_CHARS
	_LI	$t1,HighScoreTitleTarget
StartViewHigh_ResetColors:
	sw	$zero,0($t1)
	addi	$t1,$t1,1
	addi	$t0,$t0,-1
	_BNEZ	$t0,StartViewHigh_ResetColors	

	_JAL	StopStars
		
	_JAL	ViewHighFrame

	_JAL	WaitNextFrame
	_JAL	FadeBeat
	_JAL	GetWorkScreen
	mov	$a0,$v0
	_JAL	ClearScreen
	_JAL	WaitNextFrame

	POP	$ra
	_RTS
	
ViewHighFrame:
	PUSH	$ra
	PUSH	$s0
ViewHighFrame_Loop:
	_JAL	WaitNextFrame
	_JAL	FadeBeat
	_JAL	GetWorkScreen
	mov	$a0,$v0
	_JAL	ClearScreen
	_JAL	Stars
	mov	$s0,$v0
	_JAL	ColorTitle
	_JAL	PrintHighScoreList
	or	$s0,$s0,$v0
	_BNEZ	$s0,ViewHighFrame_Loop
	POP	$s0
	POP	$ra
	_RTS	
	
HIGHSCORELIST_TOP = 50
HIGHSCORELIST_NAMELEFT = 70
HIGHSCORELIST_LEVELLEFT = 320-HIGHSCORELIST_NAMELEFT-70
HIGHSCORELIST_SCORERIGHT = 320-HIGHSCORELIST_NAMELEFT

HighScoreListTextColor: .dc	0
HighScoreListTargetColor: .dc	0

PrintHighScoreList:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	
	_LDA	$s2,HighScoreListTextColor
	_BEQZ	$s2,PrintHighScoreList_BlackText

	lui	$s3,0xffff
	
	movi	$s0,1
	movi	$s1,HIGHSCORELIST_TOP
PrintHighScoreList_Loop:
	mov	$a0,$s0
	_JAL	GetHighName
	mov	$a0,$v0
	movi	$a1,HIGHSCORELIST_NAMELEFT
	mov	$a2,$s1
	mov	$a3,$s2
	or	$a3,$a3,$s3
	_JAL	PrintString
	
	mov	$a0,$s0
	_JAL	GetHighLevel
	mov	$a0,$v0
	addi	$a0,$a0,0x30
	movi	$a1,HIGHSCORELIST_LEVELLEFT
	mov	$a2,$s1
	mov	$a3,$s2
	or	$a3,$a3,$s3
	_JAL	PrintASCII
	
	mov	$a0,$s0
	_JAL	GetHighScore
	mov	$a0,$v0
	movi	$a1,HIGHSCORELIST_SCORERIGHT
	mov	$a2,$s1
	mov	$a3,$s2
	or	$a3,$a3,$s3
	_JAL	PrintNumber16
	
	movi	$t9,0x1f
	and	$t0,$s2,$t9
	slti	$t3,$t0,0x04
	addi	$t3,$t3,-1
	sll	$t3,$t3,2
	add	$t0,$t0,$t3
	
	movi	$t9,0x07e0
	and	$t1,$s2,$t9
	slti	$t3,$t1,0x80
	addi	$t3,$t3,-1
	sll	$t3,$t3,6
	add	$t1,$t1,$t3
	
	movi	$t9,0xf800
	and	$t2,$s2,$t9
	slti	$t3,$t2,0x1000
	addi	$t3,$t3,-1
	sll	$t3,$t3,11
	add	$t2,$t2,$t3
	
	or	$s2,$t0,$t1
	or	$s2,$s2,$t2
		
	addi	$s1,$s1,16
	addi	$s0,$s0,1
	slti	$t0,$s0,11
	_BNEZ	$t0,PrintHighScoreList_Loop

PrintHighScoreList_BlackText:
	_LDA	$a0,HighScoreListTextColor
	_LDA	$a1,HighScoreListTargetColor
	_JAL	FadeSourceToDest
	mov	$s0,$v0
	mov	$s1,$v1
	_JAL	GetFrameCount
	sll	$v0,$v0,31
	_BNEZ	$v0,PrintHighScoreList_DontFade
	_STA	$s0,HighScoreListTextColor
PrintHighScoreList_DontFade:
	mov	$v0,$s1
	
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS


HIGHSCORETITLE_TOP = 20
HIGHSCORETITLE_LEFT = 160-76

NOF_CHARS = 16
	
HighScoreTitle:	.ascii	"TetrIC Hall of Fame"
HighScoreTitleColor:	.pad	NOF_CHARS,0
HighScoreTitleTarget:	.pad	NOF_CHARS,0

ColorTitleInit:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	
	movi	$s0, NOF_CHARS
	_LI	$s1, HighScoreTitleColor
	_LI	$s2, HighScoreTitleTarget
	
ColorTitleInit_Loop:
	_JAL	Rnd
	movi	$t0,0x3f
	and	$t0,$t0,$v0
	sll	$t0,$t0,5
	moviu	$t1,0xf800
	or	$t0,$t0,$t1
	_SW	$t0,0($s2)
	_SW	$zero,0($s1)
	addi	$s1,$s1,1
	addi	$s2,$s2,1

	addi	$s0,$s0,-1
	_BNEZ	$s0,ColorTitleInit_Loop	
	
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS
	
ColorTitle:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	PUSH	$s6
	PUSH	$s7
	
	lui	$s7,0xffff
	
	; Update color
	_JAL	GetFrameCount
	movi	$t0,0x0f
	and	$t0,$t0,$v0
	_LI	$s1,HighScoreTitleTarget
	add	$s1,$s1,$t0
	_LW	$t1,0($s1)
	_BEQZ	$t1,ColorTitle_NoNewColor
	_JAL	Rnd
	movi	$t0,0x3f
	and	$t0,$t0,$v0
	sll	$t0,$t0,5
	movi	$t1,0xf800
	or	$t0,$t0,$t1
	_SW	$t0,0($s1)
	
ColorTitle_NoNewColor:
	; Print Text
	_LI	$s1,HighScoreTitleColor
	_LI	$s2,HighScoreTitleTarget
	_LI	$s3,HighScoreTitle
	
	movi	$s6,HIGHSCORETITLE_LEFT
ColorTitle_Loop:
	_LW	$s0,0($s3)
	; GetWord
	movi	$s4,4
ColorTitle_WordLoop:
	addi	$s4,$s4,-1
	
	sll	$t0,$s4,3
	srlv	$a0,$s0,$t0
	movi	$t1,0xff
	and	$a0,$a0,$t1
	
	movi	$t0,0x20
	_BEQ	$t0,$a0,ColorTitle_SkipChar
	_BEQZ	$a0,ColorTitle_Done
	
	mov	$a1,$s6
	movi	$a2,HIGHSCORETITLE_TOP
	_LW	$a3,0($s1)
	or	$a3,$a3,$s7
	_JAL	PrintASCII
		
	_LW	$a0,0($s1)
	_LW	$a1,0($s2)
	_JAL	FadeSourceToDest
	_SW	$v0,0($s1)

	addi	$s1,$s1,1
	addi	$s2,$s2,1
ColorTitle_SkipChar:
	addi	$s6,$s6,8
	_BNEZ	$s4,ColorTitle_WordLoop
	addi	$s3,$s3,1
	_J	ColorTitle_Loop
	
ColorTitle_Done:
	POP	$s7
	POP	$s6
	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS
##################
# Math Functions #
##################

Divu16:	; Unsigned Division
	; $a0 - dividend (16 bits) unsigned
	; $a1 - divisor (16 bits) unsigned
	; $v0 - quotient (16 bits) unsigned
	; $v1 - remainder (16 bits) unsigned		
	
	_BEQZ	$a1,Divu16_Exit		; DivideByZero
	moviu	$t8,0xffff		; mask a0 16 bits
	and	$a0,$a0,$t8		
	sll	$a1,$a1,16		; mask a1 16 bits
	movi	$t9,16
Divu16_Loop:
	sll	$a0,$a0,1
	addi	$t4,$a0,1		; add one for less than or equal
	slt	$t4,$a1,$t4
	sll	$t5,$t4,31
	sra	$t5,$t5,31
	and	$t5,$a1,$t5
	sub	$a0,$a0,$t5
	or	$a0,$a0,$t4
	addi	$t9,$t9,-1
	_BNEZ	$t9,Divu16_Loop
	and	$v0,$a0,$t8	
	srl	$v1,$a0,16
Divu16_Exit:
	_RTS				; Return from subroutine

Divs16:	; Signed Division
	; $a0 - dividend (16 bits) signed
	; $a1 - divisor (16 bits) signed
	; $v0 - quotient (16 bits) signed
	; $v1 - remainder (16 bits) signed
				
	_BEQZ	$a1,Divs16_Exit		;DivideByZero
	slti	$t0,$a0,0	; make a0 positive
	sll	$t1,$t0,31
	sra	$t1,$t1,31
	xor	$a0,$a0,$t1
	add	$a0,$a0,$t0
	slti	$t2,$a1,0	; make a1 positive
	sll	$t3,$t2,31
	sra	$t3,$t3,31
	xor	$a1,$a1,$t3
	add	$a1,$a1,$t2
	moviu	$t8,0xffff	; mask a0 16 bits
	and	$a0,$a0,$t8
	sll	$a1,$a1,16	; mask a1 16 bits 
	movi	$t9,16
Divs16_Loop:
	sll	$a0,$a0,1
	addi	$t4,$a0,1	; add one for less than or equal
	slt	$t4,$a1,$t4
	sll	$t5,$t4,31
	sra	$t5,$t5,31
	and	$t5,$a1,$t5
	sub	$a0,$a0,$t5
	or	$a0,$a0,$t4
	addi	$t9,$t9,-1
	_BNEZ	$t9,Divs16_Loop
	and	$v0,$a0,$t8
	srl	$v1,$a0,16	
	xor	$t1,$t1,$t3	; put correct sign on result
	xor	$t0,$t0,$t2
	xor	$v0,$v0,$t1
	add	$v0,$v0,$t0
	xor	$v1,$v1,$t1
	add	$v1,$v1,$t0
Divs16_Exit:
	_RTS				; Return from subroutine

Mulu16:	; Unsigned Multiplication
	; $a0 - multiplier 1 (16 bits)
	; $a1 - multiplier 2 (32 bits)
	; $v0 - result (maximum 32 bits)
	clr	$v0
	movi	$t9,16	
Mulu16_Loop:
	sll	$t8,$a0,31
	sra	$t8,$t8,31
	and	$t8,$a1,$t8
	add	$v0,$v0,$t8
	sll	$a1,$a1,1
	srl	$a0,$a0,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,Mulu16_Loop
	_RTS

Muls16:	; Signed Multiplication
	; $a0 - multiplier 1 (16 bits)
	; $a1 - multiplier 2 (32 bits)
	; $v0 - result (maximum 32 bits)
	slti	$t0,$a0,0	; make a0 positive
	sll	$t1,$t0,31
	sra	$t1,$t1,31
	xor	$a0,$a0,$t1
	add	$a0,$a0,$t0
	slti	$t2,$a1,0	; make a1 positive
	sll	$t3,$t2,31
	sra	$t3,$t3,31
	xor	$a1,$a1,$t3
	add	$a1,$a1,$t2
	clr	$v0
	movi	$t9,16	
Muls16_Loop:
	sll	$t8,$a0,31
	sra	$t8,$t8,31
	and	$t8,$a1,$t8
	add	$v0,$v0,$t8
	sll	$a1,$a1,1
	srl	$a0,$a0,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,Muls16_Loop
	xor	$t1,$t1,$t3	; put correct sign on result
	xor	$t0,$t0,$t2
	xor	$v0,$v0,$t1
	add	$v0,$v0,$t0
	_RTS

Muls16fp:
	; Signed Multiplication fixed point 16 + 16
	; $a0 - multiplier 1 (16 + 16 bits)
	; $a1 - multiplier 2 (16 + 16 bits)
	; $v0 - result (16 + 16 bits)
	slti	$t0,$a0,0	; make a0 positive
	sll	$t1,$t0,31
	sra	$t1,$t1,31
	xor	$a0,$a0,$t1
	add	$a0,$a0,$t0
	
	slti	$t2,$a1,0	; make a1 positive
	sll	$t3,$t2,31
	sra	$t3,$t3,31
	xor	$a1,$a1,$t3
	add	$a1,$a1,$t2
	clr	$v0
	
	clr	$t4	; high multiplier
	clr	$t5	; high result
	clr	$t6	; low result
	
	movi	$t9,32
Muls16fp_Loop:
	sll	$t8,$a0,31
	sra	$t8,$t8,31
	
	and	$t7,$a1,$t8
	add	$t7,$t6,$t7
	sltu	$t0,$t7,$t6
	add	$t5,$t5,$t0
	mov	$t6,$t7
	
	and	$t7,$t4,$t8
	add	$t5,$t5,$t7
	
	sll	$t4,$t4,1
	srl	$t8,$a1,31
	or	$t4,$t4,$t8
	sll	$a1,$a1,1
	srl	$a0,$a0,1
	
	addi	$t9,$t9,-1
	_BNEZ	$t9,Muls16fp_Loop
	
	xor	$t1,$t1,$t3	; put correct sign on result
	xor	$t0,$t0,$t2
	xor	$t5,$t5,$t1
	xor	$t6,$t6,$t1
	add	$t7,$t6,$t0
	sltu	$t0,$t7,$t6
	add	$t5,$t5,$t0
	mov	$t6,$t7
	sll	$t5,$t5,16
	srl	$t6,$t6,16
	or	$v0,$t5,$t6

	_RTS
	
Muls16fpfast:
	; Signed Multiplication 
	; $a0 - multiplier 1	(fixed point 0 + 16 bits)
	; $a1 - multiplier 2	(fixed point 8 + 16 bits)
	; $v0 - result		(fixed point 16 + 16 bits)
	
	sra	$a1,$a1,8
	
	slti	$t0,$a0,0	; make a0 positive
	sll	$t1,$t0,31
	sra	$t1,$t1,31
	xor	$a0,$a0,$t1
	add	$a0,$a0,$t0
	slti	$t2,$a1,0	; make a1 positive
	sll	$t3,$t2,31
	sra	$t3,$t3,31
	xor	$a1,$a1,$t3
	add	$a1,$a1,$t2
	clr	$v0
	movi	$t9,16
Muls16fpfast_Loop:
	sll	$t8,$a0,31
	sra	$t8,$t8,31
	and	$t8,$a1,$t8
	add	$v0,$v0,$t8
	sll	$a1,$a1,1
	srl	$a0,$a0,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,Muls16fpfast_Loop
	xor	$t1,$t1,$t3	; put correct sign on result
	xor	$t0,$t0,$t2
	xor	$v0,$v0,$t1
	add	$v0,$v0,$t0
	
	sra	$v0,$v0,8
	_RTS
	
Randomize:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	
	_LI	$s0,RandomSeed
	_LW	$a0,0($s0)
	
	movi	$t0, 2
	mfc1	$a1, $t0	; Get hcount
	_JAL	Mulu16		; Mulu Randomseed with hcount

	movi	$t0, 0
	mfc1	$t1, $t0	; get gfxregisters
	xor	$v0,$v0,$t1	; Xor New seed with gfxregisterss
	
	_SW	$v0, 0($s0)
	
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	
	_RTS

RANDOMMULTIPLIER = 903317621
RandomSeed:	.dc	42346786

Rnd:
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	
	_LI	$s0,RandomSeed
	_LW	$a0,0($s0)
	_LI	$a1,RANDOMMULTIPLIER
	_JAL	Mulu16
	addi	$v0,$v0,1
	_SW	$v0,0($s0)

	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra

	_RTS

Sin:	; $a0 input - 16 bit value
	; 0x0000 = 0 degrees
	; 0x4000 = 90 degrees
	; 0x8000 = 180 degrees
	; 0xc000 = 270 degrees
	; 0x10000 = 360 degrees = 0 degrees
	; $v0 = result -65535 <-> +65535
	sll	$t0,$a0,16	; remove whole part of fixed point 16+16
	srl	$t0,$t0,20	; Keep 12 upper bits (4096) of lower 16 bits (pointer)
	sll	$t1,$t9,28	; mask out odd 
	srl	$t1,$t1,31	; or even value
	sll	$t1,$t1,4	; and multiply it by 16
	li	$t2,Sinus
	add	$t2,$t2,$t0
	lw	$t0,0($t2)
	nop
	sllv	$t0,$t0,$t1
	sra	$v0,$t0,15
	_RTS

Cos:	; $a0 input - 16 bit value
	; 0x0000 = 0 degrees
	; 0x4000 = 90 degrees
	; 0x8000 = 180 degrees
	; 0xc000 = 270 degrees
	; 0x10000 = 360 degrees = 0 degrees
	; $v0 = result -65535 <-> +65535	
	addiu	$t9,$a0,0x4000	; add 90 degrees in the sin table to get cos
	sll	$t0,$t9,16	; remove whole part of fixed point 16+16
	srl	$t0,$t0,20	; Keep 12 upper bits (4096) of lower 16 bits (pointer)
	sll	$t1,$t9,28	; mask out odd 
	srl	$t1,$t1,31	; or even value
	sll	$t1,$t1,4	; and multiply it by 16
	li	$t2,Sinus
	add	$t2,$t2,$t0
	lw	$t0,0($t2)
	nop
	sllv	$t0,$t0,$t1
	sra	$v0,$t0,15
	_RTS
	
Sinus:	.file	../TLib/Data/Sinus.raw	4096

IntroDone:	.dc	0
NextMode:	.dc	0

StartIntro:
	PUSH	$ra
	
	_JAL	PlayBeat

	_LI	$t0,MenuVal
	sw	$zero,0($t0)
	sw	$zero,1($t0)
	sw	$zero,2($t0)
	sw	$zero,3($t0)
	

	_STA	$zero,IntroDone
	
	_JAL	ClearScreen
	_JAL	Drawbackground
	_JAL	WaitNextFrame
	_JAL	ClearScreen
	_JAL	DrawBackground
	_JAL	WaitNextFrame
	
	_JAL	InitScroll
	_JAL	StartMorph
		
	_LI	$t0,JoyRepeatWait
	_LI	$t1,0x000a02			; Filter = 00, RepeatVal = 0a, Accelerate = 2
	nop
	nop
	sw	$t1,JOY_UP($t0)
	sw	$t1,JOY_LEFT($t0)
	sw	$t1,JOY_RIGHT($t0)
	sw	$t1,JOY_DOWN($t0)
	sw	$t1,JOY_BUTA($t0)
	sw	$t1,JOY_BUTB($t0)
	sw	$t1,JOY_BUTC($t0)
	sw	$t1,JOY_START($t0)

StartIntro_Loop:
	_JAL	IntroFrame
	_BEQZ	$v0,StartIntro_Loop

	_LDA	$t0,NextMode
	movi	$t1,VIEWHIGHSCOREMODE
	_BEQ	$t0,$t1,DontStopBeat
	_JAL	StopBeat	
DontStopBeat:
	_JAL	IntroFadeOut
	_JAL	ScreenFadeOut
	POP	$ra
	_RTS
	
IntroFrame:
	PUSH	$ra
	_JAL	WaitNextFrame
	_JAL	FadeBeat
	_JAL	MenuJoyStick
		
	_JAL	ClearIntroScreen
	
	_JAL	DrawMenu
	movi	$a0,FADE_UP		; Dont fade out MorphFrame
	_JAL	MorphFrame
	movi	$a0,FADE_UP		; Dont fade out MorphFrame
	_JAL	Scroll
		
	_LDA	$v0,IntroDone
	POP	$ra
	_RTS

IntroFadeOut:
	PUSH	$ra	
	PUSH	$s0
IntroFadeOut_Loop:
	clr	$s0
	_JAL	WaitNextFrame
	_JAL	FadeBeat
	_JAL	ClearIntroScreen
	_JAL	DrawMenu
	movi	$a0,FADE_DOWN		; Fade out MorphFrame
	_JAL	MorphFrame
	or	$s0,$s0,$v1		; 0 in v1 if Morpframe fade out done
	movi	$a0,FADE_DOWN		; Fade out Scroll
	_JAL	Scroll
	or	$s0,$s0,$v1		; 0 in v1 if Scroll fade out is done
	_BNEZ	$s0,IntroFadeOut_Loop
	POP	$s0
	POP	$ra
	_RTS
	
BLUEBLOCKHEIGHT = 30
BLUEBLOCKCOLOR = 0x0004
REDLINECOLOR = 0xf800

DrawBackground:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	
	moviu	$a0,BLUEBLOCKCOLOR
	_JAL	SetColor
	
	movi	$a0,0
	movi	$a1,0
	movi	$a2,320
	movi	$a3,BLUEBLOCKHEIGHT
	_JAL	FilledRect

	movi	$a0,0
	movi	$a1,255-BLUEBLOCKHEIGHT+1
	movi	$a2,320
	movi	$a3,BLUEBLOCKHEIGHT
	_JAL	FilledRect

	moviu	$a0,REDLINECOLOR
	_JAL	SetColor
	
	movi	$a0,0
	movi	$a1,BLUEBLOCKHEIGHT
	movi	$a2,319
	movi	$a3,BLUEBLOCKHEIGHT
	_JAL	Line
	
	movi	$a0,0
	movi	$a1,255-BLUEBLOCKHEIGHT
	movi	$a2,319
	movi	$a3,255-BLUEBLOCKHEIGHT
	_JAL	Line
		
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS

ClearIntroScreen:
	PUSH	$ra
	
	_JAL	GetWorkScreen
	mov	$t0,$v0
	
	addi	$t0,$t0,160*60
	movi	$t1,140
ClearIntroScreen_Loop:
	movi	$t2,5
ClearIntroScreen_Loop2:
	sw	$zero,0($t0)
	sw	$zero,1($t0)
	sw	$zero,2($t0)
	sw	$zero,3($t0)
	sw	$zero,4($t0)
	sw	$zero,5($t0)
	sw	$zero,6($t0)
	sw	$zero,7($t0)
	sw	$zero,8($t0)
	sw	$zero,9($t0)
	sw	$zero,10($t0)
	sw	$zero,11($t0)
	sw	$zero,12($t0)
	sw	$zero,13($t0)
	sw	$zero,14($t0)
	sw	$zero,15($t0)
	addi	$t0,$t0,16
	addi	$t2,$t2,-1
	_BNEZ	$t2,ClearIntroScreen_Loop2
	addi	$t0,$t0,80
	addi	$t1,$t1,-1
	_BNEZ	$t1,ClearIntroScreen_Loop
	
	POP	$ra
	_RTS
	
MenuJoystick:
	PUSH	$ra				; Store to stack
	
	_JAL	CheckJoystick
	mov	$t5,$v0
	
	_LI	$t1,MenuVal
	_LW	$t2,0($t1)
	_LW	$t3,1($t1)
	clr	$t4

	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuUp			; Check LSB
	addi	$t2,$t2,-1			; Up
noMenuUp:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuButA			; Check LSB
	movi	$t4,1				; ButA
noMenuButA:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuDown			; Check LSB
	addi	$t2,$t2,1			; Down
noMenuDown:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuRight			; Check LSB
	addi	$t3,$t3,1			; Right
noMenuRight:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuButB			; Check LSB
	movi	$t4,1				; ButB
noMenuButB:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuLeft			; Check LSB
	addi	$t3,$t3,-1			; Right
noMenuLeft:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuStart			; Check LSB
	; Start
noMenuStart:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noMenuButC			; Check LSB
	movi	$t4,1				; ButC
noMenuButC:

	_SW	$t2,0($t1)
	_SW	$t3,1($t1)
	_SW	$t4,2($t1)

	POP	$ra	
	_RTS				; Return from subroutine
	
MENU_XPOS = 130
MENU_YPOS = 70

DrawMenu:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	
	_LI	$s3,MenuVal
	_LW	$s4,0($s3)
	
	slt	$t0,$s4,$zero
	_BEQZ	$t0,Menu_ChoiceNotToLow
	addi	$s4,$s4,1
Menu_ChoiceNotToLow:
	_LI	$s0,Menu
	sll	$t0,$s4,2
	add	$s0,$s0,$t0
	_LW	$t0,0($s0)
	_BNEZ	$t0,Menu_ChoiceNotToHigh
	addi	$s4,$s4,-1
Menu_ChoiceNotToHigh:
	_LDA	$t9,MenuOldRow
	_SW	$s4,0($s3)
	_STA	$s4,MenuOldRow
	_BEQ	$s4,$t9,Menu_SameRow

	_LI	$s0,Menu
	sll	$t0,$s4,2
	add	$s0,$s0,$t0

	_LW	$t0,2($s0)
	_SW	$t0,1($s3)
	_STA	$t0,MenuOldVal

	movi	$a0,FX_MENU_CHANGEROW
	_JAL	PlaySampleCh1
	_J	DrawMenu_Draw

Menu_SameRow:
	_LW	$t1,1($s3)
	slt	$t0,$t1,$zero
	_BEQZ	$t0,Menu_ValNotToLow
	addi	$t1,$t1,1
Menu_ValNotToLow:
	_LW	$t2,3($s0)
	slt	$t0,$t2,$t1
	_BEQZ	$t0,Menu_ValNotToHigh
	addi	$t1,$t1,-1	
Menu_ValNotToHigh:
	_SW	$t1,2($s0)
	_SW	$t1,1($s3)
	_LDA	$t0,MenuOldVal
	_STA	$t1,MenuOldVal
	_BEQ	$t0,$t1,DrawMenu_Draw
	
	_LI	$s0,Menu
	_LW	$a0,MENU_SFX($s0)
	_JAL	EnableFX		; Turn On/Off SFX
	_LW	$a0,MENU_MUSIC($s0)
	_JAL	EnableMusic		; Turn On/Off SFX

	movi	$a0,FX_MENU_CHANGEVALUE
	_JAL	PlaySampleCh1

DrawMenu_Draw:
	_LI	$s0,Menu
	movi	$s2,MENU_YPOS
	sll	$s4,$s4,2
	add	$s4,$s4,$s0	
Menu_GetItem:	
	_LW	$t0,0($s0)
	_BEQZ	$t0,Menu_Done
	moviu	$a3,0x7bef
	_BNE	$s4,$s0,Menu_NotHighlight
	moviu	$a3,0xffe0
Menu_NotHighlight:
	mov	$a0,$t0
	movi	$a1,MENU_XPOS
	mov	$a2,$s2
	_JAL	PrintString
	_LW	$t0,1($s0)
	_BEQZ	$t0,Menu_NextItem	
	_LW	$t1,2($s0)
	add	$a0,$t0,$t1
	addi	$a1,$a1,18*8
	_JAL	PrintString	
Menu_NextItem:
	addi	$s0,$s0,4
	addi	$s2,$s2,16
	_J	Menu_GetItem

Menu_Done:
	_LDA	$t0, IntroDone
	_BNEZ	$t0, Menu_NoNewMode

	_LW	$t0,0($s3)
	_LW	$t1,2($s3)
	_BEQZ	$t1,Menu_NoButton
	
	movi	$t1,PLAYGAMEROW
	movi	$t2,GAMEMODE
	_BEQ	$t0,$t1,Menu_ModeDone
	movi	$t1,HIGHSCOREROW
	movi	$t2,VIEWHIGHSCOREMODE
	_BEQ	$t0,$t1,Menu_ModeDone
	movi	$t2,INTROMODE
Menu_ModeDone:
	_STA	$t2,NextMode
	movi	$t0,INTROMODE
	_BEQ	$t0,$t2,Menu_NoNewMode

	movi	$a0,FX_MENU_BUTTON
	_JAL	PlaySampleCh1

	movi	$t0,1
	_STA	$t0,IntroDone
Menu_NoNewMode:
	
Menu_NoButton:
	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS

GetNextMode:
	_LDA	$v0,NextMode
	_RTS
	
GetStartLevel:	
	_LI	$t1,Menu
	_LW	$v0,MENU_STARTLEVEL($t1)
	_RTS
	
GetShowNextPiece:
	_LI	$t1,Menu
	_LW	$v0,MENU_SHOWNEXTPIECE($t1)
	_RTS

GameHeight:	.dc	0,4,10,14

GetStartHeight:
	_LI	$t1,Menu
	_LW	$t1,MENU_STARTHEIGHT($t1)
	_LW	$v0,GameHeight($t1)
	_RTS

MenuVal:	.dc	0,0,0
MenuOldRow:	.dc	0
MenuOldVal:	.dc	0

Menu:		.dc	PlayString,0,0,0
		.dc	LevelString,LevelList,5,9
		.dc	HeightString,HeightList,0,3
		.dc	ShowNextString,ShowNextList,1,1
		.dc	MusicString,MusicList,1,1
		.dc	SFXString,SFXList,1,1
		.dc	ShowHighString,0,0,0
		.dc	0,0,0,0
PLAYGAMEROW = 0
HIGHSCOREROW = 6

MENU_STARTLEVEL = 6
MENU_STARTHEIGHT = 10
MENU_SHOWNEXTPIECE = 14
MENU_MUSIC = 18
MENU_SFX = 22

TetrisString:	.ascii	"TetrIC 2002"
PlayString:	.ascii	"Play TetrIC"	
LevelString:	.ascii	"Start Level"
LevelList:	.ascii	"0"
		.ascii	"1"
		.ascii	"2"
		.ascii	"3"
		.ascii	"4"
		.ascii	"5"
		.ascii	"6"
		.ascii	"7"
		.ascii	"8"
		.ascii	"9"
HeightString:	.ascii	"Start height"
HeightList:	.ascii	"0 "
		.ascii	"4 "
		.ascii	"10"
		.ascii	"14"
ShowNextString:	.ascii	"Show next piece"
ShowNextList:	.ascii	"Off"
		.ascii	"On "
MusicString:	.ascii	"Music"
MusicList:	.ascii	"Off"
		.ascii	"On "
SFXString:	.ascii	"SFX"
SFXList:	.ascii	"Off"
		.ascii	"On "
ShowHighString:	.ascii	"Show Highscore"


INTROMODE = 0
GAMEMODE = 1
ENTERHIGHSCOREMODE = 2
VIEWHIGHSCOREMODE = 3

Mode:		.dc	0

ModeJumpTable:	.dc	ModeSwitchIntro,ModeSwitchGame,ModeSwitchEnterHigh,ModeSwitchViewHighScore
	

PreMain:
	movi	$t0,INTROMODE
	_STA	$t0,Mode
	
Main:	_JAL	Randomize
	_LDA	$t0,Mode
	_LDO	$t0,ModeJumpTable,$t0
	_JALR	$t0,$ra
	_J	Main
	
ModeSwitchIntro:
	PUSH	$ra
	_JAL	StartIntro
	_JAL	GetNextMode	
	_STA	$v0,Mode		; will we go to gamemode or view highscoremode ?
	POP	$ra
	_RTS

ModeSwitchGame:
	PUSH	$ra
	_JAL	StartGame
	movi	$t0,ENTERHIGHSCOREMODE
	_STA	$t0,Mode
	POP	$ra
	_RTS

ModeSwitchEnterHigh:
	PUSH	$ra
	_JAL	StartEnterHigh
	movi	$t0,INTROMODE		; We will go directly to intromode since enter high will go to ViewHigh
	_STA	$t0,Mode
	POP	$ra
	_RTS
	
ModeSwitchViewHighScore:
	PUSH	$ra
	_JAL	StartViewHigh
	movi	$t0,INTROMODE
	_STA	$t0,Mode
	POP	$ra
	_RTS
OnHighScoreList:
	; input:
	; a0 - The last games score
	;
	; output
	; v0 - 1 if the score should be in highscorelist
	_LI	$t0,HighScoreScores
	_LW	$t1,9($t0)
	slt	$v0,$t1,$a0
	_RTS
	
AddToHighScoreList:
	; a0 - name
	; a1 - score
	; a2 - level
	
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	
	movi	$t9,10
	_LI	$t0,HighScoreNames
	_LI	$t1,HighScoreScores
	_LI	$t2,HighScoreLevels
AddToHighScoreList_FindPosition:
	_LW	$t3,0($t1)
	addi	$t3,$t3,1
	slt	$t8,$a1,$t3
	add	$t0,$t0,$t8
	add	$t0,$t0,$t8
	add	$t0,$t0,$t8
	add	$t1,$t1,$t8
	add	$t2,$t2,$t8
	addi	$t9,$t9,-1
	sra	$t7,$t9,31
	_BNEZ	$t7,AddToHighScoreList_Done	
	_BNEZ	$t8,AddToHighScoreList_FindPosition
	_LW	$t4,0($t0)
	_LW	$t5,1($t0)
	_LW	$t6,0($t1)
	_LW	$t7,0($t2)
	
	_LW	$t3,0($a0)
	_SW	$t3,0($t0)
	_LW	$t3,1($a0)
	_SW	$t3,1($t0)
	_SW	$zero,2($t0)
	_SW	$a1,0($t1)
	_SW	$a2,0($t2)

AddToHighScoreList_MoveDown:
	_BEQZ	$t9,AddToHighScoreList_Done	
	
	addi	$t0,$t0,3
	addi	$t1,$t1,1
	addi	$t2,$t2,1
	
	_LW	$s0,0($t0)
	_LW	$s1,1($t0)
	_LW	$s2,0($t1)
	_LW	$s3,0($t2)
	
	_SW	$t4,0($t0)
	_SW	$t5,1($t0)
	_SW	$zero,2($t0)
	_SW	$t6,0($t1)
	_SW	$t7,0($t2)
	
	mov	$t4,$s0
	mov	$t5,$s1
	mov	$t6,$s2
	mov	$t7,$s3
	
	addi	$t9,$t9,-1
	_J	AddToHighScoreList_MoveDown

AddToHighScoreList_Done:
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	_RTS

GetHighScore:
	; input:  a0 - position 
	; output: v0 - score
	_LI	$t0,HighScoreScores
	addi	$t1,$a0,-1
	add	$t0,$t0,$t1
	_LW	$v0,0($t0)
	_RTS

GetHighLevel:
	; input:  a0 - position 
	; output: v0 - level
	_LI	$t0,HighScoreLevels
	addi	$t1,$a0,-1
	add	$t0,$t0,$t1
	_LW	$v0,0($t0)
	_RTS

GetHighName:
	; input:  a0 - position 
	; output: v0 - name ptr
	_LI	$v0,HighScoreNames
	addi	$t0,$a0,-1
	add	$v0,$v0,$t0
	add	$v0,$v0,$t0
	add	$v0,$v0,$t0
	_RTS
	
HighScoreNames:
	.ascii	"FAN"
	.dc	0,0
	.ascii	"TA"
	.dc	0,0
	.ascii	"MCH"
	.dc	0,0
	.ascii	"MJH"
	.dc	0,0
	.ascii	"JPN"
	.dc	0,0
	.ascii	"MSV"
	.dc	0,0
	.ascii	"ABN"
	.dc	0,0
	.ascii	"MNI"
	.dc	0,0
	.ascii	"ES"
	.dc	0,0
	.ascii	"IC"
	.dc	0,0
	
HighScoreScores:
	.dc	5000,4500,4000,3500,3000,2500,2000,1500,1000,500

HighScoreLevels:
	.dc	9,8,7,6,5,4,3,2,1,0

##################
# Check Joystick #
##################

JoyRepeatWait:	.dc	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

JOY_UP 		= 15
JOY_DOWN	= 13
JOY_LEFT	= 10
JOY_RIGHT	= 12
JOY_BUTA	= 14
JOY_BUTB	= 11
JOY_BUTC	= 8
JOY_START	= 9

CheckJoystick:
	; $v0 = Result
	mfc2	$t0			; Read Joystick (Active Low)
	not	$t0,$t0			; Neg (Active High)
	clr	$v0			; Clear Result
	moviu	$t9,0xffff		; Mask
	_LI	$t1,JoyRepeatWait	; Clear repeat counter
	movi	$t2,8			; Count=8, 8 Bits (Directions and Buttons)
	sll	$t0,$t0,24		; Shift to sign bit
CheckJoyStick_Loop:
ClearRepeat:
	_LW	$t4,0($t1)		; Load 
	_LW	$t6,8($t1)		; Load Filter | RepeatVal | Accellerate
	sll	$t6,$t6,8		
	srl	$t7,$t6,24		; Filter in $t7
	sll	$t6,$t6,8
	srl	$t8,$t6,24		; RepeatVal in $t8
	sll	$t6,$t6,8
	srl	$t6,$t6,24		; Accelerate in $t6
	
	srl	$t5,$t4,16		; Get Repeat Value
	and	$t4,$t4,$t9		; Get Repeat Count
	slti	$t3,$t0,0		; Is Joy Bit Set ?
	_BNEZ	$t3,ClearRepeat_Dont	; No, Set Default values
	mov	$t4,$t7			; Set filtervalue
	mov	$t5,$t8			; Set repeatvalue
ClearRepeat_Dont:
	sub	$t4,$t4,$t3		; Yes, repeatvalue--
SetRepeatCount:	
	slti	$t3,$t4,0		; Is repeatcount Negative ?
	sll	$v0,$v0,1		; Shift result
	or	$v0,$v0,$t3		; Yes, Set Result Bit
	_BEQZ	$t3,SetRepeatCount_Dont	; Is repeatcount negative ?
	mov	$t4,$t5			; repeatcount = repeatval
	slt	$t3,$zero,$t5		; is repeatcount bigger than zero
	sll	$t3,$t3,31		; Yes, Shift set bit to top
	sra	$t3,$t3,31		; Yes, And make a nice mask word
	and	$t3,$t3,$t6		; Mask accelerate value
	sub	$t5,$t5,$t3		; Sub Aceelerate value
SetRepeatCount_Dont:
	sll	$t5,$t5,16		; Shift up repeatval
	or	$t4,$t4,$t5		; or with repeatcount
	_SW	$t4,0($t1)		; Store until next time
	sll	$t0,$t0,1		; Next joybit
	addi	$t1,$t1,1		; Next mempos
	addi	$t2,$t2,-1		; count--
	_BNEZ	$t2,CheckJoystick_Loop	; Are we done
	_RTS
	
###########################
# WaitButton_PressRelease #
###########################

WaitButton_PressRelease:	
	PUSH	$ra
WaitButton_Press:
	mfc2	$t0
	andi	$t0,$t0,0xd2
	movi	$t1,0xd2
	_BEQ	$t0,$t1,WaitButton_Press
	_JAL	WaitNextFrameNoSwap
WaitButton_Release:
	mfc2	$t0
	andi	$t0,$t0,0xd2
	movi	$t1,0xd2
	_BNE	$t0,$t1,WaitButton_Release
	_JAL	WaitNextFrameNoSwap
	POP	$ra	
	_RTS

###############
# CheckButton #
###############

CheckButton:
	movi	$v0,0
	mfc2	$t0
	movi	$t1,0xd2
	and	$t0,$t0,$t1
	_BEQ	$t0,$t1,CheckButton_NoButton
	movi	$v0,1
CheckButton_NoButton:
	_RTS

InitScroll:
	_STA	$zero,Scroll_Char
	movi	$t0,8
	_STA	$t0,Scroll_Slide
	movi	$t0,-1
	_STA	$t0,Scroll_LastChar
	movi	$t0,-2
	_STA	$t0,Scroll_Speed
	
	_RTS

SCROLL_LEFT = 0
SCROLL_RIGHT = 312
SCROLL_FADE = 64
SCROLL_YPOS = 209
	
Scroll:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	
	mov	$s2,$a0

	clr	$v1
	_LDA	$t0,Scroll_Char
	_LDA	$t1,Scroll_LastChar
	_BEQ	$t0,$t1,Scroll_FadeDone
		
	_LI	$s0,Scroll_Text	
	_LI	$t0,Scroll_Char
	_LW	$s1,0($t0)
	_LI	$t0,Scroll_Slide
	_LW	$a1,0($t0)
	movi	$a2,SCROLL_YPOS
	movi	$s7,10
Scroll_PrintLoop:
	srl	$t0,$s1,2
	add	$t0,$t0,$s0
	_LW	$a0,0($t0)
	andi	$t0,$s1,3
	movi	$t1,3
	sub	$t1,$t1,$t0
	sll	$t1,$t1,3
	srlv	$a0,$a0,$t1
	sll	$a0,$a0,24
	srl	$a0,$a0,24
	
	moviu	$a3,0xf800
	
	slti	$t0,$a1,SCROLL_LEFT+SCROLL_FADE
	_BEQZ	$t0,Scroll_LeftNoFade
	sll	$a3,$a1,10
	_J	Scroll_Print
Scroll_LeftNoFade:
	slti	$t0,$a1,SCROLL_RIGHT-SCROLL_FADE+2
	_BNEZ	$t0,Scroll_RightNoFade
	movi	$t1,SCROLL_RIGHT
	sub	$t0,$t1,$a1
	sll	$a3,$t0,10
Scroll_RightNoFade:
Scroll_Print:
	_BEQZ	$s2,Scroll_DontEndEarly
	_LDA	$t2,Scroll_LastChar
	_BNE	$t2,$s1,Scroll_DontEndEarly
	movi	$a0,' 
	_JAL	PrintASCII
	_B	Scroll_Continue
	
Scroll_DontEndEarly:
	_JAL	PrintASCII
	addi	$s1,$s1,1
	
Scroll_Continue:
	movi	$t2,Scroll_Length+1
	_BNE	$s1,$t2,Scroll_NoLoopOver
	clr	$s1
Scroll_NoLoopOver:
	addi	$a1,$a1,8
	slti	$t0,$a1,312
	_BNEZ	$t0,Scroll_PrintLoop
	_LI	$t0,Scroll_Slide
	_LW	$t1,0($t0)
	_LDA	$t2,Scroll_Speed
	add	$t1,$t1,$t2
	slt	$t2,$t1,$zero
	_BEQZ	$t2,Scroll_SlideOn
	movi	$t3,7
	and	$t1,$t1,$t3
Scroll_SlideOn:	
	_SW	$t1,0($t0)

	_BEQZ	$s2,Scroll_DontSetLastChar
	movi	$t0,-1
	_LDA	$t1,Scroll_LastChar
	_BNE	$t0,$t1,Scroll_DontSetLastChar
	_STA	$s1,Scroll_LastChar
	movi	$t0,-4
	_STA	$t0,Scroll_Speed
Scroll_DontSetLastChar:

	_LI	$t0,Scroll_Char
	_LW	$t1,0($t0)
	add	$t1,$t1,$t2
	movi	$t2,Scroll_Length+1
	_BNE	$t1,$t2,Scroll_ScrollOn
	clr	$t1
Scroll_ScrollOn:
	_SW	$t1,0($t0)

	movi	$v1,1
Scroll_FadeDone:
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	
	_RTS



Scroll_Char:		.dc	0
Scroll_Slide:		.dc	0
Scroll_LastChar:	.dc	0
Scroll_Speed:		.dc	0

Scroll_Text:	.file	TheText.Txt 512/4
Scroll_Text_End:
Scroll_Pad:	.pad	4,0
Scroll_Length = 4*[Scroll_Text_End-Scroll_Text]
	
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
# 	Wait 1.5 bit time (312 clk)
# 	for (k=1;k=9;k++)
# 		Sample bit
# 		Wait 1.0 bit time (208 clk)
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
BOOTLOADER_LOGO = BOOTLOADER_ADDR-BOOTLOADER_START+BootLogo####################
# GfxBox Registers #
####################

GFX_TOPPOS = 0
GFX_LEFTPOS = 1
GFX_WIDTH = 2
GFX_HEIGHT = 3
GFX_PIXREAD = 4
GFX_SCRADDR = 5
GFX_DELTA = 6
GFX_ROWLENGTH = 7
GFX_HSYNC = 8
GFX_ESYNC = 9
GFX_VSYNC = 10

ClearScreen:
	_LDA	$t0,WorkScreen
	addiu	$t1,$t0,0xa000
Clear_loop:
	sw	$zero,0($t0)
	sw	$zero,1($t0)
	sw	$zero,2($t0)
	sw	$zero,3($t0)
	sw	$zero,4($t0)
	sw	$zero,5($t0)
	sw	$zero,6($t0)
	sw	$zero,7($t0)
	sw	$zero,8($t0)
	sw	$zero,9($t0)
	sw	$zero,10($t0)
	sw	$zero,11($t0)
	sw	$zero,12($t0)
	sw	$zero,13($t0)
	sw	$zero,14($t0)
	sw	$zero,15($t0)
	addi	$t0,$t0,16
	_BNE	$t0,$t1,Clear_loop
	_RTS

CopyActiveToWork:
	_LDA	$t0,WorkScreen
	_LDA	$t1,ViewScreen
	addiu	$t2,$t0,0xa000
CopyActiveToWork_Loop:
	lw	$t3,0($t0)
	nop
	lw	$t4,1($t0)
	nop
	lw	$t5,2($t0)
	nop
	lw	$t6,3($t0)
	nop
	lw	$t7,4($t0)
	nop
	lw	$t8,5($t0)
	nop
	lw	$t9,6($t0)
	nop
	sw	$t3,0($t1)	
	sw	$t4,1($t1)	
	sw	$t5,2($t1)	
	sw	$t6,3($t1)	
	sw	$t7,4($t1)	
	sw	$t8,5($t1)	
	sw	$t9,6($t1)	
	lw	$t3,7($t0)
	nop
	lw	$t4,8($t0)
	nop
	lw	$t5,9($t0)
	nop
	lw	$t6,10($t0)
	nop
	lw	$t7,11($t0)
	nop
	lw	$t8,12($t0)
	nop
	lw	$t9,13($t0)
	nop
	sw	$t3,7($t1)	
	sw	$t4,8($t1)	
	sw	$t5,9($t1)	
	sw	$t6,10($t1)	
	sw	$t7,11($t1)	
	sw	$t8,12($t1)	
	sw	$t9,13($t1)	
	lw	$t3,14($t0)
	nop
	lw	$t4,15($t0)
	nop
	sw	$t3,14($t1)	
	sw	$t4,15($t1)	
	addi	$t0,$t0,0x10
	addi	$t1,$t1,0x10
	_BNE	$t0,$t2,CopyActiveToWork_Loop
	_RTS
	
ScreenFadeList:
	.dc	FadeOutLeftRight,FadeOutTopDown
ScreenFadeList_End:	

SCREENFADELIST_SIZE = ScreenFadeList_End-ScreenFadeList

ScreenFadeOut:
	PUSH	$ra
	_JAL	Rnd
	mov	$a0,$v0
	movi	$a1,SCREENFADELIST_SIZE
	_JAL	Divu16
	_LDO	$t0,ScreenFadeList,$v1
	nop
	nop
	nop
	nop
	nop
	_JALR	$t0,$ra
	POP	$ra
	_RTS

LEFTRIGHT_ROWS = 256
LEFTRIGHT_COLS = 160
LEFTRIGHT_FRAMES = 50
LEFTRIGHT_STEP = LEFTRIGHT_COLS/LEFTRIGHT_FRAMES+1
LEFTRIGHT_HEIGHT = 8

FadeOutLeftRight:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1

	_JAL	WaitNextFrameNoSwap
	_JAL	CopyActiveToWork
	
	movi	$s1,-LEFTRIGHT_STEP
	movi	$s0,LEFTRIGHT_FRAMES
FadeOutLeftRight_FrameLoop:	
	_LDA	$t0,WorkScreen
	movi	$t9,LEFTRIGHT_ROWS/LEFTRIGHT_HEIGHT/2
FadeOutLeftRight_RowLoop:
	mov	$t3,$s1
	mov	$t1,$t0
	addi	$t2,$t0,160*LEFTRIGHT_HEIGHT*2-1
	movi	$t8,2*LEFTRIGHT_STEP
FadeOutLeftRight_ColLoop:
	slti	$t4,$t3,0
	_BNEZ	$t4,FadeOutLeftRight_OutsideScreen
	slti	$t4,$t3,160
	_BEQZ	$t4,FadeOutLeftRight_OutsideScreen
	add	$t4,$t1,$t3
	sub	$t5,$t2,$t3
	
	
	movi	$t7,LEFTRIGHT_HEIGHT	
FadeOutLeftRight_BlockLoop:

	_LI	$t6,0x20000	; Check if address t4 or t5 ever writes outside 
	slt	$at,$t4,$t6	
	_BNEZ	$at,Error	; if so jump to foreverloop error
	slt	$at,$t5,$t6
	_BNEZ	$at,Error
	_LI	$t6,0x33fff	; doublebuffer area 0x20000-0x33fff
	slt	$at,$t6,$t4
	_BNEZ	$at,Error
	slt	$at,$t6,$t5
	_BNEZ	$at,Error

	sw	$zero,0($t4)
	sw	$zero,0($t5)
	addi	$t4,$t4,160
	addi	$t5,$t5,-160
	addi	$t7,$t7,-1
	_BNEZ	$t7,FadeOutLeftRight_BlockLoop

FadeOutLeftRight_OutsideScreen:
	addi	$t3,$t3,1
	addi	$t8,$t8,-1
	_BNEZ	$t8,FadeOutLeftRight_ColLoop
	addi	$t0,$t0,160*LEFTRIGHT_HEIGHT*2
	addi	$t9,$t9,-1
	_BNEZ	$t9,FadeOutLeftRight_RowLoop
	addi	$s0,$s0,-1
	_JAL	WaitNextFrame
	addi	$s1,$s1,LEFTRIGHT_STEP
	_BNEZ	$s0,FadeOutLeftRight_FrameLoop
		
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS

TOPDOWN_ROWS = 256
TOPDOWN_COLS = 160
TOPDOWN_FRAMES = 50
TOPDOWN_STEP = TOPDOWN_ROWS/TOPDOWN_FRAMES+1
TOPDOWN_WIDTH = 4

FadeOutTopDown:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1

	_JAL	WaitNextFrameNoSwap
	_JAL	CopyActiveToWork

	movi	$s1,-TOPDOWN_STEP
	movi	$s0,TOPDOWN_FRAMES
FadeOutTopDown_FrameLoop:	
	_LDA	$t0,WorkScreen
	movi	$t9,TOPDOWN_COLS/TOPDOWN_WIDTH/2
FadeOutTopDown_ColLoop:
	mov	$t3,$s1
	mov	$t1,$t0
	addiu	$t2,$t0,255*160+TOPDOWN_WIDTH*2-1
	movi	$t8,2*TOPDOWN_STEP
FadeOutTopDown_RowLoop:
	slti	$t4,$t3,0
	_BNEZ	$t4,FadeOutTopDown_OutsideScreen
	slti	$t4,$t3,256
	_BEQZ	$t4,FadeOutTopDown_OutsideScreen
	
	sll	$t4,$t3,7
	sll	$t5,$t3,5
	add	$t5,$t5,$t4
	
	add	$t4,$t1,$t5
	sub	$t5,$t2,$t5

	movi	$t7,TOPDOWN_WIDTH
FadeOutTopDown_BlockLoop:

	_LI	$t6,0x20000	; Check if address t4 or t5 ever writes outside 
	slt	$at,$t4,$t6	
	_BNEZ	$at,Error	; if so jump to foreverloop error
	slt	$at,$t5,$t6
	_BNEZ	$at,Error
	_LI	$t6,0x33fff	; doublebuffer area 0x20000-0x33fff
	slt	$at,$t6,$t4
	_BNEZ	$at,Error
	slt	$at,$t6,$t5
	_BNEZ	$at,Error

	sw	$zero,0($t4)
	sw	$zero,0($t5)
	addi	$t4,$t4,1
	addi	$t5,$t5,-1
	addi	$t7,$t7,-1
	_BNEZ	$t7,FadeOutTopDown_BlockLoop		
FadeOutTopDown_OutsideScreen:
	addi	$t3,$t3,1
	addi	$t8,$t8,-1
	_BNEZ	$t8,FadeOutTopDown_RowLoop
	addi	$t0,$t0,TOPDOWN_WIDTH*2
	addi	$t9,$t9,-1
	_BNEZ	$t9,FadeOutTopDown_ColLoop
	addi	$s0,$s0,-1
	_JAL	WaitNextFrame
	addi	$s1,$s1,TOPDOWN_STEP
	_BNEZ	$s0,FadeOutTopDown_FrameLoop
		
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS

FadeDown:
	mov	$t0,$a0
	srl	$t1,$t0,27	; Mask out Red Left
	sll	$t0,$t0,5
	srl	$t2,$t0,27	; Mask out Green Left
	sll	$t0,$t0,6
	srl	$t3,$t0,27	; Mask out Blue Left
	sll	$t0,$t0,5
	srl	$t4,$t0,27	; Mask out Red Right
	sll	$t0,$t0,5
	srl	$t5,$t0,27	; Mask out Green Right
	sll	$t0,$t0,6
	srl	$t6,$t0,27	; Mask out Blue RIght
	clr	$v1		; clear /done flag
	mov	$t7,$a1		
	srl	$t8,$t7,27	; Get destination value Red Left
	sll	$t7,$t7,5
	slt	$t0,$t8,$t1	; To High ?
	sub	$t1,$t1,$t0	; Then Sub
	slt	$t0,$t8,$t1	; To High ?
	sub	$t1,$t1,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t1,$t8	; To Low ?
	add	$t1,$t1,$t0	; Then Add
	slt	$t0,$t1,$t8	; To Low ?
	add	$t1,$t1,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	srl	$t8,$t7,27	; Get destination value Green Left
	sll	$t7,$t7,6	
	slt	$t0,$t8,$t2	; To High ?
	sub	$t2,$t2,$t0	; Then Sub
	slt	$t0,$t8,$t2	; To High ?
	sub	$t2,$t2,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t2,$t8	; To Low ?
	add	$t2,$t2,$t0	; Then Add
	slt	$t0,$t2,$t8	; To Low ?
	add	$t2,$t2,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	srl	$t8,$t7,27	; Get destination value Blue Left
	sll	$t7,$t7,5
	slt	$t0,$t8,$t3	; To High ?
	sub	$t3,$t3,$t0	; Then Sub
	slt	$t0,$t8,$t3	; To High ?
	sub	$t3,$t3,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t3,$t8	; To Low ?
	add	$t3,$t3,$t0	; Then Add
	slt	$t0,$t3,$t8	; To Low ?
	add	$t3,$t3,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	srl	$t8,$t7,27	; Get destination value Red Right
	sll	$t7,$t7,5
	slt	$t0,$t8,$t4	; To High ?
	sub	$t4,$t4,$t0	; Then Sub
	slt	$t0,$t8,$t4	; To High ?
	sub	$t4,$t4,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t4,$t8	; To Low ?
	add	$t4,$t4,$t0	; Then Add
	slt	$t0,$t4,$t8	; To Low ?
	add	$t4,$t4,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	srl	$t8,$t7,27	; Get destination value Green Right
	sll	$t7,$t7,6
	slt	$t0,$t8,$t5	; To High ?
	sub	$t5,$t5,$t0	; Then Sub
	slt	$t0,$t8,$t5	; To High ?
	sub	$t5,$t5,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t5,$t8	; To Low ?
	add	$t5,$t5,$t0	; Then Add
	slt	$t0,$t5,$t8	; To Low ?
	add	$t5,$t5,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	srl	$t8,$t7,27	; Get destination value Blue Right
	slt	$t0,$t8,$t6	; To High ?
	sub	$t6,$t6,$t0	; Then Sub
	slt	$t0,$t8,$t6	; To High ?
	sub	$t6,$t6,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t6,$t8	; To Low ?
	add	$t6,$t6,$t0	; Then Add
	slt	$t0,$t6,$t8	; To Low ?
	add	$t6,$t6,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	sll	$v0,$t1,27	; Merge in Red Left	
	sll	$t2,$t2,22
	or	$v0,$v0,$t2	; Merge in Green Left
	sll	$t3,$t3,16
	or	$v0,$v0,$t3	; Merge in Blue Left
	sll	$t4,$t4,11
	or	$v0,$v0,$t4	; Merge in Red Right
	sll	$t5,$t5,6
	or	$v0,$v0,$t5	; Merge in Green Right
	or	$v0,$v0,$t6	; Merge in Blue Right
	_RTS

FadeSourceToDest:
	mov	$t0,$a0
	sll	$t0,$t0,16
	srl	$t4,$t0,27	; Mask out Red
	sll	$t0,$t0,5
	srl	$t5,$t0,27	; Mask out Green
	sll	$t0,$t0,6
	srl	$t6,$t0,27	; Mask out Blue
	clr	$v1		; clear /done flag
	
	mov	$t7,$a1		
	sll	$t7,$t7,16
	srl	$t8,$t7,27	; Get destination value Red Left
	sll	$t7,$t7,5
	slt	$t0,$t8,$t4	; To High ?
	sub	$t4,$t4,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t4,$t8	; To Low ?
	add	$t4,$t4,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	
	srl	$t8,$t7,27	; Get destination value Green Right
	sll	$t7,$t7,6
	slt	$t0,$t8,$t5	; To High ?
	sub	$t5,$t5,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t5,$t8	; To Low ?
	add	$t5,$t5,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	
	srl	$t8,$t7,27	; Get destination value Blue Right
	slt	$t0,$t8,$t6	; To High ?
	sub	$t6,$t6,$t0	; Then Sub
	or	$v1,$v1,$t0	; We are not done
	slt	$t0,$t6,$t8	; To Low ?
	add	$t6,$t6,$t0	; Then Add
	or	$v1,$v1,$t0	; We are not done
	
	sll	$v0,$t4,11	; Merge in Red Right
	sll	$t5,$t5,6
	or	$v0,$v0,$t5	; Merge in Green Right
	or	$v0,$v0,$t6	; Merge in Blue Right
	_RTS

SetColor:
	_LI	$t0,theColor
	_SW	$a0,0($t0)
	_RTS
	
theColor:	.dc	0xffff

Point:
	_LI	$t0,theColor
	lw	$t7,0($t0)		; Get Color
	srl	$t1,$a0,1		; t1 = xpos
	_LI	$t0,WorkScreen
	lw	$t0,0($t0)
	sll	$t2,$a1,7		; t2 = ypos*128
	sll	$t3,$a1,5		; t3 = ypos*32
	add	$t0,$t0,$t1
	add	$t0,$t0,$t2		
	add	$t0,$t0,$t3		
	
	lw	$t2,0($t0)		; Get Pixel
	moviu	$t4,0xffff		; Set Mask
	sll	$t1,$t7,16		; Shift Color to upper half
	sll	$t3,$a0,31		
	slti	$t3,$t3,0		; Is it an odd or even pixel
	sll	$t3,$t3,4		; Mult by 16
	srlv	$t1,$t1,$t3		; Set Color in correct half
	sllv	$t4,$t4,$t3		; Set Mask in correct half
	and	$t2,$t2,$t4		; Mask
	or	$t2,$t2,$t1		; Set
	nop
	nop
	sw	$t2,0($t0)		; Set Pixel
	
	_RTS

FilledRect:
	; a0 - X0
	; a1 - Y0
	; a2 - Width
	; a3 - Height

	_LI	$t0,WorkScreen
	lw	$t0,0($t0)
	nop
	_LI	$t7,theColor
	lw	$t7,0($t7)
	moviu	$t3,0xffff	; LeftMask
	lui	$t4,0xffff	; RightMask
	sll	$t5,$t7,16	; LeftPix
	srl	$t6,$t5,16	; RightPix
	or	$t7,$t5,$t6	; BothPix
	nop
	srl	$t1,$a0,1
	add	$t0,$t0,$t1
	sll	$t1,$a1,7
	add	$t0,$t0,$t1
	sll	$t1,$a1,5
	add	$t0,$t0,$t1
	
	sll	$t1,$a0,31
	_BEQZ	$t1,FilledRect_LeftEven

	mov	$t9,$t0
	mov	$t8,$a3
FilledRect_LeftOddLoop:
	_LW	$t1,0($t9)
	and	$t1,$t1,$t4
	or	$t1,$t1,$t6
	_SW	$t1,0($t9)
	addi	$t9,$t9,160
	addi	$t8,$t8,-1
	_BNEZ	$t8,FilledRect_LeftOddLoop
	addi	$a0,$a0,1
	addi	$a2,$a2,-1
	addi	$t0,$t0,1
	
FilledRect_LeftEven:
	add	$t1,$a0,$a2
	sll	$t1,$t1,31
	_BEQZ	$t1,FilledRect_RightEven

	mov	$t9,$t0
	srl	$t1,$a2,1
	add	$t9,$t9,$t1
	
	mov	$t8,$a3
FilledRect_RightOddLoop:
	_LW	$t1,0($t9)
	and	$t1,$t1,$t3
	or	$t1,$t1,$t5
	_SW	$t1,0($t9)
	addi	$t9,$t9,160
	addi	$t8,$t8,-1
	_BNEZ	$t8,FilledRect_RightOddLoop
	addi	$a2,$a2,-1	
FilledRect_RightEven:

	srl	$t1,$a2,1
FilledRect_FillRowLoop:
	mov	$t8,$a3
	mov	$t9,$t0
FilledRect_FillColLoop:
	_SW	$t7,0($t9)
	addi	$t9,$t9,160
	addi	$t8,$t8,-1
	_BNEZ	$t8,FilledRect_FillColLoop
	addi	$t0,$t0,1
	addi	$t1,$t1,-1
	_BNEZ	$t1,FilledRect_FillRowLoop
	
	_RTS
	









	
	
	



Line:	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	
	movi	$t5,160				; Yinc = t5
	
	_LI	$t7,theColor
	lw	$t7,0($t7)
	nop

	_BGE	$a2,$a0,Line_dont_swap_X	; Make  
	mov	$t0,$a0				; a0
	mov	$a0,$a2				; less
	mov	$a2,$t0				; than
	mov	$t0,$a1				; a2
	mov	$a1,$a3				; xinc always 1
	mov	$a3,$t0
Line_dont_swap_X:

	_LI	$t0,WorkScreen
	lw	$t0,0($t0)
	sll	$t1,$a1,7	; y1 = y1 * 128
	add	$t8,$t0,$t1
	sll	$t1,$a1,5	; y1 = y1 * 32
	add	$t8,$t8,$t1	; y1 row addr in t8
	sll	$t1,$a3,7	; y2 = y2 * 128
	add	$t9,$t0,$t1
	sll	$t1,$a3,5	; y2 = y2 * 32
	add	$t9,$t9,$t1	; y2 row addr in t9

	lui	$t0,0x8000
	sub	$s0,$a2,$a0			; dX = s0
	sub	$s1,$a3,$a1			; dY = s1

	_BGE	$t0,$s1,Line_dont_neg_dY
	neg	$s1,$s1				; dY = -dY
	neg	$t5,$t5				; Yinc = -Yinc
Line_dont_neg_dY:
	_BEQZ	$s0,Line_Vertical
	_BEQZ	$s1,Line_Horizontal
	_BGT	$s1,$s0,Line_Big_dY
Line_Big_dX:
	sll	$s3,$s1,1	;s3 = dPr = 2*dY
	neg	$s2,$s0		;s2 = P = -dX
	sll	$s4,$s2,1	;s4 = dPru = -2*dX
	srl	$t4,$s0,1	;t4 = loop counter = dX/2
	_BEQZ	$t4,Line_Big_dX_MidPoint
Line_Big_dX_Loop:
	srl	$t6,$a0,1	
	add	$t6,$t6,$t8
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a0,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	addi	$a0,$a0,1	
	add	$s2,$s2,$s3
	sw	$t0,0($t6)

	srl	$t6,$a2,1	
	add	$t6,$t6,$t9
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a2,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	addi	$a2,$a2,-1	
	nop
	sw	$t0,0($t6)

	slti	$t0,$s2,0
	_BNEZ	$t0,Line_Big_dX_Next
Line_Big_dX_RightUp:
	add	$s2,$s2,$s4
	add	$t8,$t8,$t5
	sub	$t9,$t9,$t5
Line_Big_dX_Next:
	addi	$t4,$t4,-1
	_BNEZ	$t4,Line_Big_dX_Loop
Line_Big_dX_MidPoint:
	srl	$t6,$a0,1	
	add	$t6,$t6,$t8
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a0,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	addi	$a0,$a0,1	
	add	$s2,$s2,$s3
	sw	$t0,0($t6)

	andi	$t0,$s0,1
	_BEQZ	$t0,Line_Done
	
	srl	$t6,$a2,1	
	add	$t6,$t6,$t9
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a2,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	addi	$a2,$a2,-1	
	nop
	sw	$t0,0($t6)

	_J	Line_Done

Line_Big_dY:
	sll	$s3,$s0,1	;s3 = dPr = 2*dX
	neg	$s2,$s1		;s2 = P = -dY
	sll	$s4,$s2,1	;s4 = dPru = -2*dY
	srl	$t4,$s1,1	;t4 = loop counter = dY/2
	_BEQZ	$t4,Line_Big_dY_MidPoint
Line_Big_dY_Loop:
	srl	$t6,$a0,1	
	add	$t6,$t6,$t8
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a0,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	add	$t8,$t8,$t5
	add	$s2,$s2,$s3
	sw	$t0,0($t6)

	srl	$t6,$a2,1	
	add	$t6,$t6,$t9
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a2,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	sub	$t9,$t9,$t5
	nop
	sw	$t0,0($t6)

	slti	$t0,$s2,0
	_BNEZ	$t0,Line_Big_dY_Next
Line_Big_dY_RightUp:
	add	$s2,$s2,$s4
	addi	$a0,$a0,1
	addi	$a2,$a2,-1	
Line_Big_dY_Next:
	addi	$t4,$t4,-1
	_BNEZ	$t4,Line_Big_dY_Loop
Line_Big_dY_MidPoint:
	srl	$t6,$a0,1	
	add	$t6,$t6,$t8
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a0,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop	
	nop	
	sw	$t0,0($t6)

	andi	$t0,$s1,1
	_BEQZ	$t0,Line_Done
	
	srl	$t6,$a2,1	
	add	$t6,$t6,$t9
	lw	$t0,0($t6)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a2,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop	
	nop
	sw	$t0,0($t6)
	_J	Line_Done	
	
Line_Vertical:
	srl	$t4,$s1,1	;t4 = loop counter = dY/2
	srl	$t0,$a0,1	
	add	$t8,$t8,$t0
	add	$t9,$t9,$t0

	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a0,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	_BEQZ	$t4,Line_Vertical_MidPoint
Line_Vertical_Loop:
	lw	$t0,0($t8)
	nop
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop
	nop
	sw	$t0,0($t8)

	lw	$t0,0($t9)
	nop
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop
	nop
	sw	$t0,0($t9)

	add	$t8,$t8,$t5
	sub	$t9,$t9,$t5
	
	addi	$t4,$t4,-1
	_BNEZ	$t4,Line_Vertical_Loop

Line_Vertical_MidPoint:	
	lw	$t0,0($t8)
	nop
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop
	nop
	sw	$t0,0($t8)
	
	andi	$t0,$s1,1
	_BEQZ	$t0,Line_Done
	
	lw	$t0,0($t9)
	nop
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop
	nop
	sw	$t0,0($t9)
	
	_J	Line_Done
	
Line_Horizontal:
	addi	$s0,$s0,1
	srl	$t0,$a0,1
	add	$t8,$t8,$t0
	srl	$t0,$a2,1
	add	$t9,$t9,$t0

	andi	$t0,$a0,1
	_BEQZ	$t0,Line_Horizontal_LeftEven
	
	lw	$t0,0($t8)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a0,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop
	nop
	sw	$t0,0($t8)
	addi	$t8,$t8,1
	addi	$s0,$s0,-1
	
Line_Horizontal_LeftEven:
	andi	$t0,$a2,1
	_BNEZ	$t0,Line_Horizontal_RightOdd

	lw	$t0,0($t9)
	moviu	$t2,0xffff
	sll	$t1,$t7,16
	sll	$t3,$a2,31
	slti	$t3,$t3,0
	sll	$t3,$t3,4
	srlv	$t1,$t1,$t3
	sllv	$t2,$t2,$t3
	and	$t0,$t0,$t2
	or	$t0,$t0,$t1
	nop
	nop
	sw	$t0,0($t9)
	addi	$t9,$t9,-1
	addi	$s0,$s0,-1
	
Line_Horizontal_RightOdd:
	srl	$t4,$s0,1	;t4 = loop counter = dY/2
	_BEQZ	$t4,Line_Done
	
	sll	$t1,$t7,16
	or	$t1,$t1,$t7
	nop
	nop
Line_Horizontal_Loop:
	sw	$t1,0($t8)
	addi	$t8,$t8,1
	addi	$t4,$t4,-1
	_BNEZ	$t4,Line_Horizontal_Loop
Line_Horizontal_MidPoint;	
	_J	Line_Done

Line_Diagonal:
	_J	Line_Done

Line_Done:
	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	_RTS
	
#######################
# Wait for next frame #
#######################
	
WorkScreen:
	.dc	0
ViewScreen:
	.dc	0
CurrentScreen:
	.dc	0
FrameCount:
	.dc	0
	
SWAP_LINE = 280

WaitNextFrame:			
	_LDA	$t0,WorkScreen
	_LDA	$t1,ViewScreen
	_STA	$t1,WorkScreen
	_STA	$t0,ViewScreen
	_SW	$t0,GFX_SCRADDR($gfx)
	_STA	$t0,CurrentScreen

	movi	$t0, 3
	movi	$t2, SWAP_LINE
NextFrame_Loop:	
	mfc1	$t1, $t0	
	_BNE	$t1, $t2, NextFrame_Loop

	movi	$t0, 3
	movi	$t2, SWAP_LINE+1
NextFrame_Loop2:	
	mfc1	$t1, $t0	
	_BNE	$t1, $t2, NextFrame_Loop2

	_LI	$t0, FrameCount
	_LW	$t1, 0($t0)
	addi	$t1,$t1,1
	_SW	$t1, 0($t0)
						
	_RTS		; Return from subroutine
	
#######################
# WaitNextFrameNoSwap #
#######################

WaitNextFrameNoSwap:	
	movi	$t0, 3
	movi	$t2, 280
NextFrameNoSwap_Loop:	
	mfc1	$t1, $t0	
	_BNE	$t1, $t2, NextFrameNoSwap_Loop	
	movi	$t2, 281
NextFrameNoSwap_Loop2:	
	mfc1	$t1, $t0	
	_BNE	$t1, $t2, NextFrameNoSwap_Loop2

	_LI	$t0, FrameCount
	_LW	$t1, 0($t0)
	addi	$t1,$t1,1
	_SW	$t1, 0($t0)

	_RTS

##############
# WaitFrames #
##############

WaitFrames:
	mov	$t9,$a0
WaitFrames_Loop:	
	movi	$t0, 3
	movi	$t2, 280
WaitFrames_InnerLoop:	
	mfc1	$t1, $t0	
	_BNE	$t1, $t2, WaitFrames_InnerLoop
	movi	$t2, 281
WaitFrames_InnerLoop2:	
	mfc1	$t1, $t0	
	_BNE	$t1, $t2, WaitFrames_InnerLoop2

	_LI	$t0, FrameCount
	_LW	$t1, 0($t0)
	addi	$t1,$t1,1
	_SW	$t1, 0($t0)
		
	addi	$t9,$t9,-1
	_BNEZ	$t9, WaitFrames_Loop	
	_RTS

#####################
# DoubleBufferStuff #
#####################

SetupDoubleBuffer:
	_STA	$a0,WorkScreen
	_STA	$a1,ViewScreen
	_RTS

GetWorkScreen:
	_LDA	$v0,WorkScreen
	_RTS

GetActiveScreen:
	_LDA	$v0,ViewScreen
	_RTS
	
GetFrameCount:
	_LDA	$v0,FrameCount
	_RTS
	

##################
# Text Functions #
##################

PrintString:
	; a0 = string
	; a1 = x (left)
	; a2 = y (top)
	; a3 = HIGH = Transparent | LOW = Color
	; Transparent 0=No, 1=Yes

	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	
	mov	$s0,$a0
	mov	$s1,$a1

String_NextWord:
	_LW	$s2,0($s0)
	addi	$s0,$s0,1
	movi	$s3,4
String_NextChar:
	srl	$a0,$s2,24
	mov	$a1,$s1
	_BEQZ	$a0,String_Done
	_JAL	PrintASCII
	addi	$s1,$s1,8
	sll	$s2,$s2,8
	addi	$s3,$s3,-1
	_BNEZ	$s3,String_NextChar
	_J	String_NextWord
	
String_Done:
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS

PrintLargeString:
	; a0 = string
	; a1 = x (left)
	; a2 = y (top)
	; a3 = Color

	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	
	mov	$s0,$a0
	mov	$s1,$a1

Large_NextWord:
	_LW	$s2,0($s0)
	addi	$s0,$s0,1
	movi	$s3,4
Large_NextChar:
	srl	$a0,$s2,24
	mov	$a1,$s1
	_BEQZ	$a0,Large_Done
	_JAL	PrintLargeASCII
	addi	$s1,$s1,16
	sll	$s2,$s2,8
	addi	$s3,$s3,-1
	_BNEZ	$s3,Large_NextChar
	_J	Large_NextWord
	
Large_Done:
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS


PrintASCII:
	; a0 = ASCII
	; a1 = x (left)
	; a2 = y (top)
	; a3 = HIGH = Transparent | LOW = Color
	; Transparent 0=No, 1=Yes
	
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	
	_LI	$s0,Font8x16		; Array Offset
	mov	$t0,$a0			; ASCII value
	srl	$t1,$t0,4		; Get Row in font
	sll	$t1,$t1,6		; 128 pixels each row gives 128/8x16=256 bytes=64 words before next char row
	add	$s0,$s0,$t1		; We are on the right row
	
	andi	$t0,$t0,0x000f		; Get Col in font
	srl	$t1,$t0,2		; 1 byte in each col gives 1/4 word
	add	$s0,$s0,$t1		; We are on the right col
	
	andi	$t0,$t0,0x0003		; Byteoffset in word
	sll	$s4,$t0,3		; Shiftamount in word = Byteoffset*8

	srl	$t6,$a3,16		; Transparant in $t6
	sll	$t7,$a3,16		; color in $t7 High/Left
	srl	$t8,$t7,16		; color in $t8 Low/Right
		
	_LI	$t0,WorkScreen		; Screen Offset
	_LW	$s1,0($t0)

	srl	$t0,$a1,1		; X / 2
	add	$s1,$s1,$t0		; Add X Offset to workscreen
	
	sll	$t0,$a2,7		; Y * 128
	sll	$t1,$a2,5		; Y * 32
	add	$t0,$t0,$t1		; Y * 160
	add	$s1,$s1,$t0		; Add Y Offset to workscreen

	movi	$s3,16			; 16 Rows in total
ASCII_RowLoop:	
	_LW	$t1,0($s0)		; Read font data
	sllv	$t1,$t1,$s4		; Character offset in word (4 characters in each word)
	movi	$s2,4			; 4 Words = 8 pixels on screen
ASCII_ColLoop:
	clr	$t0			; Clear $t0
	_BEQZ	$t6,ASCII_NotTrans	; Should the character be transparent ?
	_LW	$t0,0($s1)		; Get The word on screen
ASCII_NotTrans:
	slt	$t2,$t1,$zero		; Is pixel set in font ?
	_BEQZ	$t2,ASCII_NoLeft	; If not continue
	sll	$t0,$t0,16		; Mask away left pixel
	srl	$t0,$t0,16
	or	$t0,$t0,$t7		; Yes, set left part of word	
ASCII_NoLeft:
	sll	$t1,$t1,1		; Next pixel
	slt	$t2,$t1,$zero		; Is pixel set in font ?
	_BEQZ	$t2,ASCII_NoRight	; If not continue
	srl	$t0,$t0,16		; Mask away right pixel
	sll	$t0,$t0,16
	or	$t0,$t0,$t8		; Yes, set right part of word
ASCII_NoRight:
	_SW	$t0,0($s1)		; Store pixel
	sll	$t1,$t1,1		; Next pixel
	addi	$s1,$s1,1		; Next word on screen
	addi	$s2,$s2,-1		; Word=Word-1
	_BNEZ	$s2,ASCII_ColLoop	; Is this row done ?
	
	addi	$s1,$s1,156		; Add number of words until next row on screen
	
	addi	$s3,$s3,-1		; Row=Row-1
	addi	$s0,$s0,4		; Add number of words until next row in font
	_BNEZ	$s3,ASCII_RowLoop	; Are we done with this character ?

	POP	$s4			
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	
	_RTS

PrintLargeASCII:
	; a0 = ASCII
	; a1 = x (left)
	; a2 = y (top)
	; a3 = Color
	
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	
	_LI	$s0,Font8x16		; Array Offset
	mov	$t0,$a0			; ASCII value
	srl	$t1,$t0,4		; Get Row in font
	sll	$t1,$t1,6		; 128 pixels each row gives 128/8x16=256 bytes=64 words before next char row
	add	$s0,$s0,$t1		; We are on the right row
	
	andi	$t0,$t0,0x000f		; Get Col in font
	srl	$t1,$t0,2		; 1 byte in each col gives 1/4 word
	add	$s0,$s0,$t1		; We are on the right col
	
	andi	$t0,$t0,0x0003		; Byteoffset in word
	sll	$s4,$t0,3		; Shiftamount in word = Byteoffset*8

	sll	$t7,$a3,16		; color in $t7 High/Left
	srl	$t8,$t7,16		; color in $t8 Low/Right
	or	$t7,$t7,$t8		; color in $t7 (High and Low)
		
	_LI	$t0,WorkScreen		; Screen Offset
	_LW	$s1,0($t0)

	srl	$t0,$a1,1		; X / 2
	add	$s1,$s1,$t0		; Add X Offset to workscreen
	
	sll	$t0,$a2,7		; Y * 128
	sll	$t1,$a2,5		; Y * 32
	add	$t0,$t0,$t1		; Y * 160
	add	$s1,$s1,$t0		; Add Y Offset to workscreen

	movi	$s3,16			; 16 Rows in total
Large_RowLoop:	
	_LW	$t1,0($s0)		; Read font data
	sllv	$t1,$t1,$s4		; Character offset in word (4 characters in each word)
	movi	$s2,8			; 4 Words = 8 pixels on screen
Large_ColLoop:
	slt	$t2,$t1,$zero		; Is pixel set in font ?
	_BEQZ	$t2,Large_NotSet	; If not continue
	_SW	$t7,0($s1)		;
	_SW	$t7,160($s1)		;
Large_NotSet:
	sll	$t1,$t1,1		; Next pixel
	addi	$s1,$s1,1		; Next word on screen
	addi	$s2,$s2,-1		; Word=Word-1
	_BNEZ	$s2,Large_ColLoop	; Is this row done ?
	
	addi	$s1,$s1,312		; Add number of words until next row on screen
	
	addi	$s3,$s3,-1		; Row=Row-1
	addi	$s0,$s0,4		; Add number of words until next row in font
	_BNEZ	$s3,Large_RowLoop	; Are we done with this character ?

	POP	$s4			
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	
	_RTS

PrintNumber16:
	; a0 = tal
	; a1 = x (right edge)
	; a2 = y (top edge)
	; a3 = color
	PUSH	$ra
	PUSH	$a0
	PUSH	$a1
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	
	mov	$s0,$a0
	addi	$s1,$a1,-8
	
	movi	$s2,5
PrintNumber16_Div10Loop:
	mov	$a0,$s0
	movi	$a1,10
	_JAL	Divu16
	mov	$s0,$v0
	
	mov	$a0,$v1
	addi	$a0,$a0,0x30	; ASCII Value for zero
	mov	$a1,$s1
	_JAL	PrintASCII
	_BEQZ	$s0,PrintNumber16_Done
	addi	$s1,$s1,-8
	addi	$s2,$s2,-1
	_BNEZ	$s2,PrintNumber16_Div10Loop

PrintNumber16_Done:

	POP	$s2
	POP	$s1
	POP	$s0
	POP	$a1
	POP	$a0
	POP	$ra
	_RTS
	

PrintHex:
	; a0 = tal
	; a1 = x (right edge)
	; a2 = y (top edge)
	; a3 = color
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4

	mov	$s0,$a0
	mov	$s1,$a1
	mov	$s2,$a2
	mov	$s3,$a3
	
	movi	$s4,8
PrintHex_Loop:
	movi	$t0,0xf
	and	$t0,$s0,$t0
	srl	$s0,$s0,4
	slti	$t1,$t0,10
	addi	$a0,$t0,0x30
	addi	$t1,$t1,-1
	srl	$t1,$t1,29
	add	$a0,$a0,$t1
PrintHex_LessThan10:
	mov	$a1,$s1
	mov	$a2,$s2
	mov	$a3,$s3
	_JAL	PrintASCII
	addi	$s1,$s1,-8
	addi	$s4,$s4,-1
	_BNEZ	$s4,PrintHex_Loop

	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS


########
# Font #
########

Font8x16:	.file	../TLib/Data/Font8x16.raw 1024
EnterHighDone:	.dc	0

StartEnterHigh:
	PUSH	$ra
	_JAL	WaitNextFrame

	_JAL	InitStars
	_JAL	PlayBeat
	
	_JAL	GetScore
	mov	$a0,$v0
	_JAL	OnHighScoreList
	_BEQZ	$v0,StartEnterHigh_Done
		
	_LI	$t0,JoyRepeatWait
	_LI	$t1,0x000a00			; Filter = 00, RepeatVal = 0a, Accelerate = 2
	nop
	nop
	sw	$t1,JOY_UP($t0)
	sw	$t1,JOY_LEFT($t0)
	sw	$t1,JOY_RIGHT($t0)
	sw	$t1,JOY_DOWN($t0)
	sw	$t1,JOY_BUTA($t0)
	sw	$t1,JOY_BUTB($t0)
	sw	$t1,JOY_BUTC($t0)
	sw	$t1,JOY_START($t0)

	_LI	$t0,EnterHighName
	movi	$t1,8
EnterHigh_ClearNameLoop:
	sw	$zero,0($t0)
	addi	$t0,$t0,1
	addi	$t1,$t1,-1
	_BNEZ	$t1,EnterHigh_ClearNameLoop
	_STA	$zero,EnterHighName

	_STA	$zero,EnterHighValX
	_STA	$zero,EnterHighValY
	
	_STA	$zero,EnterHighPos
	_STA	$zero,CircleAngle
	_STA	$zero,EnterHighDone
	moviu	$t0,0x7bef
	_STA	$t0,EnterHighTextTarget
	moviu	$t0,0xffe0
	_STA	$t0,EnterHighNameTarget
	_STA	$t0,EnterHighNameColor
	_STA	$zero,EnterHighTextColor
	_STA	$zero,EnterHighCircleColor
	_JAL	EnterHighFade
	moviu	$t0,0x07e0
	_STA	$t0,EnterHighCircleTarget
StartEnterHigh_Loop:
	_JAL	EnterHighFrame
	_BEQZ	$v0,StartEnterHigh_Loop

	_STA	$zero,EnterHighCircleTarget
	_STA	$zero,EnterHighTextTarget
	_STA	$zero,EnterHighNameTarget
	_JAL	EnterHighFade
	
	_JAL	CopyNameToString

	_JAL	GetScore
	mov	$a1,$v0
	_JAL	GetLevel
	mov	$a2,$v0
	_LI	$a0,ListName
	_JAL	AddToHighScoreList

StartEnterHigh_Done:
	_J	StartViewHighFromEnterHigh

	POP	$ra
	_RTS
	
EnterHighFrame:
	PUSH	$ra
	_JAL	Rnd
	_JAL	WaitNextFrame
	_JAL	FadeBeat
	_JAL	EnterHighJoyStick
	
	_JAL	GetWorkScreen
	mov	$a0,$v0
	_JAL	ClearScreen
	
	_JAL	Stars
	_JAL	DrawEnterHighText
	_JAL	DrawEnterHighName
	_JAL	DrawSelectionBox

EnterHighFrame_DontDrawSelection:
	_LDA	$v0,EnterHighDone
	POP	$ra
	_RTS

EnterHighFade:
	PUSH	$ra	
	PUSH	$s0
EnterHighFade_Loop:
	_JAL	WaitNextFrame
	_JAL	FadeBeat
	_JAL	GetWorkScreen
	mov	$a0,$v0
	_JAL	ClearScreen
	_JAL	Stars
	_JAL	DrawEnterHighText
	mov	$s0,$v0
	_JAL	DrawEnterHighName
	or	$s0,$s0,$v0
	_JAL	DrawSelectionBox
	or	$s0,$s0,$v0
	_BNEZ	$s0,EnterHighFade_Loop
	
	POP	$s0
	POP	$ra
	_RTS

EnterHighTextColor:	.dc	0
EnterHighTextTarget:	.dc	0

NOF_LETTERS = 8

ENTERHIGH_LEFT = 84
ENTERHIGH_TOP = 50
;ENTERHIGH_ROWSPACE = 20
ENTERHIGH_LETTERSPACEX = 16
ENTERHIGH_LETTERSPACEY = 20
 
DrawEnterHighText:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	PUSH	$s5
	
	_LDA	$t0,EnterHighTextColor
	_BEQZ	$t0,DrawEnterHighText_BlackText
	
	lui	$s5,0xffff
	
	movi	$s0,ENTERHIGH_LEFT
	movi	$s1,ENTERHIGH_TOP
	_LI	$s2,EnterHighLetters
	movi	$s3,46
	movi	$s4,10
DrawEnterHighText_Loop:
	_LW	$a0,0($s2)
	addi	$s2,$s2,1
	mov	$a1,$s0
	mov	$a2,$s1
	_LDA	$a3,EnterHighTextColor
	or	$a3,$a3,$s5
	_JAL	PrintASCII
	addi	$s0,$s0,ENTERHIGH_LETTERSPACEX
	addi	$s4,$s4,-1
	_BNEZ	$s4,DrawEnterHighText_NoChangeLine
	movi	$s4,10
	addi	$s0,$s0,-ENTERHIGH_LETTERSPACEX*10
	addi	$s1,$s1,ENTERHIGH_LETTERSPACEY
DrawEnterHighText_NoChangeLine:
	addi	$s3,$s3,-1
	_BNEZ	$s3,DrawEnterHighText_Loop

	_LI	$a0,EnterHighSpecialText
	mov	$a1,$s0
	mov	$a2,$s1
	_LDA	$a3,EnterHighTextColor
	or	$a3,$a3,$s5	
	_JAL	PrintString

DrawEnterHighText_BlackText:	
	_LDA	$a0,EnterHighTextColor
	_LDA	$a1,EnterHighTextTarget
	_JAL	FadeSourceToDest
	mov	$s0,$v0
	mov	$s1,$v1
	_JAL	GetFrameCount
	sll	$v0,$v0,31
	_BNEZ	$v0,DrawEnterHighText_DontFade
	_STA	$s0,EnterHighTextColor
DrawEnterHighText_DontFade:
	mov	$v0,$s1
	POP	$s5
	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS


EnterHighNameColor:	.dc	0
EnterHighNameTarget:	.dc	0

ENTERHIGH_NAMELEFT = 160

DrawEnterHighName:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1

	_LDA	$t0,EnterHighNameColor
	_BEQZ	$t0,DrawEnterHighName_BlackText
	
	clr	$s0
	movi	$s1,160
	_LDA	$t0,EnterHighPos
	addi	$t0,$t0,1
	sll	$t0,$t0,2
	sub	$s1,$s1,$t0
DrawEnterHighName_Loop:
	_LDO	$a0,EnterHighName,$s0
	_BEQZ	$a0,EnterHighName_Done
	mov	$a1,$s1
	sll	$t0,$s0,3
	add	$a1,$a1,$t0
	movi	$a2,ENTERHIGH_TOP+6*ENTERHIGH_LETTERSPACEY
	_LDA	$a3,EnterHighNameColor
	lui	$t0,0xffff
	or	$a3,$a3,$t0
	_JAL	PrintASCII
	addi	$s0,$s0,1
	_J	DrawEnterHighName_Loop

EnterHighName_Done:
DrawEnterHighName_BlackText:	
	_LDA	$a0,EnterHighNameColor
	_LDA	$a1,EnterHighNameTarget
	_JAL	FadeSourceToDest
	mov	$s0,$v0
	mov	$s1,$v1
	_JAL	GetFrameCount
	sll	$v0,$v0,31
	_BNEZ	$v0,DrawEnterHighName_DontFade
	_STA	$s0,EnterHighNameColor
DrawEnterHighName_DontFade:
	mov	$v0,$s1
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS


NOF_DOTS = 64
CIRCLE_STEP = -0x9000/NOF_DOTS
CIRCLE_SPEED = 0x400

CIRCLE_COLOR = 0x07e0
CIRCLE_COLOR_STEP = 0x0020

EnterHighCircleColor:	.dc	0
EnterHighCircleTarget:	.dc	0
CircleAngle:	.dc	0

DrawSelectionBox:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s4
	PUSH	$s5
	PUSH	$s6
	PUSH	$s7
	
	movi	$s0,ENTERHIGH_LEFT+4
	movi	$s1,ENTERHIGH_TOP+8
	
	_LDA	$t0,EnterHighValX
	sll	$t1,$t0,4
	add	$s0,$s0,$t1
	
	_LDA	$t2,EnterHighValY
	sll	$t3,$t2,2
	add	$s1,$s1,$t3
	sll	$t3,$t3,2
	add	$s1,$s1,$t3
	
	clr	$s4
	movi	$t1,4
	_BNE	$t1,$t2,DrawSelectionBox_NotWide
	slti	$t1,$t0,6
	_BNEZ	$t1,DrawSelectionBox_NotWide
	addi	$s0,$s0,8
	movi	$s4,0xffff
DrawSelectionBox_NotWide:
	_LDA	$s5,EnterHighCircleColor
	_LDA	$s2,CircleAngle
	movi	$s3,NOF_DOTS
DrawSelectionBox_Loop:
	mov	$a0,$s2
	_JAL	Cos
	sra	$v0,$v0,1
	and	$t1,$v0,$s4
	add	$v0,$v0,$t1
	sra	$t0,$v0,12
	add	$s6,$s0,$t0

	mov	$a0,$s2	
	_JAL	Sin
	sra	$t0,$v0,13
	add	$s7,$s1,$t0
	
	mov	$a0,$s5
	_JAL	SetColor

	mov	$a0,$s6
	mov	$a1,$s7
	_JAL	Point

	
	addi	$s2,$s2,CIRCLE_STEP	
	addi	$s3,$s3,-1
		
	addi	$s5,$s5,-CIRCLE_COLOR_STEP
	slt	$t0,$s5,$zero
	_BNEZ	$t0,DrawSelectionBox_Done
	_LI	$t0,0x07e0
	and	$s5,$s5,$t0
	_BNEZ	$s3,DrawSelectionBox_Loop

DrawSelectionBox_Done:
	_LI	$t0,CircleAngle
	_LW	$t1,0($t0)
	addi	$t1,$t1,CIRCLE_SPEED
	_SW	$t1,0($t0)

	_LDA	$a0,EnterHighCircleColor
	_LDA	$a1,EnterHighCircleTarget
	_JAL	FadeSourceToDest
	mov	$s0,$v0
	mov	$s1,$v1
	_JAL	GetFrameCount
	sll	$v0,$v0,31
	_BNEZ	$v0,DrawSelectionBox_DontFade
	_STA	$s0,EnterHighCircleColor
DrawSelectionBox_DontFade:
	mov	$v0,$s1
	POP	$s7
	POP	$s6
	POP	$s5
	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0	
	POP	$ra
	_RTS
	
EnterHighJoyStick:
	PUSH	$ra				; Store to stack
	PUSH	$s0	
	_JAL	CheckJoystick
	mov	$s0,$v0

	movi	$t0,0x2d			; 00101101
	and	$t0,$t0,$s0
	_BEQZ	$t0,EnterHigh_NoMoveSound
	
	movi	$a0,FX_ENTERHIGH_MOVE
	_JAL	PlaySampleCh1
EnterHigh_NoMoveSound:
	movi	$t0,0xd2			; 11010010
	and	$t0,$t0,$s0
	_BEQZ	$t0,EnterHigh_NoButSound
	
	movi	$a0,FX_ENTERHIGH_BUTTON
	_JAL	PlaySampleCh1
EnterHigh_NoButSound:

	mov	$t5,$s0
	_LDA	$t2,EnterHighValX
	_LDA	$t3,EnterHighValY
	clr	$t4
	clr	$t6

	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighUp		; Check LSB
	addi	$t3,$t3,-1			; Up
noEnterHighUp:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighButA		; Check LSB
	movi	$t4,1				; ButA
noEnterHighButA:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighDown		; Check LSB
	addi	$t3,$t3,1			; Down
noEnterHighDown:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighRight		; Check LSB
	addi	$t2,$t2,1			; Right	
	movi	$t6,1
noEnterHighRight:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighButB		; Check LSB
	movi	$t4,1				; ButB
noEnterHighButB:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighLeft		; Check LSB
	addi	$t2,$t2,-1			; Right
	movi	$t6,-1	
noEnterHighLeft:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighStart		; Check LSB
	; Start
noEnterHighStart:
	andi	$t0,$t5,1			; LSB to t0
	srl	$t5,$t5,1			; Shift out LSB
	_BEQZ	$t0,noEnterHighButC		; Check LSB
	movi	$t4,1				; ButC
noEnterHighButC:

	slt	$t0,$t2,$zero
	_BEQZ	$t0,noEnterHighLeftEdge
	addi	$t3,$t3,-1
	movi	$t2,9
noEnterHighLeftEdge:
	slti	$t0,$t2,10
	_BNEZ	$t0,noEnterHighRightEdge
	addi	$t3,$t3,1
	movi	$t2,0
noEnterHighRightEdge:
	slt	$t0,$t3,$zero
	_BEQZ	$t0,noEnterHighTopEdge
	movi	$t3,4
noEnterHighTopEdge:
	slti	$t0,$t3,5
	_BNEZ	$t0,noEnterHighDownEdge
	movi	$t3,0
noEnterHighDownEdge:
	sll	$t6,$t6,24
	sll	$t5,$t3,16
	or	$t6,$t6,$t5
	sll	$t5,$t2,8
	or	$t6,$t6,$t5

	_LI	$t5,0xff040900
	_BNE	$t5,$t6,noSpecialBut9to8
	movi	$t2,8
noSpecialBut9to8:
	_LI	$t5,0xff040700
	_BNE	$t5,$t6,noSpecialBut7to6
	movi	$t2,6
noSpecialBut7to6:
	_LI	$t5,0x01040700
	_BNE	$t5,$t6,noSpecialBut7to8
	movi	$t2,8
noSpecialBut7to8:
	_LI	$t5,0x01040900
	_BNE	$t5,$t6,noSpecialBut9to0
	movi	$t2,0
	movi	$t3,0
noSpecialBut9to0:
	_LI	$t5,0x00040900
	_BNE	$t5,$t6,noSpecialButUpDown1
	movi	$t2,8
noSpecialButUpDown1:
	_LI	$t5,0x00040700
	_BNE	$t5,$t6,noSpecialButUpDown2
	movi	$t2,6
noSpecialButUpDown2:
	_STA	$t2,EnterHighValX
	_STA	$t3,EnterHighValY

	_BEQZ	$t4,ButtonEnd
	sll	$t0,$t2,8
	or	$t0,$t0,$t3
	moviu	$t1,0x0604
	_BNE	$t0,$t1,NotDel
Del:	
	_LDA	$t5,EnterHighPos
	_BEQZ	$t5,ButtonEnd
	addi	$t5,$t5,-1
	_STA	$t5,EnterHighPos
	_STO	$zero,EnterHighName,$t5
	_J	ButtonEnd
NotDel:
End:
	moviu	$t1,0x0804
	_BNE	$t0,$t1,NotEnd
	_STA	$t4,EnterHighDone
	_J	ButtonEnd
NotEnd:	
Letter:
	sll	$t5,$t3,3
	sll	$t6,$t3,1
	add	$t5,$t5,$t6
	add	$t5,$t5,$t2
	_LDO	$t7,EnterHighLetters,$t5
	_LDA	$t5,EnterHighPos
	slti	$t0,$t5,NOF_LETTERS
	addi	$t0,$t0,-1
	add	$t5,$t5,$t0
	_STO	$t7,EnterHighName,$t5
	addi	$t5,$t5,1
	_STA	$t5,EnterHighPos
ButtonEnd:
	POP	$s0
	POP	$ra	
	_RTS				; Return from subroutine

CopyNameToString:
	_LI	$t0,EnterHighName
	_LI	$t1,ListName
	
	movi	$t8,2
CopyNameToString_Loop:
	movi	$t9,4
	clr	$t2
CopyNameToString_WordLoop:	
	addi	$t9,$t9,-1
	_LW	$t3,0($t0)
	sll	$t7,$t9,3
	sllv	$t3,$t3,$t7
	or	$t2,$t2,$t3
	addi	$t0,$t0,1
	_BNEZ	$t9,CopyNameToString_WordLoop
	_SW	$t2,0($t1)
	addi	$t1,$t1,1
	addi	$t8,$t8,-1
	_BNEZ	$t8,CopyNameToString_Loop
	_RTS
	
GetEnterHighName:
	_LI	$v0,ListName
	_RTS
	
EnterHighLetters:
	.dc	0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a
	.dc	0x4b,0x4c,0x4d,0x4e,0x4f,0x50,0x51,0x52,0x53,0x54
	.dc 	0x55,0x56,0x57,0x58,0x59,0x5a,0x2c,0x2e,0x21,0x3f
	.dc	0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39
	.dc	0x2d,0x2f,0x3c,0x3e,0x24,0x25

EnterHighSpecialText:
	.ascii	"Del End"

EnterHighName:	.dc	0,0,0,0,0,0,0,0,0
ListName:	.dc	0,0,0
EnterHighPos:	.dc	0		

EnterHighValX:	.dc	0
EnterHighValY:	.dc	0
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
VEC_POINTS = 16
VEC_SURFACE_COUNT = 10

MIDPOINT_X = 70
MIDPOINT_Y = 128

FRAMESBEFOREMORPH = 200
ROTATESPEED = 0x180

VEC_COLOR = 0x01e0

Current_Color: 	.dc	0
Target_Color:	.dc	0

Dz = 8
Dk = 16
Dsi = 4*2
Dco = 9*2

NOFOBJECTS = 7
Current_ObjectNbr:	.dc	0
Object_List:		.dc	O_Object,I_Object,S_Object,L_Object,Z_Object,J_Object,T_Object,-1

Dot_Object:	.dc	Dot_Points_X,Dot_Points_Y,Points_Z
O_Object:	.dc	O_Points_X,O_Points_Y,Points_Z
I_Object:	.dc	I_Points_X,I_Points_Y,Points_Z
L_Object:	.dc	L_Points_X,L_Points_Y,Points_Z
J_Object:	.dc	J_Points_X,J_Points_Y,Points_Z
S_Object:	.dc	S_Points_X,S_Points_Y,Points_Z
Z_Object:	.dc	Z_Points_X,Z_Points_Y,Points_Z
T_Object:	.dc	T_Points_X,T_Points_Y,Points_Z

Dot_Points_X:	.dc	-Dsi,Dsi,Dco,Dco,Dsi,-Dsi,-Dco,-Dco
		.dc	-Dsi,Dsi,Dco,Dco,Dsi,-Dsi,-Dco,-Dco
Dot_Points_Y:	.dc	-Dco,-Dco,-Dsi,Dsi,Dco,Dco,Dsi,-Dsi
		.dc	-Dco,-Dco,-Dsi,Dsi,Dco,Dco,Dsi,-Dsi

O_Points_X:	.dc	-2*Dk,-2*Dk,2*Dk,2*Dk,2*Dk,2*Dk,-2*Dk,-2*Dk
		.dc	-2*Dk,-2*Dk,2*Dk,2*Dk,2*Dk,2*Dk,-2*Dk,-2*Dk
O_Points_Y:	.dc	-2*Dk,-2*Dk,-2*Dk,-2*Dk,2*Dk,2*Dk,2*Dk,2*Dk
		.dc	-2*Dk,-2*Dk,-2*Dk,-2*Dk,2*Dk,2*Dk,2*Dk,2*Dk

I_Points_X:	.dc	-Dk,-Dk,Dk,Dk,Dk,Dk,-Dk,-Dk
		.dc	-Dk,-Dk,Dk,Dk,Dk,Dk,-Dk,-Dk
I_Points_Y:	.dc	-4*Dk,-4*Dk,-4*Dk,-4*Dk,4*Dk,4*Dk,4*Dk,4*Dk
		.dc	-4*Dk,-4*Dk,-4*Dk,-4*Dk,4*Dk,4*Dk,4*Dk,4*Dk

L_Points_X:	.dc	-Dk,-Dk,Dk,Dk,3*Dk,3*Dk,-Dk,-Dk
		.dc	-Dk,-Dk,Dk,Dk,3*Dk,3*Dk,-Dk,-Dk		
L_Points_Y:	.dc	-3*Dk,-3*Dk,-3*Dk,Dk,Dk,3*Dk,3*Dk,3*Dk
		.dc	-3*Dk,-3*Dk,-3*Dk,Dk,Dk,3*Dk,3*Dk,3*Dk

J_Points_X:	.dc	-Dk,Dk,Dk,Dk,Dk,-3*Dk,-3*Dk,-Dk
		.dc	-Dk,Dk,Dk,Dk,Dk,-3*Dk,-3*Dk,-Dk
J_Points_Y:	.dc	-3*Dk,-3*Dk,-3*Dk,3*Dk,3*Dk,3*Dk,Dk,Dk
		.dc	-3*Dk,-3*Dk,-3*Dk,3*Dk,3*Dk,3*Dk,Dk,Dk
		
S_Points_X:	.dc	-2*Dk,0,0,2*Dk,2*Dk,0,0,-2*Dk
		.dc	-2*Dk,0,0,2*Dk,2*Dk,0,0,-2*Dk
S_Points_Y:	.dc	-3*Dk,-3*Dk,-Dk,-Dk,3*Dk,3*Dk,Dk,Dk
		.dc	-3*Dk,-3*Dk,-Dk,-Dk,3*Dk,3*Dk,Dk,Dk

Z_Points_X:	.dc	-2*Dk,0,0,2*Dk,2*Dk,0,0,-2*Dk
		.dc	-2*Dk,0,0,2*Dk,2*Dk,0,0,-2*Dk
Z_Points_Y:	.dc	-Dk,-Dk,-3*Dk,-3*Dk,Dk,Dk,3*Dk,3*Dk
		.dc	-Dk,-Dk,-3*Dk,-3*Dk,Dk,Dk,3*Dk,3*Dk
		
T_Points_X:	.dc	-Dk,-Dk,Dk,Dk,3*Dk,3*Dk,-3*Dk,-3*Dk
		.dc	-Dk,-Dk,Dk,Dk,3*Dk,3*Dk,-3*Dk,-3*Dk
T_Points_Y:	.dc	-Dk,-3*Dk,-3*Dk,-Dk,-Dk,Dk,Dk,-Dk
		.dc	-Dk,-3*Dk,-3*Dk,-Dk,-Dk,Dk,Dk,-Dk
		
Points_Z:	.dc	Dz,Dz,Dz,Dz,Dz,Dz,Dz,Dz
		.dc	-Dz,-Dz,-Dz,-Dz,-Dz,-Dz,-Dz,-Dz

Vector_Points:
Vec_Points_X:	.pad	VEC_POINTS,0
Vec_Points_Y:	.pad	VEC_POINTS,0
Vec_Points_Z:	.pad	VEC_POINTS,0

Vec_Surface_List:	.dc	Vec_Surface1 
			.dc	Vec_Surface2
			.dc	Vec_Surface3
			.dc	Vec_Surface4
			.dc	Vec_Surface5
			.dc	Vec_Surface6
			.dc	Vec_Surface7
			.dc	Vec_Surface8
			.dc	Vec_Surface9
			.dc	Vec_Surface10

Vec_Surface1:	.dc	0,1,2,3,4,5,6,7,0, -1		; Flat Top Surface
Vec_Surface2:	.dc	15,14,13,12,11,10,9,8,15, -1	; Flat Bottom Surface
Vec_Surface3:	.dc	1,0,8,9,1, -1
Vec_Surface4:	.dc	2,1,9,10,2, -1
Vec_Surface5:	.dc	3,2,10,11,3, -1
Vec_Surface6:	.dc	4,3,11,12,4, -1
Vec_Surface7:	.dc	5,4,12,13,5, -1
Vec_Surface8:	.dc	6,5,13,14,6, -1
Vec_Surface9:	.dc	7,6,14,15,7, -1
Vec_Surface10:	.dc	0,7,15,8,0, -1

Rot_Points_X:	.pad	VEC_POINTS , 0
Rot_Points_Y:	.pad	VEC_POINTS , 0
Rot_Points_Z:	.pad	VEC_POINTS , 0

Morph_Points:
Morph_Points_X:	.pad	VEC_POINTS , 0
Morph_Points_Y:	.pad	VEC_POINTS , 0
Morph_Points_Z:	.pad	VEC_POINTS , 0

Morph_Delta:
Morph_dX:	.pad	VEC_POINTS , 0
Morph_dY:	.pad	VEC_POINTS , 0
Morph_dZ:	.pad	VEC_POINTS , 0

LineDrawnTable:	.pad	VEC_POINTS , 0

Angle_X:	.dc	0
Angle_Y:	.dc	0
Angle_Z:	.dc	0

Vec_FrameCount:	.dc	0

Rotate:	PUSH	$ra
	PUSH	$s0	; Point
	PUSH	$s1	; Sin
	PUSH	$s2	; Cos
	PUSH	$s3	; X Point
	PUSH	$s4	; Y Point
	PUSH	$s5	; Z Point
	PUSH	$s6	; Acc1
	PUSH	$s7	; Acc2
	
	clr	$s0
Rotate_Point_Loop:
	; Get original positions
	lw	$s3,Vec_Points_X($s0)
	nop
	lw	$s4,Vec_Points_Y($s0)
	nop
	lw	$s5,Vec_Points_Z($s0)
	nop
	
	; Get Cos and Sin for Z-angle
	lw	$a0,Angle_Z($zero)
	nop
	_JAL	Sin
	mov	$s1,$v0			
	lw	$a0,Angle_Z($zero)
	nop
	_JAL	Cos
	mov	$s2,$v0
	; Rotate around Z-axis ( Z-pos unaffected )
	mov	$a0,$s2	; X_Rot = Cos(xphi) * X_Pos - Sin(xphi) * Y_Pos
	mov	$a1,$s3	
	_JAL	Muls16fpfast
	mov	$s6,$v0
	mov	$a0,$s1
	mov	$a1,$s4
	_JAL	Muls16fpfast
	sub	$s6,$s6,$v0
	mov	$a0,$s1	; Y_Rot = Sin(xphi) * X_Pos + Cos(xphi) * Y_Pos
	mov	$a1,$s3	
	_JAL	Muls16fpfast
	mov	$s7,$v0
	mov	$a0,$s2
	mov	$a1,$s4
	_JAL	Muls16fpfast
	add	$s4,$s7,$v0	; New Ypos after Z-rotate to s4
	mov	$s3,$s6		; New Xpos after Z-rotate to s3
	
	; Get Cos and Sin for Y-angle
	lw	$a0,Angle_Y($zero)
	nop
	_JAL	Sin
	mov	$s1,$v0			
	lw	$a0,Angle_Y($zero)
	nop
	_JAL	Cos
	mov	$s2,$v0
	; Rotate around Y-axis ( Y-pos unaffected )
	mov	$a0,$s2	; X_Rot = Cos(yphi) * X_Pos - Sin(yphi) * Z_Pos
	mov	$a1,$s3	
	_JAL	Muls16fpfast
	mov	$s6,$v0
	mov	$a0,$s1
	mov	$a1,$s5
	_JAL	Muls16fpfast
	sub	$s6,$s6,$v0
	mov	$a0,$s1	; Z_Rot = Sin(yphi) * X_Pos + Cos(yphi) * Z_Pos
	mov	$a1,$s3	
	_JAL	Muls16fpfast
	mov	$s7,$v0
	mov	$a0,$s2
	mov	$a1,$s5
	_JAL	Muls16fpfast
	add	$s5,$s7,$v0	; New Zpos after Y-rotate to s5
	mov	$s3,$s6		; New Xpos after Y-rotate to s3

	; Get Cos and Sin for X-angle
	lw	$a0,Angle_X($zero)
	nop
	_JAL	Sin
	mov	$s1,$v0			
	lw	$a0,Angle_X($zero)
	nop
	_JAL	Cos
	mov	$s2,$v0
	; Rotate around X-axis ( X-pos unaffected )
	mov	$a0,$s2	; Y_Rot = Cos(yphi) * Y_Pos - Sin(yphi) * Z_Pos
	mov	$a1,$s4	
	_JAL	Muls16fpfast
	mov	$s6,$v0
	mov	$a0,$s1
	mov	$a1,$s5
	_JAL	Muls16fpfast
	sub	$s6,$s6,$v0
	mov	$a0,$s1	; Z_Rot = Sin(yphi) * Y_Pos + Cos(yphi) * Z_Pos
	mov	$a1,$s4	
	_JAL	Muls16fpfast
	mov	$s7,$v0
	mov	$a0,$s2
	mov	$a1,$s5
	_JAL	Muls16fpfast
	add	$s5,$s7,$v0	; New Zpos after Y-rotate to s5
	mov	$s4,$s6		; New Xpos after Y-rotate to s3

	sra	$s5,$s5,16
	
	; Perspective
	sra	$a0,$s3,8	; Perspective on X-cord
	addi	$a1,$s5,256
	_JAL	Divs16
	addi	$s3,$v0,MIDPOINT_X
	nop
	nop
	sw	$s3,Rot_Points_X($s0)
	
	sra	$a0,$s4,8	; Perspective on Y-cord
	addi	$a1,$s5,256
	_JAL	Divs16
	addi	$s4,$v0,MIDPOINT_Y
	nop
	nop
	sw	$s4,Rot_Points_Y($s0)
		
	addi	$s0,$s0,1
	movi	$t9,VEC_POINTS
	_BNE	$s0,$t9,Rotate_Point_Loop
	
	POP	$s7
	POP	$s6
	POP	$s5
	POP	$s4
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS
	
Draw:	PUSH	$ra
	PUSH	$s0	; cord 0
	PUSH	$s1	; cord 1
	PUSH	$s2	; cord 2
	PUSH	$s3	;  temp
	
	PUSH	$s6	; Surface counter
	PUSH	$s7	; Surface pointer
	
	clr	$s6
	clr	$s3	; temp
		
	li	$t0,LineDrawnTable
	movi	$t1,VEC_POINTS
Draw_ClearLineDrawnTable:
	sw	$zero,0($t0)
	addi	$t0,$t0,1
	addi	$t1,$t1,-1
	_BNEZ	$t1,Draw_ClearLineDrawnTable
	
Draw_Surface_Loop:
	lw	$s7,Vec_Surface_List($s6)
	nop
	lw	$s0,0($s7)
	nop
	lw	$s1,1($s7)	
	nop
	lw	$s2,2($s7)	
	nop
	
Draw_Line_Loop:
	mov	$t0,$s0
	mov	$t1,$s1	
	slt	$t2,$t0,$t1
	_BEQZ	$t2,Draw_NoSwitch
	mov	$t0,$s1
	mov	$t1,$s0
Draw_NoSwitch:
	lw	$t2,LineDrawnTable($t0)
	nop
	movi	$t3,1
	sllv	$t4,$t3,$t1
	and	$t3,$t4,$t2
	_BNEZ	$t3,Draw_LineAlreadyDrawn
	or	$t2,$t2,$t4
	nop
	nop
	sw	$t2,LineDrawnTable($t0)
	
	_LW	$a0,Rot_Points_X($s0)
	_LW	$a1,Rot_Points_Y($s0)
	_LW	$a2,Rot_Points_X($s1)
	_LW	$a3,Rot_Points_Y($s1)
	_JAL	Line
	addi	$s3,$s3,1
		
Draw_LineAlreadyDrawn:
	addi	$s7,$s7,1
	mov	$s0,$s1
	lw	$s1,1($s7)
	nop
	movi	$t1,-1
	_BNE	$s1,$t1,Draw_Line_Loop

	addi	$s6,$s6,1
	movi	$t1,VEC_SURFACE_COUNT
	_BNE	$s6,$t1,Draw_Surface_Loop
		
	POP	$s7
	POP	$s6
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS	
	
SetupMorph:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
		
	clr	$s0
	
	li	$t1,Morph_Points
	li	$t2,Vector_Points
	li	$t3,Morph_Delta
	movi	$t9,3
SetupMorph_Loop:	
	lw	$t0,0($a0)
	movi	$t8,VEC_POINTS
SetupMorph_InnerLoop:
	lw	$t5,0($t0)
	addi	$t0,$t0,1
	lw	$t6,0($t2)
	sll	$t5,$t5,16
	addi	$t8,$t8,-1
	sub	$t7,$t5,$t6
	addi	$t2,$t2,1
	sw	$t5,0($t1)
	addi	$t1,$t1,1
	sw	$t7,0($t3)
	slti	$t5,$t7,0
	sll	$t6,$t5,31
	sra	$t6,$t6,31
	xor	$t7,$t7,$t6
	add	$t7,$t7,$t5
	slt	$t5,$s0,$t7
	_BEQZ	$t5,SetupMorph_LessThan
	mov	$s0,$t7
SetupMorph_LessThan:
	addi	$t3,$t3,1
	_BNEZ	$t8,SetupMorph_InnerLoop
	addi	$a0,$a0,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,SetupMorph_Loop

	li	$s2,Morph_Delta
	movi	$s1,VEC_POINTS*3
SetupMorph_Normalize_Loop:
	lw	$a0,0($s2)
	srl	$a1,$s0,16
	sra	$a0,$a0,8
	_JAL	Divs16
	sll	$v0,$v0,8
	nop
	nop
	sw	$v0,0($s2)
	addi	$s2,$s2,1
	addi	$s1,$s1,-1
	_BNEZ	$s1,SetupMorph_Normalize_Loop
		
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	movi	$v0,7
	
	_RTS

MorphPoints:
	clr	$v0
	li	$t0,Vector_Points
	li	$t1,Morph_Points
	li	$t2,Morph_Delta
	movi	$t9,VEC_POINTS*3
MorphPoints_Loop:
	lw	$t3,0($t0)
	addi	$t9,$t9,-1
	lw	$t4,0($t1)
	addi	$t1,$t1,1
	lw	$t5,0($t2)
	nop
	add	$t3,$t3,$t5
	
	sra	$t6,$t3,16
	sra	$t4,$t4,16
	_BNE	$t4,$t6,MorphPoints_NotDone
	sw	$zero,0($t2)
	lui	$t6,0xffff
	and	$t3,$t3,$t6
	nop
	nop
MorphPoints_NotDone:
	sw	$t3,0($t0)
	addi	$t0,$t0,1
	addi	$t2,$t2,1
	_BNEZ	$t9,MorphPoints_Loop
	_RTS
	
SimpleMorphPoints:
	clr	$v0
	li	$t1,Vector_points
	movi	$t9,3
SimpleMorphPoints_Loop:
	lw	$t0,0($a0)
	movi	$t8,VEC_POINTS
SimpleMorphPoints_Inner_Loop:
	lw	$t2,0($t0)
	addi	$t0,$t0,1
	lw	$t3,0($t1)
	addi	$t8,$t8,-1
	
	slt	$t4,$t3,$t2
	add	$t3,$t3,$t4
	or	$v0,$v0,$t4
	slt	$t4,$t2,$t3
	sub	$t3,$t3,$t4
	or	$v0,$v0,$t4
	nop
	sw	$t3,0($t1)
	addi	$t1,$t1,1
	_BNEZ	$t8,SimpleMorphPoints_Inner_Loop
	addi	$a0,$a0,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,SimpleMorphPoints_Loop
	_RTS

CopyPoints:
	li	$t1,Vector_points
	movi	$t9,3
CopyPoints_Loop:
	lw	$t0,0($a0)
	movi	$t8,VEC_POINTS
CopyPoints_Inner_Loop:
	lw	$t2,0($t0)
	addi	$t0,$t0,1
	addi	$t8,$t8,-1
	sll	$t2,$t2,16
	nop
	nop
	sw	$t2,0($t1)
	addi	$t1,$t1,1
	_BNEZ	$t8,CopyPoints_Inner_Loop
	addi	$a0,$a0,1
	addi	$t9,$t9,-1
	_BNEZ	$t9,CopyPoints_Loop
	_RTS
	
MorphFrame:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1

	_BEQZ	$a0,MorphFrame_DontChangeTarget
	_STA	$zero,Target_Color
MorphFrame_DontChangeTarget:
	_JAL	MorphPoints
	_JAL	MorphPoints
	
	_LI	$t0,Angle_Y
	_LW	$t1,0($t0)
	addi	$t1,$t1,ROTATESPEED
	_SW	$t1,0($t0)
	
	_LI	$s0,Vec_FrameCount
	_LW	$s1,0($s0)
	addi	$s1,$s1,-1
	_BNEZ	$s1,MorphFrame_DontMorphNext
	movi	$s1,FRAMESBEFOREMORPH
	_JAL	MorphNext
MorphFrame_DontMorphNext:
	_SW	$s1,0($s0)
	_LDA	$a0,Current_Color
	_JAL	SetColor
	_JAL	Rotate
	_JAL	Draw

	movi	$v1,1
	_JAL	GetFrameCount
	sll	$v0,$v0,29
	_BNEZ	$v0,MorphFrame_DontFade
	_LDA	$a0,Current_Color
	_LDA	$a1,Target_Color
	_JAL	FadeSourceToDest
	_STA	$v0,Current_Color
MorphFrame_DontFade:
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS
		
StartMorph:
	PUSH	$ra
	
	_LI	$t0,Angle_X
	movi	$t1,0x1234
	_SW	$t1,0($t0)
	_SW	$zero,1($t0)
	_SW	$zero,2($t0)
	
	_STA	$zero,Current_Color
	moviu	$t0,VEC_COLOR
	_STA	$t0,Target_Color
	
	movi	$t1,FRAMESBEFOREMORPH
	_STA	$t1,Vec_FrameCount

	_LI	$t0,Vector_Points
	movi	$t1,VEC_POINTS*3
StartMorph_Loop:
	sw	$zero,0($t0)
	addi	$t0,$t0,1
	addi	$t1,$t1,-1
	_BNEZ	$t1,StartMorph_Loop
	
	_LDA	$a0,Object_List
	_JAL	SetupMorph

	POP	$ra
	_RTS
	
MorphNext:
	PUSH	$ra
	
	_LDA	$t0,Current_ObjectNbr
	addi	$t0,$t0,1
	movi	$t1,NOFOBJECTS
	_BNE	$t0,$t1,MorphNext_NoOverflow
	clr	$t0
MorphNext_NoOverflow:
	_STA	$t0,Current_ObjectNbr

	_LDO	$a0,Object_List,$t0	
	_JAL	SetupMorph
	
	POP	$ra
	_RTS
NOF_STARS = 50
SPEED_SHIFT = 13

Stars_Xpos:	.pad	NOF_STARS,0
Stars_Ypos:	.pad	NOF_STARS,0
Stars_Speed:	.pad	NOF_STARS,0
Stars_SpeedAdd:	.dc	0

InitStars:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s7
	
	_LI	$s0,Stars_Xpos
	_LI	$s1,Stars_Ypos
	_LI	$s2,Stars_Speed
	
	movi	$s7,NOF_STARS
InitStars_Loop:
	_JAL	Rnd
	srl	$t0,$v0,8
	lui	$t1,320
	add	$t0,$t0,$t1
	_SW	$t0,0($s0)	; Xpos = Rnd(319,<(319+256)), Fp16+16

	_JAL	Rnd
	sll	$t0,$v0,24	
	srl	$t0,$t0,24
	_SW	$t0,0($s1)	; Ypos = Rnd(0,255), Int
	
	_JAL	Rnd
	srl	$t0,$v0,14	
	lui	$t1, 1
	add	$t0,$t0,$t1
	_SW	$t0,0($s2)	; Speed = Rnd(1,<5), Fp16+16
	
	addi	$s0,$s0,1
	addi	$s1,$s1,1
	addi	$s2,$s2,1
	
	addi	$s7,$s7,-1
	_BNEZ	$s7,InitStars_Loop
	
	_STA	$zero,Stars_SpeedAdd
	
	POP	$s7
	POP	$s2
	POP	$s1	
	POP	$s0
	POP	$ra
	_RTS

StopStars:
	movi	$t0,0x0100
	_STA	$t0,Stars_SpeedAdd
	_RTS
	
Stars:
	PUSH	$ra
	PUSH	$s0
	PUSH	$s1
	PUSH	$s2
	PUSH	$s3
	PUSH	$s6
	PUSH	$s7

	movi	$v0,NOF_STARS
			
	_LI	$s0,Stars_Xpos
	_LI	$s1,Stars_Ypos
	_LI	$s2,Stars_Speed
	
	_LDA	$s3,Stars_SpeedAdd
	
	movi	$s7,NOF_STARS
Stars_Loop:	
	_LW	$s6,0($s2)
	add	$t0,$s6,$s3
	_SW	$t0,0($s2)
	
	sll	$a0,$s6,SPEED_SHIFT
	srl	$a0,$a0,27
	sll	$t0,$a0,6
	or	$a0,$a0,$t0
	sll	$t0,$t0,5
	or	$a0,$a0,$t0
	_JAL	SetColor
	
	_LW	$a0,0($s0)
	sub	$a0,$a0,$s6
	slt	$t0,$a0,$zero
	_BEQZ	$t0,Stars_StarStillOnScreen
	addi	$v0,$v0,-1
	_BNEZ	$s3,Stars_SkipStar
	lui	$a0,319
Stars_StarStillOnScreen:
	_SW	$a0,0($s0)
	srl	$a0,$a0,16
	_LW	$a1,0($s1)
	
	slti	$t0,$a0,319
	_BEQZ	$t0,Stars_SkipStar
	_JAL	Point
Stars_SkipStar:
	addi	$s0,$s0,1
	addi	$s1,$s1,1
	addi	$s2,$s2,1

	addi	$s7,$s7,-1
	_BNEZ	$s7,Stars_Loop
	
	_BNEZ	$s3,Stars_FadingDown
	clr	$v0
Stars_fadingDown:
	POP	$s7
	POP	$s6
	POP	$s3
	POP	$s2
	POP	$s1
	POP	$s0
	POP	$ra
	_RTS

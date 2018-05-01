;-------------------------------------------------------------------------------
; Galaxian disasembled by DISASM6, converted to XA syntax
; and extensively annotated by lidnariq 2010-2011
;-------------------------------------------------------------------------------
;;; For reference-
	;;  loopXX = small anonymous loop, should be easy to figure out what the loop does
	;;  skpXXX = small anonymous linear code flow forward, embodying if A then B
	;;  retXX = immediately returns
	;;  saveXX = saves value of some variable, then returns
	;;  backXX = small backwards code flow
	;;  tailXX = tail-merged loop

	;; InitialCamelCase = prgrom labels to code
	;; lowercase_with_underscores = wram labels
	;; lowerCamelCase = everything else (chrrom labels, calculated numbers)
	;; CHR_Label = tile numbers
	;; ALLCAPS = SFRs
	;; dCamelCase = prgrom labels to data

	;; ramd = random-access metatile drawer
	
;;; memory addresses

	.zero
*=0	; for some reason XA starts allocating zeropage at address 4. Fix it.
music_pointer .byt 0
notes_to_play .byt 0
music_page .byt 0
music_initialized .byt 0
music_speed .byt 0
un1 .dsb 30,0
dbg_keybd_prev .byt 0
dbg_keybd_cnt .byt 0
un2 .dsb 2,0
convoy_count .byt 0
convoy_running_sum .byt 0
should_do_wipe .byt 0
nmi_entry_count .byt 0
end_game_timer .byt 0
timeout_ready .byt 0
score_line_column_idx .byt 0
wipe_mode .byt 0
title_sprites_y_offset .byt 0
game_start_timeout .byt 0
numplayers .byt 0
sinkhole1 .byt 0
wipe_xcoo .byt 0
sq1_hi_shadow .byt 0
enemy_launch_timer .byt 0	; counts 150 -> 0. launches a ship on 77. can launch bugs while on 0
chrdest .word 0
chrsrc .word 0
spincount .word 0
numplayers_bit .byt 0
act_play_extra_life_avail .byt 0
oth_play_extra_life_avail .byt 0
charger_shooting_holdoff .byt 0
noise_idx_shot .byt 0
noise_idx_died .byt 0
act_play_lives .byt 0
oth_play_lives .byt 0
joypad_holdoff .dsb 8,0
activejoykeys .byt 0
un4 .byt 0
pauseflag .byt 0
PlayerDiedThisVsync .byt 0
play_exploding_tile .byt 0
play_exploding_row .byt 0
un5 .byt 0
player_up .byt 0
score_to_add .dsb 5,0
act_play_waves .byt 0
oth_play_waves .byt 0

misc_timers .dsb 13,0
wave_vsyncs = misc_timers+8
wave_seconds = misc_timers+9
aggressiveness = misc_timers+10
launch_singleton_from_right = misc_timers+11
launch_ship_timer = misc_timers+12
misc_timers_end: 
	
ship_diving_period .byt 0
un8 .dsb 2,0
sfct_ptr .word 0
sfct_req_start .dsb 4,0
sfct_idx .byt 0
sfct_pos .dsb 4,0
sfct_note_dur .dsb 4,0
unb .dsb 4,0
apu_shadow .dsb 2,0
sq1per .word 0
ung .dsb 12,0
act_play_extra_enemy .dsb 2,0
oth_play_extra_enemy .dsb 2,0

convoyWidth = 10		; forward references not supported in .dsb! Calculate this by hand.

chargers_from_column .dsb convoyWidth,0 ; number of enemies in flight from each column
message_timer .byt 0
cur_charger_sprite .byt 0
cur_charger .byt 0
convoy_is_empty .byt 0
convoy_animation_fifo .dsb 32,0
convoy_column_req .byt 0
convoy_column_sync .byt 0
convoy_animation_column .byt 0
act_play_convoy .dsb convoyWidth,0 ; bit set for each bug in convoy (0 if dead or flying)
oth_play_convoy .dsb convoyWidth,0
convoy_column_idx .byt 0
convoy_animation .byt 0
unm .byt 0

local1 .byt 0			; local1..local7 seem to be private local variables
local2 .byt 0			; shared and reused among many different routines
local3 .byt 0			; including for parameter passing
local4 .byt 0
local5 .byt 0
local6 .byt 0
local7 .byt 0

ramd_count .byt 0
scratch_ptr .word 0
player_x_pos .byt 0
convoy_x_pos .byt 0
unn .dsb 2,0
jump_table .word 0
indjump .word 0
game_velocity_nomiss .byt 0
game_vsyncs .byt 0
joy1prev .byt 0
joy1keys .byt 0
joy2prev .byt 0
joy2keys .byt 0
BugLaunchStage .byt 0
uno .dsb 3,0			; probably ppuaddr_shadow(2) and ppudata_shadow
ppuscroll_x_shadow .byt 0
ppuscroll_y_shadow .byt 0
unp .dsb 2,0			; probably oamaddr_shaddow and oamdata_shadow
ppumask_shadow .byt 0
ppuctrl_shadow .byt 0
unq .byt 0
inner_coro_idx .byt 0
middle_coro_idx .byt 0
gamestage_coro_idx .byt 0

	.bss
*=$100
unr .byt 0
music_enable .byt 0
num_vsyncs .dsb 3,0
soft_reset_flag .dsb 16,0
reset_count .byt 0
p1score .dsb 26,0
hiscore = p1score + 10
p2score = p1score + 18
scores_end:
stack .dsb 30,0
top_of_stack: 
	;; The stack is carefully nestled in between $0130 and $014d
sfx_table .dsb 178,0
sfx_table_end: 
	;; $014e..$01ff is the sound effect table

	;; All of page 2 is the sprites table (for transfer to OAM)

#define spr_buf(n,t) $0200+n*4+t
ycoo = 0
tile = 1
attr = 2
xcoo = 3
	
; sprite0 is also the 1player/2player select arrow
; sprite0..sprite7 is "game over" animation

; sprite0 .. sprite27 is enemies
; sprite0..3 is because each charger is 4 sprites
; sprite4..7 is the enemy ship on the scoring screen
; sprite12 is for the AI so that it evades the singleton bug when launched

	
; sprite28..31 is just for explosions in the convoy

; sprite32 is player's bullet

; sprite33 .. sprite39 is enemy bullets

; sprite40 .. sprite63 is background starfield


text_table = $0300
;;; all of pages $0300, $0400, $0500, and half of $0600 are for data copied out of chrrom
;;; note that $0480-$057f isn't useful (it's just tiles and easter egg data)
pause_xcoo = $0603

text_table_end = $067f
	
*=$0680
uns .dsb 15,0
ai_x_target .byt 0
;;; $0690..$06a5 is the score line
status_line .dsb 44,0
end_of_status_line: 
active_player_score = status_line+16
status_line_lower = status_line+32
status_line_end:

text_to_blit .dsb 26,0
ascii_offset .byt 0
placard_count .byt 0
game_over_prng .dsb 16,0
game_over_y_start = game_over_prng
game_over_x_start = game_over_prng+8
charger_num_bullets .dsb 8,0
ship_score .dsb 8,0
charger_escort_a .dsb 7,0
charger_escort_direction .byt 0
charger_escort_b .dsb 7,0
column_of_ship_launching .byt 0
charger_is_ship .dsb 8,0
charger_docking_timer .dsb 8,0
charger_y_home .dsb 8,0
charger_x_home .dsb 8,0
charger_tile .dsb 8,0
charger_timer .dsb 8,0
charger_ai_coro .dsb 8,0
charger_x_target .dsb 8,0
ramd_righttile .dsb 16,0
ramd_lefttile .dsb 16,0
ramd_addr_l .dsb 16,0
ramd_addr_h .dsb 16,0

sign_bullet_x .dsb 24,0		  ; bullet_x also = gameover_x
sign_gameover_y = sign_bullet_x+8 ; yes, gameover_y and charger_x overlap
sign_charger_x = sign_bullet_x+9
sign_charger_y = sign_bullet_x+16
sign_convoy_x = sign_bullet_x+23

denominator_bullet_x .dsb 24,0
denominator_gameover_y = denominator_bullet_x+8
denominator_charger_x = denominator_bullet_x+9
denominator_charger_y = denominator_bullet_x+16
denominator_convoy_x = denominator_bullet_x+23

numerator_bullet_x .dsb 24,0
numerator_gameover_y = numerator_bullet_x+8
numerator_charger_x = numerator_bullet_x+9
numerator_charger_y = numerator_bullet_x+16
numerator_convoy_x = numerator_bullet_x+23

remainder_bullet_x .dsb 24,0
remainder_gameover_y = remainder_bullet_x+8
remainder_charger_x = remainder_bullet_x+9
remainder_charger_y = remainder_bullet_x+16

velocity_bullet_x .dsb 24,0
velocity_gameover_y = velocity_bullet_x+8
velocity_charger_x = velocity_bullet_x+9
velocity_charger_y = velocity_bullet_x+16
velocity_convoy_x = velocity_bullet_x+23

;;; PPU addresses
text_tablePPU = $1480
sfx_tablePPU = $098E
#define NameTable(x,y) ((x&31)|((y&31)<<5)|$2000|((x&32)<<5)|((y&32)<<6))
#define NamePalette(x,y) (((x&28)>>2)|((y&28)<<1)|$23C0|((x&32)<<5)|((y&32)<<6))
PalettePPU = $3F00
nametableSize = 960

;;; pattern table addresses
CHR_Blank = $10
CHR_LogoHole = $2E
CHR_Selector = $2F
CHR_PlayerBullet = $30
CHR_Star = $32
CHR_EnemyBullet = $37
CHR_Bug8AnimA = $37
CHR_Bug8AnimB = $43
CHR_Bug8AnimC = $33
CHR_Bug16AnimA = $3b
CHR_Bug16AnimB = $47
CHR_Bug16AnimC = $3f
CHR_BugsInFlight = $44
CHR_PlayerShipLL = $63
CHR_WaveFlagTop = $6C
CHR_OneUpTop = $6E
CHR_ChargerExplosion = $70
CHR_ScoreFloat150 = $80
CHR_ScoreFloat200 = $84
CHR_ScoreFloat300 = $88
CHR_ScoreFloat800 = $8C
CHR_ShipInFlight = $A4
CHR_ShipInConvoy = $A7
CHR_PlayerExplosion = $C3
	
;-------------------------------------------------------------------------------
; Hardware registers
PPUCTRL		= $2000
PPUCTRLoNT0 = 0
PPUCTRLoNT1 = 1
PPUCTRLoNT2 = 2
PPUCTRLoNT3 = 3
PPUCTRLoINC1 = 0
PPUCTRLoINC32 = 4
PPUCTRLoSPR_LEFT = 0
PPUCTRLoSPR_RIGHT = 8
PPUCTRLoBKGD_LEFT = 0
PPUCTRLoBKGD_RIGHT = 16
PPUCTRLoSPR_8X8 = 0
PPUCTRLoSPR_8X16 = 32
PPUCTRLoNMI_DIS = 0
PPUCTRLoNMI_ENA = 128
PPUCTRLaNT0 = $fc
PPUCTRLaNT1 = $fd
PPUCTRLaNT2 = $fe
PPUCTRLaNT3 = $ff
PPUCTRLaINC1 = $fb
PPUCTRLaINC32 = $ff
PPUCTRLaSPR_LEFT = $f7
PPUCTRLaSPR_RIGHT = $ff
PPUCTRLaBKGD_LEFT = $ef
PPUCTRLaBKGD_RIGHT = $ff
PPUCTRLaSPR_8X8 = $df
PPUCTRLaSPR_8X16 = $ff
PPUCTRLaNMI_DIS = $7f
PPUCTRLaNMI_ENA = $ff

PPUMASK		= $2001
PPUSTATUS	= $2002
OAMADDR		= $2003
OAMDATA		= $2004
PPUSCROLL	= $2005
PPUADDR		= $2006
PPUDATA		= $2007
SQ1_VOL		= $4000
SQ1_SWEEP	= $4001
SQ1_LO		= $4002
SQ1_HI		= $4003
SQ2_VOL		= $4004
SQ2_SWEEP	= $4005
SQ2_LO		= $4006
SQ2_HI		= $4007
TRI_LINEAR	= $4008
TRI_LO		= $400A
TRI_HI		= $400B
NOISE_VOL	= $400C
NOISE_PERIOD	= $400E
NOISE_LEN	= $400F
DMC_FREQ	= $4010
DMC_RAW		= $4011
DMC_START	= $4012
DMC_LEN		= $4013
OAM_DMA		= $4014
SND_CHN		= $4015
JOY1		= $4016
JOY2		= $4017
APU_FRAME	= $4017

;;; joypad button order
JOY_A = $80
JOY_B = $40
JOY_SELECT = $20
JOY_START = $10
JOY_UP = 8
JOY_DOWN = 4
JOY_LEFT = 2
JOY_RIGHT = 1

;-------------------------------------------------------------------------------
; Program Origin
;-------------------------------------------------------------------------------
	.text
*=$e000         ; Set program counter

dCopyright:
	.byt "COPR.1984 NAMCO "
dHUname:
	.byt "HARUHISA UDAGAWA"
dHUnameEnd:

;-------------------------------------------------------------------------------
; reset vector
;-------------------------------------------------------------------------------
Reset:	SEI
	CLD
	LDX #<top_of_stack-1	; initialize the stack to $14D (why so little space?)
	TXS
	LDA #$10
	STA PPUCTRL		; NoNMI, dc Spr8x8 Bkgd$1000 Spr$0000 Inc1 NT$2000
loop00:	LDA PPUSTATUS		; wait for a vsync
	BPL loop00
	LDX #0
	TXA
loop01:	STA 0,x			; clear memory on powerup
	STA $0200,x		; don't clear $100, that's for hiscores
	STA $0600,x		; don't clear $300-$5ff, that's cache of data from chrrom
	STA $0700,x
	INX
	BNE loop01
	LDX #0
loop02:	LDA soft_reset_flag,x
	CMP dHUname,x		; fingerprint, we copied the author name to ram elsewhere
	BNE ColdResetInit	; as a soft reset test
	INX
	CPX #(dHUnameEnd - dHUname)
	BNE loop02
	INC reset_count
	JMP WarmResetInit

;-------------------------------------------------------------------------------
ColdResetInit:
	LDX #0
	TXA
loop03:	STA $0100,x		; only difference is on a cold reset we clear page 1
	INX
	BNE loop03
	JSR ResetAllScores	; and preload the score line with some data

WarmResetInit:
	LDX #0
loop04:	LDA dHUname,x		; copy the author's name to RAM as a warm reset marker
	STA soft_reset_flag,x
	INX
	CPX #(dHUnameEnd - dHUname)
	BNE loop04
	LDX #0
	LDA #CHR_Blank
loop05:	STA status_line,x	; clears the entire 1.5 line long status line
	INX
	CPX #(status_line_end - status_line)
	BNE loop05

	LDA #>p1score
	STA chrsrc+1
	LDA #<p1score		; prep PPU line transfer of scores
	STA chrsrc
	LDA #>NameTable(3,4+32)
	STA chrdest+1
	LDA #<NameTable(3,4+32)	;  to ppu-$2883 (LL nametable, 4th col 5th row)
	STA chrdest
	LDA #$06    		; Unimportant, ignored.
	STA PPUMASK		; disable leftmost-8 clipping, but don't enable rendering
	STA ppumask_shadow
	LDA #$10
	STA PPUCTRL		; NoNMI, dc Spr8x8 Bkgd$1000 Spr$0000 Inc1 NT$2000
	STA ppuctrl_shadow
	LDA #0
	STA PPUSCROLL
	STA ppuscroll_x_shadow
	LDA #255
	STA PPUSCROLL
	STA ppuscroll_y_shadow
	LDA #0
	STA PPUMASK
	LDX PPUSTATUS
	LDA #>text_tablePPU
	STA PPUADDR
	LDA #<text_tablePPU
	STA PPUADDR		; PPUADDR= $1480 - text table
	LDA #>text_table
	STA scratch_ptr+1
	LDY #<text_table	; scratch_ptr= $0300
	STY scratch_ptr
	LDA PPUDATA
loop06:	LDA PPUDATA		; copy 768 bytes from chrrom to ram - text table
	STA (scratch_ptr),y
	INY
	BNE loop06
	INC scratch_ptr+1
	LDA scratch_ptr+1
	CMP #>text_table_end	; copy into 
	BNE loop06
loop07:	LDA PPUDATA		; copy addt'l 128 bytes for total of 896 bytes
	STA (scratch_ptr),y
	INY
	CPY #<text_table_end+1
	BNE loop07
    	;; for reference, here is the table we just copied from chrrom
;;; CPU PPU  00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff
;; 300 1480- 00 9c 15 a2 15 ad 15 b3 15 cd 15 e4 15 00 17 12  ................ ; first 128 bytes are pointers
;; 310 1490- 17 1d 17 29 17 41 17 16 15 2c 15 42 15 58 15 6e  ...).A...,.B.X.n
;; 320 14a0- 15 84 15 57 17 62 17 6d 17 7a 17 82 17 90 15 8a  ...W.b.m.z......
;; 330 14b0- 17 90 17 96 17 9c 17 a2 17 b5 17 c8 17 db 17 ee  ................
;; 340 14c0- 17 f4 17 f7 17 00 15 ff ff ff ff ff ff ff ff ff  ................
;; 350 14d0- ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
;; 360 14e0- ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
;; 370 14f0- ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................
;; 380 1500- 07 03 33 31 31 31 31 31 31 31 31 31 31 31 31 31  ..31111111111111 ; then we start actual lines of text
;; 390 1510- 31 31 31 31 35 2a 08 03 2e ff ff 38 39 3a 3b 3c  11115*.....89 ;< ; the format is    X Y String *
;; 3a0 1520- 3d 3e 3f 68 69 6a 6b ff 6c 6d 2f 2a 09 03 2e c0  =>?hijk.lm *.... 
;; 3b0 1530- c1 c2 c3 c4 c5 c6 ff ff ff ff ff c7 c8 c9 ca cb  ................
;; 3c0 1540- 2f 2a 0a 03 2e cc cd ce cf d0 d1 d2 d3 d4 d5 d6   *..............
;; 3d0 1550- d7 d8 d9 da db dc 2f 2a 0b 03 2e dd de df e0 e1  ...... *........
;; 3e0 1560- e2 e3 e4 e5 e6 e7 e8 e9 ea eb ec ed 2f 2a 0c 03  ............ *..
;; 3f0 1570- 2e ee ef f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 fa fb fc  ................
;; 400 1580- fd fe 2f 2a 15 08 90 91 92 93 94 95 96 97 98 2a  .. *...........*
;; 410 1590- 1a 08 90 91 92 93 94 95 96 97 98 2a 03 02 3a 55  ...........*.. U
;; 420 15a0- 50 2a 03 09 48 49 5b 53 43 4f 52 45 2a 03 14 3b  P*..HI[SCORE*..;
;; 430 15b0- 55 50 2a 07 01 4d 49 53 53 49 4f 4e d3 40 44 45  UP*..MISSION.@DE
;; 440 15c0- 53 54 52 4f 59 40 41 4c 49 45 4e 53 2a 09 03 57  STROY@ALIENS*..W
;; 450 15d0- 45 40 41 52 45 40 54 48 45 40 47 41 4c 41 58 49  E@ARE@THE@GALAXI
;; 460 15e0- 41 4e 53 2a 0c 01 5b 40 53 43 4f 52 45 40 41 44  ANS*..[@SCORE@AD
;; 470 15f0- 56 41 4e 43 45 40 54 41 42 4c 45 40 5b 2a ff ff  VANCE@TABLE@[*.. ;  the entire 1600 page contains no text-
;; 480 1600- c0 e0 f0 f0 90 c0 c0 c0 00 00 00 00 00 44 44 4e  .............DDN ; player ship top right
;; 490 1610- e4 f4 fc d4 44 44 00 00 6e 7e 7e 5e 4e 4e 0e 04  ....DD..n~~^NN.. ; player ship bottom right
;; 4a0 1620- 01 03 07 07 04 01 01 01 00 00 00 00 00 11 11 39  ...............9 ; player ship top left
;; 4b0 1630- 13 17 1f 15 11 11 00 00 3b 3f 3f 3d 39 39 38 10  ........;??=998. ; player ship bottom left
;; 4c0 1640- 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ ; blank tile
;; 4d0 1650- 84 70 60 80 57 a0 93 80 70 90 66 0c a2 90 80 a0  .p`.W...p.f..... ; easter egg music
;; 4e0 1660- 05 70 b1 a0 90 b0 09 00 99 0b 0d 09 8e 04 77 09  .p............w. ; easter egg music
;; 4f0 1670- 0a 07 9c 03 66 07 09 06 7a 87 8c 00 03 90 86 00  ....f...z....... ; easter egg music
;; 500 1680- 66 f0 40 60 d4 00 e5 60 f0 e0 93 00 2c 0e 2f 0c  f.@`...`....,./. ; easter egg music
;; 510 1690- fe 60 6f 00 05 e0 69 00 c9 30 20 70 8e 30 f7 40  .`o...i..0 p.0.@ ; easter egg music
;; 520 16a0- 30 80 9c 40 66 70 89 90 aa 97 99 00 b1 a0 a4 00  0..@fp.......... ; easter egg music
;; 530 16b0- 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................ ; blank tile
;; 540 16c0- 00 00 00 40 70 7c 7f 7c 00 00 00 80 80 80 80 80  ...@p|.|........ ; wave flag top
;; 550 16d0- 70 40 00 00 00 00 00 00 80 80 80 80 80 80 80 80  p@.............. ; wave flag bottom
;; 560 16e0- 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00 00  ................ ; spare life top
;; 570 16f0- 38 38 10 38 38 38 38 10 00 00 00 aa ee ee fe 92  88.8888......... ; spare life bottom
;; 580 1700- 0e 05 43 4f 4e 56 4f 59 40 40 43 48 41 52 47 45  ..CONVOY@@CHARGE
;; 590 1710- 52 2a 10 09 3a 40 50 4c 41 59 45 52 2a 12 09 3b  R*.. @PLAYER*..;
;; 5a0 1720- 40 50 4c 41 59 45 52 53 2a 18 02 5d 3a 3f 3d 3f  @PLAYERS*..] ?=?
;; 5b0 1730- 40 3a 3f 3e 3c 40 4e 41 4d 43 4f 40 4c 54 44 5c  @ ?><@NAMCO@LTD
;; 5c0 1740- 2a 1a 03 41 4c 4c 40 52 49 47 48 54 53 40 52 45  *..ALL@RIGHTS@RE
;; 5d0 1750- 53 45 52 56 45 44 2a 12 09 50 4c 41 59 45 52 40  SERVED*..PLAYER@
;; 5e0 1760- 3a 2a 12 09 50 4c 41 59 45 52 40 3b 2a 14 08 47   *..PLAYER@;*..G
;; 5f0 1770- 41 4d 45 40 40 4f 56 45 52 2a 14 0a 52 45 41 44  AME@@OVER*..READ
;; 600 1780- 59 2a 14 0a 50 41 55 53 45 2a 11 10 31 35 30 2a  Y*..PAUSE*..150*
;; 610 1790- 11 10 32 30 30 2a 11 10 33 30 30 2a 11 10 38 30  ..200*..300*..80
;; 620 17a0- 30 2a 11 07 36 30 40 40 40 40 40 40 40 40 40 40  0*..60@@@@@@@@@@
;; 630 17b0- 40 d0 d1 d2 2a 13 07 35 30 40 40 40 40 40 40 40  @...*..50@@@@@@@
;; 640 17c0- 31 30 30 40 d0 d1 d2 2a 15 07 34 30 40 40 40 40  100@...*..40@@@@
;; 650 17d0- 40 40 40 40 38 30 40 d0 d1 d2 2a 17 07 33 30 40  @@@@80@...*..30@
;; 660 17e0- 40 40 40 40 40 40 40 36 30 40 d0 d1 d2 2a 03 02  @@@@@@@60@...*..
;; 670 17f0- 3b 55 50 2a 14 00 2a 12 00 2a ff ff ff ff ff ff  ;UP*..*..*......

	LDX PPUSTATUS
	LDA #>sfx_tablePPU
	STA PPUADDR
	LDA #<sfx_tablePPU
	STA PPUADDR		; PPUADDR = $098E - sound effect table
	LDA #>sfx_table
	STA scratch_ptr+1
	LDA #<sfx_table
	STA scratch_ptr		; scratch_ptr= sfx_table
	LDA PPUDATA
	LDY #0
loop08:	LDA PPUDATA
	STA (scratch_ptr),y
	INY
	CPY #(sfx_table_end-sfx_table)
  	BNE loop08		; copy $b2=178 bytes=89 words - i.e. the rest of page 1
   	;; for reference, here is the table we just copied from chrrom
;;; CPU PPU- 00 11 22 33 44 55 66 77 88 99 aa bb cc dd eeff
;;; 150 990- 0d 0a eb 09 96 09                                pointers to 1,2,3 start
;;; 150 990-                   11 10 0f 0e 0d 0c 0b 0a 09 08  Sound Effect 3 Start
;;; 160 9a0- 07 41 42 41 42 45 42 45 47 45 47 6a 60 41 42 41  (Game start)
;;; 170 9b0- 42 45 42 45 47 45 47 6a 60 45 23 24 23 24 23 24
;;; 180 9c0- 23 24 23 24 23 24 23 24 23 24 02 03 05 06 07 08
;;; 190 9d0- 09 0a 02 03 05 06 07 08 09 0a 02 03 05 06 07 08
;;; 1a0 9e0- 09 0a 02 03 05 06 07 08 09 0a ff                 e0..ff = terminator
;;; 1a0 9e0-                                  08 07 06 05 03  Sound Effect 2 Start
;;; 1b0 9f0- 02 08 07 06 05 03 02 02 03 05 06 07 08 09 0a 0b  (Shot down bug)
;;; 1c0 a00- 0c 0d 0e 0f 10 0f 0e 0d 0c 0b 0c 0d ff
;;; 1c0 a00-                                        02 17 16  Sound Effect 1 Start
;;; 1d0 a10- 01 16 02 03 05 06 07 18 20 07 06 05 03 02 03 06  (Shot down ship)
;;; 1e0 a20- 07 08 09 0a 19 20 0a 09 08 07 08 0a 0b 0c 0d 0e
;;; 1f0 a30- 1a 20 0e 0d 0c 0b 0a 0b 0d 0e 0f 10 11 1b 3c ff
	;; only the first 6 bytes here are pointers. the rest is sound effect data
	;; .word $0a0d, $09eb, $0996

	JSR FixSfct0		; replace the pointer to Sound Effect 0 with the one in prgrom

	LDA #0
	STA scratch_ptr
ResetNametables:
	LDA ppuctrl_shadow	; we go through this twice- once for the upper nametable, once for the lower
	AND #PPUCTRLaINC1	; switch ppuctrl to inc-by-1
	STA PPUCTRL
	LDA PPUSTATUS		; reset ppuaddr flipflop
	LDA scratch_ptr		;  scratch_ptr now contains the nametable pointer
	ORA #$20
	STA PPUADDR
	LDA #0
	STA PPUADDR		; PPUADDR = $2x00 (nametables)
	LDX #>nametableSize	; 3*256+
	LDY #<nametableSize	; 192 = 960
	LDA #CHR_Blank
loop09:	STA PPUDATA		; write blank to the current nametable a total of 960 times
	DEY			; this is the entire 32x30 field
	BNE loop09
	DEX
	BPL loop09
	INX

	LDA #0
loop10:	STA PPUDATA		; then clear the attribute tables (set all to pal0)
	INX
	CPX #64
	BNE loop10

	LDX PPUSTATUS		; starting here scratch_ptr is the nametable pointer (where does that end?)
	LDX #0
	LDA scratch_ptr		; X points to first or second RLE table
	BEQ skp000		; scratch_ptr should be {0,8} for {upper,lower} nametable
	LDX #(dLowerAttributeTableRLE-dUpperAttributeTableRLE) ; first or second RLE'd attribute store
skp000:	ORA #>NamePalette(0,4)	; point to attribute table on PPU
	STA PPUADDR
	LDA #<NamePalette(0,4)
	STA PPUADDR		; PPUADDR = $2{3/7/b/f}c8 (attributes table)

loop11:	LDA dUpperAttributeTableRLE,x ; This loop loads the next RLE pair
	BEQ RLEAttrWriteDone
	TAY
	INX
	LDA dUpperAttributeTableRLE,x
loop12:	STA PPUDATA		; run-length encoding- Y counts of A
	DEY			; we started at X=0 or X=15, note, and go up, bailing when we
	BNE loop12		; hit a repeat count of 0 or X=256
	INX
	BNE loop11

RLEAttrWriteDone:
	LDA #$08
	EOR scratch_ptr		; toggle nametables (vertical arrangement)
	STA scratch_ptr
	BNE ResetNametables	; if we're writing the lower nametable go back

	LDA PPUSTATUS
	LDA #>PalettePPU
	STA PPUADDR
	LDA #<PalettePPU	; PPUADDR = $3F00 (palettes)
	STA PPUADDR
	LDY #0
loop13:	LDA dDefaultPalette,y	; load default palette
	STA PPUDATA
	INY
	CPY #(dDefaultPaletteEnd - dDefaultPalette)
	BNE loop13
	LDA ppuctrl_shadow
	ORA #PPUCTRLoNMI_ENA
	STA PPUCTRL		; enable vsync NMI
	STA ppuctrl_shadow
IdleLoop: 
	INC spincount		; 5   run counter for
	BEQ skp136		; 2/3
	JMP IdleLoop		; 3 = 10cy per inner loop, 2566cy per outer loop
skp136:	INC spincount+1		; 5 = ~660kcy per overflow, or ~20 Vsyncs
	JMP IdleLoop		; 3

;-------------------------------------------------------------------------------
ResetAllScores:
	LDX #(scores_end-p1score-1) ; sets all to $10 (blank tile)
	LDA #CHR_Blank		; (this subroutine is only called on cold reset)
loop14:	STA p1score,x
	DEX
	BPL loop14
	LDA #0
	STA hiscore+3		; then goes back and sets the high score to 5000
	STA hiscore+4		; (encoded in unpacked BCD)
	STA hiscore+5
	LDA #5
	STA hiscore+2
	JMP ResetPlayerScores	; not done yet... but the target of this jmp returns

;-------------------------------------------------------------------------------
dDefaultPalette:
	.byt $0f, $16, $30, $2c	; Black BrightOrange White Cyan (player ship)
	.byt $0f, $16, $11, $27 ; Black BrightOrange MedBlue OrangeGrey (third line of bugs and enemy ships)
	.byt $0f, $23, $11, $27	; Black LtPurple MedBlue OrangeGrey (second line of bugs)
	.byt $0f, $1a, $11, $27	; Black MedGreen MedBlue OrangeGrey (first line of bugs)
	.byt $0f, $30, $11, $27 ; Black White MedBlue OrangeGrey (stars, bullets)
	.byt $0f, $16, $11, $27 ; Black BrightOrange MedBlue OrangeGrey (stars, third line of bugs and enemy ships)
	.byt $0f, $23, $11, $27 ; Black LtPurple MedBlue OrangeGrey (stars, second line of bugs)
	.byt $0f, $1a, $11, $27 ; Black MedGreen MedBlue OrangeGrey (stars, first line of bugs)
dDefaultPaletteEnd:

dUpperAttributeTableRLE:
	.byt 2, $00		; 2 bytes of 0   ; top 16pel row = 0,0 0,0 1,1 1,1 1,1 1,1 0,0 0,0
	.byt 1, $50		; 1 byte  of $50 ; 2nd 16pel row = 0,0 0,0 0,0 1,1 1,1 0,0 0,0 0,0
	.byt 2, $55		; 2 bytes of $55
	.byt 1, $50		; 1 byte  of $50
	.byt 2, $00		; 2 bytes of 0
	.byt 8, $fa		; 8 bytes of $fa ; 3rd,5th,6th 16pel row = all 3
	.byt 8, $ff		; 8 bytes of $ff ; 4th 16pel row = all 2
	.byt 0			; terminator (total of 24 bytes)
dLowerAttributeTableRLE:
	.byt 3, $a0		; 3 bytes of $a0 ; top 16pel row = all 2
	.byt 2, $a5		; 2 bytes of $a5 ; 2nd 16pel row = 0,0 0,0 0,0 1,1 1,1 0,0 0,0 0,0
	.byt 3, $a0		; 3 bytes of $a0
	.byt 24, $aa		;24 bytes of $aa ; 3rd-8th 16pel rows = all 2
	.byt 8, $00		; 8 bytes of 0   ; 9,10th 16pel row = all 0
	.byt 8, $55		; 8 bytes of $55 ; 11,12th 16pel row = all 1
	.byt 0			;48 bytes out of 60 total
dBlankPtr:
	.word dBlankTable
dBlankTable:
	.dsb 26,CHR_Blank

;-------------------------------------------------------------------------------
; nmi vector
;-------------------------------------------------------------------------------
#define resetThreshold 45
	
NMI:	PHA			; push A, X, Y onto stack (why? we prohibit reentering
	TXA			;  and we always call from the idle loop that keeps no state in them)
	PHA
	TYA
	PHA
	TSX			; S -> X
	CPX #<stack		; check if stack overflow
	BCC Error		; carry = S>=$30
	LDA $0100+4,x		; check 4 bytes above TOS i.e. flags
	AND #$18		; check if BRK or DECimal was set
	BNE Error
	LDA $0100+6,x		; check 6 bytes above TOS i.e. MSB of return addr
	CMP #>Reset		; see where the NMI was called from
	BCC Error		; carry = NMI called from 0xE000-0xFFFF
	LDA reset_count
	CMP #resetThreshold	; see if reset count is exactly 45
	BEQ Error
	LDA nmi_entry_count	; see if the NMI reentered
	BEQ TestForMusicPlayer
Error:	JSR ReadJoy		; Something Went Wrong (or it's the 45th reset)
	LDA joy2keys		; then check player 2 joypad
	AND #(JOY_A | JOY_B)
	CMP #(JOY_A | JOY_B) 	; see if they're pressing A and B
	BNE SetCold
EnableMusic:
	LDA #1
	STA music_enable
	LDX #(dHUnameEnd - dHUname - 1)
loop15:	LDA dHUname,x		; set the warm-reset flag
	STA soft_reset_flag,x
	DEX
	BPL loop15
	JMP (dRstVec)

SetCold:
	LDA #0			; if we're not giving you the egg, reset (like a WDT)
	STA soft_reset_flag	; assume something went Wrong so make it a cold reset.
	JMP (dRstVec)

TestForMusicPlayer:
	INC nmi_entry_count
	LDA music_enable
	BEQ NoMusicEasterEgg
	LDA #$1e
	STA PPUMASK		; enable all rendering
	LDA #0
	STA OAM_DMA		; dump status of music player to screen
	JSR InitializeMusic
	LDA PPUSTATUS
	LDA #0
	STA PPUSCROLL		; reset scrolling to top left
	STA PPUSCROLL
	JMP VsyncCounter	; still run vsync count even in music easter egg

l_crud = local7
	
NoMusicEasterEgg:
	LDA #>spr_buf(0,0)	; music easteregg NOT enabled
	STA OAM_DMA		; OAM shadow is stored in page 2
	LDA ppumask_shadow	; (why do we discard this shadow?)
	LDA #$1e
	STA PPUMASK		; enable all rendering
	JSR MetatileDraw	; do metatile rendering
	LDY #235
loop16:	DEC l_crud		; 5  just something we can clobber
	DEC l_crud		; 5
	DEC l_crud		; 5
	DEY			; 2 22cy/loop
	BEQ skp001		; 2
	JMP loop16		; 3 spin 5169cy exactly (~45.5 scanlines)
skp001:	LDA PPUSTATUS
	LDA convoy_x_pos
	BEQ skp002		; if convoy_x_pos == 0 don't write a new scroll value
	EOR #$ff
	TAX
	INX
	STX PPUSCROLL		; first midframe scroll split (alien x position)
skp002:	JSR AnimateStars	;   starfield??
	JSR ReadJoy
	LDY #190
loop17:	DEC l_crud		; 5
	DEC l_crud		; 5
	DEC l_crud		; 5
	DEC l_crud		; 5
	DEC l_crud		; 5
	DEC l_crud		; 5
	DEC l_crud		; 5 42cy/loop
	DEY			; 2
	BEQ skp003		; 2
	JMP loop17		; 3 spin 7979cy exactly (~70 scanlines)

skp003:	LDA PPUSTATUS
	LDA player_x_pos
	CMP convoy_x_pos	; see if we need to adjust for 2nd midframe scroll split
	BEQ skp004		; (if player_x_pos == convoy_x_pos don't write a new scroll value)
	EOR #$ff
	TAX
	INX
	STX PPUSCROLL
skp004:	JSR PauseBlinker
	JSR DoAllSubpixelVelocity
	JSR MaybeForceCheckForStartOrSelect
VsyncCounter:
	INC num_vsyncs+2	; 24 bit vsync counter
	BNE skp005		; (not really used, sadly)
	INC num_vsyncs+1
	BNE skp005
	INC num_vsyncs
skp005:	JSR DrawScoreForCurrentPlayer
	LDA game_vsyncs
	AND #$0f
	TAX			; X=game_vsyncs&15
	LDA spincount
	ADC game_over_prng,x	; [game_over_prng+game_vsyncs&15] += spincount
	STA game_over_prng,x	; "PRNG"
	LDA #0			; done with NMI
	STA nmi_entry_count
	PLA
	TAY
	PLA
	TAX
	PLA
	RTI

;;; ----------------------------------------------------------------------------
l_subtrahend = local7
DrawScoreForCurrentPlayer:
	LDA gamestage_coro_idx
	BEQ skp006
	CMP dGamestageCoroMainGame
	BNE ret00		; bail unless dGamestageCoroMainGame or 0
skp006:	LDX #hiscore-p1score+4
loop18:	LDA p1score+1,x		; starts at LSD of high score
	STA active_player_score,x
	DEX
	BPL loop18
	LDA player_up		; are we drawing the score for player one or player two?
	BEQ skp007		; (if player one, skip the following)
	LDX #5
loop19:	LDA p2score+1,x  	; starts at LSD of P2 high score
	STA active_player_score,x ; if we're drawing player two, overwrite player one's score
	DEX			; with player two's.
	BPL loop19

skp007:	LDX #5
	SEC
loop20:	LDA active_player_score,x ; subtract the current score, whoseever it is
	AND #$0f
	STA l_subtrahend
	LDA hiscore,x		; from the highscore
	AND #$0f
	SBC l_subtrahend
	DEX
	BPL loop20

	BCS FillSpareMetatilesWithScoreLine ; skip if player's score has beat high score

	LDX #5			; if player's score has beat the high score, 
loop21:	LDA active_player_score,x ; immediately copy it over
	STA hiscore,x
	DEX
	BPL loop21
	
FillSpareMetatilesWithScoreLine:
	LDX ramd_count		; any spare metatiles should be used to draw #lives and #waves
	CPX #$10
	BCS ret00		; bail if no more allowance
	INC ramd_count
	INC score_line_column_idx
	LDA score_line_column_idx
	CMP #22			; stop at 22nd column
	BCC skp008
	LDA #0
	STA score_line_column_idx
skp008:	ASL
	TAY
	CLC
	ADC #<NameTable(20,3)	; set up for transfer as many of the row in status_line
	STA ramd_addr_l,x	; as we can
	LDA #>NameTable(20,3)
	STA ramd_addr_h,x
	LDA status_line,y
	STA ramd_lefttile,x
	LDA status_line+1,y
	STA ramd_righttile,x
	JMP FillSpareMetatilesWithScoreLine
ret00:	RTS

;-------------------------------------------------------------------------------
PauseBlinker:
	LDA pauseflag
	BEQ NotPaused		; pause flag
	LDA #0
	STA SQ1_LO		; if paused...
	STA SQ1_HI		; silence voice 1
	LDA player_x_pos
	EOR #$ff
	SEC			; calculate how to center PAUSE on screen
	ADC #132		; 132 - player_x_pos
	CMP #48			; 132 - player_x_pos <=> 48
	BCS skp009		; max(132-player_x_pos, 48)
	LDA #48
skp009:	CMP #209		; min(max(132-player_x_pos, 48), 208)
	BCC skp010		; because we used raster effects on the x scroll value
	LDA #208
skp010:	SEC
	SBC #48			; clip(0,84-player_x_pos,160)
	LSR
	LSR
	LSR			; /8
	STA pause_xcoo		; make PAUSE message appear ~centered on screen despite raster effects
	LDA #$15		; message $15 = PAUSE
	JSR ClearAndGetMessage	; clear blitter and get text
	LDA joy1keys
	AND #JOY_START		; check if p1 is holding start
	BEQ skp011
	EOR joy1prev		; check if they weren't holding start last frame
	AND #JOY_START
	BEQ skp011
	LDA #0
	STA pauseflag		; if start was newly pressed, pauseflag <= 0
	BEQ skp012
skp011:	LDA num_vsyncs+2	; make pause blink (off 8 vsyncs, on 24)
	AND #$18
	BNE ret01
skp012:	LDA #$20		; message $20 = (blank)
	JSR ClearAndGetMessage	; i.e. clear pause message
ret01:	RTS

NotPaused:
	INC game_vsyncs
	LDA gamestage_coro_idx
	JSR JumpTable
	.word DoInitPlacard	; 0
	.word TitleAndScoringScreens ; 1
	.word RunAIDemo		; 2
	.word MainGameWrapper	; 3
	.word GameOverSoundAndAnim ; 4
	.word AfterGameOverCleanup ; 5
	.word ResetGamestageCoroIdx ; 6
#define gamestageCoroInitPlacard 0
#define gamestageCoroTitleScreen 1
#define gamestageCoroRunAIDemo 2
#define gamestageCoroMainGame 3
#define gamestageCoroGameOver 4
#define gamestageCoroCleanup 5
#define gamestageCoroReset 6
;;; ----------------------------------------------------------------------------
dGamestageCoroMainGame: .byt gamestageCoroMainGame
dGamestageCoroTitleScreen: .byt gamestageCoroTitleScreen
dGamestageCoroCleanup: .byt gamestageCoroCleanup
;;; ----------------------------------------------------------------------------
ResetGamestageCoroIdx:
	LDA #0
	STA gamestage_coro_idx
	RTS
;;; ----------------------------------------------------------------------------
GameOverSoundAndAnim:
	LDA #0			; Game Over animation
	STA message_timer
	LDA #$0f		; decay over 241 periods
	STA NOISE_VOL 		; explosion sound?
	LDA #$05		;  but we hit this every vsync...?
	STA NOISE_PERIOD	; period 202 -> FIR S&H lowpass at 8.8kHz
	LDA #$08
	STA NOISE_LEN		; 10 periods
	LDA #0
	JSR RunSoundEffects
	JSR RunMainGame		; horrific reuse follows
	LDA act_play_lives	; number of frames to move things at the current velocity
	BNE skp013		; (ran out? stop now
	STA middle_coro_idx
	INC gamestage_coro_idx	;  and proceed to the next stage
	RTS

skp013:	DEC act_play_lives
	LDX #0
loop22:	TXA			; iterate over each letter in the gameover animation
	ASL
	ASL
	TAY			; Y = X*4
	CLC
	LDA velocity_bullet_x,x	; Bullet X velocities reused for Gameover velocities
	ADC spr_buf(0,xcoo),y
	STA spr_buf(0,xcoo),y
	CLC
	LDA velocity_gameover_y,x
	ADC spr_buf(0,ycoo),y
	STA spr_buf(0,ycoo),y
	INX
	CPX #$08
	BNE loop22
	RTS

;-------------------------------------------------------------------------------
AfterGameOverCleanup:
	LDA middle_coro_idx
	JSR JumpTable
	.word AfterGameOverWait, PrepareWipeAndRevertPatternTables
	.word DoRTLWipe, AfterGameOverStartTitle ; jump table
#define middleCoroAGOCWait 0
#define middleCoroAGOCPrep 1
#define middleCoroAGOCWipe 2
#define middleCoroAGOCTitle 3
;;; ----------------------------------------------------------------------------

AfterGameOverStartTitle:
	LDA #0
	STA inner_coro_idx
	STA middle_coro_idx
	LDA #gamestageCoroTitleScreen
	STA gamestage_coro_idx
	RTS

;-------------------------------------------------------------------------------
AfterGameOverWait:
	JSR RunSoundEffects
	JSR RunMainGame
	LDA #0
	STA message_timer	; reset this timer
	INC act_play_lives	; used as a timer
	BNE ret02
	INC middle_coro_idx
ret02:	RTS

;;; ----------------------------------------------------------------------------
	;; ON A GOTO y  followed by table of 16-bit addresses
	;;  code should look like JSR JumpTable ; .word fn1 fn2 fn3 fn4 &c
	;;  A can vary from 0-127; 128-255 maps to 0-127
;-------------------------------------------------------------------------------
JumpTable:
	ASL
	TAY
	PLA
	STA jump_table
	PLA
	STA jump_table+1
	INY
	LDA (jump_table),y
	STA indjump
	INY
	LDA (jump_table),y
	STA indjump+1
	JMP (indjump)

;-------------------------------------------------------------------------------
DoAllSubpixelVelocity:
	LDA game_vsyncs
	CMP game_velocity_nomiss
	BEQ ret03
	STA game_velocity_nomiss

	LDY #23			; for ALL 24 values in the arrays
loop23:	JSR DoOneSubpixelVelocity ; only do this when we caught game_vsyncs change
	DEY
	BPL loop23
ret03:	RTS

;-------------------------------------------------------------------------------
DoOneSubpixelVelocity:
	LDX #<-1
	LDA denominator_bullet_x,y
	BEQ ret03		; bail if [denominator_bullet_x+y] == 0
	LDA numerator_bullet_x,y
	CLC
	ADC remainder_bullet_x,y ; [numerator_bullet_x+y] + [remainder_bullet_x+y]
	BCC skp014

	SEC			; HERE overflow (we've lost the MSB, so run the "division" an extra time)
loop24:	INX
	SBC denominator_bullet_x,y
	BCS loop24		; when we fall out of here we've accounted for the lost MSB

skp014:	SEC			; finish the division normally
loop25:	INX
	SBC denominator_bullet_x,y
	BCS loop25

	CLC			; X = ([numerator_bullet_x+y] + [remainder_bullet_x+y])/[denominator_bullet_x+y]
	ADC denominator_bullet_x,y ; add the dividend to the overflow
	STA remainder_bullet_x,y ; and store in remainder_bullet_x
	LDA sign_bullet_x,y	; check the msb of sign_bullet_x
	BPL skp015
	TXA
	EOR #$ff		; negate
	CLC
	ADC #1			; if [R0788+y] is negative
	STA velocity_bullet_x,y ; [velocity_bullet_x+y] <- -quotient
	RTS

skp015:	TXA			; if [R0788+y] is positive
	STA velocity_bullet_x,y ; [velocity_bullet_x+y] <- quotient
	RTS

;;;-----------------------------------------------------------------------------
	;; Metatile drawer- draws one 26-tile line from the cpu address in chrsrc
	;;  to the ppu address in chrdest.
	;; Also draws up to 16 2-tile wide random-access metatiles described from $748-787
	;;  (count of tiles to draw is in ramd_count)
;-------------------------------------------------------------------------------
MetatileDraw:
	LDA ppuctrl_shadow
	AND #PPUCTRLaINC1
	STA PPUCTRL		; switch PPUCTRL to inc-1 mode
	STA ppuctrl_shadow
	LDA PPUSTATUS
	LDA chrdest+1		; start copying data to nametables
	STA PPUADDR
	LDA chrdest
	STA PPUADDR		; PPUADDR = chrdest
	LDY #0
loop26:	LDA (chrsrc),y
	STA PPUDATA
	INY
	CPY #26			; only 26 bytes (not 32?)
	BNE loop26

	LDA #>NameTable(3,0)
	STA chrdest+1		; now that we've copied those 26 bytes
	LDA #<NameTable(3,0)
	STA chrdest		; reset the blitter to defaults-
	LDA dBlankPtr+1		; namely, write 26 blank tiles
	STA chrsrc+1		; to the top row
	LDA dBlankPtr
	STA chrsrc
	LDX PPUSTATUS
	LDA ppuscroll_x_shadow
	STA PPUSCROLL		; reset scroll (we should still be in vblank, that's ok)
	LDA ppuscroll_y_shadow
	STA PPUSCROLL
	LDX #16
	LDY #0
NextTile:
	DEC ramd_count		; number of metatiles to write via this arbitrary-address mechanism
	BMI NoTile
	LDA PPUSTATUS
	LDA ramd_addr_h,y	; these are 4 16-byte arrays of data to write to ciram
	STA PPUADDR		; things are split into left tile, right tile, lower address,
	LDA ramd_addr_l,y	;  and upper address
	STA PPUADDR
	LDA ramd_lefttile,y
	STA PPUDATA
	LDA ramd_righttile,y
	STA PPUDATA
	INY
	DEX
	BNE NextTile
	JMP DoneTile

NoTile:	LDY #9
loop27:	DEY
	BNE loop27  		; spin here for the same amount of time it would take to do the writes
	DEX			; so that we always spend the same amount of time regardless of whether we're
	BNE NextTile		; blitting 16 metatiles or 0
DoneTile:
	STX ramd_count
	LDA PPUSTATUS
	LDA #>PalettePPU
	STA PPUADDR
	LDA #<PalettePPU+5	; 5th color = 2nd bkgd palette, 2nd color
	STA PPUADDR
	LDA #$16		; A=$16 (BrightOrange) (this is the same as default)
	LDX ppuscroll_y_shadow
	INX
	CPX #48			; yscroll+1 - $30
	BCC skp016
	LDA #$30		; if borrow is set (i.e. yscroll >= 48) switch A to $30 (white)
skp016:	STA PPUDATA
	LDA PPUSTATUS
	LDA ppuscroll_x_shadow	; reset scrolling
	STA PPUSCROLL
	LDA ppuscroll_y_shadow
	STA PPUSCROLL
	LDA ppuctrl_shadow
	STA PPUCTRL
	RTS

;-------------------------------------------------------------------------------
ReadJoy:
	LDA #1			; strobe joypad
	STA JOY1
	LDA #0
	STA JOY1
	LDA joy1keys
	STA joy1prev
	LDA joy2keys
	STA joy2prev
	LDX #8
loop28:	LDA JOY1		; check joypad1
	AND #$03
	CMP #$01		; button pressed in C
	ROL joy1keys		; assemble current read into joy1keys
	LDA JOY2		; check joypad2
	AND #$03
	CMP #$01
	ROL joy2keys		; assemble current read into joy2keys
	DEX
	BNE loop28

	LDA player_up		; lsb specifies whether we copy player1
	AND #$01		; or player2 input into activejoykeys
	ASL
	TAX
	LDA joy1keys,x
	STA activejoykeys
	LDX JOY1		; read 9th bit, D2
	LDA dbg_keybd_prev
	STX dbg_keybd_prev
	EOR dbg_keybd_prev	; check for change of D2
	AND #$04
	BEQ ret04
	INC dbg_keybd_cnt	; if you hit this key on D2 4 times
	LDA dbg_keybd_cnt
	CMP #4
	BCC ret04
	LDA reset_count
	CMP #10			; and if you'd reset the game 10 times
	BNE ret04
	JMP EnableMusic		; then enable the music easter egg
ret04:	RTS

;-------------------------------------------------------------------------------
dKeyMask: .byt $c0, $c0, $20, $10, 8, 4, 2, 1 ; X={0 or 1->A or B, 2->Select, 3->Start, 4->Up 5->Down 6->Left 7->Right }
FireHoldoff:			; called from ProcessPlayerBullet only with X always 0
	LDA activejoykeys	; tests for key X for the current player
	AND dKeyMask,x		; key pressed->skp017
	BNE skp017		; for Galaxian1989 replace skp017 with ret05
	LDA #3			; key not pressed->reload w/3
	STA joypad_holdoff,x
skp017:	DEC joypad_holdoff,x
	BEQ ret05
	PLA			; return to caller's caller
	PLA			; (i.e. don't StartPlayerShootSound or continue loop)
ret05:	RTS

;-------------------------------------------------------------------------------
l_player_width = local5
l_player_left_edge = local6
l_cur_bullet = local7
ProcessAllBullets:
	JSR ProcessPlayerBullet
	LDA #7
	STA l_cur_bullet
	LDY #0
	LDX #0
NextEnemyBullet:
	CLC			; loop 7 times
	LDA velocity_bullet_x,y
	ADC spr_buf(33,xcoo),x
	STA spr_buf(33,xcoo),x	; sprite33..sprite39 (enemy bullets)
	CLC
	LDA spr_buf(33,ycoo),x	; if Y coordinate of bullet is 0
	BNE skp018
	STA spr_buf(33,xcoo),x	; reset X coordinate
	BEQ DoneWithThisBullet
skp018:	ADC #2
	STA spr_buf(33,ycoo),x	; move enemy bullets down at 2pixels/vsync
	INC PlayerDiedThisVsync
	DEC PlayerDiedThisVsync	; test PlayerDiedThisVsync without modifying A
	BNE DoneWithThisBullet
	SEC
	SBC #202		; bulletY-202
	CMP #5			; bulletY-202 <=> 5?
	BCC skp019
	CMP #17			; bulletY-202 <=> 17?
	BCS DoneWithThisBullet

	LDA player_x_pos
	ADC #119
	STA l_player_left_edge	; player_x_pos + 119 = left edge
	LDA #11
	STA l_player_width	; 11 = width
	JMP skp020

skp019:	LDA player_x_pos
	ADC #122
	STA l_player_left_edge	; player_x_pos + 122 = left edge
	LDA #5
	STA l_player_width	; 5 = width

skp020:	SEC
	LDA spr_buf(33,xcoo),x
	SBC l_player_left_edge	; did it collide with the ship?
	CMP l_player_width
	BCS DoneWithThisBullet
	LDA #1
	STA PlayerDiedThisVsync
	JSR StartPlayerDiedSound
	LDA #0
	STA spr_buf(33,ycoo),x
DoneWithThisBullet:
	INY
	INX
	INX
	INX
	INX
	DEC l_cur_bullet
	BNE NextEnemyBullet
	RTS

;-------------------------------------------------------------------------------
ProcessPlayerBullet:
	LDA spr_buf(32,ycoo)	; is player's bullet at top of screen?
	BEQ skp021		; sprite32 = player bullet
	CMP #200		; is player's bullet drawn attached?
	BEQ skp022
tail05:	LDA spr_buf(32,ycoo)
	SEC
	SBC #4			; bullet velocity in pixels/vsync -- replace with 8 for Galaxian1989
	STA spr_buf(32,ycoo)
	BCS ret06		; if bullet didn't move off top of screen we're done here
skp021:	LDA #200		; bullet moved off top of screen, reset to attached-to-ship
	STA spr_buf(32,ycoo)
skp022:	LDA PlayerDiedThisVsync	; only hide bullet if player dead and bullet attached
	BEQ PinBulletToPlayer
	LDA #CHR_Blank		; player dead, hide bullet
	STA spr_buf(32,tile)
ret06:	RTS

PinBulletToPlayer:
	LDA player_x_pos	; player not dead, bullet attached to ship
	CLC
	ADC #124
	STA spr_buf(32,xcoo)	; pin bullet x to player x
	LDX #0
	JSR FireHoldoff		; check if player is holding A or B
	JSR StartPlayerShootSound
	JMP tail05		; loops back to immediately advance bullet

;-------------------------------------------------------------------------------
l_charger_xsign = local4
l_charger_ydistance = local5
l_charger_xdistance = local6
l_charger_tileoffset = local7
ret07:	RTS			; called with cur_charger_sprite=bug#*4, cur_charger=bug#
BugMakeFacing:
	LDY cur_charger_sprite	; cur_charger_sprite = which bug we're animating (0,4,8..28)
	LDA spr_buf(0,ycoo),y	; Y coord
	BEQ ret07
	CMP #192
	BCS ret07		; bail if the current bug has Y=0 or >= 192
	SEC
	SBC #208		; A = y-209
	BCS ret07		; if y>209 then bail
	EOR #$ff
	ADC #1
	STA l_charger_ydistance ; 209-y
	LDX #0
	LDA player_x_pos
	CLC
	ADC #120		; A = player_x_pos+120
	SEC
	SBC spr_buf(0,xcoo),y	; see where this sprite is relative to the player
	BCS skp024
	LDX #1
	EOR #$ff
	ADC #1			; absolute value
skp024:	STA l_charger_xdistance	; abs(player_x_pos+120-x)
	STX l_charger_xsign	; xdistance was negative
	JSR PickBugTile

WriteBugOrientation:
	ASL l_charger_tileoffset ; = tile for bug orientation
	ASL l_charger_tileoffset ; *= 4 (4 tiles per bug)
	LDX l_charger_xsign
	LDY cur_charger_sprite
	LDA spr_buf(0,attr),y
	AND #$0f		; keep palette, discard mirror&priority bits
	ORA dFlipPattern,x
	STA spr_buf(0,attr),y	; set sprite cur_charger_sprite to reflection in l_charger_xsign
	LDX cur_charger		; cur_charger = which bug we're animating (0,1,2..7)
	LDA #CHR_BugsInFlight
	CLC
	ADC charger_is_ship,x	; this is 0 or 96 for bug vs ship
	ADC l_charger_tileoffset ; is 0,4,8..24 meaning angle (units of 15deg)
	STA charger_tile,x	; and this is the resultant top-right tile for orientation
	RTS
dFlipPattern:
	.byt $80, $c0, $00, $40, ; flip sprites around (V, HV, none, H)

;-------------------------------------------------------------------------------
l_divide_divisor = local5
l_divide_dividend = local6
l_divide_quotient = local7
PickBugTile:
	LDA l_charger_xdistance	; on entry-
	CMP l_charger_ydistance	; local6 = x distance from enemy to player (abs)
	BCC skp025		; local5 = y distance from enemy to player
	LDX l_charger_ydistance
	LDY l_charger_xdistance
	STX l_divide_dividend	; swap local6 and local5 if xdist>ydist
	STY l_divide_divisor
	JSR Divide		; here l_divide_dividend=ydist l_divide_divisor=xdist
	LDA l_divide_quotient	; l_divide_quotient = (ydist/xdist)
	LDX #6			; tile 6 -- horizontal
	CMP #17 		; atan(17/128) = 7.6deg
	BCC save00		; set l_charger_tileoffset to one of 3,4,5,6 depending on l_divide_quotient
	LDX #5
	CMP #53 		; atan(53/128) = 22.5deg
	BCC save00
	LDX #4
	CMP #98			; atan(98/128) = 37.5deg
	BCC save00
	LDX #3			; tile 3 -- 45deg diagonal
	JMP save00

skp025:	JSR Divide		; bug is within the 90deg cone vertical above the player
	LDX #0			; tile 0 -- vertical
	LDA l_divide_quotient	; l_divide_quotient = xdist/ydist
	CMP #17
	BCC save00
	LDX #1
	CMP #53
	BCC save00
	LDX #2
	CMP #98
	BCC save00
	LDX #3
save00:	STX l_charger_tileoffset ; l_charger_tileoffset = tile for bug to face player
	RTS

;-------------------------------------------------------------------------------
Divide:	LDA #0			; on entry
	STA l_divide_quotient	; dividend = min(xdist,ydist)
	LDX #8			; divisor = max(xdist,ydist)
	LDA l_divide_dividend	; divides l_divide_dividend/l_divide_divisor
	LSR			; let l_divide_dividend=32, l_divide_divisor=97
loop29:	ROL			; A 32 64 128=31 62 124=27 54 108=11 22
	BCS skp026		; Q 0  0  1      2  5      10 21     42
	CMP l_divide_divisor
	BCC skp027
skp026:	SBC l_divide_divisor
	SEC
skp027:	ROL l_divide_quotient	; result in l_divide_quotient in 1.7 fixed point
	DEX			; but the MSB will only be 1 when l_divide_dividend=l_divide_divisor
	BNE loop29
	RTS

;-------------------------------------------------------------------------------
SlowBugLaunch:
	LDY cur_charger_sprite	; index in OAM of bug we're animating (0,16,32..112)
	LDX cur_charger		; which bug we're animating (0,1,2..7)
	LDA charger_timer,x
	LSR
	LSR
	CMP #12			; [charger_timer+x]=?=48,49,50,51
	BNE skp028
	INC charger_ai_coro,x
	JMP InitializeCharger

skp028:	BCS skp029
	INC charger_timer,x	; +
skp029:	BCC ContinueBugLaunch	; move charger_timer away from 0, 100 and towards 48..51
	DEC charger_timer,x	; +
ContinueBugLaunch:
	STA BugLaunchStage
	CLC
	LDA spr_buf(0,xcoo),y	; move bug according to the current velocity
	ADC velocity_charger_x,x
	STA spr_buf(0,xcoo),y
	CLC
	LDA spr_buf(0,ycoo),y
	ADC velocity_charger_y,x
	STA spr_buf(0,ycoo),y
	
	LDY BugLaunchStage	; then update the current velocity and orientation
	LDA dLaunchVelocityXPercent,y
	STA numerator_charger_x,x
	LDA dLaunchSignX,y
	STA sign_charger_x,x
	LDA dLaunchVelocityYPercent,y
	STA numerator_charger_y,x
	LDA dLaunchSignY,y
	STA sign_charger_y,x
	
YregToChargerOrientation:
	LDA dBugOrientations,y	; then update the sprite orientation
	STA l_charger_tileoffset
	LDX dBugReflection,y
	LDA local4		; save whatever was local4
	PHA
	STX l_charger_xsign	; now is reflections
	LDX cur_charger
	LDY cur_charger_sprite
	STY local3		; pointless?
	JSR WriteBugOrientation
	PLA
	STA local4		; restore whatever was local4
	RTS

dBugOrientations:
	.byt 0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1 ; 0=up, 6=right (15deg steps)
	.byt 0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0 ; other quadrants are handled by reflections
dBugReflection:
	.byt 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0 ; 2=no reflections  0=vertical
	.byt 0, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3 ; 1=both  3=horizontal
	
dLaunchVelocityXPercent:
	.byt  0, 26, 50, 71, 87, 97,100, 97, 87, 71, 50, 26
	.byt  0, 26, 50, 71, 87, 98,100, 97, 87, 71, 50, 26,  0
dLaunchSignX:
	.byt  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	.byt  0,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,  0

dLaunchVelocityYPercent:
	.byt 100, 97, 87, 71, 50, 26, 0, 26, 50, 71, 87, 97
	.byt 100, 97, 87, 71, 50, 26, 0, 26, 50, 71, 87, 97, 100
dLaunchSignY:
	.byt $80,$80,$80,$80,$80,$80,$80,  0,  0,  0,  0,  0
	.byt   0,  0,  0,  0,  0,  0,  0,$80,$80,$80,$80,$80,$80
;-------------------------------------------------------------------------------
#define BITabs .byt $2c
dScoreHundredsDigit:
	.byt 0, 0, 0, 0, 0, 0	;  this row = enemies in convoy
	.byt 0, 0, 0, 0, 1, 1	;  this row = bugs in flight
	.byt 1, 2, 3, 3, 8, 1	;  this row = ships in flight
dScoreTensDigit:
	.byt 3, 3, 3, 4, 5, 6
	.byt 6, 6, 6, 8, 0, 5
	.byt 5, 0, 0, 0, 0, 5	; score table
AddScoreToCurrentPlayer:	; A = score to add (0..17)
	JSR ExitCallerIfAI
	TAX
	LDA dScoreHundredsDigit,x ; score_to_add+0..2 aren't initialized here
	STA score_to_add+3	;  but are 0 by power-on clear
	LDA dScoreTensDigit,x
	STA score_to_add+4
	LDA player_up
	BNE skp030
	LDY #5			; player 1 has tens digit at R11B
	BITabs			; BIT, conceals following LDY
skp030:	LDY #5+p2score-p1score	; player 2 has tens digit at R12D
	CLC			; clear carry
	LDX #4
loop30:	LDA p1score,y		; starts at ones digit and goes to more significant digits
	AND #$0f		; turn blanks into 0s
	ADC score_to_add,x
	CMP #$0a		; BCD math
	BCC skp031
	SBC #$0a		; (more than 10? Subtract 10)
skp031:	STA p1score,y		; borrow from that subtract manages carry above
	DEY
	DEX
	BPL loop30

	LDX #4
loop31:	INY
	LDA p1score,y		; clear back leading 0s into blanks
	BNE skp032
	LDA #CHR_Blank
	STA p1score,y
	DEX
	BNE loop31

skp032:	TXA
	CPX #2			; looking at 1000s digit?
	BNE ret08
	LDA p1score,y		; still points to p1/p2 score as appropriate
	CMP #5			; active player gets an extra life at 5000 points.
	BNE ret08
	LDA act_play_extra_life_avail ; NO OTHER EXTRA LIVES
	BEQ ret08
	DEC act_play_extra_life_avail
	INC act_play_lives
	JSR DrawSpareLives
	LDA #1
	STA sfct_req_start
ret08:	RTS

;-------------------------------------------------------------------------------
ExitCallerIfAI:
	LDX gamestage_coro_idx
	CPX dGamestageCoroMainGame
	BEQ ret09		; if we're not playing the game
	PLA			; don't count score for the AI
	PLA
	RTS

;-------------------------------------------------------------------------------
DrawSpareLives:
	JSR ExitCallerIfAI
	LDX #2			; draws 0-3 spare lives
loop32:	CPX act_play_lives
	LDA #CHR_Blank		; pick blank tile
	BCS skp033
	LDA #CHR_OneUpTop	; or top half of lives indicator
skp033:	STA status_line+1,x
	CMP #CHR_OneUpTop&$F0	; sets carry if we're drawing a life, clears it if a space
	ADC #0			; klever hack that causes
	STA status_line_lower+1,x ; $10 if was $10
	DEX			; $6f if was $6e
	BPL loop32
ret09:	RTS

#if CHR_OneUpTop <= CHR_Blank
#print CHR_OneUpTop
#print CHR_Blank
#error CHR_OneUpTop must be > than CHR_Blank
#endif
	
;-------------------------------------------------------------------------------
l_num_flags_to_draw = local7
DrawWavesDefeated:
	JSR ExitCallerIfAI
	LDA act_play_waves
	STA l_num_flags_to_draw
	INC l_num_flags_to_draw
	CMP #5
	BCC DrawFlags		; if >=6 waves were defeated
	LDA #1			; only draw 1 flag
	STA l_num_flags_to_draw
	JSR DrawFlags		; and put the number defeated next to it
	JMP DrawFlagNumber

DrawFlags:
	LDX #4			; draws 1-5 flags
loop33:	CPX l_num_flags_to_draw
	LDA #CHR_Blank		; space
	BCS skp034
	LDA #CHR_WaveFlagTop	; a flag for each wave of enemies defeated
skp034:	STA status_line+5,x
	CMP #CHR_WaveFlagTop&$F0
	ADC #0			; same klever hack
	STA status_line_lower+5,x
	DEX
	BPL loop33
	RTS

DrawFlagNumber:
	LDX act_play_waves
	INX
	TXA
	LDY #<-1
	SEC
loop34:	INY			; add one to tens digit (in y)
	SBC #10 		; subtract ten from ones digit (in a)
	BCS loop34		; (BCD conversion)
	ADC #10
	STY status_line_lower+6
	STA status_line_lower+7
	RTS

#if CHR_WaveFlagTop <= CHR_Blank
#print CHR_WaveFlagTop
#print CHR_Blank
#error CHR_WaveFlagTop must be > than CHR_Blank
#endif

;-------------------------------------------------------------------------------
MainGameWrapper:
	JSR CheckPause		; check if start was pressed to pause game
	JSR RunSoundEffects
	LDA middle_coro_idx
	JSR JumpTable
	.word PrepareWipeAndRevertPatternTables, DoRTLWipe ; jump table
	.word InitPlayers, PlayerDiedOrWaveFinished, MaybeSkipWipe, DoRTLWipe
	.word StartNewLife, DrawPlayerAfterStartMusic, RunMainGame
#define middleCoroMainPrep 0
#define middleCoroMainWipe 1
#define middleCoroMainInit 2
#define middleCoroMainWaveFinished 3
#define middleCoroMainSkip 4
#define middleCoroMainWipe2 5
#define middleCoroMainNewLife 6
#define middleCoroMainStartMusic 7
#define middleCoroMainRun 8

;;; ----------------------------------------------------------------------------

RunMainGame:
	JSR CheckAllEnemyCollisions
	JSR EnemyLaunchTimers
	JSR IsPlayerMoving
	JSR ProcessAllBullets
	JSR AllChargerAIAndMetasprites
	JSR ConvoyAnimationOrPlayerExplosion
	JSR AdjustConvoyVelocity
	JSR MaybeFinishedWave
	JSR DoCountBugsInConvoy
	CLC
	LDA convoy_x_pos
	ADC velocity_convoy_x
	STA convoy_x_pos
	RTS

;-------------------------------------------------------------------------------
MaybeFinishedWave:
	JSR IsConvoyEmpty	; sets convoy_is_empty appropriately
	LDX #7
loop35:	LDA charger_ai_coro,x	; bail if any of the charger_ai_coros are nonzero (i.e. alive or recently dead)
	BNE ret10
	DEX
	BPL loop35

	LDX #convoyWidth-1	; HERE the convoy is empty and no ships have active AIs in flight
	LDA #0			; clear the counts here in case something got out of sync
loop36:	STA chargers_from_column,x
	DEX
	BNE loop36

	LDA convoy_is_empty
	ORA PlayerDiedThisVsync
	BEQ save01		; bail w/ side effect if player died or bugs still alive
	INC message_timer
	LDA message_timer	; wait a second
	CMP #60
	BNE ret10
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame ; not in main game mode?
	BNE skp035		; cleanup and restart something below
	LDA #middleCoroMainWaveFinished	; HERE in main game mode
	STA middle_coro_idx	; set middle_coro_idx
save01:	LDA #0
	STA message_timer
ret10:	RTS

skp035:	LDA dGamestageCoroCleanup ; restart gamestate
	STA gamestage_coro_idx
	LDA #0
	STA middle_coro_idx
	STA inner_coro_idx
	RTS

;-------------------------------------------------------------------------------
IsConvoyEmpty:
	LDX #convoyWidth-1
loop37:	LDA act_play_convoy,x	; test if any of act_play_convoy is nonzero
	BNE skp036
	DEX
	BPL loop37
	LDA #1
	STA convoy_is_empty	; convoy_is_empty is 1 iff act_play_convoy is all 0
	RTS

skp036:	LDA #0			; otherwise convoy_is_empty is 0
	STA convoy_is_empty
ret11:	RTS

;-------------------------------------------------------------------------------
CheckPause:
	LDA PlayerDiedThisVsync
	BNE ret12
	LDA joy1keys
	AND #JOY_START		; start
	BEQ ret11
	EOR joy1prev
	AND #JOY_START
	BEQ ret11
	STA pauseflag		; start was newly pressed, play sound effect for pause
	LDA #$a3		; 2-50%duty LengthCounterHalt VolumeDecays 4-Takes61Periods
	STA SQ2_VOL
	LDA #$bb		; SweepEnabled 3-Period4 SweepUp 3->>3
	STA SQ2_SWEEP
	LDA #$90		; Starting Period $190 = 280 Hz
	STA SQ2_LO
	LDA #$19		; LengthCounter = 2
	STA SQ2_HI
ret12:	RTS

;-------------------------------------------------------------------------------
AllChargerAIAndMetasprites:
	LDA #7
	STA cur_charger
	LDA #$70
	STA cur_charger_sprite
loop38:	JSR ChargerAIAndMetasprites
	SEC
	LDA cur_charger_sprite
	SBC #$10
	STA cur_charger_sprite
	DEC cur_charger
	BPL loop38
	RTS

;-------------------------------------------------------------------------------
RunChargerAI:
	LDX cur_charger
	LDA charger_ai_coro,x
	JSR JumpTable
	.word ret12
	.word MoveChargerWithConvoy, MoveChargerToTarget, ChargerOffscreen, ChargerGoesHome, DeallocateEnemy ; call table
	.word FastLaunch, MoveChargerToTarget, ChargerOffscreen, ChargerGoesHome, DeallocateEnemy ; 6 7 8 9 10
	.word EnemyExplosion, DoScoreFloat, DeallocateEnemy ; 11 12 13
#define chargerAiCoroInactive 0
#define chargerAiCoroMoveWConvoy 1
#define chargerAiCoroMoveTTarget 2
#define chargerAiCoroOffscreen 3
#define chargerAiCoroGoesHome 4
#define chargerAiCoroDeallocate 5
#define chargerAiCoroFastLaunch 6
#define chargerAiCoroMoveTTarget2 7
#define chargerAiCoroOffscreen2 8
#define chargerAiCoroGoesHome2 9
#define chargerAiCoroDeallocate2 10
#define chargerAiCoroExplode 11
#define chargerAiCoroScoreFloat 12
#define chargerAiCoroDeallocate3 13
;;; ----------------------------------------------------------------------------

FastLaunch:
	LDA #100		; initialize launch- velocities are in percent
	STA denominator_charger_x,x
	STA denominator_charger_y,x
	LDY charger_x_target,x	; this variable clearly means something different here.
	INY
	TYA
	AND #$83		; ... what?
	STA charger_x_target,x	; increment and mask?
	AND #$03
	BNE skp037
	TYA			; just incremented
	BPL skp038
	
	INC charger_timer,x	; HERE, ((1+charger_x_target)&3) == 0
	LDA charger_timer,x	;  and charger_x_target >= 127
	CMP #24
	BNE skp037		; timer counts 13..23,0..12
	LDA #0			; reset the timer if necessary
	STA charger_timer,x
	JMP skp037		; but always skip40
	
skp038:	DEC charger_timer,x	; HERE ((1+charger_x_target)&3) == 0 and charger_x_target+1 < 128
	LDA charger_timer,x
	CMP #<-1		; timer counts 11..0,23..12
	BNE skp037
	LDA #23			; reset timer if necessary
	STA charger_timer,x
	
skp037:	LDY cur_charger_sprite
	LDA charger_timer,x
	CMP #12
	BNE skp039
	INC charger_ai_coro,x	; if the timer ran out, advance to next coro
	JMP InitializeCharger	; and chain into this
skp039:	JMP ContinueBugLaunch	; timer hasn't run out.

;-------------------------------------------------------------------------------
l_distance_to_home = local7

back00:	LDA ship_score,x
	BNE skp040		; ships with nonzero score modifier can't wait for the next wave
	LDA convoy_count
	BNE skp040		; ships can't wait for the next wave if there's any members of the convoy
	LDA #chargerAiCoroInactive
	STA charger_ai_coro,x	; immediately deallocate this ship
	LDA charger_x_home,x
	TAX
	DEC chargers_from_column,x
	LDA act_play_extra_enemy ; try to save this ship for the next wave
	BNE skp041
	LDA #1
	STA act_play_extra_enemy
ret13:	RTS

skp041:	LDA act_play_extra_enemy+1 ; we've got two places for saving ships for the next wave...
	BNE ret13		; if we run out, they simply poof.
	LDA #1
	STA act_play_extra_enemy+1
	RTS

ChargerOffscreen:
	LDX cur_charger
	LDY cur_charger_sprite
	LDA PlayerDiedThisVsync
	BNE skp042		; skp042 if player's dead
	LDA convoy_count
	CMP #7
	BCS skp042		; skp042 if there are >= 7 enemies in convoy
	LDA charger_is_ship,x
	BNE back00		; try to save for the next wave if current charger's a ship
skp040:	LDA #chargerAiCoroMoveTTarget
	STA charger_ai_coro,x	; ?
	LDA #0
	STA numerator_charger_x,x ; stop moving
	STA remainder_charger_x,x
	CLC
	LDA player_x_pos
	ADC #120
	STA charger_x_target,x
tail07:	LDA #0
	STA charger_escort_b,x	; delink any escorts
	STA charger_escort_a,x
	LDA #0
	STA ship_score,x	; and reset its score
	LDA #1			;  (this way a ship that had escorts will get collected after it passes you twice)
	STA spr_buf(0,ycoo),y	; and immediately restart at at the top of the screen
	RTS

skp042:	JSR tail07
	LDA charger_x_home,x	; convert X home to pixel coordinate...
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC #48
	ADC convoy_x_pos
	STA spr_buf(0,xcoo),y	; restart ships immediately above their home position
	LDA charger_docking_timer,x ; ??
	SBC #12
	EOR #$ff		; 255-([charger_docking_timer]-12)
	STA sign_charger_x,x	;  only cares about msb
	LDA charger_y_home,x
	ASL
	ASL
	STA l_distance_to_home	; * 4
	ASL
	CLC
	ADC l_distance_to_home
	STA l_distance_to_home	; * 12
	CLC
	LDA #100
	SBC l_distance_to_home	; 100 - yhome*12
	STA charger_docking_timer,x ; count of pixels until it's home
	LDA #13
	STA numerator_charger_x,x
	LDA #0
	STA remainder_charger_x,x
	STA velocity_charger_x,x
	STA denominator_charger_x,x
	LDA #12
	STA charger_timer,x
	INC charger_ai_coro,x
	RTS

;-------------------------------------------------------------------------------
ChargerGoesHome:
	LDY cur_charger_sprite
	CLC
	LDA velocity_convoy_x
	ADC spr_buf(0,xcoo),y	; move current bug on X in parallel with convoy
	STA spr_buf(0,xcoo),y
	LDA charger_docking_timer,x
	DEC charger_docking_timer,x
	BEQ skp043
	CMP #30
	BNE skp044
	STA denominator_charger_x,x ; ???
skp044:	CLC
	LDA #1
	ADC spr_buf(0,ycoo),y	; move bug down at one pixel per vsync
	STA spr_buf(0,ycoo),y
	CLC
	LDA velocity_charger_x,x
	ADC charger_timer,x
	STA charger_timer,x	; wha?
	TAY
	JMP YregToChargerOrientation

skp043:	INC charger_ai_coro,x
	LDY charger_y_home,x
	LDA charger_x_home,x
	TAX
	LDA dTwoToThe,y
	ORA act_play_convoy,x
	STA act_play_convoy,x
	DEC chargers_from_column,x
	TXA
	JMP AllowConvoyColumnUpdate

;-------------------------------------------------------------------------------
EnemyExplosion:
	LDX cur_charger
	LDA charger_timer,x	; here is explosion stage
	INC charger_timer,x	; some kind of timer...
	CMP #$10
	BCC skp045
	LDA #chargerAiCoroInactive ; when the explosion is done, deallocate ourselves
	STA charger_ai_coro,x
	TXA
	CMP #7			; slot 7 is magic for exploding ships in formation
	BEQ DeallocateEnemy	; this causes ships in formation to never have score floats
	TAY
	LDX charger_x_home,y
	DEC chargers_from_column,x
	LDA charger_is_ship,y
	BEQ DeallocateEnemy
	LDA #chargerAiCoroScoreFloat ; here was a ship
	STA charger_ai_coro,y	; so draw the score float
	LDA #0
	STA charger_timer,y	; and reset the score float's timer
	RTS

skp045:	AND #$0c		; one of the 4 explosion tiles
	CLC
	ADC #CHR_ChargerExplosion ; (they happen to start at $70,$74,$78,$7c)
	STA charger_tile,x	; explosion tiles
	LDY cur_charger_sprite
	LDA #1
	STA spr_buf(0,attr),y	; explosion always in palette #1
	RTS

;-------------------------------------------------------------------------------
DoScoreFloat:
	LDX cur_charger
	LDA charger_timer,x
	INC charger_timer,x
	CMP #0			; on first call (was 0)
	BEQ skp046		; replace this enemy with its score
	CMP #60
	BNE ret14		; wait one second
	BEQ DeallocateEnemy	; before we hide it
ret14:	RTS

skp046:	LDY ship_score,x	; contains score value for ships
	LDA dScorePopup,y	;  (replace explosion tiles with score float)
	STA charger_tile,x	; replace this ship's tile with the score popup
	LDY cur_charger_sprite
	LDA #0
	STA spr_buf(0,attr),y	; score floats always in palette #0
	RTS
dScorePopup:
	.byt CHR_ScoreFloat150, CHR_ScoreFloat200, CHR_ScoreFloat300 ; score tile popups
	.byt CHR_ScoreFloat300, CHR_ScoreFloat800, CHR_ScoreFloat150
;;; ----------------------------------------------------------------------------
DeallocateEnemy:
	LDX cur_charger
	LDA #chargerAiCoroInactive
	STA charger_ai_coro,x
	JMP ClearEnemySprite

;-------------------------------------------------------------------------------
l_player_charger_width = local6
l_player_charger_xpos = local7

MoveChargerToTarget:
	JSR BugMakeFacing
	LDX cur_charger
	BNE skp047
	LDY charger_escort_b	; HERE we're processing spriteset 0 = ship with escorts
	BEQ skp048		; skip if no escort
	LDA charger_ai_coro,y	; charger_ai_coro[charger_escort_b]
	CMP #chargerAiCoroMoveTTarget ; skip if ai is 2
	BEQ skp048
	LDA #0
	STA charger_escort_b
	INC ship_score		; increase score if appropriate
skp048:	LDY charger_escort_a
	BEQ skp049
	LDA charger_ai_coro,y	; charger_ai_coro[charger_escort_a]
	CMP #chargerAiCoroMoveTTarget
	BEQ skp049
	LDA #0
	STA charger_escort_a
	INC ship_score		; increase score if appropriate
	JMP skp049

skp047:	LDA charger_ai_coro	; HERE we're processing spriteset 1..7
	CMP #chargerAiCoroMoveTTarget
	BNE skp049		; skip if ai is 2
	CPX charger_escort_b	; see we're pinned to the ship 0
	BNE skp050
	LDA velocity_charger_x	; if so, copy spriteset#0 x velocity to ours
	STA velocity_charger_x,x
	LDA #0
	STA numerator_charger_x,x ; obliterate subpixel calculations, we're just pinned
skp050:	CPX charger_escort_a
	BNE skp049
	LDA velocity_charger_x	; same copy of spriteset#0 to spriteset#X
	STA velocity_charger_x,x
	LDA #0
	STA numerator_charger_x,x

skp049:	LDY cur_charger_sprite	; HERE we're moving the charger towards its target.
	CLC
	LDA velocity_charger_x,x
	ADC spr_buf(0,xcoo),y
	STA spr_buf(0,xcoo),y	; move spriteset in manner of current velocity
	CMP charger_x_target,x	; compare current X to target X
	BCS skp051		; skp051 if current X > target X

	LDA numerator_charger_x,x ; as long as the x velocity is nonzero
	BEQ lAccelerateCharger
	LDA sign_charger_x,x	; and the charger's moving left (away from target)
	BPL lAccelerateCharger
	DEC numerator_charger_x,x ; slow down
	BNE skp052
	JMP skp053

lAccelerateCharger:
	ROR			; x velocity is zero or charger's moving towards the target
	STA sign_charger_x,x	; ROR=copy comparison bit from CMP above into new direction
	INC numerator_charger_x,x ; so accelerate towards target
	JMP skp052

skp051:	LDA numerator_charger_x,x ; as long as the x velocity's nonzero
	BEQ lAccelerateCharger
	LDA sign_charger_x,x	; and the charger's moving right (away from target)
	BMI lAccelerateCharger
	DEC numerator_charger_x,x ; slow down
	BNE skp052
	
skp053:	JSR MaybeChargerRelaunch ; HERE charger's x velocity is zero
	JSR InitializeCharger
skp052:	LDA spr_buf(0,ycoo),y	; done adjusting X velocity
	CLC
	ADC #1
	STA spr_buf(0,ycoo),y	; move charger down one (?)
	SEC
	SBC #64
	CMP #88			; ycoo + 192 + 168
	BCS CheckPlayerChargerCollision
	AND #$0f		; HERE 64 <= ycoo < 152
	BNE ret15		; quantized to top of every odd tile
	LDX cur_charger
	LDA charger_num_bullets,x ; if it can shoot
	BEQ ret15
	DEC charger_num_bullets,x
	JMP MaybeBugsShoot	; maybe it shoots.

ret15:	RTS

CheckPlayerChargerCollision:
	INC PlayerDiedThisVsync
	DEC PlayerDiedThisVsync
	BNE ret15		; bail unless player's alive right now.
	SBC #135
	CMP #5			; top 5 pixels of player
	BCC skp055
	CMP #19			; ? not 16 because....?
	BCS ret15
	
	LDA player_x_pos
	ADC #109		; wider (bottom 11 pixels)
	STA l_player_charger_xpos
	LDA #23			; why the extra 10? player is 13 pel wide at bottom
	STA l_player_charger_width
	JMP skp056

skp055:	LDA player_x_pos
	ADC #112		; narrower (top 5 pixels of player's ship)
	STA l_player_charger_xpos
	LDA #17			; why the extra 10? player is 7pel wide at top
	STA l_player_charger_width

skp056:	SEC
	LDA spr_buf(0,xcoo),y
	SBC l_player_charger_xpos ; player's left edge
	CMP l_player_charger_width ; player's width
	BCS ret15		; bail if no collision
	LDX cur_charger
	JSR ShotCharger		; if the charger collided with you it dies
	LDA #1
	STA PlayerDiedThisVsync	; of course, so do you.
	JMP StartPlayerDiedSound

;-------------------------------------------------------------------------------
MaybeChargerRelaunch:
	LDA convoy_is_empty
	BEQ ret16		; bail unless convoy is empty
	LDA cur_charger
	BEQ ret16		; bail if we're processing charger#0
	LDA spr_buf(0,ycoo),y
	SEC
	SBC #144		; Y - 144
	CLC
	ADC #208		; Y - 144 + 208
	BCS ret16		; bail unless 144<=y<192
	PLA
	PLA			; return to caller's caller
	LDA #chargerAiCoroFastLaunch
	STA charger_ai_coro,x	; reset ai to fast launch.
	LDA #0
	STA ship_score,x
	STA remainder_charger_x,x
	STA remainder_charger_y,x
	LDA #12
	STA charger_timer,x
	LDA charger_is_ship,x
	BEQ skp057
	LDY charger_escort_b,x	; if a ship with escorts launched
	JSR CopyChargerFractionalVelocity
	LDY charger_escort_a,x	; copy its velocity to its escorts
	JSR CopyChargerFractionalVelocity
skp057:	CLC
	LDA player_x_pos
	ADC #120
	CMP spr_buf(0,xcoo),y	; Carry if player is to left of charger
	ROR			; move C into MSB
	AND #$80		; mask out reset
	ORA #$03		; set 2 LSBs
	STA charger_x_target,x
ret16:	RTS

;-------------------------------------------------------------------------------
l_metasprite_first_tile = local7
back01:	LDX cur_charger
	INC charger_ai_coro,x	; advance ai if it went offscreen
	LDY cur_charger_sprite
	CLC
	LDA #8
	ADC spr_buf(0,xcoo),y	; did bug go off right side of screen?
	BMI skp058
	CLC			; here it didn't
	ADC #20			; 8+xcoo+20??
	JMP skp059

skp058:	SEC
	SBC #20			; 8+xcoo-20??
skp059:	STA spr_buf(0,xcoo),y
ClearEnemySprite:
	LDX cur_charger_sprite	; reset sprite starting at cur_charger_sprite (= 0,16,32..112)
	LDA #0			; we should set Y to >= 240, not 0, to disable it.
	STA spr_buf(0,ycoo),x	; except else we use bne/beq to test for utilization
	STA spr_buf(1,ycoo),x
	STA spr_buf(2,ycoo),x
	STA spr_buf(3,ycoo),x
	LDA #CHR_Blank
	STA spr_buf(0,tile),x
	STA spr_buf(1,tile),x
	STA spr_buf(2,tile),x
	STA spr_buf(3,tile),x
ret17:	RTS

ChargerAIAndMetasprites:
	JSR RunChargerAI
BuildMetasprites:
	LDX cur_charger
	LDA charger_ai_coro,x
	BEQ ret17		; bail if no-one's there
	LDX cur_charger_sprite
	LDA spr_buf(0,ycoo),x	;   0 1
	BEQ back01		;   2 3
	CMP #248
	BCS back01		; did it go off the bottom?
	STA spr_buf(1,ycoo),x	; copy sprite N (N=0,4,8...) into the 3 
	CLC			; following to make a 16x16 pel metasprite.
	ADC #8
	STA spr_buf(2,ycoo),x
	STA spr_buf(3,ycoo),x
	LDA spr_buf(0,xcoo),x
	STA spr_buf(2,xcoo),x
	CLC
	ADC #8
	STA spr_buf(1,xcoo),x
	STA spr_buf(3,xcoo),x
	
	SEC			; (Xcoordinate+8-4) >= 248
	SBC #4
	CLC
	ADC #8
	BCS back01		; did we go off right side?
	
	LDA spr_buf(0,ycoo),x
	CMP #40
	LDA spr_buf(0,attr),x
	BCC skp060		; set sprite to fg/bg based on y>=40
	AND #$df		; make sprite in foreground (over other bugs)
	JMP skp061

skp060:	ORA #$20		; make sprite behind background (under status bar)
skp061:	STA spr_buf(0,attr),x
	STA spr_buf(1,attr),x
	STA spr_buf(2,attr),x
	STA spr_buf(3,attr),x
	ROL			; rotate mirroring bits into bottom 2 bits
	ROL
	ROL
	AND #$03		; mask out mirror bits of attribute
	LDY cur_charger
	LDX charger_tile,y
	STX l_metasprite_first_tile
	LDX cur_charger_sprite
	JSR JumpTable
	.word SprSetNR, SprSetRH, SprSetRV, SprSetRBoth ; call table
;;; ----------------------------------------------------------------------------
SprSetNR:
	CLC			; not reflected at all
	LDA l_metasprite_first_tile ; sets a cluster of sprites to that starting w/ l_metasprite_first_tile
	STA spr_buf(1,tile),x	; this is not reflected on either axis-
	ADC #1			;  onscreen order is
	STA spr_buf(3,tile),x	; 2 0
	ADC #1			; 3 1
	STA spr_buf(0,tile),x
	ADC #1
	STA spr_buf(2,tile),x
	RTS
;-------------------------------------------------------------------------------
SprSetRH:
	CLC			; reflected on H
	LDA l_metasprite_first_tile
	STA spr_buf(0,tile),x	; 0 2
	ADC #1			; 1 3
	STA spr_buf(2,tile),x
	ADC #1
	STA spr_buf(1,tile),x
	ADC #1
	STA spr_buf(3,tile),x
	RTS
;-------------------------------------------------------------------------------
SprSetRV:
	CLC			; reflected V
	LDA l_metasprite_first_tile
	STA spr_buf(3,tile),x	; 3 1
	ADC #1			; 2 0
	STA spr_buf(1,tile),x
	ADC #1
	STA spr_buf(2,tile),x
	ADC #1
	STA spr_buf(0,tile),x
	RTS
;-------------------------------------------------------------------------------
SprSetRBoth:
	CLC			; reflected both
	LDA l_metasprite_first_tile
	STA spr_buf(2,tile),x	; 1 3
	ADC #1			; 0 2
	STA spr_buf(0,tile),x
	ADC #1
	STA spr_buf(3,tile),x
	ADC #1
	STA spr_buf(1,tile),x
	RTS
;-------------------------------------------------------------------------------
MaybeBugsShoot:
	PHA			; (self explanatory, right?)
	LDA charger_shooting_holdoff
	BNE skp062
	TXA
	PHA
	TYA
	PHA
	JSR AllocateBugBullet
	PLA
	TAY
	PLA
	TAX
skp062:	PLA
	RTS

;-------------------------------------------------------------------------------
l_bullet_x = local6
l_bullet_x_dist = local6
l_bullet_y = local7
AllocateBugBullet:
	LDX #6*4		; 6*4, so starts at spr_buf(39,ycoo), or last available bullet slot
loop39:	LDA spr_buf(33,ycoo),x
	BEQ skp063		; y coordinate of 0 means sprite is unused (hm)
	DEX
	DEX
	DEX
	DEX
	BPL loop39		; if all 7 bullets are in flight, don't trash stuff.
	RTS

skp063:	LDA spr_buf(0,xcoo),y	; shoot a bullet from enemy #Y/16
	CLC			; (here we transfer the x coordinate of bug -> bullet)
	ADC #4
	STA spr_buf(33,xcoo),x	; use bullet #X/4, which is the highest #d available one
	STA l_bullet_x
	LDA spr_buf(0,ycoo),y	; get the enemy's y coordinate
	CLC
	ADC #4
	STA spr_buf(33,ycoo),x	; (transfer y coordinate of bug -> bullet )
	STA l_bullet_y		; coordinates of bullet for now.
	TXA
	LSR
	LSR
	TAY			; Y now contains bullet # directly
	LDA #0
	STA remainder_bullet_x,y ; ??
	LDX #0
	CLC
	LDA player_x_pos
	ADC #124
	SEC
	SBC l_bullet_x		; distance between player and bullet
	BCS skp064		; because bug bullets are aimed at the player
	EOR #$ff		; absolute value...
	SEC
	ADC #0
	LDX #$80		; sign bit, this is a 9 bit value
skp064:	STA l_bullet_x_dist	; magnitude of distance between player and bullet
	TXA
	STA sign_bullet_x,y	; sign bit
	LDA #208
	SEC
	SBC l_bullet_y		; check vertical distance between player and bullet
	STA denominator_bullet_x,y ; <- vertical distance
	LSR			; bullets go a vspeed 2 and hspeed 1 so divide vdist by 2
	CMP l_bullet_x_dist
	BCC skp065
	LDA l_bullet_x_dist
skp065:	ASL
	STA numerator_bullet_x,y ; write either vdist or hdist*2 here ??
	RTS

;-------------------------------------------------------------------------------
l_charger_x_sign = local7
l_charger_x_dist = local7
InitializeCharger:
	LDX cur_charger
	LDY cur_charger_sprite
	LDA #0
	STA velocity_charger_x,x
	STA remainder_charger_x,x
	STA numerator_charger_x,x
	LDY charger_y_home,x
	LDA dManeuverability,y	; X speed is a function of the bug Y origin
	STA denominator_charger_x,x
	LDY cur_charger_sprite

	LDA act_play_waves
	CLC
	ADC #$ff		; !!A -> C
	LDA #0
	ADC #2			; all enemies get (at least) 2 bullets if this is the first wave
	STA charger_num_bullets,x ; and 3 every subsequent wave (some get more)

	LDA player_x_pos
	CLC
	ADC #120
	SBC spr_buf(0,xcoo),y	; see which side the bug is relative to the player
	BCS skp066		; borrow -> player is to left of bug
	EOR #$ff
	ADC #1			; absolute value again
	CLC
skp066:	ROR l_charger_x_sign	; save sign bit in MSB of l_charger_x_sign
	LSR			; A <- Xdist/2
	CMP #48
	BCS skp067
	LDA #48			; clip A to at least 48
skp067:	CMP #112
	BCC skp068
	LDA #112		; clip A to at most 111
skp068:	ROL l_charger_x_sign	;  recall sign bit
	BCC skp069
	CLC			; HERE player is to left of bug
	ADC spr_buf(0,xcoo),y
	STA charger_x_target,x	; set bug x destination - 48 to 111 pixels to right of where we are now
	CMP #248
	BCC ret18
	LDA #240
	STA charger_x_target,x	; then clip it; if it was >= 248, set it to 240
	RTS

skp069:	STA l_charger_x_dist	; HERE player is to right of bug
	SEC
	LDA spr_buf(0,xcoo),y
	SBC l_charger_x_dist
	STA charger_x_target,x	; set bug x destination - 48 to 111 pixels to left of where we are now
	BCS ret18		; if [charger_x_target+x] < 0, set it to 8
	LDA #8
	STA charger_x_target,x
ret18:	RTS

dManeuverability:
	.byt 35, 38, 40, 16, 40, 40 ; maneuverability table, lower=better
;-------------------------------------------------------------------------------
IsPlayerMoving:
	LDA PlayerDiedThisVsync
	BNE ret18
	JSR IsPlayerGoingLeft
	LDA activejoykeys
	AND #JOY_RIGHT
	BEQ ret19
	LDA player_x_pos
	CMP #106		; normalized 234
	BEQ ret19
	INC player_x_pos
ret19:	RTS

;-------------------------------------------------------------------------------
IsPlayerGoingLeft:
	LDA activejoykeys
	AND #JOY_LEFT
	BEQ ret19
	LDA player_x_pos
	CMP #<-106		; clip player to no further left than -106 (normalized 22)
	BEQ ret20
	DEC player_x_pos
ret20:	RTS

;-------------------------------------------------------------------------------
ConvoyAnimationCoro:
	DEC convoy_animation_column ; goes from 10 to -11 over and over
	LDA convoy_animation_column
	BPL AllowConvoyColumnUpdate ; while positive, AllowConvoyColumnUpdate
	CMP #<-12		; why -12?
	;; Is the important part that this -12 is convoyWidth-22,
	;; that it's -2-convoyWidth, or something else altogether?
	BNE ret21		; while it's negative, just see if we need to restart it
	LDA #convoyWidth
	STA convoy_animation_column
	INC convoy_animation	; each time we restart, increment convoy_animation
	RTS

AllowConvoyColumnUpdate:
	TAX
	INC convoy_column_req	; update one column of bugs per vsync
	LDA convoy_column_req	; but only half the time
	AND #$1f
	STA convoy_column_req
	TAY
	TXA			;  why TXA, STA  instead of STX?
	STA convoy_animation_fifo,y ; convoy_animation_fifo[convoy_column_req] <- convoy_animation_column
ret21:	RTS
;-------------------------------------------------------------------------------
l_enqueue_metatiles_ppu_addr_h = local2
l_enqueue_metatiles_ppu_addr_l = local1
l_enqueue_metatiles_first_tile = local4
l_enqueue_metatiles_draw_four = local6
l_convoy_bugmask = local5
l_convoy_animationframe = local7
dPlayerExplosionCoordinates:
	.byt <NameTable(14,28)	; The MSB is stored directly in the code
	.byt <NameTable(14,26)
	.byt <NameTable(16,28)
	.byt <NameTable(16,26)
	
ConvoyAnimationOrPlayerExplosion:
	JSR ConvoyAnimationCoro
	LDX PlayerDiedThisVsync
	BEQ DoConvoyAnimation	; go if player hasn't died
	DEX
	CPX #33
	BEQ DoConvoyAnimation	; go if player died 33 vsyncs ago
	INC PlayerDiedThisVsync
	CPX #32
	BEQ skp070
	TXA
	ASL
	TAX
	AND #$0e
	BNE DoConvoyAnimation	; go 7 out of 8 frames
	TXA			; i.e. once every 8 frames advance player explosion
	ADC #CHR_PlayerExplosion ; player's ship explosion tiles ($c3 = first frame top right)
	STA play_exploding_tile
	LDA #3
	STA play_exploding_row	; some kind of iterator
loop40:	LDA #>NameTable(14,26)
	STA l_enqueue_metatiles_ppu_addr_h
	LDX play_exploding_row	; ranges from 3..0
	LDA dPlayerExplosionCoordinates,x
	STA l_enqueue_metatiles_ppu_addr_l
	LDA play_exploding_tile
	STA l_enqueue_metatiles_first_tile ; the (lower?-)left tile to write
	STA l_enqueue_metatiles_draw_four ; if odd then draw 4 else draw 2
	CLC
	ADC #4
	STA play_exploding_tile
	JSR EnqueueMetatiles
	DEC play_exploding_row
	BPL loop40
	RTS

skp070:	LDA dPlayerExplosionCoordinates+2 ; from here to ret22
	STA l_enqueue_metatiles_ppu_addr_l ; just erases the 4x4 square
	JSR tail00		; containing the player's exploded ship
	LDA dPlayerExplosionCoordinates
	STA l_enqueue_metatiles_ppu_addr_l
tail00:	LDX #$03
loop41:	JSR tail03
	DEX
	BNE loop41
tail03:	LDY ramd_count
	CPY #$10		; only get 16*2 tiles per vsync
	BEQ ret22
	INC ramd_count
	LDA #CHR_Blank
	STA ramd_lefttile,y
	STA ramd_righttile,y
	LDA #>NameTable(14,26)
	STA ramd_addr_h,y
	LDA l_enqueue_metatiles_ppu_addr_l
	STA ramd_addr_l,y
	SEC
	SBC #$20
	STA l_enqueue_metatiles_ppu_addr_l
ret22:	RTS			; done erasing player's exploded ship

DoConvoyAnimation:
	LDA convoy_column_sync
	CMP convoy_column_req
	BEQ ret22		; bail if convoy_column_req==convoy_column_sync
	INC convoy_column_sync
	LDA convoy_column_sync
	AND #$1f
	STA convoy_column_sync	; convoy_column_sync &= 0x1F;
	TAY
	LDA convoy_animation_fifo,y
	STA convoy_column_idx	; <- convoy_animation_fifo[convoy_column_sync]
	ASL
	CLC			; convert convoy_column_idx to a coordinate on screen
	ADC #<NameTable(6,13)
	STA l_enqueue_metatiles_ppu_addr_l
	LDA #>NameTable(6,13)	; start at (6,13) and proceed to right
	STA l_enqueue_metatiles_ppu_addr_h
	LDA #4			; 4 because the top row (ships) have no idle animation
	STA l_enqueue_metatiles_draw_four ; is locally used as y coordinate of bug in convoy
	LDY convoy_column_idx 	; is x coordinate of bug in convoy
	LDA act_play_convoy,y
	STA l_convoy_bugmask	; only animate bugs that currently exist
loop42:	SEC
	LDA convoy_animation	; bug animation count (changes bugs every 22 vsyncs)
	SBC convoy_column_idx
	STA l_convoy_animationframe ; local7 = animation stage = Time - x
	LDA l_enqueue_metatiles_draw_four ; take lsb of y coordinate
	LSR			; (shove it into C)
	LDA l_convoy_animationframe
	AND #$03
	ROL			; select even or odd elements of animation by y coordinate
	TAY
	LDA dConvoyAnimationTiles,y
	STA l_enqueue_metatiles_first_tile
	LSR l_convoy_bugmask	; this column's bugs-present bits
	JSR EnqueueMetatilesBlankUnlessCarry ; so we draw blanks for missing bugs
	DEC l_enqueue_metatiles_draw_four
	BPL loop42
	LDA #CHR_ShipInConvoy
	STA l_enqueue_metatiles_first_tile
	LSR l_convoy_bugmask
	JMP EnqueueMetatilesBlankUnlessCarry

dConvoyAnimationTiles: ;lower left corners of bugs in nametable 1
	;;  (for idle animation while in convoy)
	.byt CHR_Bug8AnimB, CHR_Bug16AnimB
	.byt CHR_Bug8AnimA, CHR_Bug16AnimA
	.byt CHR_Bug8AnimB, CHR_Bug16AnimB
	.byt CHR_Bug8AnimC, CHR_Bug16AnimC
	;; this is two interleaved animations for the bugs
	;;  Bugs are on average 12 pixels high
	;;  this is achieved by alternating 16x16 metatiles with 16x8 metatiles
	;;  The odd elements ($43 $37 $43 $33) are 8 pel high
	;;  The even elements ($47 $3b $47 $3f) are 16 pel high
	;;  However the nontransparent content of each of these is the same.
;-------------------------------------------------------------------------------
;;; If Carry, fall through to EnqueueMetatiles
;;;  Otherwise, ignore local4 and draw blank tiles instead
EnqueueMetatilesBlankUnlessCarry:
	BCS EnqueueMetatiles
	LDA #1
	AND l_enqueue_metatiles_draw_four
	BEQ tail01		; tail-merged loop.
	JSR tail01
tail01:	LDA ramd_count
	CMP #$10
	BEQ ret23
	INC ramd_count
	TAY
	LDA #CHR_Blank
	STA ramd_lefttile,y
	STA ramd_righttile,y
	LDA l_enqueue_metatiles_ppu_addr_h
	STA ramd_addr_h,y
	LDA l_enqueue_metatiles_ppu_addr_l
	STA ramd_addr_l,y
	JMP tail08		; tail merged call. I wonder why more wasn't merged?

;;; EnqueueMetatiles
;;;   arguments
;;;    local2  PPU address upper byte
;;;    local1  PPU address lower byte
;;;    local4  (Lower) left of the (4) 2 tiles to draw
;;;            right is the one 2 earlier in memory
;;;            upper is one earlier than each of the two lower
;;;    local6  LSB specifies 4 vs 2 tiles
;;; local3 is trashed
l_enqueue_metatiles_current_tile = local3
EnqueueMetatiles:
	LDA l_enqueue_metatiles_first_tile ; and it-2 is the tile pair to draw
	STA l_enqueue_metatiles_current_tile
	LDA #1
	AND l_enqueue_metatiles_draw_four ; is odd->draw 4 tiles  even-> draw 2 tiles
	BEQ tail02		; tail-merged loop
	JSR tail02
	DEC l_enqueue_metatiles_current_tile ; draw 4 tiles- also draw EMFT-1 and EMFT-3
tail02:	LDA ramd_count
	CMP #$10
	BEQ ret23
	INC ramd_count
	TAY
	LDA l_enqueue_metatiles_current_tile
	STA ramd_lefttile,y	; takes the pair of tiles
	SEC
	SBC #2
	STA ramd_righttile,y	; and draws them to the location like so-
	LDA l_enqueue_metatiles_ppu_addr_h
	STA ramd_addr_h,y	;  FT-1  FT-3
	LDA l_enqueue_metatiles_ppu_addr_l ;  FT    FT-2
	STA ramd_addr_l,y
tail08:	SEC
	SBC #$20		; drawing 4 tiles -> move pointer up a row
	STA l_enqueue_metatiles_ppu_addr_l
	LDA l_enqueue_metatiles_ppu_addr_h
	SBC #0
	STA l_enqueue_metatiles_ppu_addr_h
ret23:	RTS

;-------------------------------------------------------------------------------
AnimateStars:
	LDA num_vsyncs+2	; every other vsync
	AND #$01		;    starfield animation
	BNE ret23
	LDX #$5c
loop43:	INC spr_buf(40,ycoo),x	; sprite #(63..40) move down
	LDA spr_buf(40,ycoo),x
	CMP #228		; Y=228
	BNE skp071
	DEC spr_buf(40,xcoo),x	; if we hit Y=228, move left one
	CLC			; why did we add this rather than just setting?
	ADC #40			; Y=228+40=256+12
	STA spr_buf(40,ycoo),x	; reset Y
	JMP skp072

skp071:	AND #$07		; for every other y value
	BNE skp072		; on multiples of 8 pixels
	LDA spr_buf(40,xcoo),x	; we jitter X by 128
	CLC
	ADC #$80		; (why adc instead of eor?)
	STA spr_buf(40,xcoo),x
skp072:	DEX			; start working with previous sprite
	DEX
	DEX
	DEX
	BPL loop43		; stop after we've processed sprite #40
	RTS
	RTS			; wtf?

;-------------------------------------------------------------------------------
l_launch_singleton_launch_direction = local4

TryLaunchShipOnRight:
	JSR ExitCallerIfSlot0Busy
	LDA #<-1
	STA charger_escort_direction
	LDA #0
	STA l_launch_singleton_launch_direction
	LDX #6			; only check columns 6, 5 (optimization)
loop44:	LDA act_play_convoy,x
	CMP #$20		; look for column with ship in convoy
	BCS FoundShipToLaunch	; carry = found ship
	DEX
	CPX #4
	BNE loop44
	JMP ret24		; wtf?
	RTS

TryLaunchShipOnLeft:
	JSR ExitCallerIfSlot0Busy
	LDA #1
	STA charger_escort_direction
	LDA #99
	STA l_launch_singleton_launch_direction
	LDX #3			; only check columns 3, 4 (optimization)
loop45:	LDA act_play_convoy,x
	CMP #$20
	BCS FoundShipToLaunch
	INX
	CPX #5
	BNE loop45
	JMP ret24		; wtf?
	RTS			; wtf?
ret24:	RTS

FoundShipToLaunch:
	STX column_of_ship_launching ; HERE we found a ship (X contains its column)
	JSR DoLaunchShip
	LDA #0
	STA charger_escort_b
	STA charger_escort_a
	JSR ExitCallerIfSlots1And2Busy ; make sure we have a space for its escorts
	LDX column_of_ship_launching
	LDA act_play_convoy,x
	AND #$10		; see if the bug below the ship is available
	BEQ skp073		; skip if not available
	LDA cur_charger
	STA charger_escort_b	; keep track of the last bug processed
	JSR DoLaunchEscort
	JSR ExitCallerIfSlots1And2Busy ; try to allocate escorts
skp073:	SEC
	LDA column_of_ship_launching
	SBC charger_escort_direction
	TAX
	LDA act_play_convoy,x
	AND #$10
	BEQ skp074
	LDY cur_charger
	LDA charger_escort_b
	BNE skp075
	STY charger_escort_b
	BEQ skp076
skp075:	STY charger_escort_a
skp076:	JSR DoLaunchEscort
	JSR ExitCallerIfSlots1And2Busy
skp074:	CLC
	LDA column_of_ship_launching
	ADC charger_escort_direction
	TAX
	LDA act_play_convoy,x
	AND #$10
	BEQ ret25
	LDA cur_charger
	STA charger_escort_a
	JSR DoLaunchEscort
ret25:	RTS

;-------------------------------------------------------------------------------
ExitCallerIfSlot0Busy:
	LDX charger_ai_coro	; check slot 0
	BEQ Resetship_score
	PLA			; if it's not available, return to caller's caller.
	PLA
	RTS

ExitCallerIfSlots3AndUpBusy:
	LDY act_play_waves
	CPY #1
	LDY aggressiveness
	BCC skp077
	LDX dNumberOfBugsInFlight,y ; every subsequent wave uses this table
	JMP loop46
skp077:	LDX dNumberOfBugsInFlightOnFirstWave,y ; on first wave use this table
loop46:	LDA charger_ai_coro,x	; check the AI in slot N down-to 3
	BEQ Resetship_score	; if the Xth slot is empty bail with side effect
	DEX
	CPX #2
	BNE loop46
	PLA			; return to caller's caller if none of slots N..3 are in use
	PLA
	RTS

Resetship_score:
	STX cur_charger
	LDA #0
	STA ship_score,x
	RTS

dNumberOfBugsInFlightOnFirstWave:
	.byt 3, 3, 4, 4, 5, 5, 6, 6
dNumberOfBugsInFlight:
	.byt 3, 4, 4, 5, 5, 6, 6, 6

ExitCallerIfSlots1And2Busy:
	LDX #2
loop47: LDA charger_ai_coro,x	; check AI slots 2 and 1
	BEQ Resetship_score
	DEX
	BNE loop47
	PLA			; if both slot 2 and 1 are in use, return to caller's caller.
	PLA
	RTS

;-------------------------------------------------------------------------------
l_convoy_yhome_bit = local7

TryLaunchSingletonOnLeft:
	JSR ExitCallerIfSlots3AndUpBusy
	LDA #99
	STA l_launch_singleton_launch_direction
	LDY #2			; 2=other bugs
loop48:	LDA dBugMask,y
	STA l_convoy_yhome_bit
	LDX #0			; start on left
loop49:	LDA act_play_convoy,x
	AND l_convoy_yhome_bit	; any of the relevant bug?
	BNE FoundSingletonToLaunch
	INX			; no, try next column to right
	CPX #convoyWidth	; ran out of formation?
	BNE loop49
	DEY			; we've launched all the current rank
	BPL loop48		;  try again with the next rank of enemies
	RTS			; no bugs to launch

dBugMask:
	.byt $20, $10, $0f	; ship, lieutenant bug, other bugs

TryLaunchSingletonOnRight:
	JSR ExitCallerIfSlots3AndUpBusy
	LDA #0
	STA !l_launch_singleton_launch_direction ; wtf
	LDY #2
loop50:	LDA dBugMask,y
	STA l_convoy_yhome_bit
	LDX #convoyWidth-1	; start on right
loop51:	LDA act_play_convoy,x
	AND l_convoy_yhome_bit	; any of the relevant bug?
	BNE FoundSingletonToLaunch
	DEX			; no, try next column to left
	CPX #<-1		; ran out of formation?
	BNE loop51
	DEY			; we've launched all the current rank
	BPL loop50		;  try again with the next rank
	RTS

FoundSingletonToLaunch:
	LDY #$20
	STY l_convoy_yhome_bit	; is a mask
	LDY #5			; A contained the masked set of bugs we might launch
loop52:	CMP l_convoy_yhome_bit	; pick off the top one of the set first
	BCC skp078
	TYA
	PHA			; Y,A contain the index of the bug to launch
	JSR DoLaunchSingleton
	PLA
	LDX cur_charger
	STA ship_score,x	; and save y coordinate = score
	RTS
skp078:	LSR l_convoy_yhome_bit	; try the next lower bug
	DEY
	BPL loop52
	RTS			; shouldn't fall through, but better safe than sorry

;;; ----------------------------------------------------------------------------
l_convoy_bug_y = local1
l_convoy_xhome = local2
l_convoy_yhome = local5
l_charger_tile_offset = local6
l_charger_palette = local7

DoLaunchShip:
	LDY #$20
	STY l_convoy_yhome_bit
	LDY #5			; launch a ship
	JMP DoLaunchSingleton

DoLaunchEscort:
	INC ship_score
	LDA #4
	LDY cur_charger
	STA ship_score,y	; ?
	LDY #$10		; launch a lieutenant in association with a ship
	STY l_convoy_yhome_bit
	LDY #4
	
DoLaunchSingleton:
	STX l_convoy_xhome	; Y contained bug-to-launch index (y coordinate)
	LDA act_play_convoy,x	; X contained convoy column # (x coordinate)
	EOR l_convoy_yhome_bit	; 2**Yhome
	STA act_play_convoy,x	; remove the bug to launch from formation.
	INC chargers_from_column,x
	LDA dBugPalettes,y
	STA l_charger_palette	; (variable reuse)  the palette for this ship
	LDA dBugOrShip,y
	STA l_charger_tile_offset ; the tile index offset
	STY l_convoy_yhome	; the rank/y home
	TYA
	ASL
	ASL
	STA l_convoy_bug_y	; y*4
	TXA
	JSR AllowConvoyColumnUpdate ; does something to convoy_column_req and convoy_animation_fifo
	LDX cur_charger
	INC charger_ai_coro,x	; ?
	LDA #50
	STA ship_diving_period	; 4.4kHz
	LDA #100
	STA denominator_charger_x,x
	STA denominator_charger_y,x
	LDA #0
	STA remainder_charger_x,x
	STA remainder_charger_y,x
	STA velocity_charger_x,x
	STA velocity_charger_y,x
	STA numerator_charger_x,x
	STA numerator_charger_y,x
	LDA l_launch_singleton_launch_direction
	STA charger_timer,x
	STA charger_docking_timer,x
	TXA
	ASL
	ASL
	ASL
	ASL			; convert cur_charger to
	STA cur_charger_sprite	; cur_charger_sprite = 16*cur_charger (as ever)
	TAY
	LDA l_charger_palette
	STA spr_buf(0,attr),y	; set up corresponding sprite palette
	LDA l_charger_tile_offset
	STA charger_is_ship,x	; tile number
	LDA l_convoy_yhome
	STA charger_y_home,x	; y home
	LDA l_convoy_xhome
	STA charger_x_home,x	; & x home
	ASL
	ASL
	ASL
	ASL
	CLC			; convert x home into sprite coordinate
	ADC #48
	ADC convoy_x_pos
	STA spr_buf(0,xcoo),y	; sprite x = convoy_x_pos + 48 + 16 * xhome
	LDA l_convoy_bug_y
	ASL
	CLC
	ADC l_convoy_bug_y
	STA l_convoy_bug_y		; convert y home into sprite coordinate
	SEC
	LDA #100
	SBC l_convoy_bug_y
	STA spr_buf(0,ycoo),y	; sprite y = 100 - (12 * yhome)

MoveChargerWithConvoy:
	LDY cur_charger_sprite	; move the sprite on launch in parallel with the convoy, at least at first
	CLC
	LDA spr_buf(0,xcoo),y
	ADC velocity_convoy_x
	STA spr_buf(0,xcoo),y
	JMP SlowBugLaunch

dBugPalettes:
	.byt 3, 3, 3, 2, 1, 1
dBugOrShip:
	.byt 0, 0, 0, 0, 0, (CHR_ShipInFlight - CHR_BugsInFlight)
;-------------------------------------------------------------------------------
l_convoy_column_loop = local6
AdjustConvoyVelocity:
	LDA sign_convoy_x	; is clearly another instantiation of velocity_convoy_x. But... how does it get from
	BMI skp079		;   here actually to velocity_convoy_x
	LDY #convoyWidth-1	; for each column, starting on the right
	LDA #200
loop53:	LDX act_play_convoy,y	; if the column isn't empty
	BNE skp080
	LDX chargers_from_column,y ; or someone will be returning to it
	BNE skp080		; then skip80
	SEC
	SBC #16
	DEY
	BPL loop53
	RTS

skp080:	CLC			; HERE we found a column that some bug calls home.
	ADC convoy_x_pos
	CLC
	ADC #40			; (200-16*columns_missing_on_right) + convoy_x_pos + 40
	BCC ret26
	LDA #$80		; HERE convoy_x_pos >= 16 && convoy_x_pos < 56
	STA sign_convoy_x
ret26:	RTS

skp079:	LDY #0
	LDA #<-200
	LDX #convoyWidth-1	; for each column, starting on the left
	STX l_convoy_column_loop
loop54:	LDX act_play_convoy,y
	BNE skp081
	LDX chargers_from_column,y ; look for a column that a bug calls home.
	BNE skp081
	CLC
	ADC #16
	INY
	DEC l_convoy_column_loop
	BPL loop54
	RTS

skp081:	CLC			; here we found a column a bug calls home.
	ADC convoy_x_pos
	CMP #40			; convoy_x_pos - (200-16*columns_missing_on_right) - 40
	BCS ret26
	LDA #0			; HERE convoy_x_pos >= 200 && convoy_x_pos < 240
	STA sign_convoy_x
	RTS

;-------------------------------------------------------------------------------
l_deallocate_bullet = local7
CheckAllEnemyCollisions:
	LDA #0
	STA l_deallocate_bullet	; "didn't shoot anything down"
	JSR CheckConvoyCollision
	JSR CheckAllChargerCollision ; (this allows us to hit two enemies at the same time)
	JSR RunChargerNotShootingHoldoff
	LDA l_deallocate_bullet	; "bullet collided with something"
	BEQ ret27
	LDA #0			; so deallocate it.
	STA spr_buf(32,ycoo)	; reset player bullet
ret28:	RTS

;-------------------------------------------------------------------------------
RunChargerNotShootingHoldoff:
	LDA charger_shooting_holdoff ; not clear why this is a subroutine
	BEQ ret28
	DEC charger_shooting_holdoff
	RTS

;-------------------------------------------------------------------------------
CheckAllChargerCollision:
	LDA spr_buf(32,ycoo)	; player bullet
	CMP #200
	BEQ ret28		; bail if it's attached to ship
	LDX #6			; check slot 6
	STX cur_charger
	LDY #$60		; 16 bytes per bug
	STY cur_charger_sprite
loop55:	JSR CheckChargerCollision
	LDA cur_charger_sprite
	SEC
	SBC #$10
	STA cur_charger_sprite	; and check each of slots 6,5,4,3,2,1,0.
	DEC cur_charger
	BPL loop55
ret27:	RTS

;-------------------------------------------------------------------------------
CheckChargerCollision:
	LDX cur_charger
	LDY cur_charger_sprite
	LDA charger_ai_coro,x	; bail if there's no AI for this charger
	BEQ ret27
	CMP #11
	BEQ ret27		; bail if the charger AI is on 11 (exploding)
	CMP #12
	BEQ ret27		;   or 12(score float)
	LDA spr_buf(32,xcoo)	; player bullet
	CLC
	ADC #2			; bullet starts in column 3 - 1 pixel margin on left side of bug
	SEC
	SBC spr_buf(0,xcoo),y	; check for collision between player bullet and the current bug
	CLC
	ADC #<-12		; only 11 wide
	BCS ret27		; (didn't collide on x, bail)
	LDA spr_buf(32,ycoo)
	CLC
	ADC #6			; bug margin?
	SEC
	SBC spr_buf(0,ycoo),y	; hm, could collide. is it a y collision?
	CLC
	ADC #<-13		; bugs are 12 high
	BCS ret27		; (didn't collide on y, bail)

ShotCharger:
	LDA #chargerAiCoroExplode ; HERE bullet is colliding with charger
	STA charger_ai_coro,x	;  charger AI 11 is "explode"
	LDA #0
	STA charger_timer,x
	INC l_deallocate_bullet	; mark that we shot something down
	LDA charger_is_ship,x	; see if they just shot down a bug or a ship
	BEQ ShotBugCharger	; 0 is bug
	LDA #180		; HERE shot down a ship
	STA charger_shooting_holdoff ;  other flying ships won't fire for 3 seconds after you shoot down a ship
	LDA #1
	STA sfct_req_start+1
	LDY charger_escort_b,x	; copy some stuff around...
	JSR CopyChargerFractionalVelocity
	LDY charger_escort_a,x
	JSR CopyChargerFractionalVelocity
	CLC
	LDA ship_score,x	; what's the current point value of this ship?
	ADC #12			; ranges from 12 to 17 (150, 200, 300, 300, 800, 150 points)
	JMP AddScoreToCurrentPlayer

CopyChargerFractionalVelocity:
	BEQ ret29
	LDA sign_charger_x,x
	STA sign_charger_x,y
	LDA remainder_charger_x,x
	STA remainder_charger_x,y
	LDA numerator_charger_x,x
	STA numerator_charger_x,y
	LDA denominator_charger_x,x
	STA denominator_charger_x,y
ret29:	RTS

ShotBugCharger:
	LDA #1			; HERE shot down a bug
	STA sfct_req_start+2
	CLC
	LDA charger_y_home,x	; what's the current point value of this bug?
	ADC #6			; ranges from 6 to 11 (60, 60, 60, 80, 100, 150 points)
	JMP AddScoreToCurrentPlayer

;-------------------------------------------------------------------------------
ConvoyEvadeBullet:
	LDA spr_buf(32,ycoo)
	CMP #160
	BCS ret30		; bail if the player's bullet is lower on the screen than y=160
	LDA #0
	STA velocity_convoy_x	; if higher (y<160), stay still
ret30:	RTS

CheckConvoyCollision:
	SEC
	LDA spr_buf(32,xcoo)	; player bullet
	SBC convoy_x_pos
	SEC
	SBC #46
	CMP #160		; spr_buf(32,xcoo) - convoy_x_pos - 46 <=> 160
	BCS ret29		; bail if spr_buf(32,xcoo) - convoy_x_pos >= 206
	TAX			; stuff in X
	AND #$0f
	CMP #$0d		; bugs in convoy are 13 pixels wide -- keeps the bugs from colliding sideways with the bullet
	BCS ConvoyEvadeBullet	; (i.e. on 13,14,15 don't move convoy)
	LDA spr_buf(32,ycoo)
	SEC
	SBC #108		; spr_buf(32,ycoo) - 108
	BCS ret29		; bail if spr_buf(32,ycoo) >= 108 (no bugs in convoy below there)
	EOR #$ff
	ADC #1			; 108 - spr_buf(32,ycoo)
	CMP #72			; 108 - spr_buf(32,ycoo) <=> 72
	BCS ret29		; bail if spr_buf(32,ycoo) <= 36 (no bugs in convoy above there)
	LDY #<-1
	SEC
loop56:	INY			; Y++
	SBC #12			; average height of bugs
	BCS loop56		; Y = (108-spr_buf(32,ycoo))/12
	TXA			; get back bullet X phase
	LSR
	LSR
	LSR
	LSR
	TAX			; X = (spr_buf(32,xcoo) - convoy_x_pos - 46)/16
	LDA dTwoToThe,y		; check for the existance of this bug
	AND act_play_convoy,x
	BEQ ret29		; bail if this bug doesn't exist
	EOR act_play_convoy,x
	STA act_play_convoy,x	; delete this bug
	STX l_convoy_xhome	; <- the column of bug we just killed
	TYA
	PHA
	ASL
	ASL
	STA l_convoy_bug_y	; <- 4*the row of the bug we just killed
	TXA
	JSR AllowConvoyColumnUpdate ; clobbers X,Y
	INC l_deallocate_bullet	;  mark that we shot something down
	LDA #chargerAiCoroExplode
	STA charger_ai_coro+7
	STA sfct_req_start+2	; req start sound effect two
	LDA #0
	STA charger_timer+7
	LDA l_convoy_xhome
	ASL
	ASL
	ASL
	ASL			; convert bug column back to pixel X
	CLC
	ADC convoy_x_pos	; incorporate x scroll
	CLC
	ADC #48			; and fixed skew
	STA spr_buf(28,xcoo)	; to place explosion tiles
	LDA l_convoy_bug_y
	ASL l_convoy_bug_y
	CLC
	ADC l_convoy_bug_y
	STA l_convoy_bug_y	; *= 3
	LDA #100
	SEC
	SBC l_convoy_bug_y	; converted bug row back to pixel Y
	STA spr_buf(28,ycoo)
	LDA #CHR_ChargerExplosion
	STA charger_tile+7	; slot 7 is just explosions from the convoy
	LDY #$70
	STY cur_charger_sprite	; 7 is a special value for the explosion
	LDX #7
	STX cur_charger
	JSR ChargerAIAndMetasprites
	PLA			; recover the row # of the bug-in-convoy we just killed
	JMP AddScoreToCurrentPlayer

ret31:	RTS
dTwoToThe: .byt 1, 2, 4, 8, 16, 32, 64, 128

;-------------------------------------------------------------------------------
l_timers_that_overflowed = local7
EnemyLaunchTimers:
	LDA PlayerDiedThisVsync
	BEQ skp082
	JMP ResetWaveTimers	; if the player just died, ResetWaveTimers

skp082:	LDA enemy_launch_timer	; some kind of timer
	BEQ skp083		; only decrement while it's not run out
	DEC enemy_launch_timer	;  (decrement it)
	CMP #78
	BNE skp083		; skip unless it's now 77
	LDA convoy_count
	CMP #27			; approximately 60%
	BCS skp083		; skip if there are still at least 27 bugs in convoy
	LDA player_x_pos
	BMI skp084
	JSR TryLaunchShipOnLeft	; do this if the player is on the right half screen
	JSR TryLaunchShipOnRight
	JMP skp083
skp084:	JSR TryLaunchShipOnRight ; other order if the player is on the left half screen
	JSR TryLaunchShipOnLeft
	
skp083:	INC wave_vsyncs		; counts vsyncs 
	LDA wave_vsyncs
	CMP #60 		; (60 vsyncs makes a second)
	BNE skp085
	LDA #0
	STA wave_vsyncs
	INC wave_seconds	; count seconds
	LDA wave_seconds
	CMP #20			; modulo 20
	BNE skp085
	LDA #0
	STA wave_seconds
	LDA aggressiveness	; every 20 seconds, increase AI aggressiveness
	CMP #7
	BEQ skp085
	INC aggressiveness
skp085:	LDA game_vsyncs
	AND #$03
	BNE ret31		; slow down MRSL to 1/4, allow "9 seconds*60Hz" to be specified in 1 byte
	JSR MaybeRequestShipLaunch
	LDA #0
	STA l_timers_that_overflowed

	LDX #7
loop57:	INC misc_timers,x	; increment each of the first 8 misc_timers
	LDA misc_timers,x
	CMP dMiscTimersPeriods,x ; and see when each timer hit the corresponding value in this lookup table
	BCC skp086
	ROL l_timers_that_overflowed ; at that time set the next least significant bit
	LDA #0
	STA misc_timers,x	; and reset the timer whose period just expired
skp086:	DEX
	BPL loop57
	
	LDA l_timers_that_overflowed
	LDX aggressiveness
	AND dLSBs,x		; check only the X+1 LSBs  (wtf? if anything's set the LSB is)
	BEQ ret31		; (bail if none were set)
	INC launch_singleton_from_right ; toggle if any of the timers overflowed
	LDA enemy_launch_timer
	BNE ret32		; bail if enemy_launch_timer hasn't run out
	LDA #1
	AND launch_singleton_from_right
	BEQ skp087
	JMP TryLaunchSingletonOnRight ; alternate between these two routines on every overflow
skp087:	JMP TryLaunchSingletonOnLeft

ret32:	RTS

;-------------------------------------------------------------------------------
MaybeRequestShipLaunch:
	LDX act_play_waves
	CPX #1
	LDX aggressiveness
	BCC skp088
	LDA dTimeToShipLaunch,x	; use this table for every wave after the first
	JMP skp089

skp088:	LDA dTimeToShipLaunchFirstWave,x ; use this table for the very first wave
skp089:	BEQ ret33
	INC launch_ship_timer
	CMP launch_ship_timer
	BNE ret33
	LDA #0
	STA launch_ship_timer

	LDX #6			; check columns 6,5,4,3
loop58:	LDA #$20		; check for ships in enemy convoy
	AND act_play_convoy,x
	BNE skp090		; found a ship? -> skip91
	DEX
	CPX #2
	BNE loop58
	RTS

skp090:	LDA #150		; if there are any ships still in convoy
	STA enemy_launch_timer	;  enemy_launch_timer <- 150 (Why 150?)
ret33:	RTS

dMiscTimersPeriods:
	.byt  70, 100, 178, 169, 163, 154, 151, 118
	
dLSBs:	.byt $01, $03, $07, $0f, $1f, $3f, $7f, $ff ; 2**(N+1)-1

dTimeToShipLaunchFirstWave:
	.byt   0, 135, 135, 135, 120, 120, 120, 120 ; vsyncs/4? i.e. inf,9,8 seconds
dTimeToShipLaunch:
	.byt 135, 135, 135, 120, 120, 120, 120, 105 ; and 9,8,7 seconds ?
;-------------------------------------------------------------------------------
l_bugs_in_column_count = local7
DoCountBugsInConvoy:
	LDA game_vsyncs
	AND #$0f
	CMP #convoyWidth
	BCC skp091		; branch if game_vsyncs&15<convoyWidth
	BNE ret34		; bail if game_vsyncs != convoyWidth
	LDA convoy_running_sum
	STA convoy_count	; copy it over once we've run all the columns
	LDA #0
	STA convoy_running_sum	; reset running sum
ret34:	RTS

skp091:	TAX			; X<-A is column of bugs to work with
	LDA #0
	STA l_bugs_in_column_count
	LDA act_play_convoy,x
	LDX #5
loop59:	LSR
	BCC skp092
	INC l_bugs_in_column_count ; count the number of bugs in this column
skp092:	DEX
	BPL loop59
	
	CLC
	LDA l_bugs_in_column_count
	ADC convoy_running_sum
	STA convoy_running_sum	; convoy_running_sum is running sum of bugs in convoy
	RTS

;-------------------------------------------------------------------------------
RunAIDemo:
	JSR RunSoundEffects
	LDA middle_coro_idx
	JSR JumpTable
	.word InitPlayers, PlayerDiedOrWaveFinished, StartNewLife, DrawPlayerAfterStartMusic, AIDemo
#define middleCoroAIInit 0
#define middleCoroAIWaveFinished 1
#define middleCoroAINewLife 2
#define middleCoroAIStartMusic 3
#define middleCoroAIRun 4
;;; ----------------------------------------------------------------------------
l_should_ai_shoot = local5
AIDemo: LDA #0
	STA activejoykeys	; stored separately so that one algorithm can request shooting
	STA l_should_ai_shoot	; while another requests moving
	LDA game_vsyncs
	AND #$7f		; (pick new ai target every 128)
	BNE skp093
	LDA game_over_prng 	; "prng"
	AND #$3f
	ADC #96
	STA ai_x_target		; ranges from 96 to 159
skp093:	JSR AIEvadeBullets
	JSR AIShootOrEvadeEnemy
	JSR AIShootAndMoveToTarget
	LDA activejoykeys
	ORA l_should_ai_shoot
	STA activejoykeys
	JMP RunMainGame

;-------------------------------------------------------------------------------
l_normalized_player_left_edge = local4
l_closest_bullet_y = local7
l_closest_bullet_idx = local6
AIEvadeBullets:
	LDA #0
	STA l_closest_bullet_y
	LDA player_x_pos
	CLC
	ADC #108
	STA l_normalized_player_left_edge

	LDX #6
loop60:	TXA
	ASL
	ASL
	TAY
	LDA spr_buf(33,xcoo),y	; check on sprite39..33 = enemy bullets
	SBC l_normalized_player_left_edge
	CMP #32			; is bullet X right in front of player?
	BCS skp094
	LDA spr_buf(33,ycoo),y
	CMP #216		; is bullet already past?
	BCS skp094
	CMP l_closest_bullet_y	; is another bullet closer?
	BCC skp094
	STA l_closest_bullet_y	; the closest bullet's y coordinate
	STY l_closest_bullet_idx ; the closest bullet's sprite number
skp094:	DEX
	BPL loop60
	
	LDA l_closest_bullet_y	; only start evading bullets lower than y=160
	CMP #160
	BCC ret35
	LDX l_closest_bullet_idx
	LDA player_x_pos
	ADC #123
	CMP spr_buf(33,xcoo),x
	BCC save02		; move ship to evade bullet
	BCS save03
ret35:	RTS

;-------------------------------------------------------------------------------
l_normalized_player_x = local7
AIShootOrEvadeEnemy:
	LDA activejoykeys
	BNE ret36		; bail if any buttons pressed
	LDX spr_buf(12,ycoo)
	INX
	CPX #96
	BCC ret36		; bail if spr_buf(12,ycoo)+1 < 96

	LDA player_x_pos
	CLC
	ADC #120
	STA l_normalized_player_x

	LDA spr_buf(32,ycoo)	; player bullet
	CMP #200		; different evasive behavior if we have our bullet
	BNE skp095

	LDA spr_buf(12,ycoo)	; For the beginning of the game, only spriteset#3 is active
	CMP #184		; so the AI only sees it.
	BCC skp096
	LDA #JOY_A		; shoot when you see the whites of their eyes
	STA l_should_ai_shoot
skp096:	LDA spr_buf(12,xcoo)
	SEC
	SBC l_normalized_player_x ; compare spr_buf(12,xcoo) to normalized player x
	ROR l_normalized_player_x ; signed /2
	CLC
	ADC #1			; see if difference (predivide) was -3 to +3
	CMP #3
	BCC skp097		; branch if on center
	LDA l_normalized_player_x ; otherwise move to intercept
	BPL save02
	BMI save03
skp097:	LDA #JOY_DOWN		; but this doesn't do anything...??
	STA activejoykeys	; we're aligned for incoming bug
	RTS

skp095:	LDA spr_buf(12,xcoo)	; run away from enemy if we have no bullet
	CMP l_normalized_player_x
	BCS save02
	BCC save03
ret36:	RTS

;-------------------------------------------------------------------------------
AIShootAndMoveToTarget:
	LDA activejoykeys
	BNE ret37		; bail if any buttons pressed
	LDA spr_buf(32,ycoo)	; player bullet
	CMP #200
	BNE skp098
	LDA #JOY_A		; is attached to player's ship so shoot it
	STA l_should_ai_shoot
skp098:	LDA player_x_pos
	CLC
	ADC #$80
	CMP ai_x_target		; AI, move ship towards target
	BEQ ret37
	BCS save02
save03:	LDA #JOY_RIGHT
	BNE skp099
save02:	LDA #JOY_LEFT
skp099:	STA activejoykeys
ret37:	RTS

;-------------------------------------------------------------------------------
LoadTitlePlacard:
	LDA inner_coro_idx
	JSR JumpTable
	.word InitPlacard, DrawTitlePlacard, DrawStartText, DrawScoreKey, TitleDone
#define innerCoroInitPlacard 0
#define innerCoroDrawPlacard 1
#define innerCoroDrawText 2
#define innerCoroDrawKey 3
#define innerCoroTitleDone 4
;;; ----------------------------------------------------------------------------

InitPlacard:
	LDA #0			; title screen is stored without skew
	STA ascii_offset
	LDA #6			; 6 rows in the title screen
	STA placard_count
	INC inner_coro_idx
	RTS

;-------------------------------------------------------------------------------
DrawTitlePlacard:
	LDA placard_count	; if placard_count is nonzero...
	BEQ skp100
	CLC
	ADC #$0a
	JSR ClearAndGetMessage	; display one of messages $b-$11
	DEC placard_count	; which are "fill the nametables with the title screen"
	RTS
skp100:	INC placard_count
	LDA #$22		; message $22 (title placard top margin)
	JSR ClearAndGetMessage
	INC inner_coro_idx	; after we've drawn the title screen do the next one
	LDA #4
	STA placard_count	; 4 rows in what's next
	LDA #"0"
	STA ascii_offset
	RTS

;-------------------------------------------------------------------------------
DrawStartText:
	LDA placard_count
	CLC
	ADC #6
	JSR ClearAndGetMessage	; display messages 7-$a
	DEC placard_count
	BNE ret38
	INC inner_coro_idx	; advance to next coro
ret38:	RTS

;-------------------------------------------------------------------------------
DrawScoreKey:
	INC inner_coro_idx	; next coro!
	LDA #1
	STA placard_count
	LDA #0
	JSR ClearAndGetMessage	; message 0 = 1UP
	LDA #1
	JSR GetMessage		; message 1 = HI-SCORE
	LDA #2
	JMP GetMessage		; message 2 = 2UP

;-------------------------------------------------------------------------------
TitleDone:
	INC middle_coro_idx	; outside next coro
	LDA #0
	STA inner_coro_idx	; reset this coro
	RTS

;-------------------------------------------------------------------------------
	;; needs to be before MFCfSoS instead of after the coro listing in TaSS.
#define middleCoroTSInit 0
#define middleCoroTSScroll 1
#define middleCoroTSStart 2
#define middleCoroTSReverse 3
#define middleCoroTSPrep 4
#define middleCoroTSWipe 5
#define middleCoroTSScoringInit 6
#define middleCoroTSScoringText 7
#define middleCoroTSScoringScores 8
#define middleCoroTSScoringRotate 9
#define middleCoroTSPrep2 10
#define middleCoroTSWipe2 11
#define middleCoroTSDone 12
;;; ----------------------------------------------------------------------------
l_currently_at_check_for_start_or_select = local7
MaybeForceCheckForStartOrSelect:
	LDA gamestage_coro_idx
	BEQ ret39		; bail if gamestage_coro_idx = 0 (must draw placard first)
	CMP dGamestageCoroMainGame
	BEQ ret39		; bail if gamestage_coro_idx = dGamestageCoroMainGame (then it pauses instead)
	LDA joy1keys
	AND #(JOY_SELECT|JOY_START) ; bail unless they're pressing start or select
	BEQ ret39

	LDX dGamestageCoroTitleScreen
	LDA gamestage_coro_idx
	STX gamestage_coro_idx	; force gamestage_coro_idx to gamestage_coro_Titlescreen
	EOR gamestage_coro_idx	; A is 0 if gamestage_coro_idx previously was dGamestageCoroTitleScreen
	STA l_currently_at_check_for_start_or_select
	LDX #middleCoroTSStart
	LDA middle_coro_idx
	STX middle_coro_idx	; force middle_coro_idx to 2 (CheckForStartOrSelect)
	EOR middle_coro_idx	; A is 0 if middle_coro_idx previously was 2
	ORA l_currently_at_check_for_start_or_select
				; A = (old)middle_coro_idx ^ 2  |  (old)gamestage_coro_idx ^ dGamestageCoroTitleScreen
	BEQ ret39		; bail if we didn't successfully change at least one of gamestage_coro_idx or middle_coro_idx
	LDA #0
	STA SQ1_LO		; HERE, we jumped to "checking for start or select"
	STA SQ1_HI		; silence voice 1
	LDA #$80		; reset the timeout to ~2 seconds
	STA game_start_timeout
	JMP FullTitleOn		; and Draw title screen

ret39:	RTS

;-------------------------------------------------------------------------------
TitleAndScoringScreens:
	LDA middle_coro_idx
	JSR JumpTable
	.word InitScrollTitle, ScrollTitleOn, CheckForStartOrSelect, ReversePatternTables
	.word PrepareWipeAndRevertPatternTables, DoRTLWipe, InitScoringScreen
	.word DrawScoringText, DrawScoringScores, RotateShipScores
	.word PrepareWipeAndRevertPatternTables, DoRTLWipe, ExitTitleAndScoringScreens
	;; the #defines are above by 20 lines
;;; ----------------------------------------------------------------------------
InitScrollTitle:
	INC middle_coro_idx	; reset scrolling for title screen (now 0,0)
	LDA #0
	STA ppuscroll_y_shadow
	STA sinkhole1		; never used anywhere?
	LDA #239
	STA title_sprites_y_offset
	RTS

;-------------------------------------------------------------------------------
ScrollTitleOn:
	DEC title_sprites_y_offset ; scroll down 239 times over 239 vsyncs (4sec)
	BEQ skp101
	INC ppuscroll_y_shadow
	JMP skp102
skp101:	INC middle_coro_idx	; if we finished scrolling
FullTitleOn:			;  this entry == didn't bother scrolling, just on-screen
	LDA #239
	STA ppuscroll_y_shadow	; pin everything to where it's supposed to be
	LDA #0
	STA title_sprites_y_offset
	STA message_timer
skp102: LDA #0			; disable the h-splits on the title
	STA player_x_pos
	STA convoy_x_pos
	LDA ppuscroll_y_shadow
	CMP #48
	BCC skp103
	LDA ppuctrl_shadow	; change pattern tables as we scroll past scanline 48
	AND #PPUCTRLaBKGD_LEFT	; background from $0000
	ORA #PPUCTRLoSPR_RIGHT	; sprites from $1000
	STA ppuctrl_shadow
skp103:	JSR ClearSprites	; clears first 40 sprites
	LDA #CHR_Selector
	STA spr_buf(0,tile)	; sprite 0 - tile $2F (right-pointing triangle)
	LDA #80
	STA spr_buf(0,xcoo)	; sprite 0 - X location 80 = column 10
	LDA #CHR_LogoHole
	STA spr_buf(1,tile)	; sprites 1,2,3 - tile $2E (holes in text in logo)
	STA spr_buf(2,tile)
	STA spr_buf(3,tile)
	LDA #117
	STA spr_buf(1,xcoo)	; sprite 1 - X location 117
	LDA #91
	STA spr_buf(2,xcoo)	; sprite 2 - X location 91
	LDA #162
	STA spr_buf(3,xcoo)	; sprite 3 - X location 162
	LDA title_sprites_y_offset
	CLC
	ADC #90
	BCC skp104		; if title_sprites_y_offset>166
	LDA #$ff		;  don't yet draw the holes-in-text sprites
skp104:	STA spr_buf(1,ycoo)
	STA spr_buf(2,ycoo)
	STA spr_buf(3,ycoo)
	LDA numplayers		; convert number of players (0 or 1)
	AND #1
	ASL
	ASL
	ASL
	ASL			; into
	ADC #128		; 128 or 144 meaning "1 player or 2 players"
	ADC title_sprites_y_offset
	BCC skp105		; if title_sprites_y_offset>128 or 144
	LDA #$ff		;  don't yet draw the num players selection arrow
skp105:	STA spr_buf(0,ycoo)
	RTS

;-------------------------------------------------------------------------------
ReversePatternTables:
	INC middle_coro_idx
	LDA ppuctrl_shadow
	AND #PPUCTRLaSPR_LEFT	; force sprites to pattern table 0
	ORA #PPUCTRLoBKGD_RIGHT	; force background to pattern table 1
	STA ppuctrl_shadow
	LDA #255
	STA ppuscroll_y_shadow
ClearSprites:
	LDX #0
	TXA
loop61:	STA spr_buf(0,ycoo),x	; clear first 40 sprites
	INX
	CPX #$a0
	BNE loop61
	RTS

;-------------------------------------------------------------------------------
CheckForStartOrSelect:
	LDA game_vsyncs
	AND #$01
	BNE skp106
	DEC message_timer	; decrease message_timer at 30Hz
	BNE skp106
	INC middle_coro_idx	; middle_coro_idx++ if (message_timer == 0)
skp106:	INC game_start_timeout	; try to increment
	LDA joy1keys
	AND #(JOY_START|JOY_SELECT) ; start or select?
	BNE skp107		;  while neither were pressed
	STA game_start_timeout	;   pin to 0
skp107:	LDA game_start_timeout
	CMP #3
	BNE skp108		; bail if neither button has been pressed for at least 3 passes
	LDA joy1keys
	AND #JOY_START		; start?
	BNE skp109		;  -> go there
	INC numplayers		; otherwise it was select that was pressed so toggle the number of players
	LDA #0			; wtf, WHY DID THEY USE INC?
	STA message_timer	;  also reset message_timer
skp108:	LDA numplayers
	AND #1
	ASL
	ASL
	ASL
	ASL
	ADC #128
	STA spr_buf(0,ycoo)	; update #players selection pointer
	RTS

skp109:	LDA dGamestageCoroMainGame ; HERE start was pressed!
	STA gamestage_coro_idx
	LDA #0
	STA middle_coro_idx	; reset all the coros to a known state
	STA inner_coro_idx
	LDA #0
	STA sfct_req_start
	STA sfct_req_start+1
	STA sfct_req_start+2	; explicitly don't start sound effects 0-2
	LDA #1
	STA sfct_req_start+3	; and start 3 (start 'music')
	LDA #"0"
	STA ascii_offset
	LDA #$21		; ?
	STA PlayerDiedThisVsync
	RTS

;-------------------------------------------------------------------------------
InitScoringScreen:
	INC middle_coro_idx
	LDA #0
	STA placard_count	; GetMessage into TL nametable
	STA wipe_mode		; will erase scoring screen
	STA message_timer
	STA ascii_offset
	STA inner_coro_idx
	LDA #$16
	JMP ClearAndGetMessage	; message $16 = NAMCOT (logotype)

;-------------------------------------------------------------------------------
DrawScoringText:
	INC message_timer
	LDA message_timer
	SBC #48
	BCC ret40		; bail if message_timer < 48
	STA message_timer	; and save
	LDA #"0"
	STA ascii_offset
	LDA inner_coro_idx	; inner_coro_idx is used here to draw the text
	CMP #4
	BCS DoneDrawingScoringText		;  skp110 if inner_coro_idx >= 4
	ADC #3			; display one of "MISSION- DESTROY ALIENS", 
	JSR ClearAndGetMessage	;  "WE ARE THE GALAXIANS", "- SCORE ADVANCE TABLE -", "CONVOY CHARGER"
	INC inner_coro_idx
	RTS

DoneDrawingScoringText:
	INC middle_coro_idx	; HERE inner_coro_idx >=4 - advance outer
	LDA #0
	STA inner_coro_idx	; reset self
	LDA #chargerAiCoroMoveWConvoy
	STA charger_ai_coro	; choose AI #1 for bug #0
	STA spr_buf(4,attr)	; choose palette 1 for bug #1?
	LDA #0
	STA cur_charger		; wait, AI and other properties for #0
	LDA #$10
	STA cur_charger_sprite	; but sprite for #1?
	LDA #132
	STA spr_buf(4,ycoo)	; sprite #1 is at (56,132)
	LDA #56
	STA spr_buf(4,xcoo)
	LDA #CHR_ShipInFlight	; ship facing up
	STA charger_tile
	JSR BuildMetasprites
ret40:	RTS

;-------------------------------------------------------------------------------
	;;  uses game_vsyncs as a vsync counter
ScoringRotateAvailableScoresForShip:
	LDA #$1b
	JSR ClearAndGetMessage	; message $1b = 60           pts
	LDA game_vsyncs
	LSR
	LSR
	LSR
	LSR
	LSR			; (game_vsyncs >> 5) & 3
	AND #$03
	CLC
	ADC #$17		; $17..$1A = "150","200","300","800"
	JMP GetMessage		; i.e. scores of captain ships depending on where

;-------------------------------------------------------------------------------
l_bug_loop = local7
DrawScoringScores:
	JSR ScoringRotateAvailableScoresForShip
	INC message_timer
	LDA message_timer	; Borrow will only be false if message_timer is now 256=0
	SBC #48
	BCC ret41 		;  bail if message_timer was < 48
	STA message_timer	; save it
	LDA inner_coro_idx	; inner_coro_idx is used to specify charger sprites
	CMP #3			;  and text
	BCS skp111		;  skp111 if inner_coro_idx is >= 3
	ADC #$1c
	JSR ClearAndGetMessage	; display one of "50  100 pts", "40  80 pts", "30  60 pts"
	LDA #CHR_BugsInFlight	; bug facing up
	STA charger_tile
	LDA inner_coro_idx
	ASL
	ASL
	ASL
	ASL
	STA l_bug_loop		; = inner_coro_idx * 16
	CLC
	ADC #$20
	STA cur_charger_sprite	; = l_bug_loop + $20 -> bugset #s 2..4
	TAX
	LDA l_bug_loop
	ADC #148
	STA spr_buf(0,ycoo),x	; set y coordinate for same to l_bug_loop + 148
	INC inner_coro_idx
	LDA inner_coro_idx
	STA spr_buf(0,attr),x	; and set palettes per same (except we go 1,2,3)
	LDA #56
	STA spr_buf(0,xcoo),x	; bugs on scoring screen are always at x=56
	JSR BuildMetasprites
ret41:	RTS

skp111:	INC middle_coro_idx	; inner_coro_idx >= 3
	LDA #0
	STA inner_coro_idx	; reset self and advance outer
	STA message_timer
	RTS

;-------------------------------------------------------------------------------
RotateShipScores:
	JSR ScoringRotateAvailableScoresForShip
	DEC message_timer
	BNE ret42
	INC middle_coro_idx
ret42:	RTS

;-------------------------------------------------------------------------------
ExitTitleAndScoringScreens:
	INC gamestage_coro_idx	; advance outermost and reset other two
	LDA #0
	STA middle_coro_idx
	STA inner_coro_idx
	RTS

;-------------------------------------------------------------------------------
MaybeSkipWipe:
	LDA should_do_wipe
	BNE DontSkipWipe
	INC middle_coro_idx	; skip the wipe if should_do_wipe==0
	INC middle_coro_idx
	RTS

DontSkipWipe:
	LDA #0
	STA should_do_wipe
PrepareWipeAndRevertPatternTables:
	INC middle_coro_idx
	LDA #32
	STA wipe_xcoo
	LDX ppuscroll_y_shadow
	INX			; if ppuscroll_y = 255
	BEQ skp113
	JSR ClearSprites	; then zero out all the first 40 sprites
skp113:	LDA #255
	STA ppuscroll_y_shadow
	LDA ppuctrl_shadow	; switch pattern tables
	ORA #PPUCTRLoBKGD_RIGHT	; background from $0000
	AND #PPUCTRLaSPR_LEFT	; sprites from $1000
	STA ppuctrl_shadow
	RTS

;-------------------------------------------------------------------------------
l_clear_addr_l = local1
DoRTLWipe:
	DEC wipe_xcoo		; does a right-to-left wipe of screen, used for both erasing Scoring info
	BNE skp114		; and for erasing playfield
	INC middle_coro_idx
	LDA #0
	STA convoy_x_pos
	STA convoy_animation_column
	STA convoy_column_idx
skp114:	LDX #39			; for ALL sprites except stars
loop62:	TXA
	ASL
	ASL
	TAY
	LDA spr_buf(0,xcoo),y
	LSR
	LSR
	LSR			; see if sprite X / 8 == wipe_xcoo
	CMP wipe_xcoo
	BNE skp115
	LDA #0
	STA spr_buf(0,ycoo),y	; if it were equal, 'erase' that sprite
	STA spr_buf(0,xcoo),y
skp115:	DEX
	BPL loop62

loop63:	LDX ramd_count
	CPX #$10
	BCS ret43
	INC ramd_count
	LDA #0
	STA l_clear_addr_l
	LDA dScoringScreenYCoordinates,x
	LDY wipe_mode		; picks between the two tables below
	BEQ skp116		; AFAICT, there's no reason to care.
	LDA dGameplayScreenYCoordinates,x
skp116:	LSR			; take bottom 3 bits of A
	ROR l_clear_addr_l	; rotate into top 3 bits
	LSR
	ROR l_clear_addr_l
	LSR
	ROR l_clear_addr_l	; take top 5 bits of A
	ORA #$20		; and use as CIRAM address
	STA ramd_addr_h,x	;  (treat as <ignored, ynt, xnt, y4, y3> )
	LDA wipe_xcoo		; get X address
	ORA l_clear_addr_l	; l_clear_addr_l contained <y2, y1, y0, 0,0,0,0,0>
	STA ramd_addr_l,x
	LDA #CHR_Blank
	STA ramd_lefttile,x
	STA ramd_righttile,x
	JMP loop63
ret43:	RTS
dScoringScreenYCoordinates:
	.byt 7, 9, 12, 14, 17, 19, 21, 23, 26 ; Y coordinates for messages on scoring screen
	.byt 5, 6, 27, 8, 10, 11, 13
dGameplayScreenYCoordinates:
	.byt 5, 6, 7, 8, 9, 10, 11, 12 	; for wiping game playfield
	.byt 13, 17, 19, 21, 25, 26, 27, 28

;;; ----------------------------------------------------------------------------
	;; ClearAndGetMessage- clear and get text (also entry GetMessage, just get text)
	;; parameter- A picks one of N strings fetched from chrrom and cached in $300-$5ff
	;;  Table-
	;;  A  ptr   Y  X normalized text
	;;  0 $159C  3  2 1UP
	;;  1 $15A2  3  9 HI-SCORE
	;;  2 $15AD  3 20 2UP
	;;  3 $15B3  7  1 MISSION- DESTROY ALIENS
	;;  4 $15CD  9  3 WE ARE THE GALAXIANS
	;;  5 $15E4 12  1 - SCORE ADVANCE TABLE -
	;;  6 $1700 14  5 CONVOY CHARGER
	;;  7 $1712 16  9 1 PLAYER
	;;  8 $171D 18  9 2 PLAYERS
	;;  9 $1729 24  2 ©1979 1984 NAMCO LTD.
	;; $A $1741 26  3 ALL RIGHTS RESERVED
	;; $B $1516  8  3 title screen first row
	;; $C $152C  9  3 title screen second row
	;; $D $1542 10  3 title screen third row
	;; $E $1558 11  3 title screen fourth row
	;; $F $156E 12  3 title screen fifth row
	;;$10 $1584 21  8 NAMCOT  (in logotype)
	;;$11 $1757 18  9 PLAYER 1
	;;$12 $1762 18  9 PLAYER 2
	;;$13 $176D 20  8 GAME  OVER
	;;$14 $177A 20 10 READY
	;;$15 $1782 20 10 PAUSE
	;;$16 $1590 26 10 NAMCOT  (in logotype)
	;;$17 $178A 17 16 150
	;;$18 $1790 17 16 200
	;;$19 $1796 17 16 300
	;;$1a $179C 17 16 800
	;;$1b $17A2 17  7 60           PTS
	;;$1c $17B5 19  7 50       100 PTS
	;;$1d $17C8 21  7 40        80 PTS
	;;$1e $17DB 23  7 30        60 PTS
	;;$1f $17EE  3  2 2UP
	;;$20 $17F4 20  0  (blank for erasing "PAUSE", "READY", or "GAME  OVER")
	;;$21 $17F7 18  0  (blank for erasing "PLAYER 1" or "PLAYER 2")
	;;$22 $1500  7  3 title screen zeroth row

	;; calls 35-62 point to 0xFFFF, which will be
	;;  interpreted as an address in prg-rom
	;; calls 63-127 are even worse

;-------------------------------------------------------------------------------
ClearAndGetMessage:
	PHA
	LDA #CHR_Blank
	LDY #$19
loop77:	STA text_to_blit,y 	; fill text_to_blit with 26 of tile $10
	DEY
	BPL loop77
	PLA
GetMessage:
	LDY #>text_to_blit	; set up the 26ch blitter to point to text_to_blit
	STY chrsrc+1
	LDY #<text_to_blit
	STY chrsrc
	ASL
	TAY			; Y = A*2
	LDA text_table+1,y
	STA scratch_ptr		; pick one of array of pointers to strings in chrrom
	LDA text_table+2,y	; e.g. A=0 -> scratch_ptr=$159c
	STA scratch_ptr+1
	SEC
	LDA scratch_ptr		; convert chrrom address to address we copied into memory
	SBC #<(text_tablePPU - text_table) ; ( scratch_ptr - $1180 )
	STA scratch_ptr
	LDA scratch_ptr+1
	SBC #>(text_tablePPU - text_table) ; so we've now converted it from a pointer
	STA scratch_ptr+1	; to chrrom into a ointer to wram
	LDY #0			; e.g. A=0 -> scratch_ptr=$041C
	LDA #$18
	STA chrdest		; chrdest=$18
	LDA (scratch_ptr),y	; get the lsb of the that (A=0 -> A=3)
	LSR
	ROR chrdest
	LSR
	ROR chrdest
	LSR			; move the 3lsbs out of A into the top 3msb of chrdest
	ROR chrdest		; (and so because the 3lsb of Y address in the nametable)
	ORA #$20		; the remaining 5 bits become 2msb of Y address and 3bits of crud
	LDX placard_count
	BEQ skp137
       	ORA #$08
skp137: STA chrdest+1		; draw in lower nametable if we're part of the titlescreen loops.
	INY
	LDA (scratch_ptr),y	; get the next byte (X position)
	TAX
	INY
loop78:	LDA (scratch_ptr),y	; now start fetching text
	CMP #"*"		; * terminated
	BEQ ret44
	SEC
	SBC ascii_offset	; subtract skew amount from it
	STA text_to_blit,x	; copy text to the blitter
	INX
	INY
	CPX #$1a		; no overflows please
	BCC loop78
ret44:	RTS

;-------------------------------------------------------------------------------
DoInitPlacard:
	LDA middle_coro_idx
	JSR JumpTable
	.word TitleInit, LoadTitlePlacard, ResetStarsAndStatusLine
#define middleCoroDIPInit 0
#define middleCoroDIPLoad 1
#define middleCoroDIPReset 2
;;; ----------------------------------------------------------------------------
TitleInit:
	INC middle_coro_idx	; advance middle_coro_idx timeshare
	LDA #0
	STA inner_coro_idx	; inner_coro_idx <- 0
	LDA #$c0
	STA APU_FRAME		; disable apu irq, choose 5step mode
	LDA #$0f
	STA SND_CHN		; enable noise, triangle, both pulse channels
	LDA #$bf		; duty50%, LCLHalt, Constant volume, volume 15
	STA SQ1_VOL
	LDA #$7f		; not enabled, don't randomly mute self
	STA SQ1_SWEEP
	RTS

;-------------------------------------------------------------------------------
ResetStarsAndStatusLine:
	INC gamestage_coro_idx	; rotate outside coro
	LDA #0
	STA middle_coro_idx	; reset our own coro
	JSR InitStarfield	; initialize starfield sprites
	LDX #43
	LDA #CHR_Blank
loop64:	STA status_line,x	; clears the entire status line
	DEX
	BPL loop64

	LDA #"0"
	STA ascii_offset
	LDA #0			; make sure to draw to upper nametable
	STA placard_count
	JSR ClearAndGetMessage	; message 0 = 1UP
	LDA #$01
	JSR GetMessage		; message 1 = HI-SCORE
	RTS

;-------------------------------------------------------------------------------
InitPlayers:
	INC middle_coro_idx
	LDA #0
	STA numplayers_bit
	STA player_up
	LDA #100
	STA denominator_convoy_x
	LDA #"0"
	STA ascii_offset
	LDA #20
	STA numerator_convoy_x
	LDA #1
	STA act_play_extra_life_avail
	STA oth_play_extra_life_avail
	STA wipe_mode		; 1=erase convoy and player
	LDA #$21
	STA PlayerDiedThisVsync
	LDA #1
	STA act_play_lives
	STA oth_play_lives
	LDA #0
	STA act_play_waves
	STA oth_play_waves
	STA placard_count
	STA act_play_extra_enemy
	STA act_play_extra_enemy+1
	STA oth_play_extra_enemy
	STA oth_play_extra_enemy+1
	JSR InitFirstWave
	LDX #convoyWidth-1
loop65:	LDA act_play_convoy,x
	STA oth_play_convoy,x
	DEX
	BPL loop65
	LDX #7
	LDA #chargerAiCoroInactive
loop66:	STA charger_ai_coro,x
	DEX
	BPL loop66
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame
	BNE ret45
	LDA numplayers
	AND #1
	STA numplayers_bit
	STA player_up
	LDA #3
	STA act_play_lives
	STA oth_play_lives
	JSR ResetPlayerScores
	JSR DrawWavesDefeated
	JSR DrawSpareLives
	LDA #0
	JSR ClearAndGetMessage	; message 0 = 1UP
	LDA #$01
	JSR GetMessage		; message 1 = HI-SCORE
ret45:	RTS

;-------------------------------------------------------------------------------
PlayerDiedOrWaveFinished:
	JSR RunMainGame
	LDA PlayerDiedThisVsync
	BEQ skp117		; if he didn't die, he must have killed all the enemies
	LDA act_play_lives
	BNE skp118
	JMP PlayerLostLastLife	; he just died and has no more lives

skp118:	JSR SwapPlayersIfTwoPlayer
skp117:	JSR NextWave
	INC middle_coro_idx
	RTS

;-------------------------------------------------------------------------------
StartNewLife:
	JSR RunMainGame
	LDA #0			; reset message_timer timer
	STA message_timer
	LDA inner_coro_idx
	JSR JumpTable
	.word DecrLivesAndMaybeDrawPlayerReady, MaybeDrawPlayerN, DoErasePlayerReady, DoErasePlayerN ; JumpTable
;;; ----------------------------------------------------------------------------
DecrLivesAndMaybeDrawPlayerReady:
	INC middle_coro_idx
	LDA PlayerDiedThisVsync	; er.
	BEQ ret46
	DEC act_play_lives	; finally decrement their lives after death
	LDA #0
	STA player_x_pos	; reset where they are
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame ; if in demo mode, don't draw "ready"
	BNE skp119
	LDA #$14
	JSR ClearAndGetMessage	; message $14 = READY
skp119:	DEC middle_coro_idx
	INC inner_coro_idx
ret46:	RTS

;-------------------------------------------------------------------------------
MaybeDrawPlayerN:
	INC inner_coro_idx
	LDA #60			; 1 second before we erase this message
	STA timeout_ready
	LDA numplayers
	AND #1
	BEQ ret46		; if only one player, don't indicate who's up now
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame
	BNE ret46		; if in demo mode, don't indicate who's up now
	LDA player_up
	CLC
	ADC #$11		; messages $11 or $12 = "PLAYER 1" or "PLAYER 2"
	JMP ClearAndGetMessage

;-------------------------------------------------------------------------------
DoErasePlayerReady:
	DEC timeout_ready	; wait a little while first
	BNE ret46
	INC inner_coro_idx
	LDA #$20
	JMP ClearAndGetMessage	; message $20 = (blank) to erase "READY"

;-------------------------------------------------------------------------------
DoErasePlayerN:
	INC middle_coro_idx
	LDA #0
	STA inner_coro_idx
	LDA #$21
	JMP ClearAndGetMessage	; message $21 = (blank) to erase "PLAYER 1" or "PLAYER 2"

;-------------------------------------------------------------------------------
SwapPlayersIfTwoPlayer:
	LDA numplayers_bit
	BEQ ret46
DoSwapPlayers:
	LDX act_play_extra_life_avail ; swap stuff for players.
	LDY oth_play_extra_life_avail
	STX oth_play_extra_life_avail
	STY act_play_extra_life_avail
	LDX act_play_lives
	LDY oth_play_lives
	STX oth_play_lives
	STY act_play_lives
	LDX act_play_waves
	LDY oth_play_waves
	STX oth_play_waves
	STY act_play_waves
	LDX act_play_extra_enemy
	LDY oth_play_extra_enemy
	STX oth_play_extra_enemy
	STY act_play_extra_enemy
	LDX act_play_extra_enemy+1
	LDY oth_play_extra_enemy+1
	STX oth_play_extra_enemy+1
	STY act_play_extra_enemy+1
	LDX #0
loop67:	LDA act_play_convoy,x
	LDY oth_play_convoy,x
	STA oth_play_convoy,x
	STY act_play_convoy,x
	INX
	CPX #convoyWidth
	BNE loop67

	STX should_do_wipe	; X is convoyWidth now (pertinently, nonzero)
	LDA player_up
	EOR #1
	STA player_up		; toggle who's up
	JSR DrawWavesDefeated
	JSR DrawSpareLives
	LDA #1
	JSR ClearAndGetMessage	; message 1 = HI-SCORE
	LDA player_up		; player_up = 0  ->  message 0, "1UP"
	BEQ skp120
	LDA #$1f		; player_up <> 0 ->  message $1F, "2UP"
skp120:	JSR GetMessage
	RTS

;-------------------------------------------------------------------------------
PlayerLostLastLife:
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame ; last life lost
	BEQ PlayerLostLastLifeNotDemo ; in main game, that means display game over
	INC gamestage_coro_idx	; in demo, that means end the demo
	INC gamestage_coro_idx
	LDA #0			; (in demo, also reset other coros)
	STA middle_coro_idx
	STA inner_coro_idx
ret47:	RTS

PlayerLostLastLifeNotDemo:
	LDA end_game_timer	; if end_game_timer was 0, skp122
	BEQ skp122
	DEC end_game_timer	; (decrement end_game_timer)
	BEQ DoSwapPlayers	; if end_game_timer was 1, swap players
	CMP #120		; if end_game_timer was 120, draw "GAME  OVER"
	BNE skp123
	LDA #$13
	JMP ClearAndGetMessage	; message $13 = GAME  OVER

skp123:	CMP #4			; if it was 4 to 119, return immediately
	BCS ret47
	ADC #$1e		; on 2, clear "game  over" line; on 3, clear "player 1"/"player 2"
	JMP ClearAndGetMessage

skp122:	LDA numplayers_bit	; HERE end_game_timer was 0
	BEQ skp124		; now if numplayers_bit was 0, skp125
	LDA #120
	STA end_game_timer	; reset end_game_timer
	LDA #0
	STA numplayers_bit	; clear numplayers_bit
	STA player_x_pos	; remove player x scroll (he's dead anyway)
	CLC
	LDA #$11
	ADC player_up		; draw "player 1" or "player 2" for the other player to finish their game
	JMP ClearAndGetMessage

skp124:	LDA #0
	STA act_play_lives
	STA middle_coro_idx
	STA message_timer
	JSR InitGameOverSprites	; wait, why now?
	LDA #>p1score		; Score line
	STA chrsrc+1
	LDA #<p1score
	STA chrsrc
	LDA #>NameTable(3,4+32)
	STA chrdest+1
	LDA #<NameTable(3,4+32)
	STA chrdest
	INC gamestage_coro_idx
	RTS

;-------------------------------------------------------------------------------
InitGameOverSprites:
	LDX #0			;  game over animation
	LDY #0
NextLetter:
	TXA
	ASL
	ASL
	TAY
	LDA #0
	STA spr_buf(0,attr),y	; clear attribute
	STA remainder_gameover_y,x ; clear y fractional movement
	STA remainder_bullet_x,x ; and x fractional movement
	LDA #60
	STA denominator_bullet_x,x ; gameover velocities are out of 60
	STA denominator_gameover_y,x ; so that we set the numerator to the distance to go
	STA act_play_lives	; and it arrives after 1 second
	LDA game_over_y_start,x	; also set act_play_lives to 60, used as timer
	STA spr_buf(0,ycoo),y
	SEC
	SBC #160		; game_over_y_start - 160 (Y destination)
	BCS skp125
	EOR #$ff
	ADC #1			; - abs ( [game_over_y_start+x] - 160 )
	CLC
skp125:	STA numerator_gameover_y,x ; <- Ymag
	ROR			; undo absolute value, but divide by 2
	STA sign_gameover_y,x	; <- Ydist/2 (we only care about sign)
	LDA dGameOverText,x	; choose tiles
	STA spr_buf(0,tile),y
	LDA game_over_x_start,x
	STA spr_buf(0,xcoo),y	; x coords
	SEC
	SBC dGameOver_XDestination,x ; destination x coords
	BCS skp126
	EOR #$ff
	ADC #1			; - abs ( [game_over_x_start+x] - [Xdestinations+x] )
	CLC
skp126:	STA numerator_bullet_x,x ; <- Xmag
	ROR			; undo absolute value but divide by 2
	STA sign_bullet_x,x	; <- Xdist/2 (we only care about sign)
	INX
	CPX #8
	BNE NextLetter		; only loop back 8 times
ret48:	RTS
dGameOverText:
	.byt "G"-48,"A"-48,"M"-48,"E"-48,"O"-48,"V"-48,"E"-48,"R"-48
dGameOver_XDestination:
	.byt 88, 96, 104, 112, 136, 144, 152, 160
;-------------------------------------------------------------------------------
DrawPlayerAfterStartMusic:
	JSR RunMainGame
	LDA #0
	STA message_timer
	LDA sfct_note_dur+3	; wait for start music to end
	BNE ret48
	INC middle_coro_idx
	JSR DrawWavesDefeated
	JSR DrawSpareLives
	JSR InitBulletSprites
	LDA #0
	STA PlayerDiedThisVsync
	LDA #>NameTable(15,27)
	STA l_enqueue_metatiles_ppu_addr_h
	LDA #<NameTable(15,27)
	STA l_enqueue_metatiles_ppu_addr_l
	LDA #CHR_PlayerShipLL
	STA l_enqueue_metatiles_first_tile
	STA l_enqueue_metatiles_draw_four
	LDA #0			; always the first metatile drawn
	STA ramd_count
	JMP EnqueueMetatiles

;-------------------------------------------------------------------------------
l_any_enemies_in_convoy = local7
NextWave:
	JSR ResetWaveTimers
	LDX #convoyWidth-1
	LDA #0
	STA l_any_enemies_in_convoy
	STA convoy_animation_column
	STA convoy_column_idx
loop68:	LDA #0
	STA chargers_from_column,x ; pull all bugs out of flight
	LDA act_play_convoy,x
	ORA l_any_enemies_in_convoy
	STA l_any_enemies_in_convoy ; and recalculate anyone-in-convoy
	DEX
	BPL loop68

	LDA l_any_enemies_in_convoy
	BNE ret49		; bail if anyone is
	INC act_play_waves	; everyone's dead, next wave!
	SEC
	LDA act_play_waves	; wave 100 (and above) don't exist
	SBC #99
	BNE skp127
	STA act_play_waves	; instead it becomes wave 0 again
skp127:	LDA #0			; reset aliens to center

InitFirstWave:
	STA convoy_x_pos	; (when called by this entry, A is also 0)
	LDX #convoyWidth-1
loop69:	LDA dInitialConvoy,x 	; (re)load starting convoy
	STA act_play_convoy,x
	DEX
	BPL loop69

	LDX #1			; first check for spare enemy ship on right
	JSR tail06
	DEX			; then check for spare enemy ship on left
tail06:	LDA act_play_extra_enemy,x ; see if we need to carry over one or two ships from the previous wave
	BEQ ret49
	LDA #0
	STA act_play_extra_enemy,x
	LDA #$20
	ORA act_play_convoy+4,x ; a ship stuck around from the last wave for this one
	STA act_play_convoy+4,x ; add it into the current convoy.
ret49:	RTS

;-------------------------------------------------------------------------------
ResetWaveTimers:
	LDA #0			; resets enemy_launch_timer
	STA enemy_launch_timer
	LDX #misc_timers_end-misc_timers-1
loop70:	STA misc_timers,x	; resets the misc_timers array
	DEX
	BPL loop70

	LDX act_play_waves
	CPX #7			; wave 7 and above are always maximum aggressiveness = 7
	BCC skp128
	LDX #7
skp128:	STX aggressiveness	; then rewrites aggressiveness to never be less than the current Wave #.
	RTS

;-------------------------------------------------------------------------------
InitBulletSprites:
	LDY #0
	LDA #CHR_EnemyBullet	; bullet sprite (1x4 color 1)
loop71
	STA spr_buf(32,tile),y	; set sprites 32..39 to be the color 1 bullet sprite
	INY
	INY
	INY
	INY
	CPY #$20
	BNE loop71
	LDA #CHR_PlayerBullet	; bullet sprite (1x4 color 3)
	STA spr_buf(32,tile)	; go back and rewrite sprite 32 with color 3 bullet sprite
	RTS
;;; ----------------------------------------------------------------------------
dInitialConvoy: 		; bitmask of aliens in each column (1=lowest, $20=highest)
	.byt $07, $0f, $1f, $3f, $1f, $1f, $3f, $1f, $0f, $07
dInitialConvoyEnd:
;-------------------------------------------------------------------------------
#define numberStars 24
#define firstStarY 16
l_next_star_y = local7
InitStarfield:
	LDY #4*(numberStars-1)	; initialize starfield locations (made of sprites)
	LDX #numberStars-1
	LDA #firstStarY
	STA l_next_star_y
loop72:	LDA dInitialStarX,x
	STA spr_buf(40,xcoo),y	; copy x for sprite 63..40 from table
	LDA #CHR_Star		; not randomized! Sprites $34 and $36 aren't used!
	STA spr_buf(40,tile),y	; choose tile $32 (centered dot color 1)
	LDA dInitialStarX,x
	AND #$03
	ORA #$e0		; under background, flipped both H and V (why?)
	STA spr_buf(40,attr),y	; and pick ~random palette from Xpos
	LDA l_next_star_y
	STA spr_buf(40,ycoo),y	; uniformly distribute y
	CLC
	ADC #9			; y = {$10,$19,$22,$2b &c}
	STA l_next_star_y
	DEY
	DEY
	DEY
	DEY
	DEX			; only 24 stars
	BPL loop72
	RTS
dInitialStarX:
	.byt 99, 78, 167, 61, 236, 10, 146, 159
	.byt 19, 103, 61, 86, 193, 16, 250, 114
	.byt 209, 229, 167, 87, 26, 1, 210, 71
;-------------------------------------------------------------------------------
ResetPlayerScores:
	LDX #1	 		; writes sp sp sp sp 0 0 to $117-$11C Player 1 Score
	JSR tail04
	LDX #1+p2score-p1score	; writes same to $129-$12E Player 2 Score
tail04:	LDY #5
loop73:	LDA dInitialScore,y
	STA p1score,x
	INX
	DEY
	BPL loop73
	RTS
dInitialScore:
	.byt 0, 0, CHR_Blank, CHR_Blank, CHR_Blank, CHR_Blank
;-------------------------------------------------------------------------------
SilenceAndExitCallerIfNotGame:
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame
	BEQ ret50		; if we're NOT in main game mode
	PLA			;  here we destroy our return address
	PLA			;  so that the we will return to our caller's caller
	LDA #0			; and silence the sound
	STA SQ1_LO
	STA SQ1_HI
ret50:	RTS

;-------------------------------------------------------------------------------
l_lowest_voice_active = local5
l_ship_diving_period = local6 ; local copy is to support warble
RunSoundEffects:
	JSR SilenceAndExitCallerIfNotGame
	JSR PlayerDiedNoise	; software emulation of sweep on noise channel
	JSR DoConvoyDrone	; plays a repetetive sweep while bugs are in convoy
	JSR PlayerShootNoise	; also software emulation of sweep on noise channel
	LDX #0
	LDA #0
loop74:	STA apu_shadow,x	; clobber apu_shadow[0..15] -- which appears to in practice
	INX			; only mean sq1per
	CPX #$10
	BNE loop74

	LDX #4
	STX l_lowest_voice_active	; the # of the lowest sound effect that's active (4 = none)
	DEX
	STX sfct_idx
NextSfct:
	LDX sfct_idx
	JSR SfctPlay		; plays sound effects
	DEC sfct_idx		; this ordering means that sfct0 will mask sfct1 will mask
	BPL NextSfct		; sfct2 will mask sfct3.

	LDX #convoyWidth-1
loop75:	LDA chargers_from_column,x
	BNE skp129		; see if any ships are in flight
	DEX
	BPL loop75

	STA ship_diving_period	; all were zero, silence ship_diving_period
	STA l_ship_diving_period
	JMP skp130

skp129:	LDA ship_diving_period	; HERE a ship was in flight
	CMP #$f5		; is the last one to take off >= 0xF5?
	BCC skp131		;  (if < 0xF5, just play ship_diving_period)
	TAX			; HERE ship_diving_period was >= 0xF5
	LDA game_vsyncs		; if game_vsyncs&2 then
	AND #$02
	BEQ skp132
	LDX #$c8		;  replace l_ship_diving_period with $c8
	LDA game_vsyncs		; end result is alternating tones at 15hz between 1118 Hz and 913 Hz)
	AND #$07		;   but we ignore the result of game_vsyncs&7?
skp132:	TXA
	JMP skp133

skp131:	LDA ship_diving_period	; move sweep down
	INC ship_diving_period
skp133:	STA l_ship_diving_period
skp130:	LDX #0
	LDA l_lowest_voice_active
	CMP #$04
	BNE skp134		; if l_lowest_voice_active == 4 then sq1per <- l_ship_diving_period
	LDA l_ship_diving_period ;  (upper byte still clear from resetting at loop74)
	STA sq1per
	JMP skp134		; -
	LDA #$bf		;  |  dead code
	STA SQ1_VOL		;   > but these are the same values as up in TitleInit
	LDA #$7f		;  |  so it's ok that they're not reinitialized
	STA SQ1_SWEEP		; -
skp134:	LDA sq1per+1
	ORA #$08
	LDX sq1per
	CMP sq1_hi_shadow
	STX SQ1_LO
	BEQ ret51		; only write upper byte if it differs
	STA SQ1_HI
	STA sq1_hi_shadow
ret51:	RTS

;;;-----------------------------------------------------------------------------
	;; One sound effect is stored in prgrom, the rest in chrrom.
	;; this normalizes the table so that the same shift can be used for all.
;-------------------------------------------------------------------------------
FixSfct0:
	CLC
	LDA dSfct0Pointer	; [fe52]=$54  fe52 is a pointer to another table
	ADC dSfxTableSkewLSB+1	; [fdcb]=$40  this pointer unlike all the rest comes from prgrom
	STA sfx_table		; [14e]<-$94  (the other 88 entries in the array from $0150-$01ff
	LDA dSfct0Pointer+1	; [fe53]=$fe   came from chrrom and are adjusted below)
	ADC dSfxTableSkewMSB+1	; [fdd2]=$08  so we have to add some garbage here to compensate
	STA sfx_table+1		; [14f]<-$06
	RTS

;;; Sound Effects
;;;  # 0 = enemy flew past you off the bottom
;;;  # 1 = you shot down a flying enemy ship
;;;  # 2 = you shot down a flying enemy bug or member of the convoy
;;;  # 3 = game start "music"
;-------------------------------------------------------------------------------
l_sfct_ptr_busy = local7	; not actually certain what its purpose is, since nothing seems to use it
SfctDoStart:
	LDA #0
	STA sfct_req_start,x
	LDA gamestage_coro_idx
	CMP dGamestageCoroMainGame
	BNE SfctPlay
	LDA #0
	STA sfct_pos,x
	LDA #1
	STA sfct_note_dur,x
SfctPlay:
	LDA sfct_req_start,x	; <- the actual entry   X is the value that was in sfct_idx and ranges between 0-3
	BNE SfctDoStart
	LDA sfct_note_dur,x
	BEQ ret51
	STX l_lowest_voice_active	; mark that we're playing any sound effect at all
	LDA #0
	STA l_sfct_ptr_busy
	TXA
	ASL
	TAY			; Y = 2*X
	SEC
	LDA sfx_table,y		; sfx_table is an array loaded from chrrom (ex. first entry)
dSfxTableSkewLSB:
	SBC #<(sfx_tablePPU-sfx_table) ; Unadjusted array- $0694, $0a0d, $09eb, $0996
	STA sfct_ptr		; Adjusted array- $fe54, $01cd, $01ab, $0156
	LDA sfx_table+1,y
dSfxTableSkewMSB:
	SBC #>(sfx_tablePPU-sfx_table) ; $098E(chrrom addr) - $014E(wram) = $0840  (this skew)
	STA sfct_ptr+1		; sfct_ptr points to sfx_table
	LDY sfct_pos,x		; sfct_pos #x started at 0
	LDA (sfct_ptr),y	; A is now (X-0..3)=($62,$02,$08,$11)
	DEC sfct_note_dur,x	; sfct_note_dur #x is the number of frames to play this tone
	BNE SfctNoNewNote
	INC sfct_pos,x		; sfct_pos,x is the current sfx position
	INY
	LDA (sfct_ptr),y	; A is now (X-0..3)=($5f,$17,$07,$10)
	PHA
	LSR
	LSR
	LSR
	LSR
	LSR
	TAY			; Y=A/32
	LDA dSfctDurations,y	; A=2**Y (X-0..3)=(4,0,0,0)
	STA sfct_note_dur,x
	LDA #1
	STA l_sfct_ptr_busy
	PLA			; (X-0..3)=($1f,$17,$07,$10)
SfctNoNewNote:
	ASL
	AND #$3e		; sound effect player
	TAY			; bottom 5 bits- which tone
	LDA dPitchTable,y	; top 3 bits- duration, 2**N frames
	STA sq1per
	LDA dPitchTable+1,y
	STA sq1per+1
	LDA l_sfct_ptr_busy
	BEQ ret52
	LDA #1
	STA apu_shadow
ret52:	RTS
	;;  another pitch table, for sound effects. Almost all tones are detuned by a quarterstep.
dPitchTable:
	.word $000, $13e, $0ef, $0d4  ;  off  351  468  527
	.word $0c9, $0bd, $0b3, $09f  ;  556  591  624  703
	.word $08e, $07e, $077, $06a  ;  787  887  940 1055
	.word $05f, $059, $050, $047  ; 1177 1256 1398 1575
	.word $03f, $03b, $035, $030  ; 1775 1895 2110 2330
	.word $02c, $028, $11c, $0fd  ; 2542 2796  393  442
	.word $096, $071, $04b, $038  ;  745  989 1491 1997
	.word $043, $023, $020, $000  ; 1669 3196 3495  off

	;; bitshifting table
dSfctDurations:
	.byt 1, 2, 4, 8, 16, 32, 64, 0
	;; sound effect 0
dSfct0Pointer:
	.word dSfct0Table
dSfct0Table:
	.byt $62, $5f, $62, $5f	; 8/60s of 468 hz alternating with
	.byt $62, $5f, $62, $5f	; 4/60s of silence
	.byt $62, $5f, $62, $5f	; total duration of 1.5s
	.byt $62, $5f, $62, $ff

;-------------------------------------------------------------------------------
StartPlayerDiedSound:
	JSR SilenceAndExitCallerIfNotGame
	; player hit sound effect?
	LDA #$06
	STA noise_idx_died
	STA NOISE_PERIOD	; start noise at period $6
	LDA #$0f
	STA NOISE_VOL		; full volume
	STA SQ2_VOL
	LDA #0
	STA $400d 		; pretending there's a sweep unit?
	STA SQ2_LO		; starting period $100 = 873 Hz
	LDA #$0a		; a=2^8; 2 is ignored.
	STA NOISE_LEN		; LengthCounter = 254
	LDA #$92
	STA SQ2_SWEEP		; 1-Enabled 3-Period2 1-SweepDown 3->>2
	LDA #$11
	STA SQ2_HI		; LengthCounter = 20
	RTS

;-------------------------------------------------------------------------------
PlayerDiedNoise:
	LDA noise_idx_died	; play noise if our counter is going
	BEQ ret53
	LDA game_vsyncs		; AND game_vsyncs&7 =0
	AND #$07
	BNE ret53
	INC noise_idx_died	; this counts up
	LDA noise_idx_died	; from 6 to 14
	STA NOISE_PERIOD	; making a sweeping noise
	CMP #$0e
	BNE ret53
	LDA #0			; and stops itself when it's done
	STA noise_idx_died
ret53:	RTS

;-------------------------------------------------------------------------------
StartPlayerShootSound:
	JSR SilenceAndExitCallerIfNotGame
	LDA #1
	STA noise_idx_shot	; start noise sweep
	LDA #$05
	STA SQ2_VOL		; $05- 2-12%duty LengthCounterEnable VolumeDecays 4-Takes76Periods
	STA NOISE_VOL		; ~same
	LDA #$84
	STA SQ2_SWEEP		; $84- SweepEnabled 3-Period1 SweepDown 3->>4
	LDA #$16
	STA SQ2_LO		; Starting period $016 = 8948Hz
	LDA #0
	STA $400d 		; wtf?
	LDA #$06
	STA NOISE_PERIOD	; Start noise at period $6
	LDA #$08
	STA SQ2_HI		; LengthCounter = 10
	STA NOISE_LEN		; same
	RTS

;-------------------------------------------------------------------------------
PlayerShootNoise:
	LDA noise_idx_shot	; once noise_idx_shot's triggered by becoming nonzero
	BEQ ret53
	INC noise_idx_shot	; it counts up
	CMP #40			; until it hits 40
	BEQ skp135
	LSR			; (divide by 4, becomes 0->9)
	LSR
	CLC
	ADC #$06		; sweep noise from period 6 to period 15
	STA NOISE_PERIOD
skp135:	LDA #0			; reset
	STA noise_idx_shot
	RTS

;-------------------------------------------------------------------------------
DoConvoyDrone:
	LDA game_vsyncs		; bail if game_vsyncs&31 = 0
	AND #$1f
	BNE ret54
	LDA convoy_is_empty	; bail if convoy_is_empty
	BNE ret54
	LDA sfct_note_dur+3 	; bail if Sfct #3 is playing
	BNE ret54
	LDA #$95		; $95- constant volume, duty 1/8, volume 5/15
	STA SQ2_VOL
	LDA #$a7		; $a7- sweep enabled, every 6 frames set period *= 129/128
	STA SQ2_SWEEP
	LDA #0
	STA SQ2_LO		; $200- starting pitch 218 Hz
	LDA #$52
	STA SQ2_HI		; $50- last 60 frames
ret54:	RTS

;-------------------------------------------------------------------------------
InitializeMusic:
	LDA music_initialized	; has initialization happened?
	BNE NextNote
	INC music_initialized
	LDA #$c0
	STA APU_FRAME		; choose 5step, disable irq
	LDA #$0f
	STA SND_CHN
	NOP
	NOP
	LDA #$0f
	STA SQ1_VOL
	STA SQ2_VOL
	LDA #$7f
	STA SQ1_SWEEP
	STA SQ2_SWEEP		; the first time through, we initialize the sound channels
	LDA reset_count		; and depending on the number of resets, pick a song
	LDX #$1b
	LDY #$0f
	CMP #2*resetThreshold	; # of resets < 90? start @ chr 0x1B00, speed = 16
	BCC save04
	LDX #$18
	LDY #$07
	CMP #3*resetThreshold	; # of resets < 135? start @ chr 0x0700, speed = 8
	BCC save04
	LDX #$06
	LDY #$0f
	CMP #4*resetThreshold	; # of resets < 180? start @ chr 0x0600, speed = 16
	BCC save04
	LDX #$16
	LDY #$0f
	CMP #5*resetThreshold	; # of resets < 225? start @ chr 0x1600, speed = 16
	BCC save04
	LDX #$1a
	LDY #$0f		; # of resets < 256? start @ chr 0x1A00, speed = 16
save04:	STX music_page
	STY music_speed
ret55:	RTS

;;; ----------------------------------------------------------------------------
	;; music player (easter egg)
;-------------------------------------------------------------------------------
NextNote:
	LDA num_vsyncs+2	; num_vsyncs is 24bit BE number of Vsyncs since power-on
	AND music_speed		; music_speed is the speed for the song (tracker sense)
	BNE ret54		; every music_speed refreshes we change notes
	LDA PPUSTATUS
	LDA music_page		; music_page points to which song
	STA PPUADDR
	LDA music_pointer
	INC music_pointer
	STA PPUADDR		; PPUADDR- music_page,music_pointer
	LDA PPUDATA
	LDA PPUDATA		; get the current notes to play
	STA notes_to_play
	AND #$0f
	ASL
	TAX			; break that 8-bit number into two 4-bit notes
	LDA dVoice1Periods+1,x
	STA SQ1_LO
	LDA dVoice1Periods,x
	ORA #$08
	STA SQ1_HI		; write the first note to hardware
	LDA notes_to_play
	LSR
	LSR
	LSR
	AND #$1e
	TAX
	LDA dVoice2Periods+1,x
	STA SQ2_LO
	LDA dVoice2Periods,x
	ORA #$08
	STA SQ2_HI		; write the other note to hardware
	LDA music_pointer	; see if the song's over (all songs are 256 entries long)
	BNE ret55
	LDX #0
loop76:	STA $0100,x		; if the song ended, clobber entire $100 page
	INX			; (which includes the reset counter)
	BNE loop76
	JMP (dRstVec)

;-------------------------------------------------------------------------------
	;; pitch tables for the two voices for the music player, bigendian
	;;  below table columns-   Period(raw) Frequency(hz) Name
dVoice2Periods:
	.byt 0, $00 		; $000  off none
	.byt 0, $6b		; $06b 1045 C-6
	.byt 0, $71		; $071  990 B-5
	.byt 0, $7f		; $07F  881 A-5
	.byt 0, $8f		; $08F  782 G-5
	.byt 0, $a0		; $0A0  699 F-5
	.byt 0, $aa		; $0AA  658 E-5
	.byt 0, $be		; $0BE  589 D-5
	.byt 0, $d6		; $0D6  523 C-5
	.byt 0, $e2		; $0E2  495 B-4
	.byt 0, $fe		; $0FE  440 A-4
	.byt 1, $0d		; $10D  416 G#4
	.byt 0, $87		; $087  829 G#5
	.byt 0, $ca		; $0CA  554 C#5
	.byt 0, $b4		; $0B4  621 D#5
	.byt 0, $97		; $097  741 F#5

dVoice1Periods:
	.byt 0, $00		; $000  off none
	.byt 5, $4d		; $54d   82 E-2
	.byt 5, $01		; $501   87 F-2
	.byt 4, $75		; $475   98 G-2
	.byt 3, $f9		; $3f9  110 A-2
	.byt 3, $8a		; $38a  123 B-2
	.byt 3, $57		; $357  131 C-3
	.byt 2, $fa		; $2fa  147 D-3
	.byt 2, $cf		; $2cf  156 D#3
	.byt 2, $a7		; $2a7  165 E-3
	.byt 2, $81		; $281  175 F-3
	.byt 2, $5d		; $25d  185 F#3
	.byt 2, $3b		; $23b  196 G-3
	.byt 2, $1b		; $21b  208 G#3
	.byt 1, $fc		; $1fc  220 A-3
	.byt 1, $c5		; $1c5  247 B-3

dPadding: .dsb ($fffa-*),$ff

;-------------------------------------------------------------------------------
; Vector Table
;-------------------------------------------------------------------------------
dNMIVec: .word NMI
dRstVec: .word Reset
dIRqVec: .word Reset

;-------------------------------------------------------------------------------
; CHR-ROM
;-------------------------------------------------------------------------------
	;; .bin 0,8192,"Galaxian (J) [!].chr" ; Include CHR-ROM

#if dInitialConvoy + convoyWidth - dInitialConvoyEnd
#print dInitialConvoyEnd - dInitialConvoy
#print convoyWidth
#error XA doesn't support forward references for .dsb statements, so you have to \
make sure convoyWidth has the correct value manually. It's currently wrong.
#endif

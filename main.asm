;=======================;
; Piano Piano, Pinguino ;
; DreamDisc '25 Version ;
;=======================;

;=======================;
;  Prepare Application  ;
;=======================;
	.org	$00
	jmpf	start

	.org	$03
	reti	

	.org	$0b
	reti	
	
	.org	$13
	reti	

	.org	$1b
	jmpf	t1int
	
	.org	$23
	reti	

	.org	$2b
	reti	
	
	.org	$33
	reti	

	.org	$3b
	reti	

	.org	$43
	reti	

	.org	$4b
	clr1	p3int,0
	clr1	p3int,1
	reti

	.org	$130	
t1int:
	push	ie
	clr1	ie,7
	not1	ext,0
	jmpf	t1int
	pop	ie
	reti

	.org	$1f0

goodbye:	
	not1	ext,0
	jmpf	goodbye

;=======================;
;VMU Application Header ;
;=======================;
.include "GameHeader.i"
.org	$680
    .byte   " Piano, Pinguino"
	.byte   " DreamDisc '25: "
    .byte   "  Dedicated To  "
	.byte	" Mr. R.,+ Mr. B "
	.byte   " Thanks To Many "
	.byte   "   Including:   "
    .byte   " Kresna Susila, "
    .byte   "Walter Tetzner, "
    .byte   "Falco Girgis,TZ,"
    .byte   "Dmitry Grinberg,"
    .byte   "Marcus Comstedt,"
    .byte   "Sebastian Mihai,"
    .byte   "Tyco,Trent,Speud"
    .byte   "RetroOnyx,Ian M."
    .byte   "B.Leeto,NeoGeoF,"
	.byte   "Cypress,CBarpch,"
	.byte   " And Many More. "
	.byte	" Derek (ateam), "
    .byte   "H.2.Y.I.H.,N+GB!"
    .byte   "2M.S.B.,F.,E.&M:"
    .byte   "HBD,+M.!GBRDDRAA"
    .byte   "BLCARLOA,STFEAIF"
    .byte   "HBD,+M.!GBRDDRAA"
.org	$50
	.byte   "abcdefghijklmnop"
	.byte   "qrstuvwxyz123456"
	.byte   "7891011121314151"
	.byte   "617181920212223!"
.org	$50
	; .byte   %01010101
	; .byte   %00001000
	; .byte   %00010010
	; .byte   %01010101
	; .byte   %00001000
	; .byte   %00010010
	; .byte   %01010101
	; .byte   %00001000
	; .byte   %00010010
	; .byte   %01010101
	; .byte   %00001000
	; .byte   %00010010
	; .byte   %01010101
	; .byte   %00001000
	; .byte   %00010010
	.byte   "2232223232232323"
	.byte   "2222222322332222"
	.byte   "3332223223232232"
	.byte   "2323223232232322"
	; .byte   "0010001010010101"
	; .byte   "0000000100110000"
	; .byte   "1110001001010010"
	; .byte   "0101001010010100"
.org	$2000
	.byte   "abcdefghijklmnop"
	.byte   "qrstuvwxyz123456"
	.byte   "7891011121314151"
	.byte   "617181920212223!"

;=======================;
;   Include Libraries   ;
;=======================;
.include "./lib/libperspective.asm"
.include "./lib/libkcommon.asm"
.include "./lib/sfr.i"

;=======================;
;     Include Images    ;
;=======================;
; .include		"./img/Example_Sprite.asm"
.include		"./img/AllBlack.asm"
.include		"./img/AllWhite.asm"
.include		"./img/Penguin_Trot_1_Mask.asm"
.include		"./img/Penguin_Trot_2_Mask.asm"
.include		"./img/BG_Frame_0.asm"
.include		"./img/BG_Frame_1.asm"
.include		"./img/BG_Frame_2.asm"
.include		"./img/BG_Frame_3.asm"
.include		"./img/Boulder_Sprite_Mask.asm"
.include		"./img/Boulder_Sprite_Offscreen_Mask_6.asm"
.include		"./img/Boulder_Sprite_Offscreen_Mask_5.asm"
.include		"./img/Boulder_Sprite_Offscreen_Mask_4.asm"
.include		"./img/Boulder_Sprite_Offscreen_Mask_3.asm"
.include		"./img/Boulder_Sprite_Offscreen_Mask_2.asm"
.include		"./img/Penguin_Jump_Up_Mask.asm"
.include		"./img/Penguin_Standing_Mask.asm"

;=======================;
;  Include  Code Files  ;
;=======================;
.include		"./src/Gameplay.asm"
.include		"./src/Title_Screen.asm"

;=======================;
;   Define Variables:   ;
;=======================;
p3_pressed				=		$4	; 1 Byte (For LibKCommon)
p3_last_input			=		$5	; 1 Byte (For LibKCommon)
; character_flags			=		$17	; 1 Byte
; stage_flags				=		$18	; 1 Byte

;=======================;
; Initialize Variables: ;
;=======================;
; mov #0, character_flags
; mov #0, stage_flags

;=======================;
;       Constants       ;
;=======================;
T_BTN_SLEEP				equ		7
T_BTN_MODE				equ		6
T_BTN_B1				equ		5
T_BTN_A1				equ		4
T_BTN_RIGHT1			equ		3
T_BTN_LEFT1				equ		2
T_BTN_DOWN1				equ		1
T_BTN_UP1				equ		0

;=======================;
;     Main Program      ;
;=======================;
start:
	clr1 ie,7
	mov #$a1,ocr
	mov #$09,mcr
	mov #$80,vccr
	clr1 p3int,0
	clr1 p1,7
	mov #$ff,p3
	set1 ie,7

Main_Loop:
	; callf	Title_Screen ; callf	Main_Menu
	callf	Runner_Gameplay
	jmpf Main_Loop

	.cnop	0,$200		; Pad To An Even Number Of Blocks

elf_init
	lea		$ffff8240,a0
	REPT 8
		move.l	#0,(a0)+
	ENDR

	move.l	#memBase+65536,d0			;1
	sub.w	d0,d0
	move.l	d0,screenpointer
	add.l	#32000,d0
	move.l	#tunnelOffsets,bupPtr


	lea		elfcrk,a0
	move.l	screenpointer,a1
	sub.w	#128,a1
	jsr		cranker



;	move.l	#memBase+bufsize-24960+4000+4000,d0  ;26*15*12
	move.l	#memEnd-24960-1000,d0
;	move.l	#haxplace,d0
	move.l	d0,fontPtr

;	jsr		saveStuff

	jsr		prepFont

	move.l	screenpointer,a0
	add.l	#100*160,a0
	lea		elfcrk,a1
;	move.l	bupPtr,a1
	move.w	#100-1,d7
.cp
	REPT 40
		move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.cp


	move.w	#$4e75,elf_init
	rts



elf_in_vbl
	move.l	screenpointer,$ffff8200
	move.w	#0,$ffff8240
	lea		$ffff8240,a0
	move.l	screenpointer,a1
	sub.w	#124,a1
	lea		$ffff8240,a2
	move.w	#16,d0
	subq.w	#1,.waiter
	bge		.skip
		move.w	#2,.waiter
		jsr		fade_st
.skip
	jsr		testLetter
	jsr		maskCorners
	rts
.waiter	dc.w	2


elf_out_vbl
	move.l	screenpointer,$ffff8200

	lea		$ffff8240,a0
	lea		black,a1
	lea		$ffff8240,a2
	move.w	#16,d0


	subq.w	#1,.waiter
	bge		.skip
		move.w	#2,.waiter
		jsr		fade_st
		subq.w	#1,.clear
		bge		.skip
			move.w	#$4e75,testLetter
			move.l	screenpointer,a0
			move.l	#$8000,d0
			jsr		fast_clear
.skip
	jsr		testLetter
	jsr		maskCorners
	rts
.waiter	dc.w	0
.clear	dc.w	7


WOBBLE	equ 0
FAST_CODE	equ	0
	IFEQ	FAST_CODE
BT	equ 16
	ELSE
BT 	equ 12
	ENDC

NR_CHARS	equ 31

WOBBL2	equ 0

restoreFrame
	IFEQ	WOBBLE 
	move.l	screenpointer,d0
	lea		sineYOFF,a0
	IFEQ	WOBBL2
	add.w	sineoff2,a0
	ENDC
	lea		elfcrk-100*160,a3
;	move.l	bupPtr,a3

	cmp.w	#6,sineoff
	beq		.tt
		add.w	sineoff,a0
		add.w	#2,a0
.tt

	moveq	#-1,d1
	moveq	#0,d6


		move.w	(a0),d0
		add.w	d6,d0
		add.w	#8,a0
		move.l	d0,a1
		move.l	a3,a2
		add.w	d0,a2

.y set 0
		REPT 15
			movem.l	.y(a2),d1-d4
			movem.l	d1-d4,.y(a1)
.y set .y+160
		ENDR




	move.w	#20-1,d7
.cl		
		move.w	(a0),d0
		add.w	d6,d0
		add.w	#8,a0
		move.l	d0,a1
		move.l	a3,a2
		add.w	d0,a2

.y set 0
		REPT 15
			movem.l	.y(a2),d1-d4
			movem.l	d1-d4,.y(a1)
.y set .y+160
		ENDR
		add.w	#8,d6
	dbra	d7,.cl
	ENDC
	rts

drawText
	move.l	screenpointer,a5
	IFNE	WOBBLE
	add.l	#180*160,a5
	ENDC
	lea		myText,a1
	add.w	textoff,a1
	move.l	fontPtr,a0
	add.l	fontOff,a0
	move.l	a0,a4

	lea		sineYOFF,a3
	add.w	sineoff,a3
	IFEQ	WOBBL2
	add.w	sineoff2,a3
	ENDC
		move.l	a5,a6
		IFEQ	WOBBLE
		add.w	(a3),a6
		add.w	#8,a3
		ENDC
		jsr		drawLetterCodeFirst


	move.w	#19-1,d7
.doLetter
		move.l	a5,a6
		IFEQ	WOBBLE
		add.w	(a3),a6
		add.w	#8,a3
		ENDC
		move.w	d7,-(sp)
		jsr		drawLetterCode
		add.w	#8,a5
		move.w	(sp)+,d7
		dbra	d7,.doLetter
		move.l	a5,a6
		IFEQ	WOBBLE
		add.w	(a3),a6
		add.w	#8,a3
		ENDC
		jsr		drawLetterCodeLast
		rts

testLetter	
	jsr		restoreFrame

	add.w	#4,sineoff2
	cmp.w	#160*2,sineoff2
	blt		.lll
		sub.w	#160*2,sineoff2
.lll

	jsr		drawText

	sub.l	#NR_CHARS*BT*15,fontOff
	sub.w	#2,sineoff
	bge		.ok
		move.l	#NR_CHARS*BT*15*3,fontOff
		add.w	#1,textoff
		move.w	#6,sineoff
.ok
.end
	rts
.ttt		dc.w	0
textoff	dc.w	0
sineoff	dc.w	0
sineoff2	dc.w	0
fontOff		dc.l	0

sineYOFF	include	'elf/textsine3.s'

drawLetterCodeFirst
	move.l	a4,a0
	moveq	#0,d0
	move.b	(a1)+,d0	; this is a letter	; lookup letter into distance
	sub.w	#$41,d0
	blt		.skip
	muls	#BT*15,d0
	add.l	d0,a0
	REPT 15
		IFEQ	FAST_CODE
			lea		8(a0),a0
			move.l	(a0)+,d0
			move.l	(a0)+,d1
			and.l	d0,(a6)
			or.l	d1,(a6)+
			and.l	d0,(a6)+
			lea		160-8(a6),a6
		ELSE
		lea		6(a0),a0
		move.w	(a0)+,d0		; mask 2
		move.w	d0,d2
		swap	d2
		move.w	d0,d2

		move.l	(a0)+,d1
		and.l	d2,(a6)
		or.l	d1,(a6)+
		and.l	d2,(a6)+
		lea		160-8(a6),a6
		ENDC
	ENDR
.skip
	rts

drawLetterCode
	move.l	a4,a0
	moveq	#0,d0
	move.b	(a1)+,d0	; this is a letter	; lookup letter into distance
	sub.w	#$41,d0
	blt		.skip
	muls	#BT*15,d0
	add.l	d0,a0

		IFEQ	FAST_CODE
			REPT 7
			movem.l	(a0)+,d0-d7

			and.l	d0,(a6)
			or.l	d1,(a6)+
			and.l	d0,(a6)+

			and.l	d2,(a6)
			or.l	d3,(a6)+
			and.l	d2,(a6)+
			lea		160-16(a6),a6

			and.l	d4,(a6)
			or.l	d5,(a6)+
			and.l	d4,(a6)+

			and.l	d6,(a6)
			or.l	d7,(a6)+
			and.l	d6,(a6)+
			lea		160-16(a6),a6
			ENDR
			movem.l	(a0)+,d0-d3

			and.l	d0,(a6)
			or.l	d1,(a6)+
			and.l	d0,(a6)+

			and.l	d2,(a6)
			or.l	d3,(a6)+
			and.l	d2,(a6)+


		ELSE


	REPT 15
		move.w	(a0)+,d0		; mask 1
		move.w	d0,d2			; double the mask
		swap	d2
		move.w	d0,d2

		move.l	(a0)+,d1		; data
		and.l	d2,(a6)			; apply maks
		or.l	d1,(a6)+
		and.l	d2,(a6)+

		move.w	(a0)+,d0		; mask 2
		move.w	d0,d2
		swap	d2
		move.w	d0,d2

		move.l	(a0)+,d1
		and.l	d2,(a6)
		or.l	d1,(a6)+
		and.l	d2,(a6)+
		lea		160-16(a6),a6
		ENDR
	ENDC
.skip
	rts

drawLetterCodeLast
	move.l	a4,a0
	moveq	#0,d0
	move.b	(a1)+,d0	; this is a letter	; lookup letter into distance
	sub.w	#$41,d0
	blt		.skip
	muls	#BT*15,d0
	add.l	d0,a0
	REPT 15
		IFEQ	FAST_CODE
			move.l	(a0)+,d0
			move.l	(a0)+,d1
			and.l	d0,(a6)
			or.l	d1,(a6)+
			and.l	d0,(a6)+
			lea		8(a0),a0
			lea		160-8(a6),a6
		ELSE
		move.w	(a0)+,d0		; mask 1
		move.w	d0,d2			; double the mask
		swap	d2
		move.w	d0,d2

		move.l	(a0)+,d1		; data
		and.l	d2,(a6)			; apply maks
		or.l	d1,(a6)+
		and.l	d2,(a6)+

		lea		6(a0),a0
		lea		160-8(a6),a6
		ENDC
	ENDR
.skip
	rts	

saveStuff
	move.l	screenpointer,a0
	add.l	#180*160,a0
	move.l	bupPtr,a1
	move.w	#15-1,d7
.cpl
	REPT 40
		move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.cpl
	rts

black	ds.b	32

myText
	dc.b	"                    "
	dc.b	"MERRY GREETZ TO "
	dc.b	"RAZOR[\[[ "			
	dc.b	"DEKADENCE "			
	dc.b	"SMFX "					
	dc.b	"TBL "					
	dc.b	"HOOY PROGRAM "
	dc.b	"MEC "
	dc.b	"NAH KOLOR "			
	dc.b	"PHF "					
	dc.b	"LEMON] "				
	dc.b	"BOOZE "				
	dc.b	"DEMARCHE "
	dc.b	"NEWLINE "
	dc.b	"CENSOR "				
	dc.b	"OXYGENE "				
	dc.b	"CNCD "		
	dc.b	"SYNC "			
	dc.b	"NOICE "			
	dc.b	"SKRJU "				
	dc.b	"OXYRON "				
	dc.b	"BONZAI "				
	dc.b	"DESIRE "				
	dc.b	"NEW BEAT "				
	dc.b	"TEK "			
	dc.b	"EFFECT "				
	dc.b	"DBUG "					
	dc.b	"VISION "
	dc.b	"PIXEL TWINS "		
	dc.b	"LIMP NINJA "
	dc.b	"AVENA "			
	dc.b	"DEADLINERS "
	dc.b	"LIFE ON MARS "
	dc.b	"SECTOR ONE "
	dc.b	"DHS "				
	dc.b	"WE LOVE YOU ALL]]]]]]]]"
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	dc.b	"                    "
	even


;	The Black Lotus, Vision, Nah Kolor, Razor 1911, Movement, Lemon., Desire, Excess, Booze Design, 
;	Censor Design, CNCD, Vandalism News, Pretzel Logic, Oxyron, Maniac of Noise, Virtual Dreams, 
;	Spaceballs, Bonzai, Anarchy, Melon Design, Alcatraz, Deadliners, Oxygene, Limp Ninja

prepFont
	; first copy font to buffer
	lea		font+128,a0
	move.l	fontPtr,a1
	moveq	#0,d5
	moveq	#-1,d6
	move.w	#20-1,d7
	jsr		copyLetter
	add.w	#15*160,a0
	move.w	#NR_CHARS-20-1,d7
	jsr		copyLetter
	; then shift the font, lets do this 8 times
	move.l	fontPtr,a0
	lea		NR_CHARS*BT*15(a0),a1		; next shift	4680 * 8
	move.w	#NR_CHARS*3-1,.times		;number of letters
.again
	REPT 15
		IFEQ	FAST_CODE
		movem.w	(a0)+,d0-d7		; d0/d1 mask d2/d3 data d4/d5 mask d6/d7 data

		REPT 4
		lsr.w	d0
		ori.w	#$8000,d0
		roxr.w	d4
		move.w	d0,d1
		move.w	d4,d5

		lsr.w	d2
		roxr.w	d6
		lsr.w	d3
		roxr.w	d7
		ENDR

		movem.w	d0-d7,(a1)
		lea		16(a1),a1

		ELSE
	movem.w	(a0)+,d0-d5
;	movem.w	(a0)+,d0-d7		;d0.w mask, d1/d2 data, d3.w mask d4/d5 data
	moveq	#-1,d6
	roxr.w	d6
	roxr.w	d0	;	mask
	roxr.w	d3	;	mask
	lsr.w	d1	;	data 1
	roxr.w	d4	;	data 1
	lsr.w	d2	;
	roxr.w	d5

	roxr.w	d6
	roxr.w	d0	;	mask
	roxr.w	d3	;	mask
	lsr.w	d1	;	data 1
	roxr.w	d4	;	data 1
	lsr.w	d2	;
	roxr.w	d5

	roxr.w	d6
	roxr.w	d0	;	mask
	roxr.w	d3	;	mask
	lsr.w	d1	;	data 1
	roxr.w	d4	;	data 1
	lsr.w	d2	;
	roxr.w	d5

	roxr.w	d6
	roxr.w	d0	;	mask
	roxr.w	d3	;	mask
	lsr.w	d1	;	data 1
	roxr.w	d4	;	data 1
	lsr.w	d2	;
	roxr.w	d5


	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d2,(a1)+
	move.w	d3,(a1)+
	move.w	d4,(a1)+
	move.w	d5,(a1)+
		ENDC
	ENDR
	subq.w	#1,.times
	bge		.again
	rts
.times	dc.w	0
copyLetter

.copyLetter
.y set 0
		REPT 15
			move.w	.y(a0),d0			;bpl1				; mask 1, data 1, mask 2, data 2
			move.w	.y+2(a0),d1			;bpl2
			move.w	d1,d2
			or.w	d0,d2				;bpl1+2
			not.w	d2					; mask
			move.w	d2,d3
			swap	d2
			move.w	d3,d2
			move.l	d2,(a1)+	;mask
			move.w	d0,(a1)+	;data1
			move.w	d1,(a1)+	;data2
			move.l	d6,(a1)+	;mask
			move.l	d5,(a1)+	;data1/data2
.y set .y+160
		ENDR
		add.w	#8,a0
	dbra	d7,.copyLetter
	rts
letterOffsetTable	
	; populate this with offsets

bupPtr	dc.l	0
fontPtr	dc.l	0
elfcrk	incbin	'elf/elf.crk'
	even

maskCorners
	move.l	screenpointer,a0
	and.l	#%01111111111111110111111111111111,183*160(a0)
	and.l	#%01111111111111110111111111111111,184*160(a0)
	and.l	#%00111111111111110011111111111111,185*160(a0)
	and.l	#%00111111111111110011111111111111,186*160(a0)
	and.l	#%00011111111111110001111111111111,187*160(a0)
	and.l	#%00011111111111110001111111111111,188*160(a0)
	and.l	#%00001111111111110000111111111111,189*160(a0)
	and.l	#%00001111111111110000111111111111,190*160(a0)
	and.l	#%00000111111111110000011111111111,191*160(a0)
	and.l	#%00000011111111110000001111111111,192*160(a0)
	and.l	#%00000001111111110000000111111111,193*160(a0)
	and.l	#%00000000111111110000000011111111,194*160(a0)
	and.l	#%00000000011111110000000001111111,195*160(a0)
	and.l	#%00000000001111110000000000111111,196*160(a0)
	and.l	#%00000000000011110000000000001111,197*160(a0)
	and.l	#%00000000000000110000000000000011,198*160(a0)
	move.l	#0,199*160(a0)
	and.l	#%01111111111111110111111111111111,199*160+8(a0)

	and.l	#%11111111111111101111111111111110,183*160+152(a0)
	and.l	#%11111111111111101111111111111110,184*160+152(a0)
	and.l	#%11111111111111001111111111111100,185*160+152(a0)
	and.l	#%11111111111111001111111111111100,186*160+152(a0)
	and.l	#%11111111111110001111111111111000,187*160+152(a0)
	and.l	#%11111111111110001111111111111000,188*160+152(a0)
	and.l	#%11111111111100001111111111110000,189*160+152(a0)
	and.l	#%11111111111100001111111111110000,190*160+152(a0)
	and.l	#%11111111111000001111111111100000,191*160+152(a0)
	and.l	#%11111111110000001111111111000000,192*160+152(a0)
	and.l	#%11111111100000001111111110000000,193*160+152(a0)
	and.l	#%11111111100000001111111110000000,193*160+152(a0)
	and.l	#%11111111000000001111111100000000,194*160+152(a0)
	and.l	#%11111100000000001111110000000000,195*160+152(a0)
	and.l	#%11110000000000001111000000000000,196*160+152(a0)
	and.l	#%11000000000000001100000000000000,197*160+152(a0)
	move.l	#0,199*160+152(a0)
	and.l	#%11111111111111101111111111111110,199*160+144(a0)
	rts

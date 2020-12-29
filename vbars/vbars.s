; todo:
; - finalize the bar animation
; - add support for additional sprites
; - add sprite movement


; ok, so have 
;	base index for sprites
;	

NR_FRAMES equ 300

SPRITE_WIDTH	equ 128	128	80	;128 	; %16
SPRITE_HEIGHT	equ 80	128	80

DO_MASK		equ 1
;	section text

vbars_init
	move.w	#0,$466.w
	move.l	#memBase+256,d0				;256+670*160+4402
	add.l	#90*160,d0
	sub.b	d0,d0
	move.l	d0,screenpointer
	add.l	#290*160,d0
	sub.b	d0,d0
	move.l	d0,screenpointer2
	move.l	d0,spritesrcptr
	add.l	#290*160,d0

	move.l	d0,bgcopyPtr
	add.l	#4402,d0


;			1			2			3			4
;code		57006		57792		57544		56900
;buffer		47684		49148		49028		47360
;mask		9576		9860		9800		9576

	add.l	#2000,d0

	move.l	d0,spriteCodePtr3
	add.l	#63282,d0
	move.l	d0,spriteBufferPtr3
	add.l	#52000,d0
	move.l	d0,spriteMaskPtr3
	add.l	#11300,d0

	move.l	d0,spriteCodePtr4
	add.l	#57792,d0
	move.l	d0,spriteBufferPtr4
	add.l	#49148,d0
	move.l	d0,spriteMaskPtr4
	add.l	#9860,d0

	move.l	d0,spriteCodePtr
	add.l	#57792,d0
	move.l	d0,spriteBufferPtr
	add.l	#49148,d0
	move.l	d0,spriteMaskPtr
	add.l	#9860,d0

	move.l	d0,spriteCodePtr2
	add.l	#57792,d0
	move.l	d0,spriteBufferPtr2
	add.l	#49148,d0
	move.l	d0,spriteMaskPtr2
	add.l	#9860,d0

	move.l	#memBase+bufsize,d0
	sub.l	#144000,d0
	move.l	d0,spriteptr			; space for the sprites
	add.l	#26000,d0
	move.l	d0,filePtr
	add.l	#92160,d0		




;	sub.l	#memBase,d0
;	move.b	#0,$ffffc123


;57006
;47684
;9576
	lea		spritecrk,a0
	move.l	spritesrcptr,a1
	jsr		cranker

	jsr		init_spritepal

	move.l	spritesrcptr,a0
	add.w	#34,a0
	jsr		init_sprite
	move.l	spriteCodePtr,currentSpriteCodePtr
	move.l	spriteBufferPtr,currentBufferPtr
	move.l	spriteMaskPtr,currentMaskPtr
	move.l	#xpointerListCode1,currentListCode
	move.l	#xpointerListData1,currentListData
	move.l	#xpointerListMask1,currentListMask	
	jsr		generateSpriteCode

	move.l	spritesrcptr,a0
	add.w	#34+80*160,a0
	jsr		init_sprite
	move.l	spriteCodePtr2,currentSpriteCodePtr
	move.l	spriteBufferPtr2,currentBufferPtr
	move.l	spriteMaskPtr2,currentMaskPtr
	move.l	#xpointerListCode2,currentListCode
	move.l	#xpointerListData2,currentListData
	move.l	#xpointerListMask2,currentListMask	
	jsr		generateSpriteCode

	move.l	spritesrcptr,a0
	add.w	#34+80,a0
	jsr		init_sprite
	move.l	spriteCodePtr3,currentSpriteCodePtr
	move.l	spriteBufferPtr3,currentBufferPtr
	move.l	spriteMaskPtr3,currentMaskPtr
	move.l	#xpointerListCode3,currentListCode
	move.l	#xpointerListData3,currentListData
	move.l	#xpointerListMask3,currentListMask	
	jsr		generateSpriteCode

	move.l	spritesrcptr,a0
	add.w	#34+80+80*160,a0
	jsr		init_sprite
	move.l	spriteCodePtr4,currentSpriteCodePtr
	move.l	spriteBufferPtr4,currentBufferPtr
	move.l	spriteMaskPtr4,currentMaskPtr
	move.l	#xpointerListCode4,currentListCode
	move.l	#xpointerListData4,currentListData
	move.l	#xpointerListMask4,currentListMask	
	jsr		generateSpriteCode

	lea		vbarscrk,a0
	move.l	filePtr,a1
	jsr		cranker

	jsr		genBgCopy
	move.w	#$4e75,vbars_init
	moveq	#0,d0
	move.w	$466.w,d0
	rts

init_spritepal
	move.l	spritesrcptr,a0
	add.w	#2+2*8,a0
	lea		spritePal,a1
	REPT 4
	move.l	(a0)+,(a1)+
	ENDR
	rts

vbars_fadeout_vbl
	lea		$ffff8240,a0
	lea		black,a1
	lea		$ffff8240,a2
	move.w	#16,d0
	subq.w	#1,.waiter
	bge		.skip
		move.w	#3,.waiter
		jsr		fade_st
.skip
	rts
.waiter	dc.w	3

vbars_vbl
	move.l	screenpointer2,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	move.w	#$0,$ffff8240

	move.l	filePtr,a0
	move.w	foff,d0
	muls	#194,d0
	add.l	#2,d0
	add.l	d0,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240

	lea		spritePal,a0
	lea		$ffff8240+8*2,a1
	REPT 4
		move.l	(a0)+,(a1)+
	ENDR

	move.w	#0,$ffff8240

	subq.w	#1,.waiter
	bge		.ok
		move.w	#1,.waiter
		add.w	#1,foff
		cmp.w	#NR_FRAMES,foff
		bne		.ok
			move.w	#0,foff
.ok
	jsr		background
	subq.w	#1,.waiter1
	bge		.skip1
		jsr		drawSpriteOpt1
.skip1
	subq.w	#1,.waiter2
	bge		.skip2
	jsr		drawSpriteOpt2
.skip2
	subq.w	#1,.waiter4
	bge		.skip4
	jsr		drawSpriteOpt4
.skip4
	subq.w	#1,.waiter3
	bge		.skip3
	jsr		drawSpriteOpt3
.skip3
	move.l	screenpointer2,d0
	move.l	screenpointer,screenpointer2
	move.l	d0,screenpointer
	rts
.waiter dc.w	4
.waiter1	dc.w	30
.waiter2	dc.w	126
.waiter3	dc.w	300
.waiter4	dc.w	340
vbars_main
	tst.w	bubb2done
	bne		.skip
		subq.w	#1,.waiter
		bge		.skip
		jsr		tunnel_effect_pointers_prec
.skip
	rts
.waiter	dc.w	140
bubb2done	dc.w	-1

bgcopyPtr	dc.l	0

background
	move.l	screenpointer2,a6

	move.l	filePtr,a0
	move.w	foff,d0
	muls	#194,d0
	add.l	#34,d0
	add.l	d0,a0	


	move.l	bgcopyPtr,a5
	jmp		(a5)

;	movem.l	(a0)+,d0-d7/a1-a5		;52
;.y set 0
;	REPT 200
;		movem.l	d0-d7/a1-a5,.y(a6)			;
;.y set .y+160
;	ENDR
;
;	movem.l	(a0)+,d0-d7/a1-a5		;52
;.y set 0
;	REPT 200
;		movem.l	d0-d7/a1-a5,.y+52(a6)
;.y set .y+160
;	ENDR
;
;	movem.l	(a0)+,d0-d7/a1-a5		;52
;.y set 0
;	REPT 200
;		movem.l	d0-d7/a1-a5,.y+104(a6)
;.y set .y+160
;	ENDR
;
;	move.l	(a0)+,d0
;.y set 0
;	REPT 200
;	move.l	d0,.y+156(a6)
;.y set .y+160
;	ENDR
;	rts

genBgCopy
	move.l	bgcopyPtr,a0
	move.l	.s1,d0
	move.w	.s2,d1
	move.l	.c1,d2
	move.w	#160,d4

	move.l	d0,(a0)+			; write source
	move.w	#0,d3
	move.w	#200-1,d7
.cp
		move.l	d2,(a0)+				;6
		move.w	d3,(a0)+
		add.w	d4,d3
		dbra	d7,.cp

	move.l	d0,(a0)+
	move.w	#52,d3
	move.w	#200-1,d7
.cp2
		move.l	d2,(a0)+				;6
		move.w	d3,(a0)+
		add.w	d4,d3
		dbra	d7,.cp2

	move.l	d0,(a0)+
	move.w	#104,d3
	move.w	#200-1,d7
.cp3
		move.l	d2,(a0)+				;6
		move.w	d3,(a0)+
		add.w	d4,d3
		dbra	d7,.cp3

	move.w	d1,(a0)+
	move.l	.c2,d5
	move.w	#156,d5
	move.w	#200-1,d7
.cp4
		move.l	d5,(a0)+				;4			;22*200 =  4400+2 = 4402
		add.w	d4,d5
		dbra	d7,.cp4
	move.w	#$4e75,(a0)+
	rts
.s1
	movem.l	(a0)+,d0-d7/a1-a5
.s2
	move.l	(a0)+,d0
.c1
	movem.l	d0-d7/a1-a5,1234(a6)
.c2
	move.l	d0,1234(a6)

foff	dc.w	0
filePtr	dc.l	0

drawSpriteOpt1
	move.l	screenpointer2,a6
	sub.w	#8,a6
	move.l	.yoff,d0
	cmp.l	#-90*160,d0
	blt		.end

		add.l	d0,a6
		sub.l	#1*160,.yoff

	lea		sinex,a0
	add.w	.sinexoff,a0

	add.w	#2,.sinexoff
	cmp.w	#160*2,.sinexoff
	bne		.k2
		move.w	#0,.sinexoff
.k2

	move.w	(a0),d0
	add.w	d0,d0			;xoff
	lea		xtab,a1
	add.w	(a1,d0.w),a6	;xoff
	move.w	(a0),d0
	and.w	#%1111,d0
	add.w	d0,d0
	add.w	d0,d0			; mod 16


	lea		xpointerListCode1,a0
	add.w	d0,a0
	lea		xpointerListData1,a1
	add.w	d0,a1
	lea		xpointerListMask1,a2
	add.w	d0,a2

	move.l	(a0),a5
	move.l	(a1),a0
	move.l	(a2),a1
	move.l	#0,a4
	jmp		(a5)
.end
	rts
.yoff		dc.l	200*160
.sinexoff	dc.w	0


drawSpriteOpt2
	move.l	screenpointer2,a6
	sub.w	#8,a6
	move.l	.yoff,d0
	cmp.l	#-90*160,d0
	blt		.end

		add.l	d0,a6
		sub.l	#1*160,.yoff

	lea		sinex,a0
	add.w	.sinexoff,a0

	add.w	#2,.sinexoff
	cmp.w	#160*2,.sinexoff
	bne		.k2
		move.w	#0,.sinexoff
.k2

	move.w	(a0),d0
	add.w	d0,d0			;xoff
	lea		xtab,a1
	add.w	(a1,d0.w),a6	;xoff
	move.w	(a0),d0
	and.w	#%1111,d0
	add.w	d0,d0
	add.w	d0,d0			; mod 16


	lea		xpointerListCode2,a0
	add.w	d0,a0
	lea		xpointerListData2,a1
	add.w	d0,a1
	lea		xpointerListMask2,a2
	add.w	d0,a2

	move.l	(a0),a5
	move.l	(a1),a0
	move.l	(a2),a1
	move.l	#0,a4
	jmp		(a5)
.end
	move.w	#0,bubb2done
	rts
.yoff		dc.l	200*160
.sinexoff	dc.w	0

drawSpriteOpt3
	move.l	screenpointer2,a6
	sub.w	#8,a6
	move.l	.yoff,d0
	cmp.l	#-90*160,d0
	blt		.end

		add.l	d0,a6
		sub.l	#1*160,.yoff
	lea		sinex,a0
	add.w	.sinexoff,a0

	add.w	#2,.sinexoff
	cmp.w	#160*2,.sinexoff
	bne		.k2
		move.w	#0,.sinexoff
.k2

	move.w	(a0),d0
	add.w	d0,d0			;xoff
	lea		xtab,a1
	add.w	(a1,d0.w),a6	;xoff
	move.w	(a0),d0
	and.w	#%1111,d0
	add.w	d0,d0
	add.w	d0,d0			; mod 16


	lea		xpointerListCode3,a0
	add.w	d0,a0
	lea		xpointerListData3,a1
	add.w	d0,a1
	lea		xpointerListMask3,a2
	add.w	d0,a2

	move.l	(a0),a5
	move.l	(a1),a0
	move.l	(a2),a1
	move.l	#0,a4
	jmp		(a5)
.end
	rts
.yoff		dc.l	200*160
.sinexoff	dc.w	0

drawSpriteOpt4
	move.l	screenpointer2,a6
	sub.w	#8,a6
	move.l	.yoff,d0
	cmp.l	#-90*160,d0
	blt		.end

		add.l	d0,a6
		sub.l	#2*160,.yoff

	lea		sinex,a0
	add.w	.sinexoff,a0

	add.w	#2,.sinexoff
	cmp.w	#160*2,.sinexoff
	bne		.k2
		move.w	#0,.sinexoff
.k2

	move.w	(a0),d0
	add.w	d0,d0			;xoff
	lea		xtab,a1
	add.w	(a1,d0.w),a6	;xoff
	move.w	(a0),d0
	and.w	#%1111,d0
	add.w	d0,d0
	add.w	d0,d0			; mod 16


	lea		xpointerListCode4,a0
	add.w	d0,a0
	lea		xpointerListData4,a1
	add.w	d0,a1
	lea		xpointerListMask4,a2
	add.w	d0,a2

	move.l	(a0),a5
	move.l	(a1),a0
	move.l	(a2),a1
	move.l	#0,a4
	jmp		(a5)
.end
	rts
.yoff		dc.l	200*160
.sinexoff	dc.w	0

vbars_vblcount
	addq.w	#1,$466.w
	rts

init_sprite
	move.l	spriteptr,a1

; first we copy the sprite to the spritepointer
	move.w	#SPRITE_HEIGHT-1,d7	; y
.doy
	REPT (SPRITE_WIDTH/16)
		; make mask
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
	ENDR
	move.l	#0,(a1)+			; pad right 16 px
	move.l	#0,(a1)+			; pad right 16 px
	add.w	#160-(SPRITE_WIDTH/16)*8,a0
	dbra	d7,.doy


	; then we shift all the shit to the rest of the buffer, 15 times
	move.l	spriteptr,a2									; start sprite
	move.l	a2,a0		; source
	move.l	a0,a1		; dest
	add.l	#((SPRITE_WIDTH/16)+1)*8*SPRITE_HEIGHT,a1		; next xpos
	move.w	#15-1,d5
.doshift
	jsr		preshift4bpl
	add.l	#((SPRITE_WIDTH/16)+1)*8*SPRITE_HEIGHT,a2
	dbra	d5,.doshift

	; now we can generate 1

;	move.l	spriteptr,d0
;	sub.l	d0,a1
;	move.b	#0,$ffffc123
;	nop
;	nop
	rts

preshift4bpl
	moveq	#0,d0
	roxr.w	d0
	move.w	#SPRITE_HEIGHT-1,d7	; y
.y
.o set 0
	REPT 4
.x set .o
	REPT	((SPRITE_WIDTH/16)+1)
		move.w		.x(a0),d0
		roxr.w		d0
		move.w		d0,.x(a1)
.x set .x+8
	ENDR
.o set .o+2
	ENDR

	add.l	#((SPRITE_WIDTH/16)+1)*8,a0
	add.l	#((SPRITE_WIDTH/16)+1)*8,a1
	dbra	d7,.y
	rts





testreg macro
	tst.w	\1
	bne		.k\@
		move.b	#0,$ffffc123
.k\@
        ENDM
        
possiblyAddOffsetToScreen	macro
			tst.w	d4										; check
			beq		.caseA_nooff\@							; if screen offset counter is 0, dont insert lea
				move.l	d4,(a5)+							; else insert lea
				sub.w	d4,d4								; clear screen offset counter
.caseA_nooff\@
	endm

andllist
.andld6	
			and.l	d6,d7
			and.l	d6,(a6)+
.andld5
			and.l	d5,d7
			and.l	d5,(a6)+
.andld4
			and.l	d4,d7
			and.l	d4,(a6)+
.andld3
			and.l	d3,d7
			and.l	d3,(a6)+
.andld2
			and.l	d2,d7
			and.l	d2,(a6)+
.andld1		
			and.l	d1,d7
			and.l	d1,(a6)+
.andld0		
			and.l	d0,d7
			and.l	d0,(a6)+
; this preloads the masks, if needed, and applies the right thing to the smc
possiblyLoadMasks	macro
	; first determe if we have any preloaded masks
	tst.w	d7
	bge		.ok\@
		moveq	#24,d7				; reset the thing
		move.l	.moveml,(a5)+		; preload regs
.ok\@
	move.w	(a0,d7.w),.applymask
	move.w	2(a0,d7.w),.skiponeb
	subq.w	#4,d7
	endm


; todo:
;	- make this reusable for multiple sprites
;		- extend the lists to have NR_SPRITES * 16 LONGWORDS
generateSpriteCode


	move.w	#0,.xoff
	move.w	#15,.times

	movem.l	.casea,a0/a1/a2		;d0.w, d1.l, d2.l
	move.l	.casec,d5			;d4.l


	move.l	spriteptr,a4
	move.l	currentSpriteCodePtr,a5
	move.l	currentBufferPtr,a6
	move.l	currentMaskPtr,a1
	lea		andllist,a0

.loop
;	lea		xpointerListCode,a3								; buffer for generated code
	move.l	currentListCode,a3
	add.w	.xoff,a3										; add offset for the 16 iterations to get correct code, cuz out of regs ;P ?
	move.l	a5,(a3)											; save codePointer
;	lea		xpointerListData,a3								; buffer for generated data
	move.l	currentListData,a3
	add.w	.xoff,a3										; ditto add offset
	move.l	a6,(a3)											; save dataPointer
;	lea		xpointerListMask,a3
	move.l	currentListMask,a3
	add.w	.xoff,a3
	move.l	a1,(a3)
	add.w	#4,.xoff										; increase offset

	move.w	.caseb,a3			;d3.l						; caseb opcode
	move.l	.leal,d4										; lea	x(a6),a6	opcode
	sub.w 	d4,d4											; clear offset

	moveq	#0,d7
			possiblyLoadMasks

	move.w	#SPRITE_HEIGHT-1,.ytimes						; y-loop
.doY
		move.w	#((SPRITE_WIDTH/16)+1)-1,d6					; x-loop
.doX
		move.l	(a4)+,d0	;bpl1							; get sprite mask bpl1 bpl2
		move.l	(a4)+,d1	;bpl2							; get sprite mask bpl3 bpl4
		move.w	d0,d2		;mask							; use d2 for mask (bpl2)
		swap	d0											;
		or.w	d0,d2										; mask = bpl1 || bpl2 
		swap	d0
		or.w	d1,d2										; mask = bpl1 || bpl2 || bpl 4
		swap	d1
		or.w	d1,d2										; mask = bpl1 || bpl2 || bpl3 || bpl4
		swap	d1
		cmp.w	#-1,d2										; check
		beq		.doCaseC									; if sprite covers all 16 bits; then we can just copy data, no masking needed
		tst.w	d2											; check
		beq		.doCaseB									; if sprite covers no bits; its empty, an can be skipped
.doCaseA	; the case where you want to mask and or	
					possiblyAddOffsetToScreen				; apply screen offset counter if needed
			move.w	d2,d3									; extend mask to longword to span 2 bitplanes
			swap	d2										;
			move.w	d3,d2									; d2.l = mask
			not.l	d2										; negate bits for actual mask
			move.l	d2,(a1)+								; store mask

			tst.l	d0										; check
			beq		.caseA_onlybpl2							; if bpl1, bpl2 empty, optimize
.caseA_bpl1bpl2												; else draw both bitplanes
			move.l	d0,(a6)+								; store bpl1,bpl2
			move.l	d1,(a6)+								; store bpl3,bpl4
					possiblyLoadMasks						; code for optionally loading masks to registers, incase no masks left
			move.l	.applymaskscreen,(a5)+					; code for loading bpl1,bpl2 from screen address and applying mask
			move.l	a2,(a5)+								; code for or'ing in bpl1,bpl2 from sprite data and writing back to screen
			move.l	.applymaskscreen,(a5)+					; code for loading bpl3,bpl4 from screen address and applying mask
			move.l	a2,(a5)+								; code for or'ing in bpl3,bpl4 from sprite data and writing back to screen
			jmp		.endcasea
.caseA_onlybpl2												; omit drawing bpl1,bpl2, because empty
			move.l	d1,(a6)+								; store bpl3,bpl4
					possiblyLoadMasks						; code for optionally loading masks to registers, incase no masks left
			move.w	.skiponeb,(a5)+							; code for applying mask to bpl1,bpl2 on screen, and screen post increment
			move.l	.applymaskscreen,(a5)+					; code for loading bpl3,bpl4 from screen address and applying mask
			move.l	a2,(a5)+								; code for or'ing in bpl3,bpl4 from sprite data and writing back to screen
.endcasea
			dbra	d6,.doX									; next x
			add.w	#160-((SPRITE_WIDTH/16)+1)*8,d4			; add offset to next scanline to offset counter
			subq.w	#1,.ytimes								; next y
			bge		.doY
			jmp		.end
.doCaseB	; the case where we skip drawing altogther
			addq.w	#8,d4									; no draw, and thus increase offset counter by 8		
			dbra	d6,.doX									; next x
			add.w	#160-((SPRITE_WIDTH/16)+1)*8,d4			; add offset to next scanline to offset counter
			subq.w	#1,.ytimes								; next y
			bge		.doY
			jmp		.end
.doCaseC	; the case where you want to copy
					possiblyAddOffsetToScreen				; apply screen offset counter if needed
			tst.l	d0										; check
			beq		.skipd0									; if bpl1, bpl2 empty, optimize
.caseC_bpl1bpl2												; else draw both bitplanes
				move.l	d0,(a6)+							; store bpl1,bpl2
				move.l	d1,(a6)+							; store bpl3,bpl4
				move.l	d5,(a5)+							; code for copying buffers to screen
				jmp		.cont
.skipd0														; omit drawing bpl1,bpl2, because empty
				move.l	d1,(a6)+							; store bpl3,bpl4
				move.w	.skipone,(a5)+						; add offset to screen for skippig bpl1,bpl2
				move.w	d5,(a5)+							; code for copying buffer to screen
.cont
			dbra	d6,.doX
			add.w	#160-((SPRITE_WIDTH/16)+1)*8,d4
	subq.w	#1,.ytimes
	bge		.doY
.end
	move.w	#$4e75,(a5)+									; finish current drawing route by rts
	subq.w	#1,.times										; check if we need more shifted sprites to generate
	bge		.loop											; and loop if we do

;	move.l	currentSpriteCodePtr,d0
;	move.l	currentBufferPtr,d1
;	move.l	currentMaskPtr,d2
								;			1			2			3			4
;	sub.l	d0,a5				;code		57006		57792		57544		56900
;	sub.l	d1,a6				;buffer		47684		49148		49028		47360
;	sub.l	d2,a1				;mask		9576		9860		9800		9576

;	move.b	#0,$ffffc123

	rts
.ytimes	dc.w	0
.times	dc.w	0
.xoff	dc.w	0
.casea
	move.l	(a1)+,d0
	move.l	(a1)+,d0

.applymaskscreen
	move.l	(a6),d7
.applymask
	and.l	d0,d7
	or.l	(a0)+,d7
	move.l	d7,(a6)+

.caseb
	addq.w	#8,a6

.casec
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+

.leal
.skiph
	lea		160-((SPRITE_WIDTH/16)+1)*8(a6),a6
.skipone
	move.l	a4,(a6)+
.skiponeb
	and.l	d0,(a6)+

.movemlCounter	dc.w	7
.moveml
	movem.l	(a1)+,d0-d6


;	section data

	rsreset

xpointerListCode1	ds.l	16
xpointerListData1	ds.l	16
xpointerListMask1	ds.l	16

xpointerListCode2	ds.l	16
xpointerListData2	ds.l	16
xpointerListMask2	ds.l	16

xpointerListCode3	ds.l	16
xpointerListData3	ds.l	16
xpointerListMask3	ds.l	16

xpointerListCode4	ds.l	16
xpointerListData4	ds.l	16
xpointerListMask4	ds.l	16

currentListCode		dc.l	xpointerListCode1
currentListData		dc.l	xpointerListData1
currentListMask		dc.l	xpointerListMask1

spriteptr			dc.l	0


spritesrcptr		dc.l	0
spritePal			ds.w	16

xtab
.x set 0
	REPT 20
		REPT 16
			dc.w	.x
		ENDR
.x set .x+8
	ENDR

sinex	include	'vbars/data/sine_x2.s'	; 160
siney	include	'vbars/data/sine_y.s'	; 230

currentSpriteCodePtr	ds.l	1		
currentBufferPtr		ds.l	1
currentMaskPtr			ds.l	1

spriteCodePtr			ds.l	1	;57006
spriteBufferPtr			ds.l	1	;47684
spriteMaskPtr			ds.l	1	;9576	

spriteCodePtr2			ds.l	1
spriteBufferPtr2		ds.l	1
spriteMaskPtr2			ds.l	1

spriteCodePtr3			ds.l	1
spriteBufferPtr3		ds.l	1
spriteMaskPtr3			ds.l	1

spriteCodePtr4			ds.l	1
spriteBufferPtr4		ds.l	1
spriteMaskPtr4			ds.l	1


;spritecrk	incbin	'vbars/data/8colsprite3.crk'				;10017 / 
;	even														;10018
;vbarscrk	
;		incbin	'vbars/data/result_one_600_25fps.crk'			;26846
;		even


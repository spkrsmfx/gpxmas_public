; maybe open top, bottom for extra space
; add plasma?
; then add reveal of letters?

DEV equ 0

end_endless
	jsr		sndh_disable_play
	move.l	#32000,endless
	rts

end_vbl
	move.l	screenpointer2,$ffff8200

	subq.w	#1,.waiter
	bge		.nn
		move.w	#2,.waiter
		lea		$ffff8240,a0
		lea		end_pal,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.nn
		


;	jsr		doGrid
	jsr		plasmaTest
	jsr		end_drawText

	move.l	screenpointer2,d0
	move.l	screenpointer,screenpointer2
	move.l	d0,screenpointer
	rts
.waiter	dc.w	0

GC	equ $667
TC	equ	$335

end_pal
	dc.w	$777,GC,TC,GC,TC,TC,TC,TC,$777,$777,$777,$777,$777,$777,$777,$777


end_fadewhite
	tst.w	cleared
	blt		.skip
		lea		$ffff8240,a0
		lea		tunnelWhite,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.skip
	rts

cleared	dc.w	-1

tunnelWhite
	dc.w	$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777,$777


end_init
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	add.l	#$10000,d0
	move.l	d0,screenpointer2
	add.l	#$10000,d0
	move.l	d0,sin1ptr
	add.l	#160,d0
	move.l	d0,sin2ptr
	add.l	#100,d0
	move.l	d0,endFontPtr
	add.l	#32128,d0
	move.l	d0,endFont
	add.l	#15*32*2,d0
	move.l	d0,gridPointer
	add.l	#4*120*16*2*2,d0
	move.l	d0,plasmaCodePtr

	move.l	screenpointer,a0
	move.l	#$20000,d0
	jsr		fast_clear
	move.w	#0,cleared

	lea		endfont,a0
	move.l	endFontPtr,a1
	jsr		cranker

	move.l	endFontPtr,a0
	add.l	#128,a0
	move.l	endFont,a1
	move.w	#20-1,d7
	move.w	#2-1,d6
.cp
.y set 0
		REPT 15
			move.w	.y(a0),(a1)+
.y set .y+160
		ENDR
		add.w	#8,a0
		dbra	d7,.cp
	add.w	#14*160,a0
	move.w	#12-1,d7
	dbra	d6,.cp	

	jsr		prepGrid
	jsr		generatePlasmaCode
	move.w	#$4e75,end_init
	rts

endFontPtr	dc.l	0
endFont		dc.l	0

end_drawText
	subq.w	#1,.waiter
	bge		.noNext
	move.l	screenpointer2,a0
	move.l	screenpointer,a3
	add.w	.screenOff,a0
	add.w	.screenOff,a3
	lea		end_text,a1
	add.w	.textOff,a1
	move.w	#20-1,d7

.go
	moveq	#0,d0
	move.b	(a1)+,d0
	sub.w	#$41,d0
	blt		.skip
		muls	#15*2,d0
		move.l	endFont,a2
		add.w	d0,a2
		jsr		db
.skip
		add.w	#8,a0
		add.w	#8,a3
	dbra	d7,.go

	add.w	#15*160,a0
	add.w	#15*160,a3
	move.w	#20-1,d7
.go2
	moveq	#0,d0
	move.b	(a1)+,d0
	sub.w	#$41,d0
	blt		.skip2
		muls	#15*2,d0
		move.l	endFont,a2
		add.w	d0,a2
		jsr		db
.skip2
		add.w	#8,a0
		add.w	#8,a3
	dbra	d7,.go2





	subq.w	#1,.lineWaiter
	bge		.noNext
		move.w	#140,.lineWaiter
		add.w	#20,.textOff
		add.w	#16*160,.screenOff
		cmp.w	#240,.textOff
		bne		.noNext
			move.w	#0,.textOff
			move.w	#0,.screenOff
.noNext
	rts
.textOff	dc.w	0
.lineWaiter	dc.w	200
.screenOff	dc.w	0
.waiter		dc.w	400

db
.y set 0
		REPT 15
			move.w	.y(a0),d0		; screen block
			move.w	(a2)+,d1		; new text block
			and.w	d0,d1			; hidden text block
			move.w	2+.y(a0),d2			; existing candidate screen block
			or.w	d1,2+.y(a0)		; candidate screen block
			or.w	d1,2+.y(a3)		; candidate screen block
			not.w	d0
			and.w	d0,d2
			or.w	d2,4+.y(a0)		; revealed text block
.y set .y+160
		ENDR
		rts

end_mainloop
	rts

plasmaCodePtr	dc.l	0

end_text
;	dc.b	"---------------------"	
;	dc.b	" OH MY GOSH GUYS WE "	;1
;	dc.b	"ARE ALMOST AT THEEND"	;2
;	dc.b	"  OF THIS WONDERFUL "	;3
;	dc.b	" FIRST COLLABORATION"	;4
;	dc.b	"  OF SELFPROCLAIMED "	;5	
;	dc.b	"   GENESIS PROJECT  "	;6
;	dc.b	"    SCENE LEGENDS   "	;7
;	dc.b	"   FACET PROTO SPKR "	;8
;	dc.b	"   SO MUCH AWESOME  "	;9
;	dc.b	"WE REALLY GOT ROLLIN"	;10
;	dc.b	"THERE ARE MORE DUTCH"	;11
;	dc.b	" MACHINES OUT THERE "	;12
;	dc.b	""
;	dc.b	""
;	dc.b	""
;	even


	dc.b	" OH MY GOSH LADS WE "	;1
	dc.b	" REACHED THE END OF "	;2
	dc.b	"THIS CRAZY CHRISTMAS"	;3
	dc.b	" RIDE^ WE HOPE YOU  "	;4
	dc.b	" ENJOYED_ WE SURE AS"	;5
	dc.b	" HELL DID MAKING IT^"	;6
	dc.b	"WE WISH YOU COZY AND"	;7
	dc.b	" WONDERFUL DAYS AND "	;8
	dc.b	" ALL BEST FOR [\[]^ "	;9
	dc.b	"                    "	;10
	dc.b	" FACET_ PROTO_ SPKR "	;11
	dc.b	"    SIGNING OFF     "	;12
	dc.b	"                    "	;10
	dc.b	"                    "	;10
	dc.b	"                    "	;10

	section data
grid	
	incbin	'end/grid.crk'
	even

prepGrid
	lea		grid,a0
	move.l	gridPointer,a1
	jsr		cranker

	move.l	gridPointer,a0			;4*120*16*2
	lea		120*16*2(a0),a1
	lea		120*16*2(a1),a2
	lea		120*16*2(a2),a3
	move.w	#120*2-1,d7
	moveq	#-2,d1
	moveq	#0,d2
.loop	
	REPT 15
		move.w	(a0),d0
		and.w	d1,d0
		move.w	d0,(a0)+
		move.w	d0,(a1)+
		move.w	d0,(a2)+
		move.w	d0,(a3)+
	ENDR
		move.w	d2,(a0)+
		move.w	d2,(a1)+
		move.w	d2,(a2)+
		move.w	d2,(a3)+
	dbra	d7,.loop
	rts

gridPointer	dc.l	0

; lets do a plasma?


plasmaTest
	move.l	sin1ptr,a1
;	lea		sin1,a1
	lea		sin0,a2

	move.w	#$1fe,d6
	move.w	#$1fc,d7

	movem.l	.off1,d1-d4/a3-a6
	move.w	#20-1,d7
.loop
		add.l	a3,d1
		move.l	d1,d0
		swap	d0
		and.w	d6,d0
		move.w	(a2,d0.w),d5				; 16				move.l	d4,a3			;4

		add.l	a4,d2
		move.l	d2,d0
		swap	d0
		and.w	d6,d0
		add.w	(a2,d0.w),d5				; 16				move.w	(a3),d6			;8

		move.w	d5,(a1)+					; 					add.w	(a3),d6			;8
	dbra	d7,.loop

	sub.l	#$48000,.off1
	add.l	#$24000,.off2
	sub.l	#$28000,.off3
	add.l	#$40000,.off4

	subq.w	#1,.zoomw
	bge		.nozoomflip
.zoomflip
		neg.w	.zoomdir
		move.w	#200,.zoomw
.nozoomflip


	tst.w	.zoomdir
	blt		.zooin
	add.l	#$1000,.add1
	add.l	#$1000,.add2
	add.l	#$1000,.add3
	add.l	#$1000,.add4
	jmp		.zoomdone
.zooin
	sub.l	#$1000,.add1
	sub.l	#$1000,.add2
	sub.l	#$1000,.add3
	sub.l	#$1000,.add4
.zoomdone

	movem.l	sin1ptr,a1-a2
	move.l	a1,usp
	move.l	screenpointer2,a6


	lea		sin0,a2
	movem.l	.add3,a3/a4
	movem.l	.off3,d4/d5
;	move.l	.add3,a3
;	move.l	.add4,a4
;	move.l	.off3,d4
;	move.l	.off4,d5
	move.w	#$1fe,d6
	move.w	#$1fc,d7

;	lea		grid,a5
	move.l	gridPointer,a5
	move.l	plasmaCodePtr,a0
	jmp		(a0)
		;a5 free
		;a7
.zoomdir	dc.w	1
.zoomw		dc.w	100
.off1	dc.w	0
		dc.w	0
.off2	dc.w	0
		dc.w	0
.off3	dc.w	0
		dc.w	0
.off4	dc.w	0
		dc.w	0
.add1	dc.w	24
		dc.w	0
.add2	dc.w	21
		dc.w	0
.add3	dc.w	25
		dc.w	0
.add4	dc.w	19
		dc.w	0
.offwaiter	dc.w	1



generatePlasmaCode
	move.l	plasmaCodePtr,a0
	moveq	#0,d0				;y
	move.l	.innerinner,d1
	move.w	#160,d2
	lea		.init,a1
	lea		.inner,a2

	move.w	#13-1,d7
	jsr		doBlock
	move.w	#$4e75,(a0)+

	rts
.init	
		add.l	a3,d4									;2
		move.l	d4,d3									;2
		swap	d3										;2
		and.w	d6,d3									;2
		move.w	(a2,d3.w),d2							;4
		add.l	a4,d5									;2
		move.l	d5,d3									;2
		swap	d3										;2
		and.w	d6,d3									;2
		add.w	(a2,d3.w),d2							;4
		move.l	usp,a1									;2		--> 28
.inner
		move.w	(a1)+,d0		; value
		add.w	d2,d0			; offset
		move.l	a5,a0
		add.w	d0,a0
.innerinner
		move.w	(a0)+,1234(a6)

doBlock
.doIter
; copy init	
		move.l	a1,a6
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.l	(a6)+,(a0)+
		move.w	(a6)+,(a0)+
; copy inner
		move.w	d0,d4			; .x set .y
		move.w	#20-1,d6
.inn
			move.l	a2,a6
			move.l	(a6)+,(a0)+
			move.l	(a6)+,(a0)+
			move.w	d4,d1
			move.w	#16-1,d5
.ii
				move.l	d1,(a0)+
				add.w	d2,d1
			dbra	d5,.ii
			addq.w	#8,d4
		
		dbra	d6,.inn
		add.w	#16*160,d0
	dbra	d7,.doIter
	rts

;	opt o-
;herpherp
;.y set 2
;	REPT 12
;		add.l	a3,d4									;2
;		move.l	d4,d3									;2
;		swap	d3										;2
;		and.w	d6,d3									;2
;		move.w	(a2,d3.w),d2							;4
;		add.l	a4,d5									;2
;		move.l	d5,d3									;2
;		swap	d3										;2
;		and.w	d6,d3									;2
;		add.w	(a2,d3.w),d2							;4
;		move.l	usp,a1									;2		--> 28
;.x set .y
;		REPT 20								;a0,a2,a3,a4,a5	20*4 = 80*8 = 640	80/5 = 16*32= 512
;			move.w	(a1)+,d0		; value
;			add.w	d2,d0			; offset
;			move.l	a5,a0
;			add.w	d0,a0
;.l set .x
;			REPT 16
;				move.w	(a0)+,.l(a6)
;.l set .l+160
;			ENDR
;
;.x set .x+8
;		ENDR			;20*2*8*50 = 16000 = 31 scanlines
;.y set .y+16*160
;	ENDR
;	rts
;	opt o+
;	add.l	#200*160,a6
;
;
;
;.y set 0
;	REPT 4
;		add.l	a3,d4									;2
;		move.l	d4,d3									;2
;		swap	d3										;2
;		and.w	d6,d3									;2
;		move.w	(a2,d3.w),d2							;4
;		add.l	a4,d5									;2
;		move.l	d5,d3									;2
;		swap	d3										;2
;		and.w	d6,d3									;2
;		add.w	(a2,d3.w),d2							;4
;;		and.w	d7,d2									;2		--> 26
;		move.l	usp,a1									;2		--> 30
;.x set .y
;		REPT 20								;a0,a2,a3,a4,a5	20*4 = 80*8 = 640	80/5 = 16*32= 512
;			move.w	(a1)+,d0		; value
;			add.w	d2,d0			; offset
;;			asl.w	#3,d0
;			; get the source val
;			move.l	a5,a0
;			add.w	d0,a0
;.l set .x
;			REPT 16
;				move.w	(a0)+,.l(a6)
;.l set .l+160
;			ENDR
;
;.x set .x+8
;		ENDR			;20*2*8*50 = 16000 = 31 scanlines
;.y set .y+16*160
;	ENDR
;
;	rts
;	ENDC


;			move.w	(a1)+,d0							;2
;			add.w	d2,d0								;2
;			move.l	d0,a0								;2
;			move.l	(a0),d3								;2
;			move.w	(a1)+,d1							;2
;			add.w	d2,d1								;2
;			move.l	d1,a0								;2
;			or.l	(a0),d3								;2
;			movep.l	d3,.x(a6)							;4
;
;			move.w	(a1)+,d0							;2
;			add.w	d2,d0								;2
;			move.l	d0,a0								;2
;			move.l	(a0),d3								;2
;			move.w	(a1)+,d1							;2
;			add.w	d2,d1								;2
;			move.l	d1,a0								;2
;			or.l	(a0),d3								;2
;			movep.l	d3,.x+1(a6)							;4		--> 40				(40*20+30)*50 = 830*50 = 41500




;256 items
; lets generate it, with 0..120 range *16 as indices

sin0
	include	'end/sin0.s'

endfont
	incbin	'end/15x15_font.crk'
	even

sin1ptr	ds.l	1
sin2ptr	ds.l	1
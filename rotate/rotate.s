; [x] create rotating dots, and make sure we can rotate a pretty few
; [ ] implement object: 2x torus intertwined
; [ ] optimize to draw 2 dots per, by doing x,y mirror
; [ ] add reflection with rasters?
; [ ] add panel, moving in side or synscroll ?
; [ ]

USE_BG	equ 1


; 64 frames, x,y
;256 per dot

; screen1, clear plane1, 	draw plane1		make plane2 back		drawbuff a
; screen2, clear plane1,	draw plane1		make plane2 back		drawbuff b
; screen1, clear plane2,	draw plane2		make plane2 front		drawbuff c
; screen2, clear plane2,	draw plane2		make plane2 front		drawbuff d
DOTS_PRECALC	equ 0


	IFEQ	DOTS_PRECALC
SIZE	equ	25
	ELSE
SIZE 	equ 11
	ENDC

NR_VERTICES			equ	720*4 		(SIZE+1)*SIZE*4


max_nr_of_vertices	equ NR_VERTICES			; max in vbl with music is 643
z_on				equ 1
;pers				equ 700
pers				equ 1400	1100

tabset	equ 1

LOGS            EQU 1024
EXPS            EQU 4096

sintable_size_tridi		equ	512*2				; 512 entries of wordsize

DO_COMPRESSION		equ 0						; if enabled, this uses sparse memory and compresse (byte-wise) data structure for storing and drawing

DO_LOW_MEMORY		equ 0
	incdir	../

;	SECTION text

dots_init
;	lea		tree,a0
;	move.b	#0,$ffffc123	;17376
;	lea		deer,a0
;	move.b	#0,$ffffc123	;17376

	jsr		dots_init_pointers
	jsr		dots_init_precalc
	jsr		precalcRotpoly
	move.w	#$4e75,dots_init
	rts

dots_storelower
	jsr		dots_init_pointers
	jsr		storeLowerMem
	move.w	#$4e75,dots_storelower
	rts

dots_restorelower
	jsr		restoreLowerMem
	move.w	#$4e75,dots_restorelower
	rts

dots_init_pointers
	move.l	#memBase+65536,d0			;1
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,d1
	add.l	#$8000,d1
	move.l	d1,oldLowerPtr
	add.l	#$10000,d0					;2
	move.l	d0,screenpointer2
	move.l	d0,d1
	add.l	#$8000,d1
		add.l	#2048,d1
		move.l	d1,logpointer
		add.l	#2048,d1
		add.l	#1024,d1
		move.l	d1,zpointer
		add.l	#1024,d1
		move.l	d1,y_block_pointer
		add.l	#1280,d1
		move.l	d1,x_block_add_pointer
		add.l	#2560,d1


	IFEQ	DO_LOW_MEMORY
		add.l	#8192*1,d1
		move.l	d1,expointernorm
		add.l	#8192*3,d1

			move.l	d1,d2
			move.l	d2,logpointer_src
			add.l	#8196,d2
			move.l	d2,exppointer_src
			add.l	#8196,d2



		move.l	d1,myPrecalcPtr
		add.l	#32*2*(NR_VERTICES),d1			;32*2*2600		332800/65536			2896 vertices -> 2896*32*2
		move.l	d1,myPrecalc2Ptr	;2600*64
		add.l	#32*(NR_VERTICES),d1


		move.l	d1,myPrecalc3Ptr
		add.l	#32*2*(NR_VERTICES),d1			;32*2*2600		332800/65536			2896 vertices -> 2896*32*3
		move.l	d1,myPrecalc4Ptr	;2600*64
		add.l	#32*(NR_VERTICES),d1

		move.l	d1,verticesPtr
		add.l	#2896*6,d1

;		sub.l	#memBase,d1
;		move.b	#0,$ffffc123



	ELSE

	add.l	#$10000,d0					;4
	move.l	d0,logpointer								; bottom 2048 and top 2048 (4096 size when used)
	add.l	#$10000,d0					;5
	move.l	d0,zpointer									; bottom 1024 and top 1024 used
	add.l	#$10000,d0
	move.l	d0,expointernorm
	add.l	#$10000,d0

	move.l	d0,y_block_pointer				; ytab and xtab can be put together							;4
	move.l	d0,d1
	add.l	#1280,d1
	move.l	d1,x_block_add_pointer
	add.l	#2560,d1
	move.l	d1,myPrecalcPtr
	add.l	#32*2*(NR_VERTICES),d1			;32*2*2600		332800/65536			2896 vertices -> 2896*32*3
	move.l	d1,myPrecalc2Ptr	;2600*64
	add.l	#32*(NR_VERTICES),d1

	ENDC


	move.w	#0,$466.w

;	move.l	screenpointer,a0
;	move.l	screenpointer2,a1
;	move.l	#$ffff,d0
;	moveq	#0,d1
;	move.w	#200-1,d7
;.l
;	REPT 20
;		move.l	d0,(a0)+
;		move.l	d1,(a0)+
;		move.l	d0,(a1)+
;		move.l	d1,(a1)+
;	ENDR
;	dbra	d7,.l
	rts

verticesPtr	dc.l	0
;	IFEQ	USE_BG
dots_bg
;	lea		rotateLeft+128,a0
;	lea		treecrk,a1
;	REPT 100	
;		rept 12
;			move.l	(a0)+,(a1)+
;		endr
;		lea	160-12*4(a0),a0
;	ENDR
;	lea		treecrk,a0				;12*4*100 = 4800
;	move.b	#0,$ffffc123

	lea		ornaments,a0
	lea		treecrk,a1
	jsr		cranker

	lea		treecrk,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	lea		199*160(a1),a3
	lea		199*160(a2),a4
	move.w	#100-1,d7
.cp
			movem.l	(a0)+,d0-d5

			movem.l	d0-d5,(a1)
			movem.l	d0-d5,(a2)
			movem.l	d0-d5,(a3)
			movem.l	d0-d5,(a4)

			movem.l	(a0)+,d0-d5

			movem.l	d0-d5,160-3*8(a1)
			movem.l	d0-d5,160-3*8(a2)
			movem.l	d0-d5,160-3*8(a3)
			movem.l	d0-d5,160-3*8(a4)

			lea		160(a1),a1
			lea		160(a2),a2
			lea		-160(a3),a3
			lea		-160(a4),a4
	dbra	d7,.cp
	move.w	#$4e75,dots_bg
	rts
;	ENDC


dots_init_precalc

	move.l	screenpointer,a0
	add.l	#$8000,a0
	move.l	#$50000,d0
	jsr		fast_clear

	lea		deercrk,a0
	move.l	verticesPtr,a1
	jsr		cranker

	jsr		dots_storelower

	lea		logcrk,a0
	move.l	logpointer_src,a1
	jsr		cranker

	lea		expcrk,a0
	move.l	exppointer_src,a1
	jsr		cranker

 	jsr		init_yblock_aligned
	jsr		init_xblock_aligned
	jsr		init_exp_log
	jsr		initZTable

	move.l	#NR_VERTICES,number_of_vertices				; z_off
	move.l	myPrecalcPtr,currentOffsetPtr
	move.l	myPrecalc2Ptr,currentMaskPtrx

	move.w	#80*4,vertices_xoff
	move.w	#100*4,vertices_yoff

	move.w	#2,stepSpeedX
	move.w	#4,stepSpeedY
	move.w	#1,stepSpeedZ
	rts

dots_main
	IFEQ	DOTS_PRECALC
	jsr		precalcRotpoly
	ENDC
	rts


dots_reverse

	move.l	screenpointer,a0
	move.l	#$8000,d0
	jsr		fast_clear
	move.l	screenpointer2,a0
	move.l	#$8000,d0
	jsr		fast_clear

	move.l	myPrecalc3Ptr,currentOffsetPtr
	move.l	myPrecalc4Ptr,currentMaskPtrx
	rts		

dots_deer

	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	moveq	#0,d0
	move.w	#200-1,d7
.cls
		lea		24(a0),a0
		lea		24(a1),a1
		REPT 14
			move.l	d0,(a0)+
			move.l	d0,(a0)+
			move.l	d0,(a1)+
			move.l	d0,(a1)+
		ENDR
		lea		24(a0),a0
		lea		24(a1),a1
		dbra	d7,.cls


;	move.l	#$8000,d0
;	jsr		fast_clear
;	move.l	screenpointer2,a0
;	move.l	#$8000,d0
;	jsr		fast_clear

	move.l	myPrecalcPtr,currentOffsetPtr
	move.l	myPrecalc2Ptr,currentMaskPtrx
	rts		

rotationPrecalcDone	dc.w	-1

precalcRotpoly
	
;	lea		deercrk,a0
;	move.l	verticesPtr,a1
;	jsr		cranker

	move.l	verticesPtr,currentObject
	jsr		init_object
	move.l	myPrecalcPtr,currentOffsetPtr
	move.l	myPrecalc2Ptr,currentMaskPtrx
	move.l	#0,precalcOff

	move.w	#32-1,d7
.loop
		move.w	d7,-(sp)
		jsr		doRotationPoly
		move.w	(sp)+,d7
		dbra	d7,.loop

	lea		treecrk,a0
	move.l	verticesPtr,a1
	jsr		cranker

	move.l	verticesPtr,currentObject
	jsr		init_object
	move.l	myPrecalc3Ptr,currentOffsetPtr
	move.l	myPrecalc4Ptr,currentMaskPtrx
	move.l	#0,precalcOff

	move.w	#32-1,d7
.loop2
		move.w	d7,-(sp)
		jsr		doRotationPoly
		move.w	(sp)+,d7
		dbra	d7,.loop2
		nop


;	move.l	#deer,currentObject
;	move.l	myPrecalcPtr,currentOffsetPtr
;	move.l	myPrecalc2Ptr,currentMaskPtrx


	move.w	#0,rotationPrecalcDone
	move.l	myPrecalcPtr,d0
	move.w	#$4e75,precalcRotpoly
	rts

DOT_FRONT	equ 667
DOT_BACK	equ 446

allblue
	dc.w	$013,$013,$013,$013,$013,$013,$013,$013,$013,$013,$013,$013,$013,$013,$013,$013

dots_vbl_out
	addq.w	#1,$466.w
	move.l	screenpointer,$ffff8200
	subq.w	#1,.waiter
	bge		.kk
		move.w	#1,.waiter
		lea		$ffff8240,a0
		lea		allblue,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.kk
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	d0,screenpointer2

	move.l	vertexloc_pointer,d0
	move.l	vertexloc2_pointer,vertexloc_pointer
	move.l	d0,vertexloc2_pointer

	jsr		clearPixels
	jsr		plotPrecalc

	rts
.waiter	dc.w	0

dots_vbl
	addq.w	#1,$466.w
	move.l	screenpointer,$ffff8200
	move.w	#$001,$ffff8240
	move.w	#$677,$ffff8240+1*2
	move.w	#$455,$ffff8240+2*2
	move.w	#$677,$ffff8240+3*2
	move.w	#$233,$ffff8240+4*2
	move.w	#$677,$ffff8240+5*2
	move.w	#$677,$ffff8240+6*2
	move.w	#$677,$ffff8240+7*2

	move.w	#$012,$ffff8240+8*2
	move.w	#$011,$ffff8240+9*2
;	move.w	#$047,$ffff8240+10*2
	move.w	#$035,$ffff8240+10*2
;	move.w	#$135,$ffff8240+11*2
	move.w	#$124,$ffff8240+11*2
	move.w	#$777,$ffff8240+12*2
	move.w	#$124,$ffff8240+13*2
	move.w	#$012,$ffff8240+14*2
	move.w	#$012,$ffff8240+15*2

;	move.w	#$021,$ffff8240+8*2
;	move.w	#$011,$ffff8240+9*2
;	move.w	#$074,$ffff8240+10*2
;	move.w	#$153,$ffff8240+11*2
;	move.w	#$777,$ffff8240+12*2
;	move.w	#$142,$ffff8240+13*2
;	move.w	#$021,$ffff8240+14*2
;	move.w	#$021,$ffff8240+15*2	



	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	d0,screenpointer2


	move.l	vertexloc_pointer,d0
	move.l	vertexloc2_pointer,vertexloc_pointer
	move.l	d0,vertexloc2_pointer


	tst.w	rotationPrecalcDone
	bne		.notDone
;		moveq	#0,d0
;		move.w	$466.w,d0
;		move.b	#0,$ffffc123
		jsr		clearPixels
		jsr		plotPrecalc
.notDone
	IFNE	DOTS_PRECALC
	jsr		doRotationPoly
	ENDC

;	move.w	#$020,$ffff8240

	rts
xtaboff	dc.w	1280

sinBsinC	dc.w	0
cosAcosC	dc.l	0
sinAcosC	dc.l	0

;_sinA_		equr d1
;_cosA_		equr d2
;_sinB_		equr d3
;_cosB_		equr a2
;_sinC_		equr d5
;_cosC_		equr d6

	IFEQ	tabset
	ELSE
doRotationPoly
	ENDC

doRotationPoly2
    move.w  #256*2,d7									;8
	moveq	#0,d2

    move.w  currentStepY,d4								;16
    add.w   stepSpeedY,d4								;16
    cmp.w   d7,d4										;4
    blt     .goodY										;12
        sub.w   d7,d4									;4
.goodY
    move.w  d4,currentStepY								;16		--> 68

	moveq	#0,d6

;;;;;;;;;;;;;;;;;; ANGULAR SPEEDS DONE ;;;;;;;;;;;;;;;;;;

.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		sintable1,a0								;12
	lea		sintable1+128,a1							;12

	and.w	#%1111111111111110,d4

;	move.w	(a0,d2.w),d1					;0 sin(A)	;around z axis		16		CONST
;	move.w	(a1,d2.w),d2					;1 cos(A)						16		CONST

	move.w	(a0,d4.w),d3					; sin(B)	;around y axis		16
	move.w	(a1,d4.w),d4					; cos(B)						16

;	move.w	(a0,d6.w),d5					;0 	sin(C)	;around x axis		16		CONST
;	move.w	(a1,d6.w),d6					;1	cos(C)						16		CONST
	;xx = [cos(A)cos(B)]
.xx
	move.w	d4,a2

	;xy = [sin(A)cos(B)]
.xy
	sub.w	a1,a1															; ------> 74

	;xz = [sin(B)]	sB
.xz
	move.w	d3,a0						;						4
															; ------> 4
	;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
.yx
	sub.w	a3,a3

	;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
.yy
	move.w	#$7f,d7
	neg.w	d7
	move.w	d7,a4

	;yz = [-cos(B)sin(C)]
.yz
	sub.w	a6,a6											; ------> 80
															;--------------------> 100 + 156 + 88 + 74 + 4 + 200 + 204 + 80 = 906
	;zx = [sin(A)sin(C) - cos(A)sin(B)cos(C)]
.zx
	move	d3,d7
	neg.w	d7

;	;zy = [-cos(A)sin(C) - sin(A)sin(B)cos(C)]
.zy
	sub.w	d3,d3
;;;;;;;;;;;;;;;;;; CONSTANTS DONE ;;;;;;;;;;;;;;;;;;

.setupComplete


xxxzz
	IFEQ	DO_LOW_MEMORY
		jmp		doLowMemoryRotation
	ENDC



COLOR_3	equ 0

doColor	macro
	IFEQ	COLOR_3	
	cmp.w	#$110,d2
	blt		.next\@
		sub.w	d6,d6
		jmp		.done\@
.next\@
	cmp.w	#$f0,d2
	blt		.next2\@
		move.w	#2,d6
		jmp		.done\@
.next2\@
		move.w	#4,d6

.done\@
	ELSE

	cmp.w	#$118,d2
	blt		.next\@
		sub.w	d6,d6
		jmp		.done\@
.next\@
	cmp.w	#$f0,d2
	blt		.next2\@
		move.w	#2,d6
		jmp		.done\@
.next2\@
	cmp.w	#$c8,d0
	blt		.next3\@
		move.w	#4,d6
		jmp		.done\@
.next3\@
		move.w	#6,d6
.done\@


	ENDC
	endm


doLowMemoryRotation
	move.l	logpointer,a5		;20

	move.w	a2,d0 ;xx			;4
	add.w	d0,d0				;4
	move.w	(a5,d0.w),d0
	move.w	d0,axx+2
	move.w	d0,bxx+2
;	move.w	d0,axxp2+2

	move.w	a0,d0	;xz			;4
	add.w	d0,d0				;4
	move.w	(a5,d0.w),d0
	move.w	d0,axz+2
	move.w	d0,bxz+2
;	move.w	d0,axzp2+2

	move.w	a4,d0	;yy			;4
	add.w	d0,d0				;4
	move.w	(a5,d0.w),d0
	move.w	d0,ayy+2
	move.w	d0,byy+2
;	move.w	d0,ayyp2+2

	move.w	d7,d0	;zx
	add.w	d0,d0
	move.w	(a5,d0.w),d0
	move.w	d0,azx+2
	move.w	d0,bzx+2
;	move.w	d0,azxp2+2

	move.w	d4,d0	;zz
	add.w	d0,d0
	move.w	(a5,d0.w),d0
	move.w	d0,azz+2
	move.w	d0,bzz+2
;	move.w	d0,azzp2+2



rotateLowMem
	move.l	currentObject,a5					; 20

	move.l	currentOffsetPtr,a6
	move.l	currentMaskPtrx,a4
	add.l	precalcOff,a6
	IFEQ	DO_COMPRESSION
	move.l	precalcOff,d7
	lsr.l	#1,d7
	add.l	d7,a4
	ELSE
	add.l	precalcOff,a4
	ENDC
	add.l	#2*NR_VERTICES,precalcOff

	move.l	number_of_vertices,d7				; 20
	lsr.w	#1,d7
	subq	#1,d7								; 4

	move.l	x_block_add_pointer,a2
	move.l	a2,usp
	move.l	y_block_pointer,a3
	move.l	expointernorm,d4
	move.l	logpointer,d5
	; in use:
	;	a0-a2, a4,5,a6
	;	a3 free
loopp
	movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
azx move.w	1234(a0),d1	;12			; z*zx ... +
azz add.w	1234(a2),d1	;12			; z*zz						
axx move.w	1234(a0),d0	;12			; x*xx ... +
axz add.w	1234(a2),d0	;12			; x*xz
	
	move.l	zpointer,a2
	move.w	(a2,d1.w),d2
	move.w	d2,d3
			doColor
;	move.l	logpointer,a2
	move.l	d5,a2
	add.w	(a2,d0.w),d2
ayy move.w	1234(a1),d0	;12			; y*zy ... +
	add.w	(a2,d0.w),d3

;	move.l	expointernorm,a2
	move.l	d4,a2
	move.w	(a2,d3.w),d3
	add.w	#98*4,d3

	move.w	(a2,d2.w),d2
	add.w	#160*4,d2			; add xoffset

;	move.l	y_block_pointer,a3
	add.w	(a3,d3.w),d6

	move.l	usp,a2
	add.w	d2,a2
	add.w	(a2)+,d6

	move.w	d6,(a6)+				; offset
	move.b	(a2)+,(a4)+


	movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
bzx move.w	1234(a0),d1	;12			; z*zx ... +
bzz add.w	1234(a2),d1	;12			; z*zz						
bxx move.w	1234(a0),d0	;12			; x*xx ... +
bxz add.w	1234(a2),d0	;12			; x*xz
	
	move.l	zpointer,a2
	move.w	(a2,d1.w),d2
	move.w	d2,d3
			doColor
;	move.l	logpointer,a2
	move.l	d5,a2
	add.w	(a2,d0.w),d2
byy move.w	1234(a1),d0	;12			; y*zy ... +
	add.w	(a2,d0.w),d3

;	move.l	expointernorm,a2
	move.l	d4,a2
	move.w	(a2,d3.w),d3
	add.w	#98*4,d3

	move.w	(a2,d2.w),d2
	add.w	#160*4,d2			; add xoffset

;	move.l	y_block_pointer,a3
	add.w	(a3,d3.w),d6

	move.l	usp,a2
	add.w	d2,a2
	add.w	(a2)+,d6

	move.w	d6,(a6)+				; offset
	move.b	(a2)+,(a4)+

	dbra	d7,loopp

	rts


_direction	dc.w	1

plotPrecalc
	move.l	currentOffsetPtr,a0
	add.l	.frameOff,a0

	move.l	currentMaskPtrx,a1		;	masks
	IFEQ	 DO_COMPRESSION
	move.l	.frameOff,d0
	lsr.l	#1,d0
	add.l	d0,a1
	ELSE
	add.l	.frameOff,a1
	ENDC

	tst.w	_direction
	bgt		.doadd
.dosub
	sub.l	#2*NR_VERTICES,.frameOff
	bge		.okk
		move.l	#2*NR_VERTICES*31,.frameOff
	jmp		.okk

.doadd
	add.l	#2*NR_VERTICES,.frameOff
	cmp.l	#2*NR_VERTICES*32,.frameOff
	bne		.okk
		move.l	#0,.frameOff
.okk
	move.l	vertexloc2_pointer,a2
	move.l	screenpointer2,d7

	move.w	#10-1,.times
.loop
	REPT	NR_VERTICES/70						;2896/70=41		41*7*8= 2296
		IFEQ	DO_COMPRESSION
			REPT 7
				move.b	(a1)+,d0		;7*8 = 56				41*56=	
				move.w	(a0)+,d7
				move.l	d7,a6
				or.b	d0,(a6)
			ENDR
		ELSE
		movem.w	(a1)+,d0-d6			; 410 7*8 =56 vs 24+16 = 40, 16 diff 410*16= 12.8 scanlines, 13 scanline nops

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d0,(a6)

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d1,(a6)

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d2,(a6)

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d3,(a6)

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d4,(a6)

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d5,(a6)

		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d6,(a6)
		ENDC
	ENDR
	subq.w	#1,.times
	bge		.loop

	REPT	NR_VERTICES-41*70			;724*4=  2896-2870 = 26*8= 208
		IFEQ	DO_COMPRESSION
				move.b	(a1)+,d0
				move.w	(a0)+,d7
				move.l	d7,a6
				or.b	d0,(a6)
		ELSE
		move.w	(a1)+,d0
		move.w	(a0)+,d7
		move.l	d7,a6
		or.w	d0,(a6)
		ENDC
	ENDR


	rts
.frameOff	dc.l	0
.times		dc.w	0

		

clearPixels:
	; ----- START CLEAR CUBE VERTICES -----
	move.l	vertexloc2_pointer,a0			; 20 cycles, first clear the star, load its address
	moveq.l	#0,d0
	move.l	screenpointer2,d1

	IFEQ	DOTS_PRECALC
	move.l	currentOffsetPtr,a0
	add.l	clearFrameOff,a0

	tst.w	_direction
	bgt		.doadd
.dosub
	sub.l	#2*NR_VERTICES,clearFrameOff
	bge		.okk
		move.l	#2*NR_VERTICES*31,clearFrameOff
		jmp		.okk

.doadd
	add.l	#2*NR_VERTICES,clearFrameOff
	cmp.l	#2*NR_VERTICES*32,clearFrameOff
	bne		.okk
		move.l	#0,clearFrameOff
.okk

	ENDC


	move.l	number_of_vertices,d7
	asr.l	#6,d7
	beq		.dorest
	subq	#1,d7
.clear64
	REPT 64
		move.w	(a0)+,d1		; 8					; 20 per
		move.l	d1,a1			; 4

		IFEQ	DO_COMPRESSION
		move.b	d0,(a1)
		ELSE
		move.w	d0,(a1)
		ENDC
	ENDR
	dbra	d7,.clear64

.dorest
	move.l	number_of_vertices,d7
	and.l	#%111111,d7
	beq		.end
	subq	#1,d7
.clear
		move.w	(a0)+,d1		; 8					; 20 per
		move.l	d1,a1			; 4
		IFEQ	DO_COMPRESSION
		move.b	d0,(a1)
		ELSE
		move.w	d0,(a1)
		ENDC
	dbra	d7,.clear
.end
		rts
clearFrameOff	dc.l	2*NR_VERTICES*30


initZTable
	IFEQ	DO_LOW_MEMORY
	move.l	zpointer,a0
	move.l	a0,a1

	moveq	#0,d1

	move.w	#512-1,d7

	move.l	#pers<<7,d3
	move.l	#pers,d5

	moveq	#-4,d6

.loop
		move.l	d1,d4
		add.w	d5,d4		;8
		move.l	d3,d2		;12
		divs.w	d4,d2			;146
		add.w	d2,d2
		move.w	d2,(a0)+
		addq.w	#2,d1

		move.l	d6,d4
		add.w	d5,d4
		move.l	d3,d2
		divs.w	d4,d2
		add.w	d2,d2
		move.w	d2,-(a1)

		subq.w	#2,d6

	dbra	d7,.loop

	rts

	ELSE
	move.l	zpointer,d0
	move.l	d0,a0

	moveq	#0,d1

	move.w	#512-1,d7

	move.l	#pers<<7,d3
	move.l	#pers,d5

	moveq	#-4,d6
	move.w	#-2,d0
	move.l	d0,a1

.loop
		move.l	d1,d4
		add.w	d5,d4		;8
		move.l	d3,d2		;12
		divs.w	d4,d2			;146
		add.w	d2,d2
		move.w	d2,(a0)+
		addq.w	#2,d1

		move.l	d6,d4
		add.w	d5,d4
		move.l	d3,d2
		divs.w	d4,d2
		add.w	d2,d2
		move.w	d2,(a1)

		sub.w	#2,a1
		subq.w	#2,d6

	dbra	d7,.loop

	rts
	ENDC

init_xblock_aligned
	IFEQ	DO_COMPRESSION
		jmp		initxblockcompression
	ELSE

	move.l	x_block_add_pointer,a1
	lea		1280(a1),a2
	moveq	#0,d1
	moveq	#0,d2
	moveq	#20-1,d7
	lea		heartOffs,a3
	move.w	#$8000,d5


.ol
	moveq	#16-1,d6
	move.w	d5,d0
.il
			move.w	d1,(a1)+
			move.w	d0,(a1)+
			move.w	d2,(a2)+
			move.w	d0,(a2)+
			lsr.w	#1,d0
		dbra	d6,.il
		addq	#8,d1
		addq	#8,d2
	dbra	d7,.ol
	rts
	ENDC


initxblockcompression
	move.l	x_block_add_pointer,a1
	lea		1280(a1),a2
	moveq	#0,d1
	moveq	#0,d2
	moveq	#20-1,d7
	move.w	#$8000,d5
.ol
	move.w	#8-1,d6
	move.w	d5,d0
.il1
		move.w	d1,(a1)+
		move.w	d0,(a1)+
		move.w	d2,(a2)+
		move.w	d0,(a2)+
		lsr.w	#1,d0
		dbra	d6,.il1

	move.w	#8-1,d6
	move.w	d5,d0
	addq.w	#1,d1
	addq.w	#1,d2
.il2
		move.w	d1,(a1)+
		move.w	d0,(a1)+
		move.w	d2,(a2)+
		move.w	d0,(a2)+
		lsr.w	#1,d0
		dbra	d6,.il2
	addq.w	#7,d1
	addq.w	#7,d2
	dbra	d7,.ol
	rts
	




init_yblock_aligned
	move.l	y_block_pointer,a1
	move.l	#200-1,d7
	moveq	#0,d0
	move.w	#160,d6
	swap	d6
	move.w	#160,d6
.loop
	move.l	d0,(a1)+
	add.l	d6,d0
	dbra	d7,.loop
	rts

init_exp_log:
    bsr.s   init_log
    bsr.s   init_exp
    rts

init_log:
	IFNE	DO_LOW_MEMORY
;    lea     log_src,A4    		; skip 0
    move.l	logpointer_src,a4
    move.l  logpointer,d5
    move.l  d5,a2
    moveq   #-2,d6           	; index

    move.w  #-EXPS*2,(A2)+  	; NULL					
    move.w  #LOGS-1-1,D7								; 1024 entries top and bottom
il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0
    	move.w  d0,(a2)+        ; pos2

    	add.w   #EXPS*2,D0      ; NEG

    	move.w  d6,d5           ; take negative value into account
    	move.l  d5,a3
    	move.w  d0,(a3)         ; move in value

    	subq.w  #2,d6
    dbra    D7,il
    rts
    ELSE
	move.l	logpointer_src,a4
	move.l	logpointer,a0
	move.l	a0,a1
	moveq	#-2,d6
	move.w	#-EXPS*2,(a0)+
    move.w  #LOGS-1-1,D7								; 1024 entries top and bottom
.il
		move.w	(a4)+,d0
		add.w	d0,d0
		move.w	d0,(a0)+
		add.w	#EXPS*2,d0
		move.w	d0,-(a1)
	dbra	d7,.il
    rts
    ENDC

init_exp:

    move.w  #EXPS*2,D7						;4096*2 = 8192
    move.l	exppointer_src,a3
;    lea     exp_src,a3

;    move.l  exppointer,a4
 ;   lea     (a4,d7.w),a5
  ;  lea     (a5,d7.w),a6


    move.l	expointernorm,a0
    lea		(a0,d7.w),a1
    lea		(a1,d7.w),a2
    IFEQ	DO_LOW_MEMORY
    neg.w	d7
    lea		(a0,d7.w),a4
    ENDC

    move.w  #EXPS-1,D7
ie:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

    	; this is specific for the rotation code
    	IFNE	z_on
    	asr.w	#2,d0
    	asr.w	#2,d1
    	add.w	d0,d0
    	add.w	d0,d0
    	add.w	d1,d1
    	add.w	d1,d1
		move.w  d0,(a0)+
		move.w  d1,(a1)+
		move.w  d0,(a2)+
		    IFEQ	DO_LOW_MEMORY
		move.w	#0,(a4)+
			ENDC
    	ELSE
  		asr.w	#7,d0		; fix this in exptable
		add.w	d0,d0		; fix this in exptable
		add.w	d0,d0
		asr.w	#7,d1		; fix this in exptable
		add.w	d1,d1		; fix this in exptable
		add.w	d1,d1
		; end specific code
		ENDC
;;		move.w  d0,(a4)+
;		move.w  d1,(a5)+
;		move.w  d0,(a6)+

    dbra    D7,ie


init_exp2:
	lea		$3000,a0
	moveq	#0,d0
.cl
		move.l	d0,(a0)+
		cmp.w	#$5000,a0
		bne		.cl

    move.w  #EXPS*2,D7
    move.l	exppointer_src,a3
;    lea     exp_src,a3

    lea  	$5000,a4
    lea     (a4,d7.w),a5
    lea     (a5,d7.w),a6
    move.w	#-4,d3

    move.w  #EXPS-1,D7
ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

    	; this is specific for the rotation code
    	IFEQ	tabset
  		asr.w	#4,d0		; fix this in exptable
		asr.w	#4,d1		; fix this in exptable
		ELSE
		asr.w	#5,d0
		asr.w	#5,d1
		ENDC
		and.w	d3,d0
		and.w	d3,d1

		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+

    dbra    D7,ie2


    ; range 1000 to B000
    rts


init_object
	IFEQ	DO_LOW_MEMORY
	move.l	currentObject,a0
	move.l	a0,a1
	move.l	logpointer,a2
	move.l	#max_nr_of_vertices,d7
	subq.l	#1,d7
	move.w	#$5000,d0						; base address of low memory
.loop
	REPT 3
		move.w	(a0)+,d6
		add.w	d6,d6
		move.w	(a2,d6.w),d1
		add.w	d0,d1
		move.w	d1,(a1)+
	ENDR

	dbra	d7,.loop
	rts

	ELSE
	move.l	currentObject,a0
	move.l	a0,a1
	move.l	logpointer,d6
	move.l	#max_nr_of_vertices,d7
	subq.l	#1,d7
	move.w	#$5000,d0						; base address of low memory

.loop
	REPT 3
		move.w	(a0)+,d6
		add.w	d6,d6
		move.l	d6,a2
		move.w	(a2),d1
		add.w	d0,d1
		move.w	d1,(a1)+
	ENDR

	dbra	d7,.loop
	rts
	ENDC


storeLowerMem
	lea		$3000,a0
	move.l	oldLowerPtr,a1
;	lea		lowermem,a2
.m
	REPT 16
		move.l	(a0)+,(a1)+
	ENDR
	cmp.l	#$B000,a0
	bne		.m
	move.w	#1,do_restoremem
	rts

restoreLowerMem
	tst.w	storeLowerMem
	beq		.no
	move.l	oldLowerPtr,a0
;	lea		lowermem,a2
	lea		$3000,a1
.m
	REPT 16
		move.l	(a0)+,(a1)+
	ENDR
	cmp.l	#$B000,a1
	bne		.m
	move.w	#0,do_restoremem
.no
	rts



;	SECTION data

;tree
;	incbin	'rotate/tree.bin'
;	include	'rotate/tree2.s'

treecrk
;	include	'rotate/tree3.s'
	incbin	'rotate/treefin.crk'
	even
ornaments	incbin	'rotate/ornaments2.crk'
	even

;deer
;	incbin	'rotate/deer.bin'
;	include	'rotate/dots4.s'

;
;.xstart	set 3
;.ystart	set -91
;.xinc	set 6
;.yinc	set 7
;
;
;.z set 0
;
;.y set .ystart				;-80
;	REPT SIZE+1
;.x set .xstart
;		REPT SIZE
;			dc.w	.x,.y,.z
;.x set .x+.xinc
;		ENDR
;.y set .y+.yinc				;7
;	ENDR
;
;.y set .ystart
;	REPT SIZE+1
;.x set -.xstart
;		REPT SIZE
;			dc.w	.x,.y,.z
;.x set .x-.xinc
;		ENDR
;.y set .y+.yinc
;	ENDR	
;
;
;.x set 0
;.y set .ystart
;	REPT SIZE+1
;.z set .xstart
;		REPT SIZE
;			dc.w	.x,.y,.z
;.z set .z+.xinc
;		ENDR
;.y set .y+.yinc
;	ENDR
;
;
;.x set 0
;.y set .ystart
;	REPT SIZE+1
;.z set -.xstart
;		REPT SIZE
;			dc.w	.x,.y,.z
;.z set .z-.xinc
;		ENDR
;.y set .y+.yinc
;	ENDR

;rotateLeft	incbin	'rotate/ornament_left2.neo'

sintable1:
	include	'rotate/sin_ampl_127_steps_256.s'


currentOffsetPtr		ds.l	1
currentMaskPtrx			ds.l	1

myPrecalcPtr	ds.l	1
myPrecalc2Ptr	ds.l	1

myPrecalc3Ptr	ds.l	1
myPrecalc4Ptr	ds.l	1

precalcOff	dc.l	0

y_block_pointer					ds.l	1
logpointer_src					ds.l	1
exppointer_src					ds.l	1
logpointer						ds.l	1
exppointer						ds.l	1
x_block_add_pointer				ds.l	1
zpointer						ds.l	1
expointernorm					ds.l	1
do_restoremem					ds.w	1
currentStepX            		ds.w    1
currentStepY            		ds.w    1
currentStepZ            		ds.w    1
stepSpeedX              		ds.w    1
stepSpeedY              		ds.w    1
stepSpeedZ              		ds.w    1
vertexloc_pointer				ds.l	1
vertexloc2_pointer				ds.l	1
number_of_vertices				ds.l	1
currentObject					ds.l	1
vertices_xoff					ds.w	1
vertices_yoff					ds.w	1
oldLowerPtr						ds.l	1
	even
;	SECTION text

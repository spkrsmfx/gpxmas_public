; make sure we draw line from attachment to top ball
;	- need to know x,y of first projected vertex
;	pipeline:
;	- determine angle (fixed point, ball position)
;	- rotate and plot ball
;	- determine first vertex
;	- draw line

_sintable_ball_size_tridi		equ	1024*2				; 512 entries of wordsize

_currentVerticesBall			equ $c000

longballs						equ 1

max_number_vertices		equ 190
USE_PERSPECTIVE			equ 1
OPT_BACKFACE			equ	1


PERSPECTIVE				equ	1190		equ 1190				; yes, distance for perspective
scanLineWidth			equ 160
;LOGS            		EQU 1024
;EXPS           		 	EQU 4096*2
pivotexp            	equ $2300



										;3360	336000
    section	TEXT

drawBackground
maskCorners2
;	lea		mask+128,a0
;	lea		maskBuffer,a1
;	jsr		cpMask
;	add.w	#152,a0
;	jsr		cpMask
;	add.w	#186*160-152,a0
;	jsr		cpMask
;	add.w	#152,a0
;	jsr		cpMask
;
;	lea		maskBuffer,a0
;	move.b	#0,$ffffc123


	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	moveq	#-1,d6
	move.w	#200-1,d7
.cpr
.y set 0
		REPT 20
			move.w	d6,4+.y(a0)
			move.w	d6,4+.y(a1)
.y set .y+8
		ENDR
		add.w	#160,a0
		add.w	#160,a1
	dbra	d7,.cpr

	move.l	screenpointer,a0
	move.l	screenpointer2,a1

	lea		maskBuffer,a2
	lea		.offlist,a3
	move.w	#4-1,d7
.cp
.y set 0
	REPT 14
		move.w	(a2)+,d0
		move.w	d0,4+.y(a0)
		move.w	d0,4+.y(a1)

.y set .y+160
	ENDR
	add.w	(a3),a0
	add.w	(a3)+,a1
	dbra	d7,.cp

;	lea		floor,a0
	move.l	floorptr,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	add.w	#155*160,a1
	add.w	#155*160,a2
	move.w	#45-1,d7
.dldl
.x set 0
	REPT 20
		move.w	(a0)+,d0
		move.w	d0,.x(a1)
		move.w	d0,.x(a2)
.x set .x+8
	ENDR
	lea		160(a1),a1
	lea		160(a2),a2
	dbra	d7,.dldl

	rts
.offlist
	dc.w	152
	dc.w	-152+186*160
	dc.w	152
	dc.w	0

;cpMask
;.y set 0
;	REPT 14
;		move.w	.y(a0),(a1)+
;.y set .y+160
;	ENDR
;	rts

maskBuffer	incbin	"balls/masks.bin"			; 4*14*2	112

;mask	incbin	"balls/mask.neo"
ttn	dc.w	0
balls_vbl_out
	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
	subq.w	#1,ttn
	bge		.skip
	move.w	#2,ttn
	lea		$ffff8240,a0
	lea		tunnelWhite,a1
	lea		$ffff8240,a2
	move.w	#16,d0
	jsr		fade_st
.skip
	jmp		bc

balls_vbl
	addq.w	#1,$466.w
	move.l	screenpointer2,$ffff8200
	move.w	#$013,$ffff8240
	move.w	#$137,$ffff8240+2*1
	move.w	#$707,$ffff8240+2*2
	move.w	#$115,$ffff8240+2*4
	move.w	#$147,$ffff8240+2*5
bc
	jsr		clearDots						; clear ALL dots
	jsr		changeBallsPosition				; move their x,y,z position
	jsr		determineAngles					; then determine angle based on the fixed point

	tst.w	_vertices_zoffBall
	blt		.ball1front
.ball2front
	move.l	clrptr,tmpptr
	jsr		calculateRotatedProjectionExpLogMatrix1		; prepare rotation matrix 1
	jsr		rotateAndDrawVerticesBall1					; rotate and display 1
	jsr		rotateAndStoreVertex1Ball1
	jsr		drawLine
	move.l	a0,tmpptr

	jsr		calculateRotatedProjectionExpLogMatrix2		; prepare rotation matrix 1
	jsr		rotateAndStoreVertex1Ball2
	jsr		drawLine
	move.w	#-1,(a0)
	jsr		applyMask2
	jsr		rotateAndDrawVerticesBall2					; rotate and display 1
	jmp		.cont
.ball1front
	move.l	clrptr,tmpptr
	jsr		calculateRotatedProjectionExpLogMatrix2		; prepare rotation matrix 1
	jsr		rotateAndDrawVerticesBall2					; rotate and display 1
	jsr		rotateAndStoreVertex1Ball2
	jsr		drawLine
	move.l	a0,tmpptr

	jsr		calculateRotatedProjectionExpLogMatrix1		; prepare rotation matrix 1
	jsr		rotateAndStoreVertex1Ball1
	jsr		drawLine
	move.w	#-1,(a0)
	jsr		applyMask1
	jsr		rotateAndDrawVerticesBall1					; rotate and display 1
.cont

	move.l	clrptr,d0
	move.l	clrptr2,clrptr
	move.l	d0,clrptr2

; in use:
;	a0: locpointer
;	a1: screen
;	a2:	multable
;	a3:	local smc reg
;	a4: divtable
;	a5: not used
;	a6: mask and offset table

;	jsr		calculateRotatedProjectionExpLogMatrix3
;	jsr		moveObject3
;	jsr		calculateRotatedProjectionExpLog3

	move.l	vertexLocPointer2,d0
	move.l	vertexLocPointer,vertexLocPointer2
	move.l	d0,vertexLocPointer

	move.l	screenpointer2,d0
	move.l	screenpointer,screenpointer2
	move.l	d0,screenpointer


;	move.w	#$002,$ffff8240
	rts
lineLoc	dc.w	70*4,100*4,160*4,0*4
clearLog1	dc.w	-1
			ds.w	300
clearLog2	dc.w	-1
			ds.w	300
clrptr		dc.l	clearLog1
clrptr2		dc.l	clearLog2

ball2front	dc.w	0


applyMask1
	move.w	_vertices_xoffBall,d0
	move.w	_vertices_yoffBall,d1
	jmp		applyMask


applyMask2
	move.w	_vertices_xoff2Ball,d0
	move.w	_vertices_yoff2Ball,d1


applyMask
	move.l	screenpointer2,a0
	move.l	ballMasksPtr,a1
	move.l	ballposptr,a2



	sub.w	#54*4,d1
	muls	#40,d1
	sub.w	#54*4,d0
	add.w	d1,a0
	add.w	d0,a2
	add.w	(a2)+,a0
	add.w	(a2)+,a1
	move.w	#109-1,d7
.ol
.x set 0
	REPT 8
		move.w	(a1)+,d0
		not.w	d0
		and.w	d0,.x(a0)
.x set .x+8
	ENDR
		lea		160(a0),a0
	dbra	d7,.ol
	rts



drawLine

;	not.w	$ffff8240
	lea		lineLoc,a0
	move.l	screenpointer2,a1
	move.l	multabPtr,a2
	lea		fake,a3
    move.l	lineDivTableptr,a4
	move.l	maskAndOffTabPtr,a6
	jsr		bellman_draw_line
	move.w	d0,(a3)
;	move.w	#-1,(a0)
;	not.w	$ffff8240
	; here we save addresses for DDA
	;d0: obj x
	;d1: obj y
	;d2; fix x
	;d3; fix y

	rts
tmpptr	dc.l	0


balls_init
	lea		rape,a0
	move.w	#$4e71,(a0)+
	move.w	#$4e71,(a0)+
	move.w	#$4e71,(a0)+
	move.w	#$4e71,(a0)+
	move.w	#$4e71,(a0)+
	move.l  #memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer								;1
		move.l	d0,d1
		add.l	#$8000+2048,d1
		move.l	d1,logpointer_src
		add.l	#8196,d1
		move.l	d1,exppointer_src
		add.l	#8196,d1

	add.l	#$10000,d0
	move.l	d0,screenpointer2								;2
		move.l	d0,d1
		add.l	#$8000,d1
	add.l	#$10000,d0				

	move.l	d0,y_block_pointer2								;3
		move.l	d0,d1
		add.l	#8192,d1
		move.l	d1,projectedVerticesBallPtr
		add.l	#8000,d1
		move.l	d1,vertexLocPointer
		add.l	#4000,d1
		move.l	d1,vertexLocPointer2
		add.l	#4000,d1
		move.l	d1,clearDotCodePointer
	add.l	#$10000,d0		
	move.l	d0,explog_logpointerBall							;4
	add.l	#$10000,d0
	move.l	d0,explog_expointerBall					
	move.l	d0,d1
	add.l	#4000+4000+8192+8000,d1
		move.l	d1,x_table_pointerBall
		add.l	#12000,d1
		move.l	d1,ballMasksPtr
	add.l	#$10000,d0
	move.l	d0,zpointer
	add.l	#$10000,d0

		move.l	d0,d1
		move.l	d1,v_45_90ptr
		add.l	#2802+1000,d1				;2882
		move.l	d1,v_m45_m90ptr
		add.l	#2802+1000,d1				;5764
		move.l	d1,v_0_45ptr
		add.l	#3842+1000,d1				;
		move.l	d1,v_m0_m45ptr
		add.l	#3842+1000,d1
		move.l	d1,v_45ptr
		add.l	#3202+1000,d1
		move.l	d1,v_m45ptr
		add.l	#3202+1000,d1				;19852
		move.l	d1,lineDivTableptr		;28044
		add.l	#128*128*2,d1				;8192
		move.l	d1,multabPtr
		add.l	#400,d1
		move.l	d1,maskAndOffTabPtr
		add.l	#640*2,d1
		move.l	d1,floorptr
		add.l	#1800,d1
;		move.l	d1,ballMasksPtr
;		add.l	#16*1512,d1
		move.l	d1,ballposptr
		add.l	#1280,d1	

;	move.l	d0,clearDotCodePointer
;	add.l	#$10000,d0
;	move.l	d1,d2
;	sub.l	#memBase,d2
;	move.b	#0,$ffffc123
	move.l	d1,memStore

	move.l	screenpointer,a0
	move.l	#$8000,d0
	jsr		fast_clear
	move.l	screenpointer2,a0
	move.l	#$8000,d0
	jsr		fast_clear


	jsr		storeLowerMemoryBalls

	lea		ballmask,a0
	move.l	ballMasksPtr,a1
	jsr		cranker

	lea		floor,a0
	move.l	floorptr,a1
	jsr		cranker

	lea		logcrk,a0
	move.l	logpointer_src,a1
	jsr		cranker

	lea		expcrk,a0
	move.l	exppointer_src,a1
	jsr		cranker

;	move.l	#vertexLocs,vertexLocPointer
;	move.l	#vertexLocs2,vertexLocPointer2
	lea		_currentVerticesBall,a0
	moveq	#0,d0
	move.w	#max_number_vertices*2*3-1,d7
.c
		move.l	d0,(a0)+
	dbra	d7,.c


	move.l	explog_logpointerBall,a0
	move.l	explog_expointerBall,a1
	move.l	x_table_pointerBall,a2
	moveq	#0,d0
	move.w	#65536/4/4/4-1,d7
.ll
		move.l	d0,(a0)+
		move.l	d0,(a1)+
		move.l	d0,(a2)+
	dbra	d7,.ll


	move.w	#max_number_vertices,number_of_vertices_ball

	jsr		_init_exp_log
	jsr		init_xblock_alignedBall
 	jsr		init_yblock_aligned2
	jsr		init_vertices
	jsr		generateClearDotsCode
	jsr		initZpointer
	jsr		bellman_init_line
	jsr		initLineDivTable
	jsr		genMulTab
	jsr		genMaskAndOffTab
	jsr		shiftBallMask
	jsr		genBallPos

	jsr		drawBackground
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
;	lea		floorbuffer,a3
;	lea		floor+128,a2
;	add.w	#155*160,a0
;	add.w	#155*160,a1
;	move.w	#45-1,d7
;.cp
;.x set 0
;	REPT 20
;		move.w	.x(a2),(a3)+
;.x set .x+8
;	ENDR
;		lea		160(a2),a2
;		dbra	d7,.cp
;		lea		floorbuffer,a0
;		move.b	#0,$ffffc123		;1800


;	lea		ballmask+128,a0
;	lea		ballmaskbuffer,a1
;	move.w	#109-1,d7
;.cp	
;.x set 0
;		REPT 8
;			move.w	.x(a0),(a1)+
;.x set .x+8
;		ENDR
;		lea		160(a0),a0
;
;	dbra	d7,.cp
;
;	lea		ballmaskbuffer,a0
;	move.b	#0,$ffffc123
	move.w	#$4e75,balls_init
	rts
floor	incbin	"balls/floor2.crk"
	even
floorptr	dc.l	0	
;floorbuffer	ds.b	45*40

xmov	include		"balls/xmove.s"
zmov	include		"balls/zmove.s"
ballmask	incbin	"balls/ballmask.crk"		;1512
	even
;ballmaskbuffer	ds.b	109*2*8			;1512

shiftBallMask
	move.l	ballMasksPtr,a0
	lea		109*8*2(a0),a1
	move.w	#15-1,d7
.ol
		move.w	#109-1,d6
.shift
		movem.l	(a0)+,d0-d3
		asr.l	d0
		roxr.l	d1
		roxr.l	d2
		roxr.l	d3
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.l	d3,(a1)+


		dbra	d6,.shift
	dbra	d7,.ol
	rts

ballposptr	dc.l	0		; 1280

genBallPos
	move.l	ballposptr,a0
	move.w	#20-1,d7
	moveq	#0,d0			;.o
	move.w	#1744,d2		;off
.ol
		move.w	#16-1,d6
		moveq	#0,d1			;.x
.il
			move.w	d0,(a0)+
			move.w	d1,(a0)+
			add.w	d2,d1
		dbra	d6,.il
		addq.w	#8,d0

	dbra	d7,.ol
	rts

ballMasksPtr	dc.l	0

changeBallsPosition
	; placeholder, this should be pendulums and shit
		lea		xmov,a0
		add.w	.xmovoff,a0
		move.w	(a0),_vertices_xoffBall
		add.w	#2,.xmovoff
		cmp.w	#140*2,.xmovoff
		bne		.kk
			move.w	#0,.xmovoff
.kk

		lea		zmov,a0
		add.w	.zmovoff,a0
		move.w	(a0),_vertices_zoffBall
		add.w	#2,.zmovoff
		cmp.w	#140*2,.zmovoff
		bne		.kk2
			move.w	#0,.zmovoff
.kk2


		lea		xmov,a0
		add.w	.xmovoff2,a0
		move.w	(a0),_vertices_xoff2Ball
		add.w	#2,.xmovoff2
		cmp.w	#140*2,.xmovoff2
		bne		.kk3
			move.w	#0,.xmovoff2
.kk3

		lea		zmov,a0
		add.w	.zmovoff2,a0
		move.w	(a0),_vertices_zoff2Ball
		add.w	#2,.zmovoff2
		cmp.w	#140*2,.zmovoff2
		bne		.kk4
			move.w	#0,.zmovoff2
.kk4


;xsmd	move.w	#70*4,_vertices_xoffBall
;		move.w	#100*4,_vertices_yoffBall	
;zsmd	move.w	#80*4,_vertices_zoffBall
;
;xsmd2	move.w	#150*4,_vertices_xoff2Ball
;		move.w	#140*4,_vertices_yoffBall
;		move.w	#0,_vertices_zoff2Ball


		move.w	#0,_currentStepXBall
		move.w	#0,_currentStepYBall
		move.w	#0,_currentStepZBall

		move.w	#0,_currentStepX2Ball
		move.w	#0,_currentStepY2Ball
		move.w	#0,_currentStepZ2Ball

;		add.w	#4,xsmd+2
;		add.w	#4,zsmd+2

	rts
.xmovoff	dc.w	0
.zmovoff	dc.w	0
.xmovoff2	dc.w	70*2
.zmovoff2	dc.w	70*2

determineAngles
	move.w	_vertices_xoffBall,d0
	move.w	thread_x,d2
    jsr		fixAngle
	move.w	d1,_currentStepXBall

	move.w	_vertices_zoffBall,d0				;0
	move.w	thread_z,d2
    jsr		fixAngle
	move.w	d1,_currentStepZBall

	move.w	_vertices_xoff2Ball,d0
	move.w	thread_x,d2
    jsr		fixAngle
	move.w	d1,_currentStepX2Ball

	move.w	_vertices_zoff2Ball,d0				;0
	move.w	thread_z,d2
    jsr		fixAngle
	move.w	d1,_currentStepZ2Ball



	rts


thread_x dc.w	160
thread_y dc.w	0
thread_z dc.w	0

atab	include	"balls/arctan.s"

_vertices_zoffBall	dc.w	0
_vertices_zoff2Ball	dc.w	0


fixAngle
	asr.w	#2,d0
	move.w	_vertices_yoffBall,d1
	asr.w	#2,d1
	move.w	thread_y,d3
	lea		atab,a0

	move.w	#-1,positive
	; we reason from ball to thread
	sub.w	d0,d2				;160-70 = 90
	bge		.positivex
		neg.w	positive
		neg.w	d2
.positivex
	sub.w	d1,d3				;-100				; sign doesnt matter, ebcause ball is always lower then thingie
	bge		.positivey
		neg.w	positive
		neg.w	d3
.positivey


	; slope should be partitioned into 2 parts:
	; dx/dy <= 1
	; dx/dy > 1	
;	cmp.w	d2,d3
;	bgt		.y_over_x
;.x_over_y 	; >
;	; now we can determine slope
;	ext.l	d2
;	asl.l	#8,d2
;	divs	d3,d2
;;	ext.l	d2
;	jmp		.cont



;	rts
;.y_over_x	; < 45'
	ext.l	d2
	asl.l	#8,d2
	divs	d3,d2
	ext.l	d2
.cont
	; we have 256 entries; so 128 is the half
	move.w	#256,d0
	moveq	#0,d1
	add.w	d0,d1
.compare
	move.w	(a0,d1.w),d3
	cmp.w	d3,d2		
	blt		.d1gr
.d1le
		lsr.w	#1,d0
		cmp.w	#1,d0
		beq		.end
		add.w	d0,d1
		jmp		.compare
.d1gr
		lsr.w	#1,d0
		cmp.w	#1,d0
		beq		.end
		sub.w	d0,d1
		jmp		.compare
.end
	; now d1 is index
;	move.w	(a0,d1.w),d0
	tst.w	positive
	bge		.okxx
		neg.w	d1
		add.w	#2048,d1
.okxx

;	add.w	#4*1,xsmd+2
	rts
.step	dc.w	0

positive	dc.w	0


_vertices_xoff_direction	dc.w	-1
_vertices_yoff_direction	dc.w	1

_vertices_xoff_direction2	dc.w	1
_vertices_yoff_direction2	dc.w	-1

_vertices_xoff_direction3	dc.w	-1
_vertices_yoff_direction3	dc.w	1


ballFadeTabOff	dc.w	0



clearDots
	; first clean the old line
	move.l	clrptr,a0
	move.l	screenpointer2,a1
	moveq	#0,d0
.rego
	REPT 10
	move.w	(a0)+,d1
	blt		.end
		move.w	d0,(a1,d1.w)
	ENDR
	jmp		.rego
.end



	move.l	vertexLocPointer2,a0
	move.w	#0,d0
	move.l	screenpointer2,d1
	move.l	clearDotCodePointer,a6
	jmp		(a6)

;	REPT max_number_vertices
;		move.w	(a0)+,d1	; 8			20 per			movem.l	(a0)+,a1-a7	
;		move.l	d1,a1		; 4							move.w	d0,(a1)
;		move.w	d0,(a1)		; 8		6
;	ENDR
;	rts

clearDotTemplate
		move.w	(a0)+,d1	; 8			20 per			movem.l	(a0)+,a1-a7	
		move.l	d1,a1		; 4							move.w	d0,(a1)
		move.w	d0,(a1)		; 8		6
		move.w	(a0)+,d1	; 8			20 per			movem.l	(a0)+,a1-a7	
		move.l	d1,a1		; 4							move.w	d0,(a1)
		move.w	d0,(a1)		; 8		6											12 size for 2



generateClearDotsCode
	move.l	clearDotCodePointer,a0
	move.l	#clearDotTemplate,a1
	move.w	number_of_vertices_ball,d7
;	move.w	d7,d6
;	asr.w	#1,d6
;	add.w	d6,d7
	sub.w	#1,d7
.l
	move.l	a1,a2
		move.l	(a2)+,(a0)+			;12*190+2	~ 5000
		move.l	(a2)+,(a0)+
		move.l	(a2)+,(a0)+
	dbra	d7,.l
	move.w	#$4e75,(a0)+
	rts



init_yblock_aligned2
	move.l	y_block_pointer2,a1
	move.l	a1,a2
	move.l	#200-1,d7
	moveq	#0,d0
	move.w	#scanLineWidth,d6
	swap	d6
	move.w	#scanLineWidth,d6
.loop
		move.l	d0,(a1)+
;		move.l	d0,(a1)+
		add.l	d6,d0
	dbra	d7,.loop

	add.l	#$10000,a2
	move.w	#$4000,d7
.ll
		move.w	#32002,(a1)+
		move.w	#32002,-(a2)
	dbra	d7,.ll
	rts

init_xblock_alignedBall
	move.l	x_table_pointerBall,a0
	move.w	#3-1,d2
	moveq	#0,d4
.start
	move.l	d4,d0
	move.w	#20-1,d7

.ol
		move.w	#16-1,d6
		move.w	#1<<15,d1
.il
			move.w	d0,(a0)+
			move.w	d1,(a0)+
			lsr.w	#1,d1
		dbra	d6,.il
		addq.w	#8,d0
	dbra	d7,.ol
	add.w	#1280,a0
	addq.w	#2,d4
	dbra	d2,.start
	rts





_sinA_		equr d1
_cosA_		equr d2
_sinB_		equr d3
_cosB_		equr d4
_sinC_		equr d5
_cosC_		equr d6

calculateRotatedProjectionExpLogMatrix3
	movem.w	_currentStepX3Ball,d2/d4/d6
	jmp		entry

calculateRotatedProjectionExpLogMatrix2
	movem.w	_currentStepX2Ball,d2/d4/d6
	jmp		entry

calculateRotatedProjectionExpLogMatrix1
	movem.w	_currentStepXBall,d2/d4/d6
	and.w	#-2,d2
	and.w	#-2,d4
	and.w	#-2,d6

entry
.get_rotation_values_x_y_z								; http://mikro.naprvyraz.sk/docs/Coding/1/3D-ROTAT.TXT
	lea		_sintable_ball,a0
	lea		_sintable_ball+(_sintable_ball_size_tridi/4),a1

	move.w	(a0,d2.w),d1					; _sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; _cosA						16

	move.w	(a0,d4.w),d3					; _sinB	;around y axis		16
	move.w	(a1,d4.w),d4					; _cosB						16

	move.w	(a0,d6.w),d5					; _sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; _cosC						16

	move.l	explog_logpointerBall,d0		;20	

; xx = cos(A) * cos(B)
	move.w	_cosA_,d7
	muls	_cosB_,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_oxx+2
;xy = [sin(A)cos(B)]		
	move.w	_sinA_,d7
	muls	_cosB_,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_oxy+2
;xz = [sin(B)]
	move.w	_sinB_,d0
	asr.w	#7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_oxz+2
;yz = [-cos(B)sin(C)]
	move.w	_cosB_,d7
	neg.w	d7
	muls	_sinC_,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_oyz+2
; zz = [cos(B)cos(C)]
	move.w	_cosB_,d7
	muls	_cosC_,d7
;	move.l	d7,_zz
	swap	d7
;	move.w	d7,_zz
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_ozz+2
;yx = [sin(A)cos(C) + cos(A)sin(B)sin(C)]
	move.w	_sinA_,d4
	muls	_cosC_,d4	
	move.l	d4,a0			; save for zy
	move.w	_cosA_,d7
	muls	_sinB_,d7
	swap	d7
	add.w	d7,d7
	muls	_sinC_,d7
	add.l	d7,d4	
	swap	d4
	asr.w	#6,d4
	move.w	d4,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_oyx+2
;yy = [-cos(A)cos(C) + sin(A)sin(B)sin(C)]
	move.w	_cosA_,d7
	muls	_cosC_,d7
	move.l	d7,a1			; save for zx
	neg.l	d7
	move.w	_sinA_,d4
	muls	_sinB_,d4
	swap	d4
	add.w	d4,d4
	muls	_sinC_,d4
	add.l	d4,d7
	swap	d7
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_oyy+2
;zx = [sin(A)sin(C) - cos(A)sin(B)cos(C)]
	move.w	_sinA_,d7
	muls	_sinC_,d7
	move.l	a1,d4
	swap	d4
	add.l	d4,d4
	muls	_sinB_,d4
	sub.l	d4,d7
;	move.l	d7,_zx
	swap	d7
;	move.w	d7,_zx
	asr.w	#6,d7
	move.w	d7,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_ozx+2
;zy = [-cos(A)sin(C) - sin(A)sin(B)cos(C)]
	move.w	_cosA_,d4
	neg.w	d4
	muls	_sinC_,d4
	move.l	a0,d1
	swap	d1
	add.w	d1,d1
	muls	_sinB_,d1
	sub.l	d1,d4
;	move.l	d4,_zy
	swap	d4
;	move.w	d4,_zy
	asr.w	#6,d4
	move.w	d4,d0
	add.w	d0,d0
	move.l	d0,a5
	move.w	(a5),_ozy+2
.setupComplete		
	rts	


rotateAndDrawVerticesBall1
	lea		_currentVerticesBall,a5					;8	
	move.l	vertexLocPointer2,a4			; save stuff
	move.w	number_of_vertices_ball,d5				;20
	subq	#1,d5								;4
	move.l	explog_logpointerBall,d0		;20	
	move.l	explog_expointerBall,d2						;20
	move.l	d2,d3								;4
	move.w	_vertices_xoffBall,d4				;12
	add.w	#4000+4000+8192+8000,d4
	move.w	_vertices_yoffBall,d7				;12
	move.l	x_table_pointerBall,d1
	move.l	x_table_pointerBall,d2
	jmp		entryRotation

rotateAndDrawVerticesBall2
	lea		_currentVerticesBall+max_number_vertices*2*3,a5					;8	
	move.l	vertexLocPointer2,a4			; save stuff
	add.w	#max_number_vertices*2,a4
	move.w	number_of_vertices_ball,d5				;20
	subq	#1,d5								;4
	move.l	explog_logpointerBall,d0		;20	
	move.l	explog_expointerBall,d2						;20
	move.l	d2,d3								;4
	move.w	_vertices_xoff2Ball,d4				;12
	add.w	#4000+4000+8192+8000,d4
	move.w	_vertices_yoff2Ball,d7				;12
	move.l	x_table_pointerBall,d1
	move.l	x_table_pointerBall,d2
	jmp		entryRotation

rotateAndStoreVertex1Ball1
	lea		_currentVerticesBall,a5					;8	
	move.w	_vertices_xoffBall,d4	
	move.w	_vertices_yoffBall,d7				;12
	jmp		entryRotationStore


rotateAndStoreVertex1Ball2
	lea		_currentVerticesBall+max_number_vertices*2*3,a5					;8	
	move.w	_vertices_xoff2Ball,d4	
	move.w	_vertices_yoff2Ball,d7				;12
	jmp		entryRotationStore


entryRotationStore
	move.l	y_block_pointer2,d3
	move.l	zpointer,d6

	move.w	_oxx+2,_oxx2+2
	move.w	_oxy+2,_oxy2+2
	move.w	_oxz+2,_oxz2+2
	move.w	_oyx+2,_oyx2+2
	move.w	_oyy+2,_oyy2+2
	move.w	_oyz+2,_oyz2+2
;	move.w	_ozx+2,_ozx2+2
;	move.w	_ozy+2,_ozy2+2
;	move.w	_ozz+2,_ozz2+2

		movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
_oxx2		move.w		1234(a0),d1	;12			; x*xx ... +
_oxy2		add.w		1234(a1),d1	;12			; x*xy ... +
_oxz2		add.w		1234(a2),d1	;12			; x*xz 
_oyx2		move.w		1234(a0),d3	;12			; z*zx ... +
_oyy2		add.w		1234(a1),d3	;12			; z*zy ... +
_oyz2		add.w		1234(a2),d3	;12			; z*zz
;_ozx2		move.w		1234(a0),d6	;12			; z*zx ... +
;_ozy2		add.w		1234(a1),d6	;12			; z*zy ... +
;_ozz2		add.w		1234(a2),d6	;12			; z*zz
		add.w		d4,d1		;4			; add object x_offset
		add.w		d7,d3		;4			; add object y_offset

		move.w		d1,lineLoc
		move.w		d3,lineLoc+2

	rts






calculateRotatedProjectionExpLog2


	;				old				new	
	; a2	xx		000000FE		000000FF
	; a1	xy		00000002		00000003
	; a0	xy		00000003		00000003
	; a3	yx		00000002		00000003
	; a4	yy		FFFFFF01		FFFFFF00
	; a6	yz		FFFFFFFD		FFFFFFFC
	; d7	zx		0000FFFD		728E0003
	; d3	zy		0002FFFC		0002FFFC
	; d4	zz		000000FE		000000FF
	lea		_currentVerticesBall+max_number_vertices*2*3,a5					;8	
	move.l	vertexLocPointer2,a4			; save stuff
	add.w	#max_number_vertices*2,a4

	move.w	number_of_vertices_ball,d5				;20
	subq	#1,d5								;4

	move.l	explog_logpointerBall,d0		;20	


;	move.l	rotation_perspectivePointer,d1				;20

	move.l	explog_expointerBall,d2						;20
	move.l	d2,d3								;4



	move.w	_vertices_xoff2Ball,d4				;12
	add.w	#4000+4000+8192+8000+1280*2,d4
	move.w	_vertices_yoff2Ball,d7				;12

	move.l	x_table_pointerBall,d1
	move.l	x_table_pointerBall,d2


	jmp		entryRotation



calculateRotatedProjectionExpLog3
	lea		_currentVerticesBall+max_number_vertices*2*3*2,a5					;8	
	move.l	vertexLocPointer2,a4			; save stuff
	add.w	#max_number_vertices*4,a4

	move.w	number_of_vertices_ball,d5				;20
	subq	#1,d5								;4

	move.l	explog_logpointerBall,d0		;20	


;	move.l	rotation_perspectivePointer,d1				;20

	move.l	explog_expointerBall,d2						;20
	move.l	d2,d3								;4



	move.w	_vertices_xoff3Ball,d4				;12
	add.w	#4000+4000+8192+8000+1280*4,d4
	move.w	_vertices_yoff3Ball,a4				;12

	move.l	x_table_pointerBall,d1
	move.l	x_table_pointerBall,d2


	jmp		entryRotation
; d0 explog_logpointerBall
; d1 perspective pointer
; d2 explog_exppointer
; d3 explog_exppointer

; d4 xoff
; d5 number of vertices
; d6 -
; d7 yoff

; a0-a2 x,y,z vertices pointers
; a3	local reg
; a4	free
; a5	source
; a6	screen


entryRotation
	move.w	d4,a3
	move.w	#12,d2
	move.l	y_block_pointer2,d3
	move.l	zpointer,d6
	move.l	screenpointer2,d4
_orotationLoop
		movem.w	(a5)+,a0-a2		;24				addresses into exp table, a0 points to a0=>exp(d0), a1=>exp(d1) => a2=>exp(d2)
_oxx		move.w		1234(a0),d1	;12			; x*xx ... +
_oxy		add.w		1234(a1),d1	;12			; x*xy ... +
_oxz		add.w		1234(a2),d1	;12			; x*xz 
_oyx		move.w		1234(a0),d3	;12			; z*zx ... +
_oyy		add.w		1234(a1),d3	;12			; z*zy ... +
_oyz		add.w		1234(a2),d3	;12			; z*zz
_ozx		move.w		1234(a0),d6	;12			; z*zx ... +
_ozy		add.w		1234(a1),d6	;12			; z*zy ... +
_ozz		add.w		1234(a2),d6	;12			; z*zz
planeCheck
		blt			plane2draw
plane1draw
		add.w		a3,d1		;4			; add object x_offset
		add.w		d7,d3		;4			; add object y_offset
		move.l		d1,a6
		move.w		(a6)+,d4		; xoff
		move.l		d3,a0
		add.w		(a0)+,d4		; yoff
		move.l		d4,a0			; screen
		move.w		(a6),d0
		move.w		d4,(a4)+
		or.w		d0,(a0)			; write
	dbra	d5,_orotationLoop		;12			; 24 + 52 + 2*72 + 12 = 36 + 212 = 232 for x,y,z rotation with perspective
	rts
plane2draw
		neg.w		d1
		sub.w		d2,d1
		add.w		a3,d1		;4			; add object x_offset
		neg.w		d3
		sub.w		d2,d3
		add.w		d7,d3		;4			; add object y_offset
		move.l		d1,a6
		move.w		(a6)+,d4
		move.l		d3,a0
		add.w		(a0)+,d4
		move.l		d4,a0
		move.w		(a6),d0
		move.w		d4,(a4)+
		or.w		d0,(a0);		or.w		d0,160(a0)			; write
	dbra	d5,_orotationLoop		;12			; 24 + 52 + 2*72 + 12 = 36 + 212 = 232 for x,y,z rotation with perspective
	rts

persoff	dc.w	0




; distance between two points:

; p1 = x1,y1,z1
; p2 = x2,y2,z2

; distance = p2-p1 = sqrt (x2-x1)

init_vertices
	lea		vertexList,a0
	lea		_currentVerticesBall,a1
	move.l	explog_logpointerBall,d6
	move.w	number_of_vertices_ball,d7
	asr.w	#1,d7
	sub.w	#1,d7
	move.w	#pivotexp,d0						; base address of low memory

;	lea		.jmpMarker,a6

;	add.w	d7,d7	;4
;	add.w	d7,d7	;4
;	move.w	d7,d2	;4
;	lsl.w	#3,d7	;12
;	add.w	d2,d7	;4		*36

;	sub.w	d7,a6
;	jmp		(a6)

.loop
	REPT 6									; for x,y,z
		move.w	(a0)+,d6		;8
		add.w	d6,d6			;4
		move.l	d6,a2			;4
		move.w	(a2),d1			;8
		add.w	d0,d1			;4
		move.w	d1,(a1)+		;8		-> 36*3			(12*3 size)	
	ENDR
	dbra	d7,.loop


; init object 2

	lea		vertexList,a0
	move.l	explog_logpointerBall,d6
	move.w	number_of_vertices_ball,d7
	asr.w	#1,d7
	sub.w	#1,d7
	move.w	#pivotexp,d0						; base address of low memory

;	lea		.jmpMarker,a6

;	add.w	d7,d7	;4
;	add.w	d7,d7	;4
;	move.w	d7,d2	;4
;	lsl.w	#3,d7	;12
;	add.w	d2,d7	;4		*36

;	sub.w	d7,a6
;	jmp		(a6)

.loop2
	REPT 6									; for x,y,z
		move.w	(a0)+,d6		;8
		add.w	d6,d6			;4
		move.l	d6,a2			;4
		move.w	(a2),d1			;8
		add.w	d0,d1			;4
		move.w	d1,(a1)+		;8		-> 36*3			(12*3 size)	
	ENDR
	dbra	d7,.loop2


	lea		vertexList,a0
	move.l	explog_logpointerBall,d6
	move.w	number_of_vertices_ball,d7
	asr.w	#1,d7
	sub.w	#1,d7
	move.w	#pivotexp,d0						; base address of low memory

;	lea		.jmpMarker,a6

;	add.w	d7,d7	;4
;	add.w	d7,d7	;4
;	move.w	d7,d2	;4
;	lsl.w	#3,d7	;12
;	add.w	d2,d7	;4		*36

;	sub.w	d7,a6
;	jmp		(a6)

.loop3
	REPT 6									; for x,y,z
		move.w	(a0)+,d6		;8
		add.w	d6,d6			;4
		move.l	d6,a2			;4
		move.w	(a2),d1			;8
		add.w	d0,d1			;4
		move.w	d1,(a1)+		;8		-> 36*3			(12*3 size)	
	ENDR
	dbra	d7,.loop3


	rts

; linerout
fake			ds.w	1




lineDivTableptr	ds.l	1

_stepSpeedXBall		dc.w	0
_stepSpeedYBall		dc.w	0
_stepSpeedZBall		dc.w	0

_stepSpeedX2Ball	dc.w	8
_stepSpeedY2Ball	dc.w	2
_stepSpeedZ2Ball	dc.w	2

_stepSpeedX3Ball	dc.w	6
_stepSpeedY3Ball	dc.w	6
_stepSpeedZ3Ball	dc.w	8



_currentStepXBall	dc.w	0
_currentStepYBall	dc.w	0
_currentStepZBall	dc.w	0


_currentStepX2Ball	dc.w	0
_currentStepY2Ball	dc.w	0
_currentStepZ2Ball	dc.w	0

_currentStepX3Ball	dc.w	0
_currentStepY3Ball	dc.w	0
_currentStepZ3Ball	dc.w	0

;_zz					dc.w	0
;_zx					dc.w	0
;_zy					dc.w	0
_vertices_xoffBall		dc.w	160*4
_vertices_yoffBall		dc.w	100*4
_vertices_xoff2Ball		dc.w	-80*4
_vertices_yoff2Ball		dc.w	100*4
_vertices_xoff3Ball		dc.w	160*4
_vertices_yoff3Ball		dc.w	-100*4
number_of_vertices_ball	dc.w	0

;_sintable_ball		include		'flatshade/sintable_amp32768_steps1024.s'

vertexList			;380*6 = 2280
	include	"balls/ball.s"

projectedVerticesBallPtr			dc.l	0
vertexLocPointer					ds.l	1
vertexLocPointer2					ds.l	1
explog_expointerBall				ds.l	1
explog_logpointerBall				ds.l	1
y_block_pointer2					ds.l	1
x_table_pointerBall					ds.l	1
clearDotCodePointer					ds.l	1
memStore							ds.l	1
	even

_init_exp_log:
.init_log:      
	move.l	logpointer_src,a4
    move.l  explog_logpointerBall,a2
    move.l  a2,a3
    add.l   #$10000,a3
    moveq   #-2,d6           	; index
    move.w  #EXPS*2,(A2)+  	; NULL                      ; I changed this, no more bugs
    move.w  #LOGS-1-1,D7
.il:
    	move.w  (A4)+,D0        ; log
    	add.w   D0,D0

    	move.w  d0,(a2)+        ; pos2
    	add.w   #EXPS*2,D0      ; NEG
    	move.w  d0,-(a3)         ; move in value
    dbra    D7,.il

.init_exp:      
    move.w  #EXPS*2,D7                          ; d7 = 8096
    move.l	exppointer_src,a3
    move.l	explog_expointerBall,a0                 ;  a0 = xxxx0000-xxxx2000
    lea		(a0,d7.w),a1                        ;  a1 = xxxx2000-xxxx4000
    lea		(a1,d7.w),a2                        ;  a2 = xxxx4000-xxxx6000
    move.w  #-4,d6
    move.w  #EXPS-1,D7
.ie:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1
        and.w   d6,d0
        and.w   d6,d1
		move.w  d0,(a0)+
		move.w  d1,(a1)+
		move.w  d0,(a2)+
    dbra    D7,.ie

_init_exp_low:    
	lea		pivotexp-$2000,a0			;$300			;$2000
    move.w  #-4,d6
	moveq	#0,d0
.cl
		move.l	d0,(a0)+
		cmp.w	#pivotexp,a0
		bne		.cl
    move.w  #EXPS*2,D7					;4096*2*2+$2000
    move.l	exppointer_src,a3
    lea  	pivotexp,a4           ; $4000
    lea     (a4,d7.w),a5          ; $6000
    lea     (a5,d7.w),a6          ; $8000
    move.w  #EXPS-1,D7            ; $
.ie2:
    	move.w  (a3)+,D0
    	move.w  D0,D1
    	neg.w   D1

  		asr.w	#6,d0
		asr.w	#6,d1

        and.w   d6,d0
        and.w   d6,d1

		move.w  d0,(a4)+
		move.w  d1,(a5)+
		move.w  d0,(a6)+
    dbra    D7,.ie2
    rts

SO	equ 0

bellman_draw_line:
; Line-Rout ver. 1.1b (optimized a lot and then some more) (low/mid/high)
; pre calculated lists and selfmodifying code to skip the time eating loops
; Coded by Criz/2SMART4U
; 1/13-93  20.47

; in use:
;	a0: locpointer
;	a1: screen
;	a2:	multable
;	a3:	local smc reg
;	a4: divtable
;	a5: not used
;	a6: mask and offset table

; 	d0:	x2,smc instr
;	d1:	x1
;	d2:	y2
;	d3:	y1
;	d4: delta x
;	d5: fraction or smt
;	d6: local
;	d7: unused

lw:              equ    160
ww:              equ    8               ;8=low 4=mid 2=high
shift:           equ    1               ;1=low 2=mid 3=high

; a0.l = (x1.w,y1.w,x2.w,y2.w)
; a1.l = screen address

                moveq   #0,D4           ;clear for later use
;                lea     mul_tab(PC),A2  ;mul table

                move.w  (A0),D1         ;x1
                sub.w   4(A0),D1        ;x1-x2
                beq     vert            ;x1-x2=0 -> vertical line
                bmi.s   dx_neg          ;negative delta x?
;postive delta x
                move.w  4(A0),D0        ;start with x2
                move.w  6(A0),D2        ;start with y2
                move.w  2(A0),D3        ;y1
                sub.w   D2,D3           ;y1-y2=delta y
*               beq     horiz           ;y1-y1=0 -> horizontal line
                bmi     dy_neg          ;delta y negative?
                bra.s   dy_pos          ;delta y positive?

;negative delta x
dx_neg:
                neg.w   D1              ;make pos
                move.w  (A0),D0        ;start with x1
                move.w  2(A0),D2        ;start with y1
                move.w  6(A0),D3        ;y2
                sub.w   D2,D3           ;y2-y1=delta y
*               beq     horiz
                bmi     dy_neg

;postive delta y
dy_pos:
; d0=start x d1=deltax=xlength
; d2=start y d3=deltay
                move.w  D3,D4           ;d4=deltay
                sub.w   D1,D4           ;delty-deltax
                blt     less_than_45
                bgt.s   more_than_45

;--------> V=45 <----------
				lsr.w	#1,d2

                adda.w  0(A2,D2.w),A1   ;*lw
				move.l	(a6,d0.w),d6		;20
				add.w	d6,a1				;8
				swap 	d6						;4		-> 40 -> 16 cycles profit

;                lea     buf+v_45,A0     ;pre calced point list
				move.l	v_45ptr,a5

 				add.w	d0,d0
 				move.w	d0,d2

 				add.w	d1,d1

                addq.w  #8,D1
                add.w   D2,D1           ;where to stop
                move.l	a5,a3
                IFEQ	SO
	                move.l tmpptr,a0
	                ext.l	d1
	                ext.l	d2
	                asr.w	#3,d2
	                muls	#10,d2
	                asr.w	#3,d1
	                muls	#10,d1
                ENDC
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3) ;put an RTS there instead
                jmp     0(a5,D2.w)      ;draw the fuckin' line

;--------> 45 < V <= 90 <----------
more_than_45:
				lsr.w	#1,d2
				lsr.w	#1,d3

				lsl.w	#6,d1
                add.w	d3,d1				;4
                move.w	(a4,d1.w),d4		;16

                adda.w  0(A2,D2.w),A1   ;*lw

				move.l	(a6,d0.w),d6		;20
				add.w	d6,a1				;8
				swap 	d6						;4		-> 40 -> 16 cycles profit

                move.w	d3,d0
                add.w	d3,d3
                add.w	d3,d0
                add.w	d3,d3
                add.w	d0,d3

                move.w  #199*14,D0      ;list length-14
                sub.w   D3,D0           ;-line length=start offset
                move.w  #lw,D3
;                lea     buf+v_45_90,A0  ;pre calced point list
				move.l	v_45_90ptr,a5
                lea		fake,a3
                IFEQ	SO
                	ext.l	d0
	                move.l tmpptr,a0
	                divs	#14,d0
	                asl.w	#4,d0
                ENDC
                jmp     0(a5,D0.w)

less_than_45:
				lsr.w	#1,d2
				lsr.w	#1,d1

;---------> 0 <= V > 45 <------------
				lsl.w	#6,d3
                add.w	d1,d3				;4
                move.w	(a4,d3.w),d4		;16

                adda.w  0(A2,D2.w),A1   ;*lw

				move.w	d0,d2
				move.l	(a6,d0.w),d6
				add.w	d6,a1
				swap	d6

                add.w	d0,d0
                add.w	d0,d2

                addq.w	#2,d1
                add.w	d1,d1
                move.w	d1,d0
                add.w	d1,d1
                add.w	d0,d1

                add.w	d2,d1			;12*4 = 48

;                lea     buf+v_0_45,A0   ;pre calced point list
				move.l	v_0_45ptr,a5
                move.l	a5,a3
                IFEQ	SO
                	ext.l	d1
                	ext.l	d2
	                move.l tmpptr,a0
	                divs	#12,d2
	                muls	#14,d2
	                divs	#12,d1
	                muls	#14,d1
                ENDC
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3) ;put an RTS there instead
                move.w  #lw,D3          ;line width
                jmp     0(a5,D2.w)      ;draw the fuckin' line

;------> negative delta y <-------
dy_neg:
; d0=start x d1=deltax=xlength
; d2=start y d3=deltay
                neg.w   D3
                move.w  D3,D4           ;d4=deltay
                sub.w   D1,D4           ;delty-deltax
                blt     less_than_m45
                bgt.s   more_than_m45

				lsr.w	#1,d2

;---------> V=(-45) <----------
;                add.w   D2,D2           ;ystart*2
                adda.w  0(A2,D2.w),A1   ;*lw

				move.l	(a6,d0.w),d6				;20
				add.w	d6,a1						;8
				swap	d6							;4

				move.l	v_m45ptr,a5

				add.w	d0,d0
				move.w	d0,d2
				add.w	d1,d1

                add.w   D2,D1           ;where to stop
  				addq.w	#8,d1

                move.l	a5,a3
                IFEQ	SO
                	ext.l	d1
                	ext.l	d2
	                move.l tmpptr,a0
	                asr.w	#3,d2
	                muls	#10,d2
	                asr.w	#3,d1
	                muls	#10,d1
                ENDC
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3) ;put an RTS there instead
                jmp     0(a5,D2.w)      ;draw the fuckin' line

;---------> (-45) < - >= (-90) <-------------
more_than_m45:
				lsr.w	#1,d2
				lsr.w	#1,d3

				lsl.w	#6,d1
                add.w	d3,d1				;4
                move.w	(a4,d1.w),d4		;16

                adda.w  0(A2,D2.w),A1   ;*lw

				move.l	(a6,d0.w),d6
				add.w	d6,a1
				swap	d6

                move.w	d3,d0
                add.w	d3,d3	;4
                add.w	d3,d0
                add.w	d3,d3
                add.w	d0,d3

                move.w  #199*14,D0      ;list length-14
                sub.w   D3,D0           ;-line length=start offset
                move.w  #lw,D3          ;line width
;                lea     buf+v_m45_m90,A0 ;pre calced point list
				move.l	v_m45_m90ptr,a5
                lea		fake,a3
                IFEQ	SO
	                move.l tmpptr,a0
	                ext.l	d0
	                divs	#14,d0
	                asl.w	#4,d0
                ENDC
                jmp     0(a5,D0.w)
less_than_m45:
				lsr.w	#1,d2
				lsr.w	#1,d1
;---------> 1 <-> (-45) <--------------
				lsl.w	#6,d3
                add.w	d1,d3				;4
                move.w	(a4,d3.w),d4		;16

                adda.w  0(A2,D2.w),A1   ;*lw

				move.w	d0,d2
				move.l	(a6,d0.w),d6
				add.w	d6,a1
				swap	d6

                add.w	d0,d0
                add.w	d0,d2

                addq.w	#2,d1
                add.w	d1,d1
                move.w	d1,d0
                add.w	d1,d1
                add.w	d0,d1
                add.w	d2,d1			;12*4 = 48

;                lea     buf+v_m0_m45,A0 ;pre calced point list
				move.l	v_m0_m45ptr,a5

                move.l	a5,a3
                IFEQ	SO
                	ext.l	d1
                	ext.l	d2
	                move.l tmpptr,a0
	                divs	#12,d2
	                muls	#14,d2
	                divs	#12,d1
	                muls	#14,d1
                ENDC
                add.w	d1,a3
                move.w	(a3),d0
                move.w  #$4E75,(a3);put an RTS there instead
                move.w  #lw,D3          ;line width
                jmp     (a5,D2.w)      ;draw the fuckin' line

;---------> V=0 <---------- (horizontal line)
horiz:
				lsr.w	#1,d2
				lsr.w	#2,d1

                adda.w  0(A2,D2.w),A1   ;*lw

				move.l	(a6,d0.w),d6
				add.w	d6,a1
				swap	d6
                IFEQ	SO
	                move.l tmpptr,a0
                ENDC
looph:          
               	IFEQ	SO
				move.w	a1,(a0)+
				ENDC
				or.w    D6,(A1)         ;plot point
                ror.w   #1,D6
                bcc.s   dont_addh
                addq.w  #ww,A1
dont_addh:      dbra    D1,looph
				lea		fake,a3
				rts

;---------> V=90 <---------- (vertical line)
vert:
                move.w  4(A0),D0        ;start with x2
                move.w  6(A0),D2        ;start with y2
                move.w  2(A0),D3        ;y1
                sub.w   D2,D3           ;y1-y2=delta y
                bge.s   pos_vert
                neg.w   D3
                move.w  2(A0),D2        ;start with y1
pos_vert:
				lsr.w	#1,d2
				lsr.w	#2,d3

                adda.w  0(A2,D2.w),A1   ;*lw

				move.l	(a6,d0.w),d6
				add.w	d6,a1
				swap	d6

                IFEQ	SO
	                move.l tmpptr,a0
                ENDC
loopv:          
                IFEQ	SO
				move.w	a1,(a0)+
				ENDC
				or.w    D6,(A1)         ;plot point
				lea		160(a1),a1
;                adda.w  #lw,A1
                dbra    D3,loopv
                lea		fake,a3
line_done:      rts

**** Make som premodified lists ****
bellman_init_line:
; 45 <-> 90
                move.w  #200-1,D1
;                lea     buf+v_45_90,A1
				move.l	v_45_90ptr,a1
copy1b:         move.w  #(d_45_90_e-d_45_90)/2-1,D0
                lea     d_45_90(PC),A0
copy1:          move.w  (A0)+,(A1)+
                dbra    D0,copy1
                dbra    D1,copy1b
                move.w  #$4E75,(A1)     ;rts
; -45 <-> -90
                move.w  #200-1,D1
;                lea     buf+v_m45_m90,A1
				move.l	v_m45_m90ptr,a1
copy2b:         move.w  #(d_m45_m90_e-d_m45_m90)/2-1,D0
                lea     d_m45_m90(PC),A0
copy2:          move.w  (A0)+,(A1)+
                dbra    D0,copy2
                dbra    D1,copy2b
                move.w  #$4E75,(A1)     ;rts
; 0 <-> 45
                move.w  #320/16-1,D1
;                lea     buf+v_0_45,A1
				move.l	v_0_45ptr,a1
copy3d:         move.w  #15-1,D2        ;15 first
copy3b:         move.w  #(d_0_45_1_e-d_0_45_1)/2-1,D0
                lea     d_0_45_1(PC),A0
copy3:          move.w  (A0)+,(A1)+
                dbra    D0,copy3
                dbra    D2,copy3b
                move.w  #(d_0_45_2_e-d_0_45_2)/2-1,D0
                lea     d_0_45_2(PC),A0
copy3c:         move.w  (A0)+,(A1)+
                dbra    D0,copy3c
                dbra    D1,copy3d
                move.w  #$4E75,(A1)     ;rts
; -0 <-> -45
                move.w  #320/16-1,D1
;                lea     buf+v_m0_m45,A1
				move.l	v_m0_m45ptr,a1
copy4d:         move.w  #15-1,D2        ;15 first
copy4b:         move.w  #(d_m0_m45_1_e-d_m0_m45_1)/2-1,D0
                lea     d_m0_m45_1(PC),A0
copy4:          move.w  (A0)+,(A1)+
                dbra    D0,copy4
                dbra    D2,copy4b
                move.w  #(d_m0_m45_2_e-d_m0_m45_2)/2-1,D0
                lea     d_m0_m45_2(PC),A0
copy4c:         move.w  (A0)+,(A1)+
                dbra    D0,copy4c
                dbra    D1,copy4d
                move.w  #$4E75,(A1)     ;rts
; 45
                move.w  #400/16-1,D1
;                lea     buf+v_45,A1
				move.l	v_45ptr,a1
copy5d:         move.w  #15-1,D2        ;15 first
copy5b:         move.w  #(d_45_1_e-d_45_1)/2-1,D0
                lea     d_45_1(PC),A0
copy5:          move.w  (A0)+,(A1)+
                dbra    D0,copy5
                dbra    D2,copy5b
                move.w  #(d_45_2_e-d_45_2)/2-1,D0
                lea     d_45_2(PC),A0
copy5c:         move.w  (A0)+,(A1)+
                dbra    D0,copy5c
                dbra    D1,copy5d
                move.w  #$4E75,(A1)     ;rts
; -45
                move.w  #400/16-1,D1
;                lea     buf+v_m45,A1
				move.l	v_m45ptr,a1
copy6d:         move.w  #15-1,D2        ;15 first
copy6b:         move.w  #(d_m45_1_e-d_m45_1)/2-1,D0
                lea     d_m45_1(PC),A0
copy6:          move.w  (A0)+,(A1)+
                dbra    D0,copy6
                dbra    D2,copy6b
                move.w  #(d_m45_2_e-d_m45_2)/2-1,D0
                lea     d_m45_2(PC),A0
copy6c:         move.w  (A0)+,(A1)+
                dbra    D0,copy6c
                dbra    D1,copy6d
                move.w  #$4E75,(A1)     ;rts
                rts
****** Some data to use doing the lists ******
; in use: d3,d4,d5,d6,a1
; 45 <-> 90
d_45_90:        
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
				or.w    D6,(A1)         ;plot point
                adda.w  D3,A1
                add.w   D4,D5
                bcc.s   d_45_90_e
                ror.w   #1,D6
                bcc.s   d_45_90_e
                addq.w  #ww,A1
d_45_90_e:
; -45 <-> -90
d_m45_m90:
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC			
                or.w    D6,(A1)         ;plot point
                suba.w  D3,A1
                add.w   D4,D5
                bcc.s   d_m45_m90_e
                ror.w   #1,D6
                bcc.s   d_m45_m90_e
                addq.w  #ww,A1
d_m45_m90_e:
; 0 <-> 45
d_0_45_1:
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point						;12
                ror.w   #1,D6           ;rotate to next point			;8
                add.w   D4,D5           ;add fraction
                bcc.s   d_0_45_1_e      ;next y?
                adda.w  #lw,A1          ;next y
d_0_45_1_e:
d_0_45_2:
; the 16th one, adds to the next word
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                addq.w  #ww,A1          ;next word
                add.w   D4,D5           ;add fraction
                bcc.s   d_0_45_2_e      ;next y?
                adda.w  D3,A1           ;next y
d_0_45_2_e:
; -0 <-> -45
d_m0_m45_1:
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                add.w   D4,D5           ;add fraction
                bcc.s   d_m0_m45_1_e    ;next y?
                suba.w  #lw,A1          ;next y
d_m0_m45_1_e:
d_m0_m45_2:
; the 16th one, adds to the next word
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point
                ror.w   #1,D6           ;rotate to next point
                addq.w  #ww,A1          ;next word
                add.w   D4,D5           ;add fraction
                bcc.s   d_m0_m45_2_e    ;next y?
                suba.w  D3,A1           ;next y
d_m0_m45_2_e:
; 45
d_45_1:
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point
                lea		160(a1),a1
;                adda.w  d3,A1          ;next line
                ror.w   #1,D6           ;rotate
d_45_1_e:
d_45_2:
;16th adds the word offset
				IFEQ	SO
					move.w	a1,(a0)+						;8/10
				ENDC
                or.w    D6,(A1)         ;plot point
                lea		168(a1),a1
;                adda.w  d1,A1           ;next line
                ror.w   #1,D6           ;rotate
;                addq.w  #ww,A1          ;next word
d_45_2_e:
; -45
d_m45_1:
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point
                lea		-160(a1),a1
;                suba.w  #lw,A1          ;next line
;				sub.w	d3,a1
                ror.w   #1,D6           ;rotate
d_m45_1_e:
d_m45_2:
;16th adds the word offset
				IFEQ	SO
					move.w	a1,(a0)+
				ENDC
                or.w    D6,(A1)         ;plot point
                lea		-152(a1),a1
;                sub.w  d1,A1           ;next line
                ror.w   #1,D6           ;rotate
;                addq.w  #ww,A1          ;next word
d_m45_2_e:
;mul_tab:
;i               SET 0
;                REPT 200
;                DC.w i*lw
;i               SET i+1
;                ENDR

v_45_90ptr			ds.l	1
v_m45_m90ptr		ds.l	1
v_0_45ptr			ds.l	1
v_m0_m45ptr			ds.l	1
v_45ptr				ds.l	1
v_m45ptr			ds.l	1
	


initLineDivTable
;	lea		lineDivTable,a0
	move.l	lineDivTableptr,a0

	moveq	#0,d0

	move.w	#128-1,d7
.l
		moveq	#0,d1
		move.w	#128-1,d6
.i
			move.l	d0,d2
			swap	d2
			divu	d1,d2
			move.w	d2,(a0)+

			add.w	#1,d1
		dbra	d6,.i
		add.w	#1,d0
	dbra	d7,.l
	rts

genMulTab
	move.l	multabPtr,a0
	move.w	#160,d0
	moveq	#0,d1
	move.w	#200-1,d7
.cc
		move.w	d1,(a0)+
		add.w	d0,d1
	dbra	d7,.cc

	rts
multabPtr		ds.l	1	


maskAndOffTabPtr	ds.l	1				;20*16*4 = 1280

genMaskAndOffTab
	move.l	maskAndOffTabPtr,a0
	moveq	#0,d0		;off
	move.w	#$8000,d2	;mask
	move.w	#20-1,d7
.ol
		move.w	#16-1,d6
		move.w	d2,d1
.il
		move.w	d1,(a0)+
		move.w	d0,(a0)+
		lsr.w	#1,d1
		dbra	d6,.il
	addq.w	#8,d0
	dbra	d7,.ol
	rts    

lowermemBalls	dc.w	0

storeLowerMemoryBalls
	lea		$300,a0
	move.l	memStore,a1
	move.w	#$6000/4/4-1,d7
.ll
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.ll
		move.w	#1,lowermemBalls
	rts

restoreLowerMemoryBalls
	tst.w	lowermemBalls
	beq		.no
	move.l	memStore,a0
	lea		$300,a1
	move.w	#$6000/4/4-1,d7
.ll
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d7,.ll	
	move.w	#0,lowermemBalls
.no
	rts

initZpointer
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

CPUSHOW		equ 1
screensize	equ 200*160			; screensize constant



;;;;; FOR SUBPIXEL
sintable_size		equ 1024*2
number_of_vertices2	equ 8
DRAWREGS			equ 0
SCANLINEWIDTH		equ 160
FOCALLENGTH 		equ 280				; more is less deformed?
FOCALOPT			equ 0					; asr.w #6 in the table generation, 1 scanline profit
; rotateprecise uses actual vertices x,y,z values , rather than vectors and a table
PRECISEROTATION		equ 1					; using vectors+table = 6 scanlines
; precisediv switches between multable and actual div in determining the slope
PRECISEDIV			equ 1					; using multable = 4 scanlines profit		
CULLTHRESHOLD		equ 1882			; 256 -> 2048
SHOWMASK			equ 1

		section text


	even

;		section	text

flatshade_init
	jsr		flatshade_init_pointers
	move.l	screenpointer,$ffff8200
	IFNE	SHOWMASK
	lea		logocrk,a0
	move.l	screenpointer,a1
	sub.w	#128,a1
	jsr		cranker
	ENDC
	move.l	screenpointer,a0
	move.l	screenpointer2,a1
	move.w	#200-1,d7
.cp
	REPT 40
		move.l	(a0)+,(a1)+
	ENDR
	dbra	d7,.cp

	jsr		flatshade_precalc
;	lea		logo+128,a0


	move.w	#$4e75,flatshade_init
	rts

flatshade_fadein_vbl
	lea		$ffff8240,a0
	lea		flatShadePal,a1
	lea		$ffff8240,a2
	move.w	#16,d0
	subq.w	#1,.waiter
	bge		.skip
	move.w	#2,.waiter
	jsr		fade_st
.skip
	rts
.waiter	dc.w	9
	rsreset
rsstart							rs.b	0
								rs.b	65536*3
;screen1							rs.b	screensize+256		
;screen2							rs.b	screensize
; cube shit
ytable4							rs.b	800					
multable						rs.b	8162	
xbars equ 31			
xtable							rs.l	xbars*16			
xtable2							rs.l	xbars*16			
xtable2_noslope					rs.l	xbars*16			
xtable2_2bpl					rs.l	xbars*16			
xtable2_noslope_2bpl			rs.l	xbars*16			
myDrawRoutPos_2bpl				rs.b	xbars*258			
myDrawRoutNeg_2bpl				rs.b	xbars*258			
myDrawRoutPos					rs.b	xbars*194			
myDrawRoutNeg					rs.b	xbars*194			
myDrawRoutPosNoSlope			rs.b	xbars*162
myDrawRoutNegNoSlope			rs.b	xbars*162			
myDrawRoutPosNoSlope_2bpl		rs.b	xbars*226
myDrawRoutNegNoSlope_2bpl		rs.b	xbars*226		

zTableStart						rs.b	28640+2
zTable							rs.b	28640+2
								rs.w	100		
paletteLUT						rs.w	6602					
xmask_offset					rs.w	31*16+4			;484
xmask_fill						rs.l	31*16+4			;968
xmask_clear						rs.l	31*16+4			;968
clearCodePtr					rs.b	7320+2
;eorCodePtr						rs.b	18000



rsend							rs.w	0						;	260044/1024= 254
		



flatshade_init_pointers
	move.l	#memBase+65536,d0
	sub.w	d0,d0
	move.l	d0,screenpointer
	move.l	d0,d1
	add.l	#$a000,d1
	move.l	d1,eorCodePtr
	add.l	#65536,d0
	move.l	d0,screenpointer2
	add.l	#65536,d0

	rts


flatshade_precalc
	move.w	#600,_currentStepX
	move.w	#200,_currentStepY
	move.w	#1200,_currentStepZ

	lea		cubeVertices,a0
	lea		currentVertices,a1
	REPT 8*3
		move.w	(a0)+,(a1)+
	ENDR

	jsr		generatePaletteTable			;1
	jsr		generateZTable					;33
	jsr		generateMulTable				;5
	jsr		genYTable2						;1
	jsr		genXTable						;1
	jsr		genSlopeTables					;1
	jsr		generateDrawTables				;5
	jsr		generateClearStuff				;2
	jsr		generateEorStuff				;1

	rts

flatshade_main
	rts

flatshade_fadeout_vbl
	move.l	screenpointer2,d0
	move.l	screenpointer,screenpointer2
	move.l	d0,screenpointer					

	lea		$ffff8240,a0
	lea		black,a1
	lea		$ffff8240,a2
	move.w	#16,d0
	subq.w	#1,.waiter
	bge		.skip
	move.w	#2,.waiter
	jsr		fade_st
.skip
	rts
.waiter	dc.w	1


	jsr		doCube
	move.l	screenpointer2,$ffff8200
	rts


flatshade_vbl:		
	move.l	screenpointer2,d0
	move.l	screenpointer,screenpointer2
	move.l	d0,screenpointer					
;	move.w	#$070,$ffff8240
;	jsr		doPalette
	jsr		setFixedPalette


	IFEQ	SHOWMASK
	lea		$ffff8240+2,a0
	REPT 15
		move.w	#$777,(a0)+
	ENDR
	ENDC

	jsr		doCube

	move.l	screenpointer2,$ffff8200
	rts

flatShadePal	
	dc.w	0
	dc.w	$123
		dc.w	$235
		dc.w	$256
		dc.w	$246
		dc.w	$247
		dc.w	$247
		dc.w	$247
		dc.w	$025
		dc.w	$126
		dc.w	$137
		dc.w	$137
		dc.w	$014
		dc.w	$125
		dc.w	$126
		dc.w	$136
	

setFixedPalette
	lea		$ffff8240,a0
	move.w	#0,(a0)+				;0

	move.w	#$123,(a0)+				;1
	move.w	#$235,(a0)+				;2
	move.w	#$256,(a0)+				;3

	move.w	#$246,(a0)+				;4
	move.w	#$247,(a0)+				;5
	move.w	#$247,(a0)+				;6
	move.w	#$247,(a0)+				;7

	move.w	#$025,(a0)+				;8
	move.w	#$126,(a0)+				;9
	move.w	#$137,(a0)+				;10
	move.w	#$137,(a0)+				;11

	move.w	#$014,(a0)+				;12
	move.w	#$125,(a0)+				;13	
	move.w	#$126,(a0)+				;14
	move.w	#$136,(a0)+				;15



;	move.w	#$221,(a0)+				;1
;	move.w	#$321,(a0)+				;2
;	move.w	#$422,(a0)+				;3
;
;	move.w	#$331,(a0)+				;5
;	move.w	#$441,(a0)+				;6
;	move.w	#$551,(a0)+				;7
;	move.w	#$762,(a0)+				;4
;
;	move.w	#$220,(a0)+				;9
;	move.w	#$330,(a0)+				;10
;	move.w	#$440,(a0)+				;11
;	move.w	#$750,(a0)+				;8
;
;	move.w	#$210,(a0)+				;13	
;	move.w	#$320,(a0)+				;14
;	move.w	#$430,(a0)+				;15
;	move.w	#$730,(a0)+				;12
	rts



;;;;;;; SUBPIXEL
cubeOffset	dc.l	0
doCube
	jsr		clearScreen1plOpt1
	jsr		calculateRotatedProjectionMulTable
	jsr		cullCubeNormals
	jsr		drawCubeEdges
	jsr		eorFillScreen1plOpt
	jsr		increaseStep
	rts


; data astructure should be:
;	dc.w	x,y,z	face normal
;	dc.w	x,y,z	face vertex
cubeNormals
	; face 1 - front
	dc.w	0,0,CULLTHRESHOLD				
	dc.w	0,0,32767
	; face 2 - right
	dc.w	CULLTHRESHOLD,0,0
	dc.w	32767,0,0
	; face 3 - top
	dc.w	0,-CULLTHRESHOLD,0
	dc.w	0,-32767,0
	; face 4 - back
	dc.w	0,0,-CULLTHRESHOLD
	dc.w	0,0,-32767
	; face 5 - left
	dc.w	-CULLTHRESHOLD,0,0
	dc.w	-32767,0,0
	; face 6 - bottom
	dc.w	0,CULLTHRESHOLD,0
	dc.w	0,32767,0



cullCubeNormals
	move.w	#-1<<15,d3

	move.w	_zx,d0				;	upper half
	muls	d3,d0
	swap	d0

	move.w	_zy,d1
	muls	d3,d1
	swap	d1

	move.w	_zz,d2
	muls	d3,d2
	swap	d2
	; this is the rotation matrix for inverse camera
	lea		cubeNormals,a0
	lea		facesVisible,a1
	move.w	#6-1,d6
	moveq	#0,d5
.loop
;	conventional
;		move.w	(a0)+,d4			
;		move.w	(a0)+,d5
;		move.w	(a0)+,d6
;		sub.w	d0,d4
;		sub.w	d1,d5
;		sub.w	d2,d6
;		muls	(a0)+,d4
;		muls	(a0)+,d5
;		muls	(a0)+,d6
;		add.l	d4,d6
;		add.l	d5,d6
;		bgt		.notVisible
;.visible
;		move.w	#-1,(a1)+
;		dbra	d7,.loop
;		rts
;.notVisible	
;		move.w	#0,(a1)+
;		dbra	d7,.loop
;		rts	
; each of this is just based around one thing so


;------------ x
		move.w	(a0)+,d4
		beq		.skipx
			sub.w	d0,d4
			muls	4(a0),d4
			bgt		.notVisibleX
.visibleX
				swap	d4
				neg.w	d4
				add.w	d4,d4
				move.w	d4,(a1)+
				lea		10(a0),a0
				dbra	d6,.loop
				rts
.notVisibleX
				move.w	d5,(a1)+
				lea		10(a0),a0
				dbra	d6,.loop
				rts
.skipx		
;------------ end x
;------------ y
		move.w	(a0)+,d4
		beq		.skipy



			sub.w	d1,d4
			muls	4(a0),d4
			bgt		.notVisibleY
.visibleY
				swap 	d4
				neg.w	d4
				add.w	d4,d4
				move.w	d4,(a1)+
				lea		8(a0),a0
				dbra	d6,.loop
				rts
.notVisibleY
				move.w	d5,(a1)+
				lea		8(a0),a0
				dbra	d6,.loop
				rts
.skipy
;------------- end y
		move.w	(a0)+,d4
		;; this cant be wrong :)			
			sub.w	d2,d4
			muls	4(a0),d4
			bgt		.notVisibleZ
				swap	d4
				neg.w	d4
				add.w	d4,d4				
				move.w	d4,(a1)+
				lea		6(a0),a0
				dbra	d6,.loop
				rts
.notVisibleZ
				move.w	d5,(a1)+
				lea		6(a0),a0
				dbra	d6,.loop
				rts


drawEdge macro
;	lea		projectedVertices,a0
	move.l	a5,a0
	move.l	\1*8+0(a0),d0
	move.l	\1*8+4(a0),d1
	move.l	\2*8(a0),d2
	move.l	\2*8+4(a0),d3
	move.l	usp,a0
	add.w	#\3,a0
	jsr		drawLines
	move.w	(a6),(a2)
;	move.w	smcStore,(a2)
	endm

drawEdge2 macro
;	lea		projectedVertices,a0
	move.l	a5,a0
	move.l	\1*8+0(a0),d0
	move.l	\1*8+4(a0),d1
	move.l	\2*8(a0),d2
	move.l	\2*8+4(a0),d3
	move.l	usp,a0
	jsr		drawLines2
	move.w	(a6),(a2)
;	move.w	smcStore,(a2)
	endm


drawCubeEdges
	move.l	screenpointer2,a0
	lea		projectedVertices,a5
	lea		smcStore,a6
	add.l	cubeOffset,a0
	move.l	#ytable2,d7
	add.w	#4,a0
	move.l	a0,usp
	tst.w	facesVisible
	beq		.skipFront
		drawEdge 0,1,0
		drawEdge 1,2,0
		drawEdge 2,3,0
		drawEdge 3,0,0				;0,1,2,3
.skipFront

	tst.w	facesVisible+2
	beq		.skipRight
	drawEdge 0,3,2					0,1,2,3	;	4,7
	drawEdge 3,7,2
	drawEdge 7,4,2
	drawEdge 4,0,2
.skipRight

	tst.w	facesVisible+4
	beq		.skipTop
	drawEdge2 2,3,0					0,1,2,3,4, 7		6
	drawEdge2 3,7,0					
	drawEdge2 7,6,0
	drawEdge2 6,2,0
.skipTop

	tst.w	facesVisible+6
	beq		.skipBack
	drawEdge 4,5,0
	drawEdge 5,6,0
	drawEdge 6,7,0
	drawEdge 7,4,0
.skipBack


	tst.w	facesVisible+8
	beq		.skipLeft		; 		0,1,2,3,4,6,7 
	drawEdge 1,5,2			
	drawEdge 5,6,2
	drawEdge 6,2,2
	drawEdge 2,1,2
.skipLeft

	tst.w	facesVisible+10
	beq		.skipBottom
	drawEdge2 0,1,0
	drawEdge2 1,5,0
	drawEdge2 5,4,0
	drawEdge2 4,0,0
.skipBottom

	rts

matrixValues		ds.w	9
; rotation matrix code
; determines the rotation matrix and rotates the vertices, using multiplications

_sinA		equr d1
_cosA		equr d2
_sinB		equr d3
_cosB		equr a2
_sinC		equr d5
_cosC		equr d6
calculateRotatedProjectionMulTable
	lea		_sintable,a0
	lea		_sintable+(sintable_size/4),a1
   
	move.w	_currentStepX,d2
	move.w	_currentStepY,d4
	move.w	_currentStepZ,d6
	and.w	#-2,d2
	and.w	#-2,d4
	and.w	#-2,d6

	move.w	(a0,d2.w),d1					; sinA	;around z axis		16
	move.w	(a1,d2.w),d2					; cosA						16

	move.w	(a0,d4.w),d3					; sinB	;around y axis		16
	move.w	(a1,d4.w),a2					; cosB						16

	move.w	(a0,d6.w),d5					; sinC	;around x axis		16
	move.w	(a1,d6.w),d6					; cosC						16

	lea		matrixValues,a3

;	xx = [cosA * cosB]
	move.w	_cosB,d4					;d4
	muls	_cosA,d4					;d2
	swap	d4
	IFEQ	PRECISEROTATION
	move.w	d4,.xx+2
	ELSE
	move.w	d4,(a3)+
	ENDC

;	xy = [sinA * cosB]
	move.w	_cosB,d4					;d4					;d4 free
	muls	_sinA,d4					;d1
	swap	d4
	IFEQ	PRECISEROTATION
	move.w	d4,.xy+2
	ELSE
	move.w	d4,(a3)+
	ENDC

;	xz = [sinB]	
	move.w	_sinB,d4
	asr.w	#1,d4
	IFEQ	PRECISEROTATION
	move.w	d4,.xz+2
	ELSE
	move.w	d4,(a3)+
	ENDC


;	yx = [sinA * cosC + cosA * sinB * sinC]
	move.w	_sinA,d4
	muls	_cosC,d4
	move.w	_cosA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_sinC,d0
	add.l	d4,d0
	swap	d0
	IFEQ	PRECISEROTATION
	move.w	d0,.yx+2
	ELSE
	move.w	d0,(a3)+
	ENDC

;	yy = [-cosA * cosC + sinA * sinB * sinC]
	move.w	_cosA,d4
	neg		d4
	muls	_cosC,d4
	move.w	_sinA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_sinC,d0
	add.l	d4,d0
	swap	d0
	IFEQ	PRECISEROTATION
	move.w	d0,.yy+2
	ELSE
	move.w	d0,(a3)+
	ENDC


;	yz = [-cosB * sinC]
	move.w	_cosB,d4					;d4
	neg.w	d4
	muls	_sinC,d4					;d5
	swap	d4
	IFEQ	PRECISEROTATION
	move.w	d4,.yz+2
	ELSE
	move.w	d4,(a3)+
	ENDC


;;	zx = [sinA * sinC - cosA * sinB * cosC]
	move.w	_sinA,d4
	muls	_sinC,d4
	move.w	_cosA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_cosC,d0
	sub.l	d0,d4
	move.l	d4,_zx								; save for culling
	swap	d4
	IFEQ	PRECISEROTATION
	move.w	d4,.zx+2
	ELSE
	move.w	d4,(a3)+
	ENDC

;;	zy = [-cosA * sinC - sinA * sinB * cosC]
	move.w	_cosA,d4
	muls	_sinC,d4
	neg.l	d4
	move.w	_sinA,d0
	muls	_sinB,d0
	lsl.l	#1,d0
	swap	d0
	muls	_cosC,d0
	sub.l	d0,d4
	move.l	d4,_zy								; save for culling
	swap	d4
	IFEQ	PRECISEROTATION
	move.w	d4,.zy+2
	ELSE
	move.w	d4,(a3)+
	ENDC


;;	zz = [cosB * cosC]
	move.w	_cosB,d4
	muls	_cosC,d4
	move.l	d4,_zz
	swap	d4
	IFEQ	PRECISEROTATION
	move.w	d4,.zz+2
	ELSE
	move.w	d4,(a3)+
	ENDC

;					16k			32k				
;	a0	xx			00003FFC	00003FFD
;	a1	xy			000000C8	000000C8
;	a2	xz			000000C9	000000C9
;	a3	yx			000000CB	000000CA
;	a4	yy			FFFFC004	FFFFC003
;	move.w	_yz,a5 ;FFFFFF37	FFFFFF37

        ;xx     a0      00003FE8			00003FE9
        ;xy     a1      0000025A			0000025A
        ;xz     a2      FFFFFDA5			00007DA5
        ;yx     a3      00000244			00000244
        ;yy     a4      FFFFC017			FFFFC016
        ;yz     a5      FFFFFDA5			FFFFFDA5
    IFEQ	PRECISEROTATION
	jmp		.rotatePrecise
	ENDC

	;		a0 is rotation matrix
	lea		matrixValues,a0
	move.l	a0,usp
	lea		.doStuff,a1
	lea		verticesMasks,a2
	lea		.jmptable,a3
	lea		projectedVertices,a4				;8
	move.l	#160<<16,d5
	move.l	#99<<16,d6
	; d0-d4 used for rotation matrix values
	; d5,d6 free
.rotateNewOpt
	move.l	usp,a0
	move.w	(a2)+,d0			; encoding for the table
	blt		.end
	jmp		(a3,d0.w)
.jmptable
;-a,-a,-a									000
	movem.w	(a0)+,d0-d2										;4
	add.l	d1,d0											;2
	add.l	d2,d0											;2
	neg.l	d0												;2

	movem.w	(a0)+,d1-d3		;24								;4
	add.l	d2,d1			;8								;2
	add.l	d3,d1			;8								;2
	neg.l	d1												;2

	movem.w	(a0)+,d2-d4		;24								;4
	add.l	d3,d2			;8								;2
	add.l	d4,d2			;8								;2
	neg.l	d2												;2

	jmp		(a1)
; now we have shit, lets go	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	28

;-a,-a,a									001
	movem.w	(a0)+,d0-d2
	add.l	d1,d0
	neg.l	d0
	add.l	d2,d0

	movem.w	(a0)+,d1-d3
	add.l	d2,d1
	neg.l	d1
	add.l	d3,d1

	movem.w	(a0)+,d2-d4
	add.l	d3,d2
	neg.l	d2
	add.l	d4,d2

	jmp		(a1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	32

;-a,a,-a									010
	movem.w	(a0)+,d0-d2
	add.l	d2,d0
	neg.l	d0
	add.l	d1,d0
;
	movem.w	(a0)+,d1-d3
	add.l	d3,d1
	neg.l	d1
	add.l	d2,d1

	movem.w	(a0)+,d2-d4
	add.l	d4,d2
	neg.l	d2
	add.l	d3,d2

;
	jmp		(a1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	32

;-a,a,a										011
	movem.w	(a0)+,d0-d2
	sub.l	d1,d0
	sub.l	d2,d0
	neg.l	d0

	movem.w	(a0)+,d1-d3
	sub.l	d2,d1
	sub.l	d3,d1
	neg.l	d1

	movem.w	(a0)+,d2-d4
	sub.l	d3,d2
	sub.l	d4,d2
	neg.l	d2

	jmp		(a1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	32

;a,-a,-a									100
	movem.w	(a0)+,d0-d2
	sub.l	d1,d0
	sub.l	d2,d0

	movem.w	(a0)+,d1-d3
	sub.l	d2,d1
	sub.l	d3,d1

	movem.w	(a0)+,d2-d4
	sub.l	d3,d2
	sub.l	d4,d2

	jmp		(a1)

	ds.b	4

.end
	rts		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	12+14+2 28

;a,-a,a										101
	movem.w	(a0)+,d0-d2
	sub.l	d1,d0
	add.l	d2,d0

	movem.w	(a0)+,d1-d3
	sub.l	d2,d1
	add.l	d3,d1

	movem.w	(a0)+,d2-d4
	sub.l	d3,d2
	add.l	d4,d2

	jmp		(a1)

	ds.b	6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	20

;a,a,-a										110
	movem.w	(a0)+,d0-d2
	add.l	d1,d0
	sub.l	d2,d0

	movem.w	(a0)+,d1-d3
	add.l	d2,d1
	sub.l	d3,d1

	movem.w	(a0)+,d2-d4
	add.l	d3,d2
	sub.l	d4,d2
	jmp		(a1)

	ds.b	6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	20

;a,a,a										111
	movem.w	(a0)+,d0-d2		;24
	add.l	d1,d0			;8
	add.l	d2,d0			;8

	movem.w	(a0)+,d1-d3		;24	
	add.l	d2,d1			;8
	add.l	d3,d1			;8

	movem.w	(a0)+,d2-d4		;24
	add.l	d3,d2			;8
	add.l	d4,d2			;8

	jmp		(a1)

	ds.b	6

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	20

.doStuff
	; size is wordsize, so we need a table that is wordsize


	and.w	#-2,d2					; do this once			;8
	lea		buf+zTable,a0

	move.w	(a0,d2.l),d2

	muls	d2,d0
	muls	d2,d1

	IFEQ	FOCALOPT
	asr.l	#1,d0
	asr.l	#1,d1
	ELSE
	asr.l	#6,d0					; do we need this precision ?		>> 6			;20
	asr.l	#6,d1					; do we need this precision ?						;20		8*40 = 320 cycles 
	ENDC

	add.l	d5,d0
	add.l	d6,d1

	move.l	d0,(a4)+
	move.l	d1,(a4)+

	move.w	(a2)+,d0			; encoding for the table
	blt		.end
	move.l	usp,a0
	jmp		(a3,d0.w)


	IFEQ	PRECISEROTATION
.rotatePrecise
	lea		currentVertices,a2					;8	
	lea		projectedVertices,a4				;8
	move.w	#number_of_vertices2,d6
	subq.w	#1,d6
	move.l	#SCANLINEWIDTH<<16,a0
	move.l	#99<<16,a1
.rotateNew
	movem.w	(a2)+,d0-d2			;24

	move.l	d0,d3				;4						; move.l	#xx,d3		;12
.xx	muls	#313,d3				;44						; move.l	#xy,d4		;12
	move.l	d1,d4				;4						; move.l	#xz,d5		;12
.xy	muls	#313,d4				;44						; add.l		d3,d5		;8
	add.l	d4,d3				;8						; add.l		d4,d5		;8		
	move.l	d2,d4				;4						; lsl.l		#7,d5		;24		76 vs
.xz	muls	#313,d4				;44
	add.l	d4,d3				;8		160						

	move.l	d0,d4
.yx	muls	#323,d4
	move.l	d1,d5
.yy	muls	#323,d5
	add.l	d5,d4
	move.l	d2,d5
.yz muls	#323,d5
	add.l	d5,d4

.zx	muls	#313,d0
.zy	muls	#313,d1
.zz	muls	#313,d2
	add.l	d0,d2
	add.l	d1,d2									;16 ; 16


	move.l	#256<<20,d0		;focal length														;12
	move.l	d0,d1																				;4
	lsl.l	#4,d2			; z value				; 16.4 ; 12									;16
	add.l	d2,d1			; focallength + z													;8
	lsl.l	#2,d1			; 6 bits of fraction with it										;12
	swap	d1																					;4
	divs	d1,d0			; lower holds value													;144	--> 200 cycles

	asr.w	#2,d0

	add.l	d4,d4			;8	
	add.l	d4,d4			;8
	add.l	d4,d4			;8
	add.l	d4,d4			;8
	swap	d4
	muls	d0,d4	
	add.l	d3,d3			;8
	add.l	d3,d3			;8
	add.l	d3,d3			;8
	add.l	d3,d3			;8
	swap	d3
	muls	d0,d3

	add.l	a0,d3
	add.l	a1,d4

	move.l	d3,(a4)+
	move.l	d4,(a4)+


	dbra	d6,.rotateNew
	rts
	ENDC






; this should generate a 256/(256+x) table
generateZTable		
	move.l	#FOCALLENGTH<<20,d0			; focal length
	lea		buf+zTable,a0
	move.l	a0,a1
	move.w	#$3800>>4-2,d3		; number
	move.w	#FOCALLENGTH<<7-1,d1
	move.w	#FOCALLENGTH<<7+1,d2
	move.w	#$ffff>>3+$ffff>>5,(a1)+	; first, wnich is otherwise 1
.loopneg
	REPT 16
		move.l	d0,d5		; focal length
		divu	d1,d5		;
		move.w	d5,d6
		lsr.w	#1,d6
		add.w	d6,d5
		lsr.w	#3,d6
		add.w	d6,d5
		IFEQ	FOCALOPT
		asr.w	#5,d5
		ENDC
		move.w	d5,-(a0)
		subq.l	#1,d1


		move.l	d0,d5		; focal length
		divu	d2,d5		;
		move.w	d5,d6
		lsr.w	#1,d6
		add.w	d6,d5
		lsr.w	#3,d6
		add.w	d6,d5
		IFEQ	FOCALOPT
		asr.w	#5,d5
		ENDC
		move.w	d5,(a1)+
		addq.l	#1,d2



	ENDR
	dbra	d3,.loopneg
	rts


;	dc.w	$0777

; color table		ste pal
;	0				0
;	1				8		
;	2				1
;	3				9		
;	4				2		
;	5				a		
;	6				3		
;	7				b		
;	8				4		
;	9				c		
;	10				5		
;	11				d		
;	12				6		
;	13				e		
;	14				7		
;	15				f		

;	554
;	654
;	664
;	665
;	765
;	775
;	776

pal5
	dc.w	$009			;0
	dc.w	$009			;0
	dc.w	$802
	dc.w	$10a
	dc.w	$903
	dc.w	$203
	dc.w	$20b
	dc.w	$a0b
	dc.w	$304
	dc.w	$b0c
	dc.w	$404
	dc.w	$40b
	dc.w	$c03
	dc.w	$c0b
	dc.w	$c0a
	dc.w	$502
	dc.w	$509
	dc.w	$d01
	dc.w	$d08
	dc.w	$600
	dc.w	$680
	dc.w	$e80
	dc.w	$e10
	dc.w	$e90
	dc.w	$e20
	dc.w	$ea0
	dc.w	$740
	dc.w	$7b0
	dc.w	$740
	dc.w	$fc0
	dc.w	$f50
	dc.w	$f52
	dc.w	$fd9
	dc.w	$f69
	dc.w	$f62
	dc.w	$f63
	dc.w	$feb
	dc.w	$f74
	dc.w	$f7c
	dc.w	$ff5
	dc.w	$ffd
	dc.w	$ff6
	dc.w	$ffe
	dc.w	$ff7


;	include pal6.s

_thresholds
;	max val 3100. do a 0-1/2 pi sine, aplitude 3100, 22 steps
	dc.w	113
	dc.w	226
	dc.w	339
	dc.w	451
	dc.w	563
	dc.w	674
	dc.w	784
	dc.w	893
	dc.w	1001
	dc.w	1107
	dc.w	1212
	dc.w	1316
	dc.w	1417
	dc.w	1517
	dc.w	1615
	dc.w	1710
	dc.w	1804
	dc.w	1895
	dc.w	1983
	dc.w	2069
	dc.w	2152
	dc.w	2232
	dc.w	2309
	dc.w	2383
	dc.w	2454
	dc.w	2521
	dc.w	2585
	dc.w	2646
	dc.w	2703
	dc.w	2757
	dc.w	2807
	dc.w	2853
	dc.w	2895
	dc.w	2934
	dc.w	2969
	dc.w	2999
	dc.w	3026
	dc.w	3048
	dc.w	3067
	dc.w	3081
	dc.w	3092
	dc.w	3098
	dc.w	3300

generatePaletteTable
	lea	buf+paletteLUT,a0
	move.w	#100-1,d7
.cc	
		move.w	#0,-(a0)
	dbra	d7,.cc
	lea	buf+paletteLUT,a0
	lea	_thresholds,a1
	lea	pal5,a2
	move.w	#43-1,d3

	moveq	#0,d0
.loop
	; here we init the shit
	move.w	(a1)+,d1		;threshold
	move.w	(a2)+,d2		;color
.il
		move.w	d2,(a0)+	; add color to lut
		addq.w	#1,d0		; advance local threshold
		cmp.w	d1,d0		; have we reached threshold?
		bne		.il			; if not, go again!

	dbra	d3,.loop
	move.w	d2,(a0)
	rts

generateMulTable
	; this should generate a word sized 1/x table, where 1/1 = $ffff
	lea		buf+multable,a0
	move.w	#$ffff,(a0)+
	move.l	#$10000,d0
	moveq	#0,d6
	move.w	#-1,d6
	lsr.w	#8,d6
	subq.w	#1,d6
	moveq	#2,d2
.loop
	REPT 16
		move.l	d0,d1
		divu	d2,d1
		move.w	d1,(a0)+
		addq.w	#1,d2
	ENDR
	dbra	d6,.loop

	rts

genYTable2
	lea		ytable2,a0
	moveq	#0,d0
	move.w	#SCANLINEWIDTH,d1
	move.w	#200-1,d6
.loop
		move.w	d0,(a0)+
		add.w	d1,d0
	dbra	d6,.loop
	rts

genXTable
	lea		buf+xtable,a0
	moveq	#0,d0
	swap	d0
	move.l	#$80000,d1

	move.w	#xbars-1,d5
.ol
	move.w	#16-1,d6
	move.w	#$1<<15,d0
.il
		move.l	d0,(a0)+
		lsr.w	#1,d0
	dbra	d6,.il
		add.l	d1,d0
	dbra	d5,.ol
	rts



genSlopeTables
	lea		buf+xtable2_noslope,a0
	move.l	#10,d3
	IFNE DRAWREGS
	add.l	#2,d3
	ENDC
	jsr		genXTableDraw

	lea		buf+xtable2,a0
	move.l	#12,d3
	IFNE DRAWREGS
	add.l	#2,d3
	ENDC
	jsr		genXTableDraw

	lea		buf+xtable2_noslope_2bpl,a0
	move.l	#14,d3
	IFNE DRAWREGS
	add.l	#4,d3
	ENDC
	jsr		genXTableDraw

	lea		 buf+xtable2_2bpl,a0
	move.l	#16,d3
	IFNE DRAWREGS
	add.l	#4,d3
	ENDC
	jsr		genXTableDraw
	rts


generateDrawTables
	lea		buf+myDrawRoutPos_2bpl,a0
	lea		myDrawRoutPos_2bplStart,a2
	lea		myDrawRoutPos_2bplEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutPos,a0
	lea		myDrawRoutPosStart,a2
	lea		myDrawRoutPosEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutNeg,a0
	lea		myDrawRoutNegStart,a2
	lea		myDrawRoutNegEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutNeg_2bpl,a0
	lea		myDrawRoutNeg_2bplStart,a2
	lea		myDrawRoutNeg_2bplEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutPosNoSlope,a0
	lea		myDrawRoutPosNoSlopeStart,a2
	lea		myDrawRoutPosNoSlopeEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutNegNoSlope,a0
	lea		myDrawRoutNegNoSlopeStart,a2
	lea		myDrawRoutNegNoSlopeEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutPosNoSlope_2bpl,a0
	lea		myDrawRoutPosNoSlope_2bplStart,a2
	lea		myDrawRoutPosNoSlope_2bplEnd,a3
	jsr		copyCodeTemplate

	lea		buf+myDrawRoutNegNoSlope_2bpl,a0
	lea		myDrawRoutNegNoSlope_2bplStart,a2
	lea		myDrawRoutNegNoSlope_2bplEnd,a3
	jsr		copyCodeTemplate


	rts

genXTableDraw
	move.w	#xbars-1,d6
	moveq	#0,d0		;xoff
	moveq	#0,d1		;joff

.ol	
	REPT 8
		move.w	d0,(a0)+	;xoff
		move.w	d1,(a0)+	;joff
		add.w	d3,d1		;joff inc
	ENDR
	addq.w	#1,d0			;xoff inc
	REPT 8
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		add.w	d3,d1
	ENDR
	addq.w	#2,d1			; joff inc
	addq.w	#7,d0			; xoff inc

	dbra	d6,.ol
	rts


;+	d7	eor		pixel 10000000
;+	d6	eor		pixel 01000000	
;+	d4	eor 	pixel 00100000
;+	d2	bchg	pixel 00010000	bit 4
;+	d3	eor		pixel 00001000
;+	d2	eor		pixel 00000100
;+	d0	bchg	pixel 00000010	bit 1
;+	d0	eor		pixel 00000001


myDrawRoutPosStart
;	REPT 20
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0					; add dy int							;2
	add.w	a3,d1					; add dy frac							;2
	bcc.s	*+6						; skip if no overflow					;4
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,(a0)+
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	ELSE
	eor.b	#%00000001,(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutPosEnd

myDrawRoutNegStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0					; add dy int							;2
	sub.w	a3,d1					; add dy frac							;2
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,(a0)+
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	ELSE
	eor.b	#%00000001,(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutNegEnd
	

myDrawRoutPosNoSlopeStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	add.w	a3,d1					; add dy frac							;2
	bcc.s	*+6						; skip if no overflow					;4
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,(a0)+
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	ELSE
	eor.b	#%00000001,(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutPosNoSlopeEnd

myDrawRoutNegNoSlopeStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	sub.w	a3,d1					; add dy frac							;2
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,(a0)+
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	ELSE
	eor.b	#%00100000,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	ELSE
	eor.b	#%00010000,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	ELSE
	eor.b	#%00001000,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	ELSE
	eor.b	#%00000100,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	ELSE
	eor.b	#%00000010,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	ELSE
	eor.b	#%00000001,(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0
	addq.w	#7,a0

myDrawRoutNegNoSlopeEnd



;myDrawRoutPos_2bpl
;	REPT 20
myDrawRoutPos_2bplStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel						
	eor.b	#%10000000,2(a0)			; draw pixel					
	ENDC
	add.w	a1,a0					; add dy int						
	add.w	a3,d1					; add dy frac						
	bcc.s	*+6						; skip if no overflow				
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,2(a0)
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,2(a0)
	eor.b	#%00000001,(a0)+
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	eor.b	d0,2(a0)
	ELSE
	eor.b	#%00000001,(a0)
	eor.b	#%00000001,2(a0)
	ENDC
	add.w	a1,a0
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutPos_2bplEnd

myDrawRoutNeg_2bplStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0					; add dy int							;2
	sub.w	a3,d1					; add dy frac							;2
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d0,2(a0)
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,2(a0)
	eor.b	#%00000001,(a0)+
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	eor.b	d0,2(a0)
	ELSE
	eor.b	#%00000001,(a0)
	eor.b	#%00000001,2(a0)
	ENDC
	add.w	a1,a0
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutNeg_2bplEnd
	

myDrawRoutPosNoSlope_2bplStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	add.w	a3,d1					; add dy frac							;2
	bcc.s	*+6						; skip if no overflow					;4
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,2(a0)
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,2(a0)
	eor.b	#%00000001,(a0)+
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	eor.b	d0,2(a0)
	ELSE
	eor.b	#%00000001,(a0)
	eor.b	#%00000001,2(a0)
	ENDC
	add.w	a3,d1
	bcc.s	*+6
	lea		SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutPosNoSlope_2bplEnd

myDrawRoutNegNoSlope_2bplStart
	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	sub.w	a3,d1					; add dy frac							;2
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d0,2(a0)
	eor.b	d0,(a0)+
	ELSE
	eor.b	#%00000001,2(a0)
	eor.b	#%00000001,(a0)+
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ 	DRAWREGS
	eor.b	d5,(a0)
	eor.b	d5,2(a0)
	ELSE
	eor.b	#%10000000,(a0)			; draw pixel							;4
	eor.b	#%10000000,2(a0)			; draw pixel							;4
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d6,(a0)
	eor.b	d6,2(a0)
	ELSE
	eor.b	#%01000000,(a0)													
	eor.b	#%01000000,2(a0)													
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d4,(a0)
	eor.b	d4,2(a0)
	ELSE
	eor.b	#%00100000,(a0)
	eor.b	#%00100000,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d2,(a0)
	bchg	d2,2(a0)
	ELSE
	eor.b	#%00010000,(a0)
	eor.b	#%00010000,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d3,(a0)
	eor.b	d3,2(a0)
	ELSE
	eor.b	#%00001000,(a0)
	eor.b	#%00001000,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d2,(a0)
	eor.b	d2,2(a0)
	ELSE
	eor.b	#%00000100,(a0)
	eor.b	#%00000100,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	bchg	d0,(a0)
	bchg	d0,2(a0)
	ELSE
	eor.b	#%00000010,(a0)
	eor.b	#%00000010,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0

	IFEQ	DRAWREGS
	eor.b	d0,(a0)
	eor.b	d0,2(a0)
	ELSE
	eor.b	#%00000001,(a0)
	eor.b	#%00000001,2(a0)
	ENDC
	sub.w	a3,d1
	bcc.s	*+6
	lea		-SCANLINEWIDTH(a0),a0
	addq.w	#7,a0
myDrawRoutNegNoSlope_2bplEnd


copyCodeTemplate
	sub.l	a2,a3			; number of bytes
	move.l	a3,d4			; save
	lsr.w	#1,d4			; shit down
	sub.w	#1,d4			; one less
	move.l	#xbars-1,d6
.copy
	move.w	d4,d5
	move.l	a2,a1
.doOne
			move.w	(a1)+,(a0)+
		dbra	d5,.doOne

	dbra	d6,.copy
	rts

clearColumn	macro
y_off set \1*SCANLINEWIDTH
x_off set \2
height set \3

y_start set ((160-height)/2)*SCANLINEWIDTH

y set y_off+x_off+y_start			;20+
	REPT height
		move.l	d0,y(a0)				;4				
y set y+SCANLINEWIDTH
	ENDR
	endm

cubevertWaiter	dc.w	3




generateClearStuff
	lea		buf+clearCodePtr,a0
	move.w	#160,d5
	lea		multitab,a1
	move.l	.code,d7
.next
	move.w	(a1)+,d7			; offset
	blt		.end
		move.w	(a1)+,d0		; height

		move.w	d0,d6
		lsr.w	#5,d6
		beq		.dorest
		subq.w	#1,d6
.do16
		REPT 32
			move.l	d7,(a0)+
			add.w	d5,d7
		ENDR
		dbra	d6,.do16
.dorest
		and.w	#%11111,d0
		beq		.next
		subq.w	#1,d0

.do1
		move.l	d7,(a0)+
		add.w	d5,d7
	dbra	d0,.do1	
	


	jmp		.next
.end
	move.w	#$4e75,(a0)+
	rts
.code	move.l	d0,1234(a0)

multitab
	dc.w	52*160+32,96					
	dc.w	31*160+40,138
	dc.w	20*160+48,160
	dc.w	11*160+56,178
	dc.w	7*160+64,186
	dc.w	5*160+72,190
	dc.w	5*160+80,190
	dc.w	7*160+88,186
	dc.w	12*160+96,176
	dc.w	19*160+104,162
	dc.w	31*160+112,138
	dc.w	51*160+120,98
	dc.w	-1

eorCodePtr	dc.l	0


generateEorStuff
	move.l	eorCodePtr,a0
	move.w	#160,d4
	lea		multitab,a1
	move.l	.codem,d7		; move
	move.l	.codee,d6		; eor
.next
	move.w	(a1)+,d7			; offset
	blt		.end
		move.w	d7,d6		; same place
		add.w	d4,d6
		move.w	(a1)+,d0		; height

		move.w	d0,d5
		lsr.w	#5,d5
		beq		.dorest
		subq.w	#1,d5
.do16
		REPT 32
			move.l	d7,(a0)+
			move.l	d6,(a0)+
			add.w	d4,d7
			add.w	d4,d6
		ENDR
		dbra	d5,.do16
.dorest
		and.w	#%11111,d0
		beq		.next
		subq.w	#1,d0

.do1
		move.l	d7,(a0)+
		move.l	d6,(a0)+
		add.w	d4,d7
		add.w	d4,d6
	dbra	d0,.do1	
	jmp		.next
.end
	move.w	#$4e75,(a0)+
	rts
.codem	move.l	1234(a0),d0							;4
.codee	eor.l	d0,1234+160(a0)				;6





clearScreen1plOpt1
	move.l	screenpointer2,a0
	add.l	cubeOffset,a0
	add.w	#4,a0
	IFEQ SHOWMASK
		moveq	#-1,d0
	ELSE
		moveq	#0,d0
	ENDC
	jmp		buf+clearCodePtr
;	move.l	#fin-start,d0
;	move.b	#0,$ffffc123
;
;start
;			clearColumn	20,32,90	
;			clearColumn	20,40,126
;			clearColumn	20,48,156
;			clearColumn	20,56,174
;			clearColumn	20,64,178
;			clearColumn	20,72,190
;			clearColumn	20,80,186
;			clearColumn	20,88,184
;			clearColumn	20,96,170
;			clearColumn	20,104,160
;			clearColumn	20,112,126
;			clearColumn	20,120,90
;fin
;	rts

eorfill macro
y_off set \1*SCANLINEWIDTH
x_off set \2
height set \3

y_start set ((160-height)/2)*SCANLINEWIDTH

y set y_off+x_off+y_start
	REPT height-1
		move.l	y(a0),d0							;4
		eor.l	d0,y+SCANLINEWIDTH(a0)				;6
y set y+SCANLINEWIDTH
	ENDR
	endm

eorFillScreen1plOpt
	move.l	screenpointer2,a0
	add.l	cubeOffset,a0

	add.w	#4,a0
	move.l	eorCodePtr,a1
	jmp		(a1)
;	jmp		eorCodePtr

;			eorfill	20,32,90						;90
;			eorfill	20,40,126					;90
;			eorfill	20,48,156					;212
;			eorfill	20,56,174					;352
;			eorfill	20,64,178					;506
;			eorfill	20,72,190					;666
;			eorfill	20,80,186					;826	
;			eorfill	20,88,184					;980
;			eorfill	20,96,170					;1126
;			eorfill	20,104,160					;1246
;			eorfill	20,112,126					;1336
;			eorfill	20,120,90					;1336
;	rts


increaseStep
	add.w	#9,_currentStepX
	add.w	#5,_currentStepY
	add.w	#11,_currentStepZ
	and.w	#sintable_size-1,_currentStepX
	and.w	#sintable_size-1,_currentStepY
	and.w	#sintable_size-1,_currentStepZ
.end
	rts	

blank	ds.l	1
skipLines
	lea		blank,a2
	rts

upslope	dc.w	0


errorCorrect	macro
		move.l	d6,d3			; FyInc			
		lsl.l	#8,d3			; max 512
		swap	d3
		mulu	d5,d3
		lsr.l	#8,d3
		tst.w	upslope
		beq		.adderr
.suberr
		sub.l	d3,d1
		jmp		.noCorrection
.adderr
		add.l	d3,d1
	endm

divideShit	macro
	IFEQ PRECISEDIV
		divideShitDiv
	ELSE
		divideShitMultable
	ENDC
	ENDM

divideShitMultable	macro
	lsl.l	#4,d3
	lsl.l	#4,d2
	sub.w	d2,d2
	sub.w	d3,d3
	swap	d3
	swap	d2
	lea		buf+multable,a4
	add.w	d2,d2
	muls	(a4,d2.w),d3
	move.l	d3,d6

	endm

divideShitDiv	macro
	; determine slope
	; dx/dy				; dx = d2; 16.16 int.frac
	;					; dy = d3; 16.16 int.frac	of both, only max 512 bits used (can assume 256 as well)
						;							2^9 = 512, so we have 7 bits left for fraction 

	; divs stuff:
	;	uuuu llll
	;	---- dddd
	;	--> 
	;	put 2 longwords in, get two words out, one word int, one int frac
	;	y/x = 
	;	
	;	I want output like: 16 int, 16 frag
	lsl.l	#8,d3		; up 7, because source int is max 512
	lsl.l	#8,d2		; ditto

	sub.w	d3,d3		; clear lower

	swap	d3			
	swap	d2			

	divu	d2,d3		; result is whole

	move.w	d3,d6		; whole
	sub.w	d3,d3		; clear lower

	divu	d2,d3		; divide remaining
	swap	d6			; swap
	move.w	d3,d6		; remainder
	endm




; d0,d1,d2,d3 in
drawLines
; 	lea		ytable2,a1
	move.l	d7,a1
	move.w	#0,upslope
	cmp.l	d0,d2
	bge.s	.noswap
		exg		d0,d2
		exg		d1,d3
.noswap
	move.l	d0,d5
	add.l	#$ffff,d5
	sub.w	d5,d5								; round x_left
	move.l	d2,d4
	add.l	#$ffff,d4
	sub.w	d4,d4								; round x_right
	sub.l	d5,d4														; d5 = ceil (xleft)
	ble		skipLines

	sub.l	d0,d2		; x_right - x_left 
	ble		skipLines

	sub.l	d1,d3		; y_right - y_left
	bgt		.up
		move.w	#-1,upslope
		neg.l	d3
.up
	divideShit

; # the error we lost is (1.0-orig_y_frac) or (ceil_y - orig_y)
; Fxerr = (ix0 << 16) - Fx0			# ceil'd x minus original x = +ve error lost
	move.l	d5,d2
	sub.l	d0,d5									; x_rounding_error	
	beq.s	.noCorrection	
; # compensate Y for rounding error in X
; # CAUTION: I HAVE NO FUCKING IDEA why the int(...) cast is needed around the shift. it's shifting an int. wtf ?_? python
; # if you remove this, the PlotPixelRaw complains of non-integer parameters
; Fyscan = Fy0 + int(int(Fyinc * Fxerr) >> 16)	# assumes ceil() for rounding earlier
;		move.l	d7,d3			; FyInc			
;		lsl.l	#8,d3			; max 512
;		swap	d3
;		mulu	d5,d3
;		lsr.l	#8,d3
;		tst.w	upslope
;		beq		.adderr
;.suberr
;		sub.l	d3,d1
;		jmp		.noCorrection
;.adderr
;		add.l	d3,d1
	errorCorrect
.noCorrection
	; d6 is 16.16


 

	; y offset to screen
	add.l	#$ffff,d1			; y_corrected + 0.9999	
	swap	d1
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	; we need to put this here for some slope opt
	move.w	d6,a3
	swap 	d6				; int slope
	add.w	d6,d6
	bne		.gotSlope
	; if this is 0, then we dont need no stinkin slopes, and this influences the xtable selection AND drawRout detection
.noSlope
	lea		buf+xtable2_noslope,a1
	tst.w	upslope
	beq		.positive_noslope
		lea		buf+myDrawRoutNegNoSlope,a2
	jmp		.go
.positive_noslope
		lea		buf+myDrawRoutPosNoSlope,a2		; for smc
	jmp		.go

.gotSlope
	move.w	(a1,d6.w),d6
	; x offset to screen
	lea		buf+xtable2,a1			; xtable
	tst.w	upslope
	beq		.positive
 		neg.w	d6
		lea		buf+myDrawRoutNeg,a2
	jmp		.go
.positive
		lea		buf+myDrawRoutPos,a2		; for smc
.go

	swap	d2					; get integer
	add.w	d2,d2				; *4
	add.w	d2,d2
	add.w	d2,a1				; add x_left starting position
;	add.w	(a1)+,d1			; x+y-offset
;	add.w	d1,a0
	add.w	(a1)+,d1			; x+y-offset
	add.w	d1,a0

	move.l	a2,a4
	swap	d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	(a1,d4.w),a2
;	move.w	(a2),smcStore		; make this smc, and free up a3
	move.w	(a2),(a6)		; make this smc, and free up a3
	move.w	#$4E75,(a2)			; rts

	; using for SMC
	;	a0		screenpointer
	;	a1		?
	;	a2,a3

	add.w	(a1),a4
	
	move.w	d6,a1
	move.w	#%10000000,d5
	move.w	#%01000000,d6				; this can be moved outside loop?
	move.w	#%00100000,d4
	moveq	#8,d3
	moveq	#4,d2
	moveq	#1,d0
	swap	d1
	jmp		(a4)	



drawLines2
; 	lea		ytable2,a1
	move.l	d7,a1
	move.w	#0,upslope
	cmp.l	d0,d2
	bge.s	.noswap
		exg		d0,d2
		exg		d1,d3
.noswap
	move.l	d0,d5
	add.l	#$ffff,d5
	sub.w	d5,d5								; round x_left
	move.l	d2,d4
	add.l	#$ffff,d4
	sub.w	d4,d4								; round x_right
	sub.l	d5,d4														; d5 = ceil (xleft)
	ble		skipLines
.drawLine
	sub.l	d0,d2		; x_right - x_left 
	ble		skipLines
	sub.l	d1,d3		; y_right - y_left
	bgt		.up
		move.w	#-1,upslope
		neg.l	d3
.up
	divideShit
	move.l	d5,d2	
	sub.l	d0,d5									; x_rounding_error	
	beq.s	.noCorrection	
		errorCorrect
.noCorrection
	add.l	#$ffff,d1			; y_corrected + 0.9999	
	swap	d1					; get integer
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	move.w	d6,a3
	swap 	d6				; int slope
	add.w	d6,d6
	bne		.gotSlope
.noSlope
	lea		buf+xtable2_noslope_2bpl,a1
	tst.w	upslope
	beq		.positive_noslope
		lea		buf+myDrawRoutNegNoSlope_2bpl,a2
	jmp		.go
.positive_noslope
		lea		buf+myDrawRoutPosNoSlope_2bpl,a2		; for smc
	jmp		.go

.gotSlope
	move.w	(a1,d6.w),d6
	; x offset to screen
	lea		buf+xtable2_2bpl,a1			; xtable
	tst.w	upslope
	beq		.positive
 		neg.w	d6
		lea		buf+myDrawRoutNeg_2bpl,a2
	jmp		.go
.positive
		lea		buf+myDrawRoutPos_2bpl,a2		; for smc
.go
	swap	d2					; get integer
	add.w	d2,d2				; *4
	add.w	d2,d2
	add.w	d2,a1				; add x_left starting position
	add.w	(a1)+,d1			; x+y-offset
	add.w	d1,a0

	move.l	a2,a4
	swap	d4
	add.w	d4,d4
	add.w	d4,d4
	add.w	(a1,d4.w),a2
;	move.w	(a2),smcStore		; SAVE MY SHIST
	move.w	(a2),(a6)		; SAVE MY SHIST
	move.w	#$4E75,(a2)			; rts

	; using for SMC
	;	a0		screenpointer
	;	a1		?
	;	a2,a3

	add.w	(a1),a4
	
	move.w	d6,a1
	move.w	#%10000000,d5
	move.w	#%01000000,d6				; this can be moved outside loop?
	move.w	#%00100000,d4
	moveq	#8,d3
	moveq	#4,d2
	moveq	#1,d0
	swap	d1
	jmp		(a4)

facesVisible	
	ds.w	6
	dc.w	-1


doPalette
	lea	$ffff8240+4*2,a0		; target palette
	lea	facesVisible,a1

	lea	buf+paletteLUT,a2

	move.w	(a1)+,d0
	bne		.this1
		move.w	4(a1),d0
.this1
		move.w	(a2,d0.w),(a0)+			;4
		sub.w	#$100,d0
		move.w	(a2,d0.w),(a0)+		;5
		move.w	(a2,d0.w),(a0)+		;6
		move.w	(a2,d0.w),(a0)+		;7


	move.w	(a1)+,d0
	bne		.this2
		move.w	4(a1),d0
.this2
		move.w	(a2,d0.w),(a0)+			;8
		sub.w	#$100,d0
		move.w	(a2,d0.w),(a0)+		;9
		move.w	(a2,d0.w),(a0)+		;10
		move.w	(a2,d0.w),(a0)+		;11
;		move.w	d0,(a0)+			;4,5
;		move.w	d0,(a0)+			;4,5
;		move.w	d0,(a0)+			;4,5
;		move.w	d0,(a0)+			;4,5



	move.w	(a1)+,d0
	bne		.this3
		move.w	4(a1),d0
.this3
		move.w	(a2,d0.w),(a0)+			;12
		sub.w	#$100,d0
		move.w	(a2,d0.w),(a0)+		;13
		move.w	(a2,d0.w),(a0)+		;14
		move.w	(a2,d0.w),(a0)+		;15
;		move.w	d0,(a0)+			;4,5
;		move.w	d0,(a0)+			;4,5
;		move.w	d0,(a0)+			;4,5
;		move.w	d0,(a0)+			;4,5

	rts

_sintable_ball
_sintable		include	"flatshade/sintable_amp32768_steps1024.s"


cubeVertices	
;a set 20*10
a set	32000
		dc.w	a,a,a
		dc.w	-a,a,a
		dc.w	-a,-a,a
		dc.w	a,-a,a

		dc.w	a,a,-a
		dc.w	-a,a,-a
		dc.w	-a,-a,-a
		dc.w	a,-a,-a


verticesMasks
		dc.w	%111<<5		;0		1,1,1
		dc.w	%011<<5		;1		-1,1,1
		dc.w	%001<<5		;2		-1,-1,1
		dc.w	%101<<5		;3		1,-1,1

		dc.w	%110<<5		;4		1,1,-1
		dc.w	%010<<5		;5		-1,1,-1
		dc.w	%000<<5		;6	
		dc.w	%100<<5		;7

		dc.w	-1

		rsreset


ytable2							ds.w	200
; for rotation stuff
_currentStepX					ds.w	1
_currentStepY					ds.w	1
_currentStepZ					ds.w	1	
; for inverse camera, culling
_zx								ds.l	1
_zy								ds.l	1
_zz								ds.l	1

smcStore						ds.w	1


currentVertices					ds.w	32
projectedVertices				ds.w	32


raster_ofs:		ds.w	1
	even

;	section text


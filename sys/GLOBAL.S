;--------  TOM'S GLOBAL TOOLS ------------------------
;-------- suck compared with evl's but whatevz -------

		section	text

global_calc_sinewave_new:

; a0 = destination
; d0 = start of phase (/255) - ALL .W
; d1 = end of phase
; d2 = amplitude
; d3 = addition
; d4 = steps
; d5 = number of times to repeat wave (ideally to fit in 256b counter)
; d6 = multiplier (e.g. for pointers into buffer/screen mem)

		lea	sin,a1
		move.l	a1,a2		; backup dest
		move.l	a0,a5

		move.w	#1,a6
		moveq	#0,d7

		add.w	d0,d0
		add.w	d1,d1
		adda.w	d0,a1		; a1 = pointer to start of phase
		adda.w	d1,a2
		add.w	d4,d4		; double steps
		move.w	d4,.gf+2

		moveq	#8,d1
		moveq	#0,d4

.wl:			move.w	(a1),d0
.gf:			lea	$1234(a1),a1

			mulu.w	d2,d0
			lsr.l	d1,d0
			addx.w	d7,d0

			add.w	d3,d0

			tst.w	d6
			beq.s	.skm
			mulu.w	d6,d0

.skm:			move.w	d0,(a0)+
			add.w	a6,d4

			cmpa.l	a2,a1
			ble.s	.wl
	
		subq	#1,d5		; how many copies?
		tst.w	d5
		beq	.end

		subq	#1,d5		; prep copyloop		
		subq	#1,d4

.bl:			move.l	a5,a1
			move.w	d4,d6		; get ready to loop

.cl:				move.w	(a1)+,(a0)+
				dbf	d6,.cl

			dbf	d5,.bl	

.end:		rts




global_copy_code:
		; a0 = codebuf
		; d0 = start ad
		; d1 = end ad
		; d7 = number of lines

		sub.l	d0,d1
		lsr.w	#1,d1
		sub.w	#1,d1
		sub.w	#1,d7

.cl1:		move.w	d1,d2
		move.l	d0,a1
.cl2:			move.w	(a1)+,(a0)+
			dbf	d2,.cl2
		dbf	d7,.cl1

		rts

; d0 = start; d1 = end; must be in words
global_clr_memory:

	move.l	d0,a0
	move.l	d1,a1

	sub.l	d0,d1
	move.l	d1,d0
	lsr.l	#5,d0
	andi.l	#31,d1
	lsr.l	#1,d1

	moveq	#0,d2

	tst.l	d0
	beq.s	.nxt

	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d7,a2
	move.l	d7,a3

	subq	#1,d0

.cm:	movem.l	d2-d7/a2-a3,-(a1)
	dbf	d0,.cm

.nxt:	tst.l	d1
	beq.s	.end

	subq	#1,d1
.co:	move.w	d2,(a0)+
	dbf	d1,.co

.end:	rts



global_fadefromblack:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = number of colours to do

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
		move.w	#0,a5		; count
		
.copy:		move.w	(a6)+,(a0)+
		dbf	d7,.copy

;; from gfx pal

		move.l	a0,a1
		suba.w	d0,a1
		suba.w	d0,a1
		moveq	#0,d0

		add.w	#1,a5			; a5 = count
		move.w	#$0f00,d4		; d4 = mask
		move.w	#$0100,d5		; d5 = increment

.mfl:		
		moveq	#1,d6			; flag to see if fade done
		move.w	(sp),d7

.ecfl:			move.w	(a1)+,d0		; d0 = cur gen pal colour		
			beq.s	.write

			clr.w	d6			; set change flag
			move.w	d0,d2			; d2 = gen pal bkup
			and.w	d4,d2			; isolate rgb
			beq.s	.write

.sub:			sub.w	d5,d0
.write:			move.w	d0,(a0)+

			dbf	d7,.ecfl

		lsr.w	#4,d5
		lsr.w	#4,d4
		bne.s	.chk

		move.w	#$0f00,d4
		move.w	#$0100,d5

.chk:		adda.w	#1,a5		; one more palette in
		tst.w	d6
		beq	.mfl

; -30(a0) is the pointer to the start of the palette run

		clr.w	(sp)+
		rts


global_fadefromwhitetosepia:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = number of colours to do

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)

		lea	rr,a4
		lea	rtab,a5

.cloop:			move.w	(a6)+,d1
			move.w	d1,d2
			move.w	d2,d3
			moveq	#0,d5

			andi.w	#$700,d1
			lsr.w	#8,d1

			andi.w	#$070,d2
			lsr.w	#4,d2

			andi.w	#$007,d3

			moveq	#0,d4
			move.b	(a4,d1.w),d4
			add.b	8(a4,d2.w),d4
			add.b	16(a4,d3.w),d4
			add.w	d4,d4
			move.w	(a5,d4.w),d5

			moveq	#0,d4
			move.b	24(a4,d1.w),d4
			add.b	32(a4,d2.w),d4
			add.b	40(a4,d3.w),d4
			add.w	d4,d4
			or.w	20(a5,d4.w),d5

			moveq	#0,d4
			move.b	48(a4,d1.w),d4
			add.b	56(a4,d2.w),d4
			add.b	64(a4,d3.w),d4
			add.w	d4,d4
			or.w	40(a5,d4.w),d5

			move.w	d5,(a0)+

		dbf	d7,.cloop

		move.w	#0,a5		; count
		bra	gl_dtf


global_fadefromwhite:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = number of colours to do

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
		move.w	#0,a5		; count
		
.copy:		move.w	(a6)+,(a0)+
		dbf	d7,.copy

;; from gfx pal

gl_dtf:		move.l	a0,a1
		suba.w	d0,a1
		suba.w	d0,a1
		moveq	#0,d0

		add.w	#1,a5			; a5 = count
		move.w	#$0700,d4		; d4 = mask
		move.w	#$0100,d5		; d5 = increment

.mfl:		
		moveq	#1,d6			; flag to see if fade done
		move.w	(sp),d7

.ecfl:			move.w	(a1)+,d0		; d0 = cur gen pal colour
			cmp.w	#$777,d0		
			beq.s	.write

			clr.w	d6			; set change flag
			move.w	d0,d2			; d2 = gen pal bkup
			and.w	d4,d2			; isolate rgb
			cmp.w	d4,d2
			beq.s	.write

.sub:			add.w	d5,d0
.write:			move.w	d0,(a0)+

			dbf	d7,.ecfl

		lsr.w	#4,d5
		lsr.w	#4,d4
		bne.s	.chk

		move.w	#$0700,d4
		move.w	#$0100,d5

.chk:		adda.w	#1,a5		; one more palette in
		tst.w	d6
		beq	.mfl

; -30(a0) is the pointer to the start of the palette run

		clr.w	(sp)+
		rts



global_flashtowhite:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = # cols

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
		move.w	#0,a5		; count
	
.copy:		move.w	#$777,(a0)+
		dbf	d7,.copy

;; from gfx pal

		move.l	a0,a1			; a1 = last gen pal
		suba.w	d0,a1
		suba.w	d0,a1
		add.w	#1,a5			; a5 = count

.mfl:		move.l	a6,a2			; a2 = work target pal
		moveq	#1,d6			; flag to see if fade done
		move.w	(sp),d7

.ecfl:			move.w	(a1)+,d0		; d0 = cur gen pal colour
			move.w	(a2)+,d1

			cmp.w	d1,d0			; equal?
			beq.s	.write

			clr.w	d6			; set change flag
			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$f00,d2		; isolate rgb
			move.w	d1,d3
			andi.w	#$f00,d3

			cmp.w	d3,d2		; equal?
			beq.s	.gr

				subi.w	#$100,d0
				moveq	#0,d6

.gr:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$0f0,d2		; isolate rgb
			move.w	d1,d3
			andi.w	#$0f0,d3

			cmp.w	d3,d2		; equal?
			beq.s	.bl

				subi.w	#$010,d0
				moveq	#0,d6

.bl:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$00f,d2		; isolate rgb
			move.w	d1,d3
			andi.w	#$00f,d3

			cmp.w	d3,d2		; equal?
			beq.s	.write

				subi.w	#$001,d0
				moveq	#0,d6

.write:			move.w	d0,(a0)+
			dbf	d7,.ecfl


		adda.w	#1,a5		; one more palette in
		tst.w	d6
		beq	.mfl

; -30(a0) is the pointer to the start of the palette run

		clr.w	(sp)+
		rts



global_flashtoblack:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = # cols

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
		move.w	#0,a5		; count
	
.copy:		move.w	#0,(a0)+
		dbf	d7,.copy

;; from gfx pal

		move.l	a0,a1			; a1 = last gen pal
		suba.w	d0,a1
		suba.w	d0,a1
		add.w	#1,a5			; a5 = count

.mfl:		move.l	a6,a2			; a2 = work target pal
		moveq	#1,d6			; flag to see if fade done
		move.w	(sp),d7

.ecfl:			move.w	(a1)+,d0		; d0 = cur gen pal colour
			move.w	(a2)+,d1

			cmp.w	d1,d0			; equal?
			beq.s	.write

			clr.w	d6			; set change flag
			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$f00,d2		; isolate rgb
			move.w	d1,d3
			andi.w	#$f00,d3

			cmp.w	d3,d2		; equal?
			beq.s	.gr

				addi.w	#$100,d0
				moveq	#0,d6

.gr:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$0f0,d2		; isolate rgb
			move.w	d1,d3
			andi.w	#$0f0,d3

			cmp.w	d3,d2		; equal?
			beq.s	.bl

				addi.w	#$010,d0
				moveq	#0,d6

.bl:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$00f,d2		; isolate rgb
			move.w	d1,d3
			andi.w	#$00f,d3

			cmp.w	d3,d2		; equal?
			beq.s	.write

				addi.w	#$001,d0
				moveq	#0,d6

.write:			move.w	d0,(a0)+
			dbf	d7,.ecfl


		adda.w	#1,a5		; one more palette in
		tst.w	d6
		beq	.mfl

; -30(a0) is the pointer to the start of the palette run

		clr.w	(sp)+
		rts


global_flashfromwhite:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = # cols

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
		move.w	#0,a5		; count
	
.copy:		move.w	(a6)+,(a0)+
		dbf	d7,.copy

;; from gfx pal

		move.l	a0,a1			; a1 = last gen pal
		suba.w	d0,a1
		suba.w	d0,a1
		add.w	#1,a5			; a5 = count

.mfl:		moveq	#1,d6			; flag to see if fade done
		move.w	(sp),d7

.ecfl:			move.w	(a1)+,d0		; d0 = cur gen pal colour

			cmpi.w	#$777,d0		; equal?
			beq.s	.write

			clr.w	d6			; set change flag
			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$f00,d2		; isolate rgb

			cmpi.w	#$700,d2		; equal?
			beq.s	.gr

				addi.w	#$100,d0
				moveq	#0,d6

.gr:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$0f0,d2		; isolate rgb

			cmpi.w	#$070,d2		; equal?
			beq.s	.bl

				addi.w	#$010,d0
				moveq	#0,d6

.bl:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$00f,d2		; isolate rgb

			cmpi.w	#$007,d2		; equal?
			beq.s	.write

				addi.w	#$001,d0
				moveq	#0,d6

.write:			move.w	d0,(a0)+
			dbf	d7,.ecfl


		adda.w	#1,a5		; one more palette in
		tst.w	d6
		beq	.mfl

; -30(a0) is the pointer to the start of the palette run

		clr.w	(sp)+
		rts


global_flashfromblack:
; a0 = buffer to write to
; a6 = target palette
; a3/a4 clean
; d0 = # cols

		move.w	d0,d7
		subq.w	#1,d7
		move.w	d7,-(sp)
		move.w	#0,a5		; count
	
.copy:		move.w	(a6)+,(a0)+
		dbf	d7,.copy

;; from gfx pal

		move.l	a0,a1			; a1 = last gen pal
		suba.w	d0,a1
		suba.w	d0,a1
		add.w	#1,a5			; a5 = count

.mfl:		moveq	#1,d6			; flag to see if fade done
		move.w	(sp),d7

.ecfl:			move.w	(a1)+,d0		; d0 = cur gen pal colour
			beq.s	.write

			clr.w	d6			; set change flag
			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$f00,d2		; isolate rgb
			beq.s	.gr

				subi.w	#$100,d0
				moveq	#0,d6

.gr:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$0f0,d2		; isolate rgb
			beq.s	.bl

				subi.w	#$010,d0
				moveq	#0,d6

.bl:			move.w	d0,d2			; d2 = gen pal bkup
			andi.w	#$00f,d2		; isolate rgb
			beq.s	.write

				subi.w	#$001,d0
				moveq	#0,d6

.write:			move.w	d0,(a0)+
			dbf	d7,.ecfl


		adda.w	#1,a5		; one more palette in
		tst.w	d6
		beq	.mfl

; -30(a0) is the pointer to the start of the palette run

		clr.w	(sp)+
		rts


;-----------------------------------------------;

		section	data

sin:		incbin	'sys\sin2.tab'

; sepia transform
rr:		dc.b	0,0,1,1,2,2,2,3
rg:		dc.b	0,1,2,2,3,4,5,5
rb:		dc.b	0,0,0,1,1,1,1,1
gr:		dc.b	0,0,1,1,1,2,2,2
gg:		dc.b	0,1,1,2,3,3,4,5
gb:		dc.b	0,0,0,1,1,1,1,1
br:		dc.b	0,0,1,1,1,1,2,2
bg:		dc.b	0,1,1,2,2,3,3,4
bb:		dc.b	0,0,0,0,1,1,1,1
rtab:		dc.w	$000,$100,$200,$300,$400,$500,$600,$700,$700,$700
gtab:		dc.w	$000,$010,$020,$030,$040,$050,$060,$070,$070,$070
btab:		dc.w	$000,$001,$002,$003,$004,$005,$006,$007,$007,$007
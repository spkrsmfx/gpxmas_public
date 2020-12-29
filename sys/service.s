; Synclock demosystem for ST/STe
;
; service.s
; Misc service routines
;
; ae@dhs.nu

service_palset:		equ	1
service_faders:		equ	1
service_clear:		equ	1
service_code_copy:	equ	1
service_lmc1992:	equ	1
service_loader:		equ	1
service_syscalls:	equ	1

		section	text

;-------------------------------------------------------
;		PALETTE SERVICE ROUTINES
;-------------------------------------------------------

		ifne	service_palset
;============== Set all ST/e-palette black =============
black_pal:	moveq	#0,d0
		lea	$ffff8240.w,a0
		rept	8
		move.l	d0,(a0)+
		endr
		rts

;============== Set all ST/e-palette white =============
white_pal:	ifne	ste_demo
		move.l	#$0fff0fff,d0
		else
		move.l	#$07770777,d0
		endc
		lea	$ffff8240.w,a0
		rept	8
		move.l	d0,(a0)+
		endr
		rts

;============== Set palette ============================
;in:	a0.l	address to palette
setpal:		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
		endc

		ifne	service_faders
;============== ST palette fade 8-steps ================
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
fade_st:	movem.l	d0-d6/a0-a2,-(sp)

		subq.w	#1,d0
.loop:
		move.w	(a0)+,d6			;source
		move.w	(a1)+,d3			;dest
		move.w	d6,d1
		move.w	d6,d2
		move.w	d3,d4
		move.w	d3,d5

		and.w	#$0700,d6
		and.w	#$0700,d3
		and.w	#$0070,d1
		and.w	#$0070,d4
		and.w	#$0007,d2
		and.w	#$0007,d5

.red:		cmp.w	d6,d3
		beq.s	.green
		blt.s	.redsub
		add.w	#$0100,d6
		bra.s	.green
.redsub:	sub.w	#$0100,d6


.green:		cmp.w	d1,d4
		beq.s	.blue
		blt.s	.greensub
		add.w	#$0010,d1
		bra.s	.blue
.greensub:	sub.w	#$0010,d1


.blue:		cmp.w	d2,d5
		beq.s	.store
		blt.s	.bluesub
		addq.w	#$1,d2
		bra.s	.store
.bluesub:	subq.w	#$1,d2

.store:		or.w	d1,d6
		or.w	d2,d6
		move.w	d6,(a2)+

		dbra	d0,.loop

		movem.l	(sp)+,d0-d6/a0-a2
		rts

;============== ST palette fade 24-steps (one component per call)
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
component_fade_st:
		movem.l	d0-d5/a0-a4,-(sp)

		subq.w	#1,d0
		lea	.component(pc),a4
.loop:
		move.w	(a0)+,d5			;source
		move.w	d5,d4
		move.w	(a1)+,d1			;dest

		move.w	(a4),d2				;mask
		move.w	6(a4),d3			;shift

		and.w	d2,d5
		and.w	d2,d1
		not.w	d2
		and.w	d2,d4
		lsr.w	d3,d5
		lsr.w	d3,d1

		cmp.w	d5,d1
		beq.s	.store
		blt.s	.sub
		addq.w	#1,d5
		bra.s	.store
.sub:		subq.w	#1,d5

.store:		lsl.w	d3,d5
		or.w	d5,d4
		move.w	d4,(a2)+
		dbra	d0,.loop

		;rotate masks and shifts
		move.w	(a4),d0
		lea	2(a4),a3
		move.l	(a3)+,(a4)+
		move.w	d0,(a4)+
		move.w	(a4),d0
		lea	2(a4),a3
		move.l	(a3)+,(a4)+
		move.w	d0,(a4)+

		movem.l	(sp)+,d0-d5/a0-a4
		rts
.component:	dc.w	$0007,$0070,$0700		;Masks
		dc.w	0,4,8				;Shifts


		ifne	ste_demo
;============== STe palette fade 16-steps ==============
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
fade_ste:	movem.l	d0-d7/a0-a4,-(sp)

		lea	stetohex(pc),a3
		lea	hextoste(pc),a4

		moveq	#$f,d7

		subq.w	#1,d0
.loop:
		move.w	(a0)+,d6			;source
		move.w	d6,d1
		move.w	d6,d2
		move.w	(a1)+,d3			;dest
		move.w	d3,d4
		move.w	d3,d5

		lsr.w	#8,d6
		lsr.w	#8,d3
		lsr.w	#4,d1
		lsr.w	#4,d4
		and.w	d7,d6
		and.w	d7,d1
		and.w	d7,d2
		and.w	d7,d3
		and.w	d7,d4
		and.w	d7,d5

		move.b	(a3,d6.w),d6
		move.b	(a3,d1.w),d1
		move.b	(a3,d2.w),d2
		move.b	(a3,d3.w),d3
		move.b	(a3,d4.w),d4
		move.b	(a3,d5.w),d5

.red:		cmp.b	d6,d3
		beq.s	.green
		blt.s	.redsub
		addq.b	#1,d6
		bra.s	.green
.redsub:	subq.b	#1,d6

.green:		cmp.b	d1,d4
		beq.s	.blue
		blt.s	.greensub
		addq.b	#1,d1
		bra.s	.blue
.greensub:	subq.b	#1,d1

.blue:		cmp.b	d2,d5
		beq.s	.store
		blt.s	.bluesub
		addq.b	#1,d2
		bra.s	.store
.bluesub:	subq.b	#1,d2

.store:		move.b	(a4,d6.w),d6
		move.b	(a4,d1.w),d1
		move.b	(a4,d2.w),d2
		lsl.w	#8,d6
		lsl.w	#4,d1
		or.w	d1,d6
		or.w	d2,d6
		move.w	d6,(a2)+

		dbra	d0,.loop

		movem.l	(sp)+,d0-d7/a0-a4
		rts

;============== STe palette fade 48-steps (one component per call)
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade
component_fade_ste:
		movem.l	d0-d5/a0-a6,-(sp)

		lea	stetohex(pc),a4
		lea	hextoste(pc),a5
		lea	.component(pc),a6

		subq.w	#1,d0
.loop:
		move.w	(a0)+,d5			;source
		move.w	d5,d4
		move.w	(a1)+,d1			;dest

		move.w	(a6),d2				;mask
		move.w	6(a6),d3			;shift

		and.w	d2,d5
		and.w	d2,d1
		not.w	d2
		and.w	d2,d4
		lsr.w	d3,d5
		lsr.w	d3,d1

		move.b	(a4,d5.w),d5			;stetohex
		move.b	(a4,d1.w),d1

		cmp.b	d5,d1
		beq.s	.store
		blt.s	.sub
		addq.b	#1,d5
		bra.s	.store
.sub:		subq.b	#1,d5

.store:		move.b	(a5,d5.w),d5			;hextoste

		lsl.w	d3,d5
		or.w	d5,d4
		move.w	d4,(a2)+
		dbra	d0,.loop

		;rotate masks and shifts
		move.w	(a6),d0
		lea	2(a6),a3
		move.l	(a3)+,(a6)+
		move.w	d0,(a6)+
		move.w	(a6),d0
		lea	2(a6),a3
		move.l	(a3)+,(a6)+
		move.w	d0,(a6)+

		movem.l	(sp)+,d0-d5/a0-a6
		rts
.component:	dc.w	$000f,$00f0,$0f00		;Masks
		dc.w	0,4,8				;Shifts

stetohex:	dc.b	$0,$2,$4,$6,$8,$a,$c,$e,$1,$3,$5,$7,$9,$b,$d,$f
hextoste:	dc.b	$0,$8,$1,$9,$2,$a,$3,$b,$4,$c,$5,$d,$6,$e,$7,$f
		endc

		endc

;-------------------------------------------------------
;		FAST CLEARING SERVICE ROUTINES
;-------------------------------------------------------

		ifne	service_clear
;============== Clear workscreens ======================
;clear_screens:	move.l	scraddrbase,a0
;		move.l	#scrsize*scrnum,d0
;		bra.s	fast_clear

;============== Clear generic BSS buffer ===============
clear_buf:	lea	buf,a0
		move.l	#bufsize,d0
		;bra.s	fast_clear

;============== Fast clear, even 256-byte chunks =======
;in:	a0.l	pointer to memory
;	d0.l	bytes to clear (even by 256 bytes)
fast_clear:
		add.l	d0,a0				;End of buffer
		lsr.l	#8,d0				;Don't loop lower 8bit
		subq.l	#1,d0

		moveq	#0,d1
		move.l	d1,d2
		move.l	d1,d3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a1
		move.l	d1,a2
		move.l	d1,a3
		move.l	d1,a4
		move.l	d1,a5
		move.l	d1,a6

.loop:		movem.l	d1-d7/a1-a6,-(a0)		;52 bytes
		movem.l	d1-d7/a1-a6,-(a0)		;104 bytes
		movem.l	d1-d7/a1-a6,-(a0)		;156 bytes
		movem.l	d1-d7/a1-a6,-(a0)		;208 bytes
		movem.l	d1-d7/a1-a5,-(a0)		;256 bytes
		dbra	d0,.loop
		rts
		endc


;-------------------------------------------------------
;		CODE MULTIPLYING SERVICE ROUTINES
;-------------------------------------------------------

		ifne	service_code_copy
;============== Code copy reset ========================
;in:	d0.l	address to code start (even address)
code_copy_reset:
		move.l	d0,code_copy_addr
		rts

;============== Copy code multiple times ===============
code_copy:
;in:	d0.l	Start address of code
;	d1.l	End address of code
;	d2.w	Copies to make
		lea	code_copy_addr(pc),a2
		move.l	(a2),a0
		sub.l	d0,d1				;length of routine
		lsr.l	#1,d1				;loop /2 (word copies)
		subq.l	#1,d1				;loop -1
		subq.w	#1,d2				;next loop -1
.next:		move.l	d1,d3
		move.l	d0,a1
.code:		move.w	(a1)+,(a0)+
		subq.l	#1,d3
		bpl.s	.code
		dbra	d2,.next
		move.l	a0,(a2)
		rts
code_copy_addr:	dc.l	0

;============== End code with RTS ======================
code_copy_rts:	lea	code_copy_addr(pc),a0
		move.l	(a0),a1
		move.w	.rts(pc),(a1)+
		move.l	a1,(a0)
.rts:		rts
		endc


;-------------------------------------------------------
;		MISC SERVICE ROUTINES
;-------------------------------------------------------

		ifne	service_lmc1992
		ifne	ste_demo
;============== Program LMC1992 through Microwire ======
;in:	d0.w	LMC1992 command
lmc1992:	move.w	#%11111111111,$ffff8924.w	;set microwire mask
		move.w	d0,$ffff8922.w
.waitstart	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		beq.s	.waitstart
.waitend	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		bne.s	.waitend
		rts
		endc
		endc


		ifne	service_loader
;============== Load file from disk ====================
;in:	a0.l	address to filename
;	a1.l	address to buffer
;	d0.l	bytes to load
load_file:	move.l	a1,.buf
		move.l	d0,.size

		clr.w	-(sp)				;fopen()
		move.l	a0,-(sp)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		tst.l	d0
		bmi.s	.skip
		move.w	d0,.fh

		move.l	.buf,-(sp)			;fread()
		move.l	.size,-(sp)
		move.w	.fh,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	.fh,-(sp)			;fclose()
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
.skip:		rts
.buf:		dc.l	0
.size:		dc.l	0
.fh:		dc.w	0
		endc

		ifne	service_syscalls
;============== Wait for vsync =========================
vsync:		move.w	#37,-(sp)			;vsync()
		trap	#14
		addq.l	#2,sp
		rts


;============== Print text string ======================
;in:	d0.l	address to null terminated string
cconws:		move.l	d0,-(sp)			;cconws()
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		rts

;============== Wait for key ===========================
crawcin:	move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts
		endc

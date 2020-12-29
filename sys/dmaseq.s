; Synclock demosystem for ST/STe
;
; dmaseq.s
; Simple DMA sound sequencer
;
; ae@dhs.nu

dmaseq_freq:	equ	1				;0=12516 Hz 1=25033 Hz

		
		section	text

;-------------- Load sample file(s) --------------------
dmaseq_load:
		ifne	floppy
		jsr	dmaseq_floppy_load
		else

		;move.w	#$0700,$ffff8240.w

		lea	dmaseq_fn,a0
		lea	dmaseq_sample,a1
		move.l	#1173931,d0
		jsr	load_file

		;move.w	#$0070,$ffff8240.w

		endc

		rts

;-------------- Init variables and setup hardware ------
dmaseq_init:	move.l	dmaseq_seq,dmaseq_dat
		move.l	dmaseq_seq+4,d0
		move.l	dmaseq_seq+8,d1

		move.b	d0,$ffff8907.w			;Start of sample
		lsr.l	#8,d0
		move.b	d0,$ffff8905.w
		lsr.l	#8,d0
		move.b	d0,$ffff8903.w

		move.b	d1,$ffff8913.w			;End of sample
		lsr.l	#8,d1
		move.b	d1,$ffff8911.w
		lsr.l	#8,d1
		move.b	d1,$ffff890f.w

		ifne	dmaseq_freq
		move.b	#%10000010,$ffff8921.w 		;25033Hz mono
		else
		move.b	#%10000001,$ffff8921.w 		;12517Hz mono
		endc

		rts

;-------------- Music sequencer ------------------------
dmaseq_vbl:
		tst.w	dmaseq_enabled
		bne.s	.go
		rts

.go:		subq.l	#1,.once
		bne.s	.playingalready

		move.b	#%00000011,$ffff8901.w		;Start sample with loop
.playingalready:
		lea	dmaseq_dat(pc),a1
		subq.l	#1,(a1)
		beq.s	.next_sample
		rts

.next_sample:	lea	dmaseq_addr(pc),a2
		move.l	(a2),a0
		tst.l	12(a0)
		bne.s	.no_loop
		lea	dmaseq_loop-12,a0

.no_loop:	lea	12(a0),a0
		move.l	a0,(a2)
		move.l	(a0)+,d0			;VBL counter
		move.l	d0,(a1)

		move.b	3(a0),$ffff8907.w		;Start of sample
		move.b	2(a0),$ffff8905.w
		move.b	1(a0),$ffff8903.w

		move.b	7(a0),$ffff8913.w		;End of sample
		move.b	6(a0),$ffff8911.w
		move.b	5(a0),$ffff890f.w

		rts
.once:		dc.l	1
dmaseq_enabled:	dc.w	0
dmaseq_addr:	dc.l	dmaseq_seq
dmaseq_dat:	dc.l	0

;-------------- Stop DMA sequence ----------------------
dmaseq_exit:	clr.w	dmaseq_enabled
		clr.b	$ffff8901.w			;Kill sample playback
		rts

dmaseq_enable_play:
		move.w	#1,dmaseq_enabled
		rts

		section	data

;-------------- Music datas ----------------------------
; 25033 Hz = 500.16 samples/vbl
; dc.l vbls,start-address,end-address ;for each sample
; dc.l 0 ;end of sample list
;500,16
		rsreset

dmaseq_seq:
		rept	3
		dc.l	207,dmaseq_blixt+54,dmaseq_blixt_end
		endr

		rept	50
		dc.l	2,dmaseq_empty,dmaseq_empty_end
		endr

dmaseq_loop:
		rept	7
		dc.l	.v01,dmaseq_sample+.s01,dmaseq_sample+.s02		;Sample 01
		endr

		dc.l	.v02,dmaseq_sample+.s02,dmaseq_sample+.s03		;Sample 02

		rept	7
		dc.l	.v03,dmaseq_sample+.s03,dmaseq_sample+.s04		;Sample 03
		endr

		dc.l	.v04,dmaseq_sample+.s04,dmaseq_sample+.s05		;Sample 04

		rept	7
		dc.l	.v04,dmaseq_sample+.s03,dmaseq_sample+.s04		;Sample 03
		endr

		dc.l	.v05,dmaseq_sample+.s05,dmaseq_sample+.s06		;Sample 05

		rept	3
		dc.l	.v06,dmaseq_sample+.s06,dmaseq_sample+.s07		;Sample 06
		endr

		dc.l	.v07,dmaseq_sample+.s07,dmaseq_sample+.s08		;Sample 07

		rept	3
		dc.l	.v08,dmaseq_sample+.s08,dmaseq_sample+.s09		;Sample 08
		endr

		dc.l	.v09,dmaseq_sample+.s09,dmaseq_sample+.s10		;Sample 09

		rept	3
		dc.l	.v10,dmaseq_sample+.s10,dmaseq_sample+.s11		;Sample 10
		endr

		dc.l	.v11,dmaseq_sample+.s11,dmaseq_sample+.s99		;Sample 11


		dc.l	0

		even


.s01:		rs.b	69055
.s02:		rs.b	69055
.s03:		rs.b	69055
.s04:		rs.b	69055
.s05:		rs.b	69055
.s06:		rs.b	138109
.s07:		rs.b	138109
.s08:		rs.b	138109
.s09:		rs.b	138109
.s10:		rs.b	138110
.s11:		rs.b	138110
.s99:		rs.b	0
.v01:		equ	138
.v02:		equ	138
.v03:		equ	138
.v04:		equ	138
.v05:		equ	138
.v06:		equ	276
.v07:		equ	276
.v08:		equ	276
.v09:		equ	276
.v10:		equ	276
.v11:		equ	276



		ifne	floppy
dmaseq_fn1:	dc.b	'music1.raw',0
		even
dmaseq_fn2:	dc.b	'music2.raw',0
		even
		else
dmaseq_fn:	dc.b	'music.raw',0
		even
		endc

dmaseq_blixt:
		incbin	'blixt.wav'
dmaseq_blixt_end:

dmaseq_empty:	dcb.w	512,$0000
dmaseq_empty_end:

		section	bss

		even
dmaseq_sample:	ds.b	1173931
dmaseq_sample_end:
		even

		section	text

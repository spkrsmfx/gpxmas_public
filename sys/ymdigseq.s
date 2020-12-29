; Synclock demosystem for ST/STe
;
; ymdigseq.s
; Plays unsigned 8-bit PCM sound with sequence
; Volume table by Wizzcat / Delta Force
;
; ae@dhs.nu


ymdigseq_hz7877:	equ	1				;0=15754 Hz 1=7877 Hz 
ymdigseq_fastplay:	equ	0				;1=faster interrupt that trashes a5 and d7, and uses a6 as sample pointer
								;Change the register saving in main.se vbl/timera

		section	text

ymdigseq_init:
		;Setup YM for sample playback
		lea	$ffff8800.w,a0
		move.l	#$00000000,(a0)				;Channel 1 tone period 0
		move.l	#$01000000,(a0)
		move.l	#$02000000,(a0)				;Channel 3 tone period 0
		move.l	#$03000000,(a0)
		move.l	#$04000000,(a0)				;Channel 3 tone period 0
		move.l	#$05000000,(a0)
		move.b	#7,(a0)					;Mixing all channels
		move.b	(a0),d0
		or.b	#%00111111,d0
		move.b	#7,(a0)
		move.b	d0,2(a0)


		move.w	#$2700,sr
		move.l	$40.w,ymdigseq_save40
		move.l	#ymdigseq_td,$110.w			;Timer D vector

		and.b	#%11111000,$fffffa1d.w			;Timer C/D control (stop Timer D)
		bclr	#3,$fffffa17.w				;Automatic end of interrupt
		bset	#4,$fffffa09.w				;Interrupt enable B (Timer-D)
		bset	#4,$fffffa15.w				;Interrupt mask B (Timer D)

		ifne	ymdigseq_hz7877
		move.b	#78,$fffffa25.w				;2457600/4/78 = 7877 Hz (Timer D Data)
		else						;HBL/2 = 7832 Hz (45 Hz diff)
		move.b	#39,$fffffa25.w				;2457600/4/39 = 15754 Hz (Timer D Data)
		endc						;HBL = 15666 Hz (88 Hz diff)

		lea	ymdigseq_sequence,a0			;Sample start address from sequence
		move.l	(a0)+,ymdigseq_count
		ifne	ymdigseq_fastplay
		move.l	(a0)+,a6				;a6 for sample pointer
		else
		move.l	(a0)+,$40.w				;Unused vector for sampel pointer
		endc

		move.w	#$2300,sr
		rts

ymdigseq_exit:
		move.l	#$08000000,$ffff8800.w			;Channel 1 silence
		move.l	#$09000000,$ffff8800.w			;Channel 2 silence
		move.l	#$0a000000,$ffff8800.w			;Channel 3 silence
		move.l	ymdigseq_save40,$40.w
		rts


ymdigseq_td:
		ifne	ymdigseq_fastplay
		moveq	#0,d7					;1	Fast play
		move.b	(a6)+,d7				;2	a6=Sample pointer
		move.l	a6,-(sp)				;3	a5 and d7 are trashed
		lsl.w	#4,d7					;4
		movem.l	ymdigseq_voltab(pc,d7.w),d7/a5-a6	;11
		movem.l	d7/a5-a6,$ffff8800.w			;9 
		move.l	(sp)+,a6				;3	=33
		else
		movem.l	a5-a6/d7,-(sp)				;9
		moveq	#0,d7					;1	Slow play
		move.l	$40.w,a6				;4	All regs free
		move.b	(a6)+,d7				;2
		move.l	a6,$40.w				;4
		lsl.w	#4,d7					;4
		movem.l	ymdigseq_voltab(pc,d7.w),d7/a5-a6	;11
		movem.l	d7/a5-a6,$ffff8800.w			;9 
		movem.l	(sp)+,a5-a6/d7				;8	=52
		endc
		rte

ymdigseq_voltab:
		incbin	'sys/wizvol.8'
		even

ymdigseq_hardsync_sample:	macro
; a6 = sample pointer
; a5/d7 trashed
		moveq	#0,d7					;1
		move.b	(a6)+,d7				;2
		lsl.w	#4,d7					;4
		movem.l	(a4,d7.w),d6-d7/a5			;12 (eqx table says 11??)
		movem.l	d6-d7/a5,$ffff8800.w			;10 (eqx table says 9??)
		endm


ymdigseq_syncscroll_sample:	macro
; a6 = sample pointer
; a5/d7 trashed
		not.w	d4					;1
		beq.s	.nosample				;taken=3, not taken=2

		moveq	#0,d7					;1
		move.b	(a6)+,d7				;2
		lsl.w	#4,d7					;4
		movem.l	(a4,d7.w),d6-d7/a5			;12 (eqx table says 11??)
		movem.l	d6-d7/a5,$ffff8800.w			;10 (eqx table says 9??)

		bra.s	.done					;3 =35 total 
.nosample:	dcb.w	31,$4e71
.done:		
		endm


ymdigseq_stop_sequence:
		move.w	#1,ymdigseq_play_silence
		rts

ymdigseq_vbl:
		and.b	#%11111000,$fffffa1d.w			;Timer C/D control (stop Timer D)
		or.b	#%00000001,$fffffa1d.w			;Timer D divide (by 4) (start Timer-D)

		tst.w	ymdigseq_play_silence
		beq.s	.go_on
		ifne	ymdigseq_fastplay
		move.l	#ymdigseq_silent_sample,a6
		else
		move.l	#ymdigseq_silent_sample,$40.w
		endc
		rts

.go_on:		lea	ymdigseq_count(pc),a2
		subq.l	#1,(a2)
		bne.s	.not_yet				;This sample still playing, don't change

		lea	.seqaddr(pc),a1
		move.l	(a1),a0

		addq.l	#8,a0
		tst.l	(a0)
		bne.s	.next_sample				;If not null, next sequence

		;lea	ymdigseq_sequence(pc),a0		;Loop sequence
		lea	ymdigseq_sequence_loop(pc),a0
.next_sample:	move.l	a0,(a1)					;Store sequence position
		move.l	(a0)+,(a2)				;VBL's to run
		ifne	ymdigseq_fastplay
		move.l	(a0)+,a6				;Set address of new sample
		else
		move.l	(a0)+,$40.w
		endc
.not_yet:	rts
.seqaddr:	dc.l	ymdigseq_sequence
ymdigseq_count:	dc.l	0



		section	data

; 157,3826 samples/vbl at 7877 Hz
cq_chords1v:	equ	100
cq_chords2v:	equ	100
cq_chords3v:	equ	75
cq_chords4v:	equ	25

ymdigseq_sequence:
ymdigseq_sequence_loop:
		;dc.l	vbl,startaddr

		dc.l	cq_chords1v,cq_chords1
		dc.l	cq_chords1v,cq_chords1
		dc.l	cq_chords2v,cq_chords2
		dc.l	cq_chords3v,cq_chords3
		dc.l	cq_chords4v,cq_chords4
		dc.l	cq_chords1v,cq_chords1
		dc.l	cq_chords1v,cq_chords1
		dc.l	cq_chords2v,cq_chords2
		rept	4
		dc.l	cq_chords4v,cq_chords4
		endr

		dc.l	0,0

cq_chords1:	incbin	'music/ymdigi/chords1.raw'
cq_chords2:	incbin	'music/ymdigi/chords2.raw'
cq_chords3:	incbin	'music/ymdigi/chords3.raw'
cq_chords4:	incbin	'music/ymdigi/chords4.raw'
		even

ymdigseq_silent_sample:
		ifne	ymdigseq_hz7877
		dcb.b	160,$00
		else
		dcb.w	320,$00
		endc

ymdigseq_play_silence:
		dc.w	0

		section	bss

ymdigseq_save40:ds.l	1

		section	text
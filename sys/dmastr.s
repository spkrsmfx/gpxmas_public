; Synclock demosystem for ST/STe
;
; dmastr.s
; Simple DMA audio streamer
; Call fillrout before the buffer has played through
;
; ae@dhs.nu


dmastream_size:	equ	25033*70					;Larger buffer = longer time between refills possible
dmastream_head:	equ	0						;Header size of sample
dmastream_vbls:	equ	dmastream_size*100/50016			;VBL's to run before stopping (-1 for endless)


		section	text

dmastream_init:
		move.w	#$4e75,(pc)					;run once
		lea	dmastream_SA,a0					;fill entire buffer initially
		move.l	#dmastream_size,d0
		moveq	#0,d1
		moveq	#0,d2
		bsr	dmastream_load

		move.l	#dmastream_EA-dmastream_SA,dmastream_seek	;update file offset

		rts

dmastream_startplay:
		move.w	#$4e75,(pc)					;run once
		move.w	#1,dmastream_doplay
		rts

dmastream_play:
		tst.w	dmastream_doplay
		beq.s	.notfinished

		tst.w	.once
		bne.s	.done
		not.w	.once

		move.l	#dmastream_SA,d0
		move.l	#dmastream_EA,d1
		bsr	dmastream_play_sample
.done:
		subq.l	#1,dmastream_counter
		bgt.s	.notfinished

		bsr	dmastream_exit
		move.w	#-1,dmastream_ended

.notfinished:	rts
.once:		dc.w	0

dmastream_stop_dmasound:
		move.w	#$4e75,(pc)					;run once
		clr.b	$ffff8901.w
		rts

dmastream_exit:
		clr.b	$ffff8901.w
		rts

dmastream_refill:
		tst.w	dmastream_ended
		bne	.done

		;if last loaded address is lower than current playing address

		moveq	#0,d0						;d0 = PP play pos
		move.b	$ffff8909.w,d0
		lsl.w	#8,d0
		move.b	$ffff890b.w,d0
		lsl.l	#8,d0
		move.b	$ffff890d.w,d0

		move.l	d0,dmastream_PP					;update play pos
		move.l	dmastream_LL,d1					;d1 = LL last load
		
		cmp.l	d0,d1
		bgt.s	.wrapbuf					;if LL > PP buffer will wrap around

		sub.l	d1,d0						;d0 = len
		move.l	d0,.len
		move.l	dmastream_seek,d1				;d1 = file offset

		move.l	dmastream_LL,a0					;a0 = buf addr
		moveq	#-1,d2
		bsr	dmastream_load

		move.l	.len,d0
		add.l	d0,dmastream_seek				;update file offset
		move.l	dmastream_PP,dmastream_LL			;update last load
		rts
.wrapbuf:
		;first fill to the top of the buffer
		move.l	#dmastream_EA,d0
		sub.l	dmastream_LL,d0					;d0 = len
		move.l	d0,.len
		move.l	dmastream_seek,d1				;d1 = file offset	
		move.l	dmastream_LL,a0					;a0 = buf addr
		move.l	#-1,d2
		bsr	dmastream_load

		move.l	.len,d0
		add.l	d0,dmastream_seek				;update file offset

		;now fill from bottom to playing position
		move.l	dmastream_PP,d0
		move.l	#dmastream_SA,d1
		sub.l	d1,d0						;d0 = len
		move.l	d0,.len
		move.l	dmastream_seek,d1				;d1 = file offset
		lea	dmastream_SA,a0					;a0 = buf addr
		moveq	#-1,d2
		bsr	dmastream_load

		move.l	.len,d0
		add.l	d0,dmastream_seek				;update file offset
		move.l	dmastream_PP,dmastream_LL			;update last load

.done:		rts
.pos:		dc.l	0
.len:		dc.l	0

dmastream_play_sample:
;in	d0.l	start addr
;in	d1.l	end addr

		move.b	d0,$ffff8907.w
		lsr.l	#8,d0
		move.b	d0,$ffff8905.w
		lsr.l	#8,d0
		move.b	d0,$ffff8903.w

		move.b	d1,$ffff8913.w
		lsr.l	#8,d1
		move.b	d1,$ffff8911.w
		lsr.l	#8,d1
		move.b	d1,$ffff890f.w

		move.b	#%10000010,$ffff8921.w 				;25033Hz mono
		move.b	#%00000011,$ffff8901.w				;Start DMA, loop

		rts

dmastream_load:
; in
; a0 = dest addr
; d0.l = bytes to load
; d1.l = file offset
		move.l	a0,.buf
		move.l	d0,.size
		move.l	d1,.seek

		move.w	d2,.mfp
		beq.s	.nomfphack1

		move.w	#$2700,sr
		move.l	save_timer_c,$114.w
		move.b	save_mfp+10,$fffffa1d.w
		move.w	#$2300,sr

.nomfphack1:

		clr.w	-(sp)						;fopen()
		pea	dmastream_file
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		move.w	d0,.fid

		tst.l	.seek
		beq.s	.skipseek

		clr.w	-(sp)						;fseek()
		move.w	.fid,-(sp)
		move.l	.seek,-(sp)
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp

.skipseek:
		move.l	.buf,-(sp)					;fread()
		move.l	.size,-(sp)
		move.w	.fid,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp

		move.w	.fid,-(sp)					;fclose()
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp

		tst.w	.mfp
		beq.s	.nomfphack2

		move.w	#$2700,sr
		move.l	#timer_c,$114.w
		clr.b	$fffffa1d.w					;Timer-C & D control (stop)
		move.w	#$2300,sr
.nomfphack2:
		rts
.fid:		dc.w	0
.buf:		dc.l	0
.size:		dc.l	0
.seek:		dc.l	0
.mfp:		dc.w	0

		section	data

dmastream_doplay:	dc.w	0
dmastream_counter:	dc.l	dmastream_vbls
dmastream_ended:	dc.w	0
dmastream_seek:		dc.l	dmastream_head
dmastream_LL:		dc.l	dmastream_SA
dmastream_PP:		dc.l	dmastream_SA

dmastream_file:	;dc.b	'music\orbxia.raw',0				;3m35s version
		dc.b	'keephack.ing',0				;4m59s version
		even


		section	bss

dmastream_SA:		ds.b	dmastream_size
dmastream_EA:

		section	text

;refill routs to call during demo

refill01:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts
refill02:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts
refill03:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts
refill04:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts
refill05:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts
refill06:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts

refill07:	move.w	#$4e75,(pc)			;run once
		ifne	music_dmastr
		jsr	dmastream_refill
		endc
		rts



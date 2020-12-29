; loader for music sample file
; floppy version does force media change and should autodetect when the user changes disk
; 

		section	text

dmaseq_floppy_load:

		lea	loader_pal,a0
		jsr	setpal

		lea	loader_gfx_packed,a0
		lea	buf,a1
		jsr	cranker


;--------------------------------------------------------------
; Load photos on disk 1, no mediachange stuff needed

		bsr	loader_loading

		clr.w	-(sp)					;open file read only
		pea	picshow_fn				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,.filenumber				;store filenumber
 
		;pea	dmaseq_sample				;buffer address
		pea	picshow_data
		move.l	#436007,-(sp)				;length of file
		move.w	.filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea	12(sp),sp				;

		move.w	.filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;


;--------------------------------------------------------------
; Load first sample on disk 2
	
.load_d2:	clr.w	-(sp)					;fsfirst() get fileinfo
		pea	dmaseq_fn1				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	.ok					;ok

		bsr	loader_insert_disk_2

		move.w	#25-1,.count				;wait 0.5 sec between each try
.vsync:		bsr.w	vsync
		subq.w	#1,.count
		bpl.s	.vsync
		bsr.w	mediach
		bra.s	.load_d2

.ok:		bsr.w	loader_loading

		move.w	#25-1,.count				;wait 0.5 sec
.vsync2:	bsr.w	vsync
		subq.w	#1,.count
		bpl.s	.vsync2

		clr.w	-(sp)					;open file read only
		pea	dmaseq_fn1				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,.filenumber				;store filenumber
 
		pea	dmaseq_sample				;buffer address
		move.l	#800000,-(sp)				;length of file
		move.w	.filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea	12(sp),sp				;

		move.w	.filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;

;--------------------------------------------------------------
; Load second sample on disk 3
	
.load_d3:	clr.w	-(sp)					;fsfirst() get fileinfo
		pea	dmaseq_fn2				;
		move.w	#$4e,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;

		tst.l	d0					;
		beq.s	.ok2					;ok

		bsr	loader_insert_disk_3

		move.w	#25-1,.count				;wait 0.5 sec between each try
.vsync3:	bsr.w	vsync
		subq.w	#1,.count
		bpl.s	.vsync3
		bsr.w	mediach
		bra.s	.load_d3

.ok2:		bsr.w	loader_loading

		move.w	#25-1,.count				;wait 0.5 sec
.vsync4:	bsr.w	vsync
		subq.w	#1,.count
		bpl.s	.vsync4

		clr.w	-(sp)					;open file read only
		pea	dmaseq_fn2				;address to filename
		move.w	#$3d,-(sp)				;
		trap	#1					;
		addq.l	#8,sp					;
		move.w	d0,.filenumber				;store filenumber
 
		pea	dmaseq_sample+800000			;buffer address
		move.l	#373931,-(sp)				;length of file
		move.w	.filenumber,-(sp)			;filenumber
		move.w	#$3f,-(sp)				;
		trap	#1					;
		lea	12(sp),sp				;

		move.w	.filenumber,-(sp)			;filenumber for closing
		move.w	#$3e,-(sp)				;
		trap	#1					;
		addq.l	#4,sp					;


		bsr	loader_fadeout

		jsr	clear_screens
		jsr	clear_buf

		rts
.filenumber:	dc.w	0
.count:		dc.w	0

loader_fadeout:

		jsr	vsync

		lea	loader_pal,a0
		jsr	setpal

		lea	loader_pal,a0
		lea	loader_black,a1
		move.l	a0,a2
		moveq	#16,d0
		jsr	fade_ste

		subq.w	#1,.steps
		bpl.s	loader_fadeout
		rts
.steps:		dc.w	20

loader_loading:
		move.l	scraddrbase,a0
		lea	160*80(a0),a0
		lea	buf+320*80/4,a1
		move.w	#320*40/16-1,d7
.copy:		move.l	(a1)+,(a0)
		addq.l	#8,a0
		dbra	d7,.copy
		rts

loader_insert_disk_2:
		move.l	scraddrbase,a0
		lea	160*80(a0),a0
		lea	buf,a1
		move.w	#320*40/16-1,d7
.copy:		move.l	(a1)+,(a0)
		addq.l	#8,a0
		dbra	d7,.copy
		rts

loader_insert_disk_3:
		move.l	scraddrbase,a0
		lea	160*80(a0),a0
		lea	buf+320*40/4,a1
		move.w	#320*40/16-1,d7
.copy:		move.l	(a1)+,(a0)
		addq.l	#8,a0
		dbra	d7,.copy
		rts
		
		
		section	data

loader_pal:	;dc.w	$0777,$0555,$0222,$0000
		dc.w	$0666,$0555,$0444,$0333
		dcb.w	12,$0000

loader_black:	dcb.w	16,$0000


loader_gfx_packed:
		incbin	'loader/text2.crk'
		even

		section	text

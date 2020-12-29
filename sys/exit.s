; Synclock demosystem for ST/STe
;
; exit.s
;
; ae@dhs.nu

		section	text

exit:
		move.w	#$2700,sr			;Stop all interrupts
                tst.w   do_restoremem
                beq.s   .norestore
	                jsr     restoreLowerMem
.norestore:
				tst.w	lowermemBalls
				beq		.nores
					move.b	#0,$ffffc123
					jsr		restoreLowerMemoryBalls
.nores
;============== Deinit music driver ====================
		ifne	music_sndh
		bsr	sndh_disable_play
		bsr	sndh_exit
		endc

		ifne	music_ymdigi_seq
		bsr	ymdigseq_exit
		endc

		ifne	music_dma_seq
		bsr	dmaseq_exit
		endc

;============== Restore MFP and vectors ================
		lea	save_vect_mfp,a0
		move.l	(a0)+,$70.w			;Restore old VBL
		move.l	(a0)+,$68.w			;Restore old HBL
		move.l	(a0)+,$134.w			;Restore old Timer A
		move.l	(a0)+,$120.w			;Restore old Timer B
		move.l	(a0)+,$114.w			;Restore old Timer C
		move.l	(a0)+,$110.w			;Restore old Timer D
		move.l	(a0)+,$118.w			;Restore ACIA ADDED 20190401
		move.b	(a0)+,$fffffa07.w		;Interrupt Enable A
		move.b	(a0)+,$fffffa09.w		;Interrupt Enable B
		move.b	(a0)+,$fffffa13.w		;Interrupt Mask A
		move.b	(a0)+,$fffffa15.w		;Interrupt Mask B
		move.b	(a0)+,$fffffa19.w		;Timer A Control
		move.b	(a0)+,$fffffa1b.w		;Timer B Control
		move.b	(a0)+,$fffffa1d.w		;Timer C & D Control
		move.b	(a0)+,$fffffa1f.w		;Timer A Data
		move.b	(a0)+,$fffffa21.w		;Timer B Data 
		move.b	(a0)+,$fffffa25.w		;Timer D data
		move.w	#$2300,sr			;Interrupts back on

;============== Restore video and other stuff ===========
		bsr	vsync

		lea	save_scraddr,a0			;Restore old screen address
		move.b	(a0)+,$ffff8201.w
		move.b	(a0)+,$ffff8203.w
		move.b	(a0)+,$ffff820d.w

		move.b	save_res,$ffff8260.w		;Restore old resolution
		move.b	save_freq,$ffff820a.w		;Restore old refresh

		movem.l	save_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		ifne	ste_demo
		bsr	vsync
		move.b	save_hscroll,$ffff8265.w	;Restore horizonal finescroll
		move.b	save_modulo,$ffff820f.w		;Restore modulo
		endc

		cmp.l	#"MSTe",machine
		bne.s	.not_mste
		move.b	save_mste,$ffff8e21.w		;Restore MSTe cache and CPU-speed
.not_mste:
		move.b	save_keyclick,$484.w		;Restore keyclick
		move.b	#$8,$fffffc02.w			;Enable mouse

;============== Exit supervisor mode and terminate =====
exit_early:	move.l	save_stack,-(sp)		;Back to usermode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp

		move.l	errmsg,d0			;Print eventual error message and wait for key
		beq.s	.noerr
		bsr	cconws
		move.l	#errmsg_mch,d0
		bsr	cconws
		move.l	#machine,d0
		bsr	cconws
		move.l	#errmsg_crlf,d0
		bsr	cconws
		move.l	#errmsg_exit,d0
		bsr	cconws
		bsr	crawcin
.noerr:
		clr.w	-(sp)				;pterm()
		trap	#1

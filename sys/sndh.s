; Synclock demosystem for ST/STe
;
; sndh.s
; 50 Hz songs without timer effects
;
; ae@dhs.nu

		section	text

;============== Initialise the SNDH player =============
sndh_init:
		clr.b	sndh_doplay

		moveq	#1,d0
		move.l	sndh_addr,a0
		jsr	(a0)

		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		rts

;============== SNDH 50 Hz interrupt player ============
sndh_play:	tst.b	sndh_doplay
		beq.s	.noplay

		move.l	sndh_addr,a0
		jsr	8(a0)
.noplay:	rts

;============== Deinitalise SNDH player ================
sndh_exit:
		clr.b	sndh_doplay

		move.l	sndh_addr,a0
		jsr	4(a0)

		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		rts

;============== Enable interrupt player ================
sndh_enable_play:
		move.b	#1,sndh_doplay
		rts

;============== Disable interrupt player ===============
sndh_disable_play:
		clr.w	sndh_doplay
		move.l	#$08000000,$ffff8800.w
		move.l	#$09000000,$ffff8800.w
		move.l	#$0a000000,$ffff8800.w
		rts

		section	data

sndh_addr:	dc.l	sndh_file

sndh_file:	incbin	'sys/tune.snd'

sndh_doplay:	dc.b	0				;0 = Don't call player
		even


		section	text
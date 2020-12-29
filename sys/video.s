; Generic demo system for widespread compatibility
; ST, STm, STf, STfm, Mega ST, STe, Mega STe, TT, Falcon 030, Falcon 060
;
; video.s
;
; Falcon save/restore by Chris/Aura and Scandion/The Mugwumps
;
; ae@dhs.nu

st_hz:		equ	0				;0=50, 1=60 Hz

		section	text

;============== Save video mode ========================
save_video:	lea	save_scraddr,a0			;Save old screen address
		move.b	$ffff8201.w,(a0)+
		move.b	$ffff8203.w,(a0)+
		move.b	$ffff820d.w,(a0)+

		movem.l	$ffff8240.w,d0-d7		;Save ST palette
		movem.l	d0-d7,save_pal

		cmp.b	#"F",computer
		beq	falcon_save_video

		move.b	$ffff8260.w,save_res		;Save old ST-shifter resolution

		cmp.w	#"TT",computer
		beq.s	.tt
		cmp.b	#2,$ffff8260.w
		beq	exit_mono

		move.b	$ffff820a.w,save_freq		;Save old refresh

		bsr	vsync
		ifeq	st_hz
		move.b	#2,$ffff820a.w			;Set 50 Hz
		else
		move.b	#1,$ffff820a.2			;Set 60 Hz
		endc

		cmp.l	#"STe ",computer
		beq.s	.ste
		cmp.l	#"MSTe",computer
		beq.s	.ste
		rts
.tt:		move.w	$ffff8262.w,d0
		and.w	#%0000011100000000,d0
		cmp.w	#%0000011000000000,d0
		beq	exit_mono
		move.w	$ffff8262.w,save_ttres		;Save old TT-resolution
.ste:		move.b	$ffff8265.w,save_hscroll	;Save horizonal finescroll
		move.b	$ffff820f.w,save_modulo		;Save modulo
		rts

;============== Restore video mode =====================
restore_video:
		movem.l	save_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		lea	save_scraddr,a0			;Restore old screen address
		move.b	(a0)+,$ffff8201.w
		move.b	(a0)+,$ffff8203.w
		move.b	(a0)+,$ffff820d.w

		cmp.b	#"F",computer
		beq	falcon_restore_video

		bsr	vsync
		move.b	save_res,$ffff8260.w		;Restore old resolution
		cmp.w	#"TT",computer
		beq.s	.tt
		move.b	save_freq,$ffff820a.w		;Restore old refresh

		cmp.l	#"STe ",computer
		beq.s	.ste
		cmp.l	#"MSTe",computer
		beq.s	.ste
		rts
.tt:		move.w	save_ttres,$ffff8262.w		;Restore old TT-resolution
.ste:		move.b	save_hscroll,$ffff8265.w	;Restore horizonal finescroll
		move.b	save_modulo,$ffff820f.w		;Restore modulo
		rts

;============== Set ST-LOW resolution ==================
set_stlow:	cmp.b	#"F",computer
		beq	falcon_set_stlow

		bsr	vsync
		clr.b	$ffff8260.w			;Set ST-LOW
		rts

;============== Set ST-MED resolution ==================
set_stmed:	cmp.b	#"F",computer
		beq	falcon_set_stmed

		bsr	vsync
		move.b	#1,$ffff8260.w			;Set ST-MED
		rts

;============== Save Falcon video registers ============
falcon_save_video:
		move.w	#$59,-(sp)			;VgetMonitor()
		trap	#14
		addq.l	#2,sp
		tst.w	d0				;0=Mono 
		beq	exit_mono
		move.b	d0,fmonitor

		move.w	#-1,-(sp)			;VsetMode()
		move.w	#$58,-(sp)
		trap	#14
		addq.l	#4,sp

		btst	#5,d0
		beq.s	.ntsc
.pal:		move.b	#50,falcon_rgbfreq
		bra.s	.save
.ntsc:		move.b	#60,falcon_rgbfreq

.save:		lea	save_fvideo,a0
		move.l	$ffff8200.w,(a0)+		;Video address
		move.w	$ffff820c.w,(a0)+
		move.l	$ffff8282.w,(a0)+		;Horizontal regs
		move.l	$ffff8286.w,(a0)+
		move.l	$ffff828a.w,(a0)+
		move.l	$ffff82a2.w,(a0)+		;Vertical regs
		move.l	$ffff82a6.w,(a0)+
		move.l	$ffff82aa.w,(a0)+
		move.w	$ffff82c0.w,(a0)+		;Video clock
		move.w	$ffff82c2.w,(a0)+		;VCO - Video Control
		move.l	$ffff820e.w,(a0)+		;Modulo
		move.w	$ffff820a.w,(a0)+		;50/60 Hz (ST)
		move.b  $ffff8265.w,(a0)+		;Hscroll
		clr.b   (a0)				;Check ST or Falcon mode
		cmp.w   #$b0,$ffff8282.w		;HHT - Horizontal Hold Timer
		sle     (a0)+				;If ST-mode, set flag
		move.w	$ffff8266.w,(a0)+		;SPSHIFT (Falcon colour mode)
		move.w	$ffff8260.w,(a0)+		;Shifter resolution
		rts

;============== Restore Falcon video registers =========
falcon_restore_video:
		bsr	vsync
		lea	save_fvideo,a0			
		clr.w   $ffff8266.w			;SPSHIFT reset
		move.l	(a0)+,$ffff8200.w		;Video address
		move.w	(a0)+,$ffff820c.w
		move.l	(a0)+,$ffff8282.w		;Horizontal regs
		move.l	(a0)+,$ffff8286.w
		move.l	(a0)+,$ffff828a.w
		move.l	(a0)+,$ffff82a2.w		;Vertical regs
		move.l	(a0)+,$ffff82a6.w
		move.l	(a0)+,$ffff82aa.w
		move.w	(a0)+,$ffff82c0.w		;Video clock
		move.w	(a0)+,$ffff82c2.w		;VCO - Video Control
		move.l	(a0)+,$ffff820e.w		;Modulo
		move.w	(a0)+,$ffff820a.w		;50/60 Hz (ST)
	        move.b  (a0)+,$ffff8256.w		;Hscroll

	        tst.b   (a0)+   			;ST-mode?
        	bne.s   .st

		move.l	a0,-(sp)
		bsr	vsync
		movea.l	(sp)+,a0
	       	move.w  (a0),$ffff8266.w		;SPSHIFT (Falcon colour mode)
		rts
.st:		move.w  2(a0),$ffff8260.w		;Shifter resolution
		lea	save_fvideo,a0
		move.w	32(a0),$ffff82c2.w		;VCO - Video Control
		move.l	34(a0),$ffff820e.w		;Modulo
		rts

;============== Set Falcon to ST-LOW resolution ========
falcon_set_stlow:
		cmp.b	#2,fmonitor
		beq.s	.vga
		bra.s	.rgb

.vga:		lea	falcon_stlow_vga60,a0
		bra.s	falcon_setres
.rgb:		cmp.b	#50,falcon_rgbfreq
		beq.s	.pal
.ntsc:		lea	falcon_stlow_rgb60,a0
		bra.s	falcon_setres
.pal:		lea	falcon_stlow_rgb50,a0
		bra.s	falcon_setres

;============== Set Falcon to ST-MED resolution ========
falcon_set_stmed:
		cmp.b	#2,fmonitor
		beq.s	.vga
		bra.s	.rgb

.vga:		lea	falcon_stmed_vga60,a0
		bra.s	falcon_setres
.rgb:		cmp.b	#50,falcon_rgbfreq
		beq.s	.pal
.ntsc:		lea	falcon_stmed_rgb60,a0
		bra.s	falcon_setres
.pal:		lea	falcon_stmed_rgb50,a0
		;bra.s	falcon_setres

;============== Set Falcon video registers =============
;in: a0.l = address to register dump (35 bytes)
falcon_setres:	move.l	(a0)+,$ffff8282.w
		move.l	(a0)+,$ffff8286.w
		move.l	(a0)+,$ffff828a.w
		move.l	(a0)+,$ffff82a2.w
		move.l	(a0)+,$ffff82a6.w
		move.l	(a0)+,$ffff82aa.w
		move.w	(a0)+,$ffff820a.w
		move.w	(a0)+,$ffff82c0.w
		move.w	(a0)+,$ffff8266.w
		move.b	(a0)+,$ffff8260.w
		move.w	(a0)+,$ffff82c2.w
		move.w	(a0)+,$ffff8210.w
		rts

		section	data

;============== Falcon video register dumps ============
falcon_stlow_rgb50:	incbin	'sys/lrgb50.vid'
falcon_stlow_rgb60:	incbin	'sys/lrgb60.vid'
falcon_stlow_vga60:	incbin	'sys/lvga60.vid'
falcon_stmed_rgb50:	incbin	'sys/mrgb50.vid'
falcon_stmed_rgb60:	incbin	'sys/mrgb60.vid'
falcon_stmed_vga60:	incbin	'sys/mvga60.vid'
		even

		section	text
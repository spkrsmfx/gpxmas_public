; todo:
;#cube:
;	- color ramp for flat shade highlight
;	- fade in background first
;	- introduction and removal of cube
;	- fade out background
;
;rotate:
;	- inverse movement on music
;	- use the raster to present and remove
;	- ornaments

; Coding informations
;
; 1. To save memory we have no generic screen buffers, each
;    part need to setup it's own screens from the generic bss 'buf'
;ss
; 2. Every part should have an rs-section (not absolute offsssets)
;    when using the generic bss. The rs-section must end with
;    "partname_sizeof: rs.b 0"
;
; 3. Total memory should not exceed 915kbytes, no malloc() allowed.
;    Run this terminal command on the executable to see text/data/bss:
;    file main.tos
;
; 4. When loading data, avoid raster and synclock as it will
;    struggle together with harddrive loading (and probably floppy too).



music_sndh:		equ	1			;ST/STe SNDH player (50 Hz without timers)
music_ymdump:		equ	0			;ST/STe YM2149 register dump player
music_ymdigi_seq:	equ	0			;ST/STe YM2149 sample sequence
music_dma_seq:		equ	0			;STe DMA sample sequence
music_dma_stream:	equ	0			;STe DMA sample stream
music_lance:		equ	0			;STe 50 kHz Protracker player

crankerpacker:		equ	1			;Include Cranker depack routine by Bifat/TEK
arjpacker:		equ	0			;Include arj m4
arj7packer:			equ	0			;Include ARJ depack routine by Ni!/TOS Crew (800 bytes)
sincos_table:		equ	0			;Include sin/cos-table
sincos_precalc:		equ	0			;Generate a sin/cos-table instead of including


bufsize:		equ	1024*756		;Shared BSS buffer, needs to be even by 256 bytes
ste_demo:		equ	0			;0=ST/STe demo, 1=STe-only demo
floppy:			equ	0			;0=HDD version 1=Floppy version

;; tom's customparts and libraries
;syncscroll:		equ	1
;trucolour:		equ	1
;c2p_library:		equ	1


; parts
part_test1:	equ	1				;Example of a normal 320x200 double buffer setup


part_vbars: 	equ 1			;-16kb to remove sprite source ; -22kb to use cranked data
part_tunnel:	equ 1			;-14kb crank texture -32kb to remove .neo
part_flatshade:	equ 1
part_elf:		equ 1
part_dots:		equ 1
part_balls:		equ 1
part_end:		equ 1
		section	text

		include	'sys/init.s'
		jmp		demoStart
; this is for padding shit!
logcrk	incbin 'rotate/log.crk'			;2900
	even
expcrk	incbin 'rotate/exp.crk'			;6156
	even
deercrk
	incbin	'rotate/deer.crk'			;7830
	even

demoStart
;============== Mainloop ===============================
ml		lea	vblcount(pc),a0
.wait:		tst.w	(a0)
		beq.s	.wait
		clr.w	(a0)

		move.l	mainrout(pc),a0
		jsr		(a0)

		tst.b	doexit
		bne.s	ml
		bra	exit

;============== 50 Hz VBL ==============================
vbl:		movem.l	d0-a6,-(sp)
		addq.w	#1,vblcount

		;Sequencer
		lea	scriptaddr(pc),a4
		move.l	(a4),a0
		subq.l	#1,(a0)
		bne.s	.noswitch
		lea	28(a0),a0
		move.l	a0,(a4)
.noswitch:	lea	tarout(pc),a4
		move.b	7(a0),$fffffa1f.w		;Timer A data
		move.b	11(a0),$fffffa19.w		;Timer A pre-div
		movem.l	12(a0),a0-a3			;A0=TA, A1=VBL1, A2=VBL2, A3=Main
		movem.l	a0-a3,(a4)

		;Run VBL1 routine
		jsr	(a1)

		;Run music player
		ifne	music_sndh
		bsr	sndh_play
		endc

		ifne	music_ymdigi_seq
		bsr	ymdigseq_vbl
		endc

		ifne	music_dma_seq
		bsr	dmaseq_vbl
		endc

		ifne	music_dma_stream
		bsr	dma_stream_vbl
		endc

		ifne	music_lance
		bsr	lance_vbl
		endc

		;Run VBL2 routine
		move.l	vblrout2(pc),a0
		jsr	(a0)

rape
		cmp.b	#$39,$fffffc02.w
		bne.s	.noexit
		clr.b	doexit

.noexit:	movem.l	(sp)+,d0-a6
		rte

scriptaddr:	dc.l	demoscript			;Don't reorder the demosystem variables
tarout:		dc.l	dummy
vblrout:	dc.l	dummy
vblrout2:	dc.l	dummy
mainrout:	dc.l	dummy
vblcount:	dc.w	0
machine:	dc.l	0				;"ST  ", "STe ", "MSTe", "TT  ", "F030", "F060"
		dc.b	0
doexit:		dc.b	1
		even

;============== Variable speed Timer A =================
timer_a:	clr.b	$fffffa19.w

		movem.l	d0-a6,-(sp)

		move.l	tarout(pc),a0
		jsr	(a0)

		movem.l	(sp)+,d0-a6
		move.w	#$2300,sr
		bclr	#5,$fffffa0b.w
		bclr	#5,$fffffa0f.w
dummy_rte:	rte



;============== Demoscript =============================
demoscript:	;dc.l	VBLs,TA-data,TA-prediv,TimerArout,VBLrout1 (before music),VBLrout2 (after music),Mainrout

;		dc.l	2,0,0,dummy,dummy,dummy,sndh_disable_play									
;
;	ifne	part_balls
;		dc.l	23,0,0,dummy,dummy,dummy,balls_init
;		dc.l	25*50,0,0,dummy,balls_vbl,dummy,dummy
;	endc
;		dc.l	2,0,0,dummy,dummy,dummy,end_init
;		dc.l	60*50,98,4,dummy,end_vbl,dummy,dummy
;s		dc.l	60*50,98,4,end_top_border,end_vbl,dummy,dummy





	ifne	part_vbars
		dc.l	2,0,0,dummy,dummy,dummy,sndh_disable_play									
		dc.l	110,0,0,dummy,vbars_vblcount,dummy,vbars_init
		dc.l	2,0,0,dummy,dummy,dummy,sndh_enable_play
		dc.l	12*50,0,0,dummy,vbars_vbl,dummy,vbars_main									;12 seconds
	endc

	ifne	part_tunnel
		dc.l	34,0,0,dummy,vbars_fadeout_vbl,dummy,tunnel_effect_init						
		dc.l	12*50+30,0,0,dummy,tunnel_vbl,dummy,tunnel_effect_mainloop						;24 seconds
		dc.l	14,0,0,dummy,tunnel_vbl_transition_white,dummy,tunnel_effect_mainloop
		dc.l	11*50+30-14,0,0,dummy,tunnel_vbl_transition_alt,dummy,tunnel_effect_mainloop
		dc.l	20,0,0,dummy,tunnel_vbl2,dummy,tunnel_effect_mainloop
	endc

	ifne	part_flatshade
		dc.l	60,0,0,dummy,flatshade_fadein_vbl,dummy,flatshade_init
		dc.l	14*50-20-20-23,0,0,dummy,flatshade_vbl,dummy,flatshade_main					;14 seconds
		dc.l	33,0,0,dummy,flatshade_fadeout_vbl,dummy,dummy
	endc

	ifne	part_elf
		dc.l	15,0,0,dummy,dummy,dummy,elf_init
		dc.l	23*50+30,0,0,dummy,elf_in_vbl,dummy,dots_init								;23 seconds
		dc.l	55,0,0,dummy,elf_out_vbl,dummy,dummy
	endc

	ifne	part_dots
		dc.l	3,0,0,dummy,dummy,dummy,dots_bg
;		dc.l	3,0,0,dummy,dummy,dummy,dots_bg
		dc.l	12*50+30,0,0,dummy,dots_vbl,dummy,dummy										;12 seconds
		dc.l	2,0,0,dummy,dummy,dummy,dots_deer
;		dc.l	3,0,0,dummy,dummy,dummy,dots_bg
		dc.l	12*50-15,0,0,dummy,dots_vbl,dummy,dummy											;12 seconds
		dc.l	15,0,0,dummy,dots_vbl_out,dummy,dummy
		dc.l	2,0,0,dummy,dummy,dummy,restoreLowerMem
	endc

	ifne	part_balls
		dc.l	42,0,0,dummy,dummy,dummy,balls_init
		dc.l	25*50-32,0,0,dummy,balls_vbl,dummy,dummy
		dc.l	32,0,0,dummy,balls_vbl_out,dummy,dummy
	endc


	ifne	part_end
		dc.l	20,0,0,dummy,end_fadewhite,dummy,end_init
		dc.l	60*50+20,0,0,dummy,end_vbl,dummy,dummy
endless
		dc.l	60*50,0,0,dummy,end_vbl,dummy,end_endless
	endc


		dc.l	0,0,0,dummy,dummy,dummy,exit

;============== Demosystem includes ====================
		include	'sys/exit.s'
		include	'sys/cookie.s'
		include	'sys/service.s'
		include	'sys/errmsg.s'
		include	'sys/graphics.h'


;		; tom's parts
;		include	'sys/global.s'
;
;		ifne	arjpacker
;		include	'sys/arjdep.s'
;		endc
;
;		ifne	syncscroll
;		include	'sys/sscrl2.s'
;		endc
;
;		ifne	c2p_library
;		include	'sys/c2p.s'
;		endc
;
;		ifne	trucolour
;		include	'sys/trueclr2.s'
;		endc
;		; end tom's parts		


		ifne	crankerpacker
		include	'sys/cranker.s'
		endc

		ifne	arj7packer
		include	'sys/arj7.s'
		endc			

		ifne	music_sndh
		include	'sys/sndh.s'
		endc

		ifne	music_ymdigi_seq
		include	'sys/ymdigseq.s'
		endc

		ifne	ste_demo

		ifne	music_dma_seq
			ifne	floppy
			include	'sys/dmaload.s'
			include	'sys/mediach.s'
			endc
		include	'sys/dmaseq.s'
		endc

		ifne	music_dma_stream
		include	'sys/dmastr.s'
		endc

		ifne	music_lance
		include	'sys/lance.s'
		endc

		endc

;============== Demopart includes ======================

;		ifne	part_test1
;		include	'test1/test1.s'
;		endc

	ifne	part_balls
		include	'balls/balls.s'
	endc

	ifne	part_dots
		include	'rotate/rotate.s'
	endc

	ifne	part_flatshade
		include	'flatshade/flatshade.s'
	endc

	ifne	part_elf
		include	'elf/elf.s'
	endc
	ifne	part_end
		include	'end/end.s'
	endc
;============== 	s before demoscript starts =========
inits:
		ifne	music_dma_seq
		jsr	dmaseq_load
		endc

dummy:		rts

;============== Shared datas between parts =============
		ifne	sincos_table
sincos:		incbin	'sys/sin.bin'
		even
		endc


;		section	bss
		
;============== Shared BSS between parts ===============
save_stack:	ds.l	1
save_vect_mfp:	ds.b	38
save_pal:	ds.w	16
save_res:	ds.b	1
save_freq:	ds.b	1
save_scraddr:	ds.b	3
save_mste:	ds.b	1
save_keyclick:	ds.b	1
		ifne	ste_demo
save_hscroll:	ds.b	1
save_modulo:	ds.b	1
		endc
		even

screenpointer	ds.l	1
screenpointer2	ds.l	1
screenpointer3	ds.l	1
memBase
buf:		ds.b	bufsize-10018-51400-7+1000
	even

spritecrk	
	;incbin	'vbars/data/8colsprite3.crk'				;10017 / 
	incbin	'vbars/data/8colfin.crk'				;10017 / 
	even														;10018
vbarscrk	
		incbin	'vbars/data/result_one_600_25fps.crk'			;26846
		even
textureCrk	incbin	'tunnel/data/final.crk'
	even
	ifne	part_vbars
		include	'vbars/vbars.s'
	endc
xmascrk	incbin	"tunnel/gfx/paltext4.crk"
	even
	ifne	part_tunnel
		include	'tunnel/tunnel.s'
	endc
font	incbin	'elf/font.neo'	
	even
logocrk	incbin	'flatshade/logo4.crk'
		even
tunnelOffsets		include	'tunnel/data/tunneloffsets3.s'			;32000
	even

memEnd

;============== Variables and save/restore buffers =====
		even

		end

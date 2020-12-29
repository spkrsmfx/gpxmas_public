; Synclock demosystem for ST/STe
;
; init.s
;
; ae@dhs.nu

		section	text
init:

;============== Calculate program size and return mem ==
		move.l	4(sp),a5			;Store basepage addr
		move.l	$0c(a5),d0			;Text
		add.l	$14(a5),d0			;Data
		add.l	$1c(a5),d0			;BSS
		add.l	#$100,d0			;Basepage
		add.l	#$1000,d0			;Stack
		move.l	a5,d1				;Basepage
		add.l	d0,d1				;End
		and.l	#-2,d1				;Even
		move.l	d1,sp				;Stackaddr

		move.l	d0,-(sp)			;mshrink()
		move.l	a5,-(sp)
		move.w	d0,-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp

;============== Enter Supervisor mode ==================
		clr.l	-(sp)				;super()
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,save_stack

;============== Detect machine type ====================
		bsr	detect_machine

		move.l	#errmsg_mch_st,errmsg

		cmp.b	#"F",machine			;No Falcon please
		beq	exit_early
		cmp.b	#"T",machine			;No TT please
		beq	exit_early
		cmp.b	#2,$ffff8260.w			;No monochrome monitor please
		beq	exit_early
		ifne	ste_demo
		cmp.l	#"ST  ",machine			;No ST if we are doing an STe demo
		beq	exit_early
		endc

		clr.l	errmsg				;No error to print

		cmp.l	#"MSTe",machine
		bne.s	.not_mste
		move.b	$ffff8e21.w,save_mste		;Save MSTe cache and CPU-speed
		clr.b	$ffff8e21.w			;Set MSTe to 8 MHz and no cache
.not_mste:

;============== Save and setup video ===================

		lea	save_scraddr,a0			;Save old screen address
		move.b	$ffff8201.w,(a0)+
		move.b	$ffff8203.w,(a0)+
		move.b	$ffff820d.w,(a0)+

		movem.l	$ffff8240.w,d0-d7		;Save ST palette
		movem.l	d0-d7,save_pal

		move.b	$ffff8260.w,save_res		;Save old ST-shifter resolution
		move.b	$ffff820a.w,save_freq		;Save old refresh

		ifne	ste_demo
		move.b	$ffff8265.w,save_hscroll	;Save horizonal finescroll
		move.b	$ffff820f.w,save_modulo		;Save modulo
		endc

		bsr	vsync
		bsr	black_pal
		clr.b	$ffff8260.w			;Set ST-LOW
		move.b	#2,$ffff820a.w			;Set 50 Hz

		ifne	0
;============== Setup screen buffers ===================
		move.l	#scr+256,d0
		clr.b	d0
		lea	scraddrbase,a0
		lea	screens,a1
		move.l	d0,(a0)+			;scraddrbase
		move.l	d0,(a0)+			;scraddr1
		cmp.b	#1,(a1)
		beq.s	.screensdone
		add.l	#scrsize,d0
		move.l	d0,(a0)+			;scraddr2
		cmp.b	#2,(a1)
		beq.s	.screensdone
		add.l	#scrsize,d0
		move.l	d0,(a0)+			;scraddr3
.screensdone:	bsr	clear_screens

		bsr	vsync				;ADDED 20190331
		move.l	scraddrbase,d0			;
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;
		endc

;============== Misc ===================================
		move.b	$484.w,save_keyclick		;Save keyclick
		bclr	#0,$484				;Set keyclick off

		move.b	#$12,$fffffc02.w		;Kill mouse

		jsr	inits

;============== Save vectors and MFP ===================
		move.w	#$2700,sr
		lea	save_vect_mfp,a0
		move.l	$70.w,(a0)+			;VBL
		move.l	$68.w,(a0)+			;HBL
		move.l	$134.w,(a0)+			;MFP Timer A
		move.l	$120.w,(a0)+			;MFP Timer B
		move.l	$114.w,(a0)+			;MFP Timer C
		move.l	$110.w,(a0)+			;MFP Timer D
		move.l	$118.w,(a0)+			;ACIA ADDED 20190401
		move.b	$fffffa07.w,(a0)+		;MFP interrupt Enable A
		move.b	$fffffa09.w,(a0)+		;MFP interrupt Enable B
		move.b	$fffffa13.w,(a0)+		;MFP interrupt Mask A
		move.b	$fffffa15.w,(a0)+		;MFP interrupt Mask B
		move.b	$fffffa19.w,(a0)+		;MFP Timer A Control
		move.b	$fffffa1b.w,(a0)+		;MFP Timer B Control
		move.b	$fffffa1d.w,(a0)+		;MFP Timer C & D Control
		move.b	$fffffa1f.w,(a0)+		;MFP Timer A Data
		move.b	$fffffa21.w,(a0)+		;MFP Timer B Data
		move.b	$fffffa25.w,(a0)+		;MFP Timer D data

;============== Setup vectors and MFP ==================
		clr.b	$fffffa07.w			;MFP interrupt Enable A (Timer-A & B)
		clr.b	$fffffa13.w			;MFP interrupt Mask A (Timer-A & B)
		clr.b	$fffffa09.w			;MFP interrupt Enable B (Timer D)
		clr.b	$fffffa15.w			;MFP interrupt Mask B (Timer D)

		clr.b	$fffffa19.w			;Timer-A control (stop) ADDED 20190401
		clr.b	$fffffa1b.w			;Timer-B control (stop) ADDED 20190401
		clr.b	$fffffa1d.w			;Timer-C & D control (stop) ADDED 20190401

		bclr	#3,$fffffa17.w			;MFP automatic end of interrupt
		bset	#5,$fffffa07.w			;Interrupt enable A (Timer-A)
		bset	#5,$fffffa13.w			;Interrupt mask A

		lea	dummy_rte(pc),a0
		move.l	#vbl,$70.w			;Install VBL
		move.l	a0,$68.w			;Install HBL
		move.l	#timer_a,$134.w			;Install Timer A
		move.l	a0,$120.w			;Install Timer B
		move.l	a0,$114.w			;Install Timer C
		move.l	a0,$110.w			;Install Timer D
		move.l	a0,$118.w			;ACIA ADDED 20190401

		ifne	music_sndh
		bsr	sndh_init
		bsr	sndh_enable_play
		endc

		ifne	music_ymdigi_seq
		bsr	ymdigseq_init
		endc

		ifne	music_dma_seq
		bsr	dmaseq_init
		bsr	dmaseq_enable_play
		endc

		move.w	#$2300,sr

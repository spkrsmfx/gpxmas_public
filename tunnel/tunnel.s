; smc in generated code, and larger offsmap, for look around
; make generic code for rotation direction and movement + speed; so it can switch
; make multi palette possible

TUNNEL_Y_LINES	equ 100
TUNNEL_X_PARTS	equ 20			;16*96*48
GENERATE_TEXTURE_BINARY equ 0


;	section text

fadePalTunnelPtr	dc.l	0

tunnelAltPal
	dc.w	$001,$477,$707,$714,$403,$747,$202,$510,$000,$035,$177,$743,$710,$700,$632,$777

tunnelPal
	dc.w	$001,$565,$157,$240,$020,$361,$202,$332,$000,$035,$676,$750,$440,$734,$632,$777


tunnel_fade_precalc
	move.l	fadePalTunnelPtr,a0
	movem.l	tunnelPal,d0-d7
	movem.l	d0-d7,(a0)


;============== ST palette fade 8-steps ================
;in:	a0.l	start palette
;	a1.l	end palette
;	a2.l	destination palette
;	d0.w	number of colours to fade

	move.w	#8-1,d7
.do
		lea		black,a1
		lea		32(a0),a2
		move.w	#16,d0
		jsr		fade_st
		lea		32(a0),a0
	dbra	d7,.do

	rts


tunnel_vbl_transition_white
	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	subq.w	#1,.waiter
	bge		.no
		move.w	#1,.waiter
		lea		$ffff8240,a0
		lea		tunnelWhite,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.no
	subq.w	#1,change
	bge		.llll
		move.l	#3*4-128*4*3,textureMovement
.llll

	rts
.waiter	dc.w	1


tunnel_vbl_transition_alt
	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	subq.w	#1,.waiter
	bge		.no
		move.w	#2,.waiter
		lea		$ffff8240,a0
		lea		tunnelAltPal,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.no
	subq.w	#1,change
	bge		.llll
		move.w	#32000,change
		move.l	#3*4-128*4*3,textureMovement
.llll


	subq.w	#1,herp
	bge		.noherp
		move.l	#-5*4+128*4*5,textureMovement
		move.w	#20,herp
		subq.w	#1,herp2
		bge		.noherp
				move.l	#3*4-128*4*3,textureMovement
			move.w	#7000,herp

.noherp
	rts
.waiter	dc.w	1
herp		dc.w	5*50+15
herp2		dc.w	1



tunnel_vbl_transition_normal
	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	subq.w	#1,.waiter
	bge		.no
		move.w	#2,.waiter
		lea		$ffff8240,a0
		move.l	xmasPtr,a1
		add.w	#4,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.no
	subq.w	#1,change
	bge		.llll
		move.l	#3*4-128*4*3,textureMovement
.llll
	rts	
.waiter	dc.w	1

tunnel_vbl
	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	move.l	fadePalTunnelPtr,a0
	add.w	fadeOffIn,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240



	subq.w	#1,.timer
	bge		.end
		move.w	#1,.timer
		sub.w	#32,fadeOffIn
		bge		.end
			move.w	#0,fadeOffIn
			move.w	#0,fadeOffOut
.end
	addq.w	#1,vblcountTun
	cmp.w	#500,vblcountTun
	bne		.ll
		moveq	#0,d0
		moveq	#0,d1
		move.w	vblcountTun,d0
		move.w	tunnel_effect_count,d1
;		move.b	#0,$ffffc123
.ll
	subq.w	#1,change
	bge		.llll
		move.l	#3*4-128*4*3,textureMovement
.llll
	rts
.timer		dc.w	4
vblcountTun	dc.w	0
fadeOffIn	dc.w	7*32
tunnel_effect_count	dc.w	0
change		dc.w	12*50+30

tunnel_vbl2
	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200

	subq.w	#1,.timer
	bge		.skip
		move.w	#1,.timer
		lea		$ffff8240,a0
		lea		black,a1
		lea		$ffff8240,a2
		move.w	#16,d0
		jsr		fade_st
.skip

;	move.l	fadePalTunnelPtr,a0
;	add.w	fadeOffOut,a0
;	movem.l	(a0),d0-d7
;	movem.l	d0-d7,$ffff8240
;	subq.w	#1,.timer
;	bge		.end
;		move.w	#1,.timer
;		add.w	#32,fadeOffOut
;		cmp.w	#7*32,fadeOffOut
;		ble		.end
;			tst.w	fadeOffIn
;			bne		.noadd
;				lea		textureMovementList,a0
;				add.w	textureMovementOff,a0
;				move.l	(a0),textureMovement
;				add.w	#4,textureMovementOff
;.noadd
;			move.w	#7*32,fadeOffOut
;			move.w	#7*32,fadeOffIn
.end

;	addq.w	#1,vblcountTun
;	cmp.w	#500,vblcountTun
;	bne		.ll
;		moveq	#0,d0
;		moveq	#0,d1
;		move.w	vblcountTun,d0
;		move.w	tunnel_effect_count,d1
;.ll
	rts
.timer		dc.w	1
fadeOffOut	dc.w	0


;	section text

tunnelTextureDepack
	move.w	#$4e75,tunnelTextureDepack
	lea		textureCrk,a0
	move.l	texturePtr,a1
	jsr		cranker
	rts

; now for a real tunnel

tunnel_effect_precalc
	jsr		tunnelTextureDepack
	IFEQ	GENERATE_TEXTURE_BINARY
;		jsr		convertTexture				;2			;0 mem
	ENDC
	jsr		opt_calcTexture					;27			
	jsr		genTunnelCopy
	jsr		genC2PTable						;28
	jsr		genTunnelCode					;4

	lea		xmascrk,a0
	move.l	xmasPtr,a1
	jsr		cranker

	jsr		tunnel_fade_precalc				;1
	jsr		generateSpriteCode2
	rts
.code	
	jmp		*+48
FAST_OFFSET_CODE	equ 0

tunnel_effect_vbl
	move.l	screenpointer,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200
	movem.l	palss,d0-d7
	movem.l	d0-d7,$ffff8240
	rts

tunnel_effect_mainloop
	jsr		drawTunnelNew
	move.l	screenpointer2,a0
	move.l	tunnelCopyPtr,a6
	jsr		(a6)
	jsr		drawSpriteOptX

	addq.w	#1,tunnel_effect_count
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	screenpointer3,screenpointer2
	move.l	d0,screenpointer3
	rts

tunnel_effect_init
	move.w	#$4e75,tunnel_effect_init
	jsr		tunnel_effect_pointers
	jsr		tunnel_effect_precalc
	rts

tunnel_effect_pointers_prec
	move.l	#memBase+256,d0				; 64kb
	sub.b	d0,d0
	add.l	#32000,d0
	add.l	#32000,d0
	move.l	d0,xmasPtr
	add.l	#$8000+8192*2,d0						; 32kb
	and.l	#-1024*16,d0
	IFEQ	FAST_OFFSET_CODE
	move.l	d0,opt_c2ptable_pointer							; lower word should be $b000 or lower
	add.l	#$40000,d0						; 256kb
	ENDC	

	move.l	d0,tunnelCopyPtr
	add.l	#3602,d0

	add.l	#300,d0			; hax so we can precalc
	move.l	d0,planartexturepointer1
	add.l	#65536*2,d0						; 256kb
	move.l	d0,planartexturepointer2
	add.l	#65536*2,d0
	move.l	d0,tunnelCodeGeneratedPtr
	move.l	d0,texturePtr
	add.l	#48*TUNNEL_X_PARTS*TUNNEL_Y_LINES+2,d0			;48*20*100+2
	move.l	d0,fadePalTunnelPtr



	jsr		tunnelTextureDepack
	jsr		opt_calcTexture
	move.w	#$4e75,tunnel_effect_pointers_prec
	rts



tunnel_effect_pointers
	move.l	#memBase+256,d0				; 64kb
	sub.b	d0,d0
	move.l	d0,screenpointer
	add.l	#32000,d0
	move.l	d0,screenpointer2
	add.l	#32000,d0
	move.l	d0,screenpointer3
	move.l	d0,xmasPtr
	add.l	#$8000+8192*2,d0						; 32kb
	and.l	#-1024*16,d0
	IFEQ	FAST_OFFSET_CODE
	move.l	d0,opt_c2ptable_pointer							; lower word should be $b000 or lower
	add.l	#$40000,d0						; 256kb
	ENDC	

	move.l	d0,tunnelCopyPtr
	add.l	#3602,d0

;	move.l	d0,d1
;	sub.l	#memBase,d1
;	move.b	#0,$ffffc123

	add.l	#300,d0			; hax so we can precalc
	move.l	d0,planartexturepointer1
	add.l	#65536*2,d0						; 256kb
	move.l	d0,planartexturepointer2

;	move.l	d0,d1
;	sub.l	#memBase,d1
;	move.b	#0,$ffffc123


	add.l	#65536*2,d0
	move.l	d0,tunnelCodeGeneratedPtr
	move.l	d0,texturePtr
	add.l	#48*TUNNEL_X_PARTS*TUNNEL_Y_LINES+2,d0			;48*20*100+2 = 96002

	move.l	d0,spriteCodePtrDataPtr
	add.l	#7500,d0
	move.l	d0,spriteBufferPtrDataPtr
	add.l	#5500,d0
	move.l	d0,spriteMaskPtrDataPtr
	add.l	#2500,d0

	move.l	d0,fadePalTunnelPtr
	add.l	#9*32,d0

;	sub.l	#memBase,d0
;	move.b	#0,$ffffc123



	rts

spriteCodePtrDataPtr	dc.l	0
spriteBufferPtrDataPtr	dc.l	0
spriteMaskPtrDataPtr	dc.l	0
tunnelCopyPtr	dc.l	0

genTunnelCopy
	move.l	tunnelCopyPtr,a0
	move.w	#100-1,d7
	move.l	.s1,d0
	sub.w	d1,d1			; source
	move.l	.s2,d2
	move.w	#160,d3
	move.w	#160,d4
	move.w	#56,d5
	move.l	.s5,a1			;
	move.l	.s6,a2
	move.w	#160+48,a3
.cp
		move.l	d0,(a0)+		; read1			4
		move.w	d1,(a0)+		; read1 off		6
		move.l	d2,(a0)+		; write1		10
		move.w	d3,(a0)+		; write2 off	12
		add.w	d5,d1
		add.w	d5,d3
		move.l	d0,(a0)+		; read2			16
		move.w	d1,(a0)+		; read2 off		18
		move.l	d2,(a0)+		; write2		22
		move.w	d3,(a0)+		; write2 off	24
		add.w	d5,d1
		add.w	d5,d3
		move.l	a1,(a0)+		; read3			28
		move.w	d1,(a0)+		; read3 off		30
		move.l	a2,(a0)+		; write 3		34
		move.w	d3,(a0)+		; write 3 off	36
		add.w	a3,d1
		add.w	a3,d3
	dbra	d7,.cp								;3600
	move.w	#$4e75,(a0)+						;3600+2
	rts

.s1
		movem.l	1234(a0),d0-d7/a1-a6			;8+6 = 14*4  = 56
.s2
		movem.l	d0-d7/a1-a6,1234(a0)
.s3
		movem.l	1234+56(a0),d0-d7/a1-a6			;8+6 = 14*4  = 56
.s4
		movem.l	d0-d7/a1-a6,1234+160+56(a0)
.s5
		movem.l	1234+112(a0),d0-d7/a1-a4			;8+6 = 14*4  = 56
.s6
		movem.l	d0-d7/a1-a4,1234+160+112(a0)


opt_c2ptable_pointer	ds.l	1


genC2PTable
	move.l	opt_c2ptable_pointer,a4
	lea		TAB1,a3
	lea		TAB4,a0
	move.l	a0,usp
	moveq	#16-1,d7
.l4
		lea		TAB2,a2
		moveq	#16-1,d6
		move.l	(a3)+,d3
.l3
			lea		TAB3,a1
			moveq	#16-1,d5
			move.l	(a2)+,d2
.l2
				move.l	usp,a0
				move.l	(a1)+,d1
					REPT 16
					move.l	(a0)+,d0
					add.l	d1,d0
					add.l	d2,d0
					add.l	d3,d0
					move.l	d0,(a4)+
					ENDR
			dbra	d5,.l2
		dbra	d6,.l3
	dbra	d7,.l4
	rts	


opt_calcTexture
;	lea		texture,a0
	move.l	texturePtr,a0
	move.l	planartexturepointer1,a1
	move.l	planartexturepointer2,a2
	move.l	a1,a3
	move.l	a2,a4
	add.l	#65536,a3
	add.l	#65536,a4
	move.l	opt_c2ptable_pointer,d1

	move.w	#128*128-1,d7
.loop
		moveq	#0,d0		;4		
		move.b	(a0)+,d0	;8				0000 00ff
		lsl.w	#4,d0		;16				0000 03fc
		move.w	d0,2(a2)	;12
		move.w	d0,2(a4)	;12
		lsl.w	#4,d0		;16				0000 0ff0
		move.w	d0,(a2)		;8
		move.w	d0,(a4)		;8
		add.w	#4,a2		;8
		add.w	#4,a4		;8
		lsl.l	#4,d0		;16				0000 3fc0
		add.l	d1,d0		;8	
		move.l	d0,(a1)+	;12
		move.l	d0,(a3)+	;12
	dbra	d7,.loop
	move.w	#$4e75,opt_calcTexture
	rts

drawTunnelNew
	move.l	screenpointer2,a6

	move.l	textureMovement,d0
	add.l	d0,texoff
	bge		.okoff
		add.l	#128*128*4,texoff
.okoff

	cmp.l	#128*128*4,texoff
	blt		.ok2
		sub.l	#128*128*4,texoff
.ok2
	neg.w	.flipper
	move.l	planartexturepointer1,a0
	move.l	planartexturepointer2,a1
	add.l	#16384*2,a0
	add.l	#16384*2,a1
	add.l	texoff,a0
	add.l	texoff,a1

TUNNEL_SCREEN_HEIGHT equ 100
TUNNEL_SCREEN_WIDTH equ 20
TUNNEL_DO_BUMP	equ 1

	move.l	tunnelCodeGeneratedPtr,a4
	jmp		(a4)
.flipper 	dc.w	-1
.texoff		dc.l	0
.tunoffdir	dc.w	1



;cptr
;.y set 0
;	REPT TUNNEL_Y_LINES
;.x set .y
;		REPT 	TUNNEL_X_PARTS	
;			move.l	1234(a0),d0		;4	
;			add.w	1234(a1),d0		;4
;			add.w	1234(a1),d0		;4
;			add.b	1234(a1),d0		;4
;			move.l	d0,a5			;2
;			move.l	(a5),d0			;2
;			movep.l	d0,.x(a6)		;4		24
;	
;
;			move.l	1234(a0),d0		;4	
;			add.w	1234(a1),d0		;4
;			add.w	1234(a1),d0		;4
;			add.b	1234(a1),d0		;4
;			move.l	d0,a5			;2
;			move.l	(a5),d0			;2
;			movep.l	d0,.x+1(a6)		;4
;.x set .x+8
;		ENDR
;.y set .y+320
;	ENDR	
;
;	ENDC
	rts
texoff	dc.l	0

palss	
	dc.w	$205,$314,$207,$512,$316,$523,$426,$434,$632,$536,$546,$644,$752,$656,$764,$766




;tunnel_test_init
;	jsr		convertFlare2			; first we convert the flare the bumpChunky;	jsr		preCalcBumpOffset		; make offset map
;	rts



planartexturepointer1	dc.l	0
planartexturepointer2	dc.l	0
planartexturepointer3	dc.l	0
planartexturepointer4	dc.l	0
tunnelCodeGeneratedPtr	dc.l	0

;
;	; 128 x 128 tunnel
;	; 128 x 128 bump
;	; 128 x 128 texture
;
;; lets get a xor pattern going first
;; with a tunnel
;; and a seperate bumpmap on a texture
;; then combine stuff
;
;	; lets first get a tunnel going
;TUNNEL_SCREEN_HEIGHT	equ 100
;TUNNEL_SCREEN_WIDTH		equ 20
;
;TUNNEL_TEXTURE_WIDTH	equ 	64
;TUNNEL_TEXTURE_HEIGHT	equ 	64


;prepareTextureTab
;	moveq	#0,d0
;
;	move.l	texturePtr,a0
;;	lea		texture,a0
;	lea		c2p12,a1
;	lea		c2p34,a2
;	move.l	planartexturepointer1,a3
;	move.l	a3,a4
;	add.l	#$10000,a4
;	move.l	planartexturepointer2,a5
;	move.l	a5,a6
;	add.l	#$10000,a6
;
;	move.w	#128*128/32-1,d7
;	jsr		gentab
;
;	move.l	texturePtr,a0
;;	lea		texture,a0
;	lea		c2p56,a1
;	lea		c2p78,a2
;	move.l	planartexturepointer3,a3
;	move.l	a3,a4
;	add.l	#$10000,a4
;	move.l	planartexturepointer4,a5
;	move.l	a5,a6
;	add.l	#$10000,a6
;
;	move.w	#128*128/32-1,d7
;	jsr		gentab
;	rts

;gentab
;.loop
;	REPT 32
;		move.b	(a0)+,d0
;		move.l	(a1,d0.w),d1
;		move.l	d1,(a3)+
;		move.l	d1,(a4)+
;		move.l	(a2,d0.w),d1
;		move.l	d1,(a5)+
;		move.l	d1,(a6)+
;	ENDR
;	dbra	d7,.loop
;	rts



genTunnelCode
	move.l	tunnelCodeGeneratedPtr,a6
	lea		tunnelOffsets,a5
	movem.l	.code,d0-d3/d5
	move.l	.movepx,d4
	sub.w	d4,d4

	move.w	#TUNNEL_Y_LINES-1,d7
.y

	REPT TUNNEL_X_PARTS				
		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		addq.w	#2,d2
		move.w	(a5)+,d3

		move.l	d0,(a6)+	;
		move.l	d1,(a6)+	;
		move.l	d2,(a6)+	;
		move.l	d3,(a6)+	;
		move.l	d5,(a6)+
		move.l	d4,(a6)+	;	5*4 = 24

		addq.w	#1,d4

		move.w	(a5)+,d0
		move.w	(a5)+,d1
		move.w	(a5)+,d2
		addq.w	#2,d2
		move.w	(a5)+,d3

		move.l	d0,(a6)+	;
		move.l	d1,(a6)+	;
		move.l	d2,(a6)+	;	
		move.l	d3,(a6)+	;
		move.l	d5,(a6)+
		move.l	d4,(a6)+	;	5*4 = 24 => 48*TUNNEL_X_PARTS*TUNNEL_Y_LINES
		addq.w	#7,d4
	ENDR
	IFNE	TUNNEL_X_PARTS-20
	lea		(20-TUNNEL_X_PARTS)*8*2(a5),a5
	add.w	#(20-TUNNEL_X_PARTS)*8+160,d4
	ELSE
	add.w	#160,d4	
	ENDC
;	lea		8*8*2(a5),a5
;	add.w	#8*8+160,d4



	dbra	d7,.y
	move.w	#$4e75,(a6)+	; 100*20*48+2 = 96002
	move.w	#$4e75,genTunnelCode
	rts


.code
	move.l	1234(a0),d0		;16
	add.w	1234(a1),d0		;12		
	add.w	1234(a1),d0		;12
	add.b	1234(a1),d0		;12
	move.l	d0,a5			;4
	move.l	(a5),d0			;12			68
.movepx
	movep.l d0,1234(a6)		;24			92





;	section data
texturePtr			dc.l	0

	IFEQ	GENERATE_TEXTURE_BINARY
;texture	incbin	'tunnel/data/text3.raw'								;16384		;-12kb cranker
convertTexture
;	lea		texture,a0
;	lea		texture,a1
	move.l	texturePtr,a0
	move.l	a0,a1
	move.w	#128*128/2-1,d7
.doit
		move.w	(a0)+,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,(a1)+
		dbra	d7,.doit

		move.l	texturePtr,a0
		move.b	#0,$ffffc123
	rts
	ELSE
texture			incbin	'tunnel/data/texture.bin'
	ENDC

;xmas	incbin	 "tunnel/gfx/paltext3.neo"

xmasPtr	dc.l	0

;	section text


tryStoreOff	macro
	tst.w	.storeOff
	bge		.skip\@
		move.w	.completeOff,(a3)+
.skip\@
	endm

testreg2 macro
	tst.w	\1
	bne		.k\@
		move.b	#0,$ffffc123
.k\@
        ENDM
        
possiblyAddOffsetToScreen2	macro
			tst.w	d4										; check
			beq		.caseA_nooff\@							; if screen offset counter is 0, dont insert lea
				move.l	d4,(a5)+							; else insert lea
				sub.w	d4,d4								; clear screen offset counter
.caseA_nooff\@
	endm

; this preloads the masks, if needed, and applies the right thing to the smc
possiblyLoadMasks2	macro
	; first determe if we have any preloaded masks
	tst.w	d7
	bge		.ok\@
		moveq	#24,d7				; reset the thing
		move.l	.moveml,(a5)+		; preload regs
.ok\@
	move.w	(a0,d7.w),.applymask
	move.w	2(a0,d7.w),.skiponeb
	subq.w	#4,d7
	endm




;spriteCodePtrData	ds.b	50000
;spriteBufferPtrData	ds.b	50000
;spriteMaskPtrData	ds.b	50000
; todo:
;	- make this reusable for multiple sprites
;		- extend the lists to have NR_SPRITES * 16 LONGWORDS
tunnelopt	equ 1
	IFEQ	tunnelopt
notDrawList	ds.l	1000
	ENDC

generateSpriteCode2
	move.w	#0,.xoff
	movem.l	.casea,a0/a1/a2		;d0.w, d1.l, d2.l
	move.l	.casec,d5			;d4.l

	move.l	xmasPtr,a4
	add.l	#128,a4
;	lea		spriteCodePtrData,a5
;	lea		spriteBufferPtrData,a6
;	lea		spriteMaskPtrData,a1


	move.l	spriteCodePtrDataPtr,a5
	move.l	spriteBufferPtrDataPtr,a6
	move.l	spriteMaskPtrDataPtr,a1


	lea		andllist,a0

	lea		xpointerListCode1,a3								; buffer for generated code
	move.l	a5,(a3)											; save codePointer
	lea		xpointerListData1,a3								; buffer for generated data
	move.l	a6,(a3)											; save dataPointer
	lea		xpointerListMask1,a3
	move.l	a1,(a3)
	add.w	#4,.xoff										; increase offset

	move.w	.caseb,a3			;d3.l						; caseb opcode
	move.l	.leal,d4										; lea	x(a6),a6	opcode
	sub.w 	d4,d4											; clear offset
	IFEQ	tunnelopt
	lea		notDrawList,a3
	ENDC

	moveq	#0,d7
			possiblyLoadMasks2

	move.w	#104-1,.ytimes						; y-loop
.doY
		move.w	#((10)+1)-1,d6					; x-loop
.doX
		move.l	(a4)+,d0	;bpl1							; get sprite mask bpl1 bpl2
		move.l	(a4)+,d1	;bpl2							; get sprite mask bpl3 bpl4
		move.w	d0,d2		;mask							; use d2 for mask (bpl2)
		swap	d0											;
		or.w	d0,d2										; mask = bpl1 || bpl2 
		swap	d0
		or.w	d1,d2										; mask = bpl1 || bpl2 || bpl 4
		swap	d1
		or.w	d1,d2										; mask = bpl1 || bpl2 || bpl3 || bpl4
		swap	d1
		cmp.w	#-1,d2										; check
		beq		.doCaseC									; if sprite covers all 16 bits; then we can just copy data, no masking needed
		tst.w	d2											; check
		beq		.doCaseB									; if sprite covers no bits; its empty, an can be skipped
.doCaseA	; the case where you want to mask and or	
					possiblyAddOffsetToScreen2				; apply screen offset counter if needed
			move.w	d2,d3									; extend mask to longword to span 2 bitplanes
			swap	d2										;
			move.w	d3,d2									; d2.l = mask
			not.l	d2										; negate bits for actual mask
			move.l	d2,(a1)+								; store mask

			tst.l	d0										; check
			beq		.caseA_onlybpl2							; if bpl1, bpl2 empty, optimize
.caseA_bpl1bpl2												; else draw both bitplanes
			move.l	d0,(a6)+								; store bpl1,bpl2
			move.l	d1,(a6)+								; store bpl3,bpl4
					possiblyLoadMasks2						; code for optionally loading masks to registers, incase no masks left
			move.l	.applymaskscreen,(a5)+					; code for loading bpl1,bpl2 from screen address and applying mask
			move.l	a2,(a5)+								; code for or'ing in bpl1,bpl2 from sprite data and writing back to screen
			move.l	.applymaskscreen,(a5)+					; code for loading bpl3,bpl4 from screen address and applying mask
			move.l	a2,(a5)+								; code for or'ing in bpl3,bpl4 from sprite data and writing back to screen
			jmp		.endcasea
.caseA_onlybpl2												; omit drawing bpl1,bpl2, because empty
			move.l	d1,(a6)+								; store bpl3,bpl4
					possiblyLoadMasks2						; code for optionally loading masks to registers, incase no masks left
			move.w	.skiponeb,(a5)+							; code for applying mask to bpl1,bpl2 on screen, and screen post increment
			move.l	.applymaskscreen,(a5)+					; code for loading bpl3,bpl4 from screen address and applying mask
			move.l	a2,(a5)+								; code for or'ing in bpl3,bpl4 from sprite data and writing back to screen
.endcasea
			add.w	#8,.completeOff
			dbra	d6,.doX									; next x
			add.w	#160-((10)+1)*8,d4			; add offset to next scanline to offset counter
			add.w	#160-((10)+1)*8,a4
			IFEQ	tunnelopt
			add.w	#160-((10)+1)*8,.completeOff
			ENDC
			neg.w	.storeOff
			subq.w	#1,.ytimes								; next y
			bge		.doY
			jmp		.end
.doCaseB	; the case where we skip drawing altogther
			addq.w	#8,d4									; no draw, and thus increase offset counter by 8	
			add.w	#8,.completeOff	
			dbra	d6,.doX									; next x
			add.w	#160-((10)+1)*8,d4			; add offset to next scanline to offset counter
			add.w	#160-((10)+1)*8,a4
			IFEQ	tunnelopt
			add.w	#160-((10)+1)*8,.completeOff
			ENDC
			neg.w	.storeOff
			subq.w	#1,.ytimes								; next y
			bge		.doY
			jmp		.end
.doCaseC	; the case where you want to copy
					possiblyAddOffsetToScreen2				; apply screen offset counter if needed
;			tst.l	d0										; check
;			beq		.skipd0									; if bpl1, bpl2 empty, optimize
.caseC_bpl1bpl2												; else draw both bitplanes
				move.l	d0,(a6)+							; store bpl1,bpl2
				move.l	d1,(a6)+							; store bpl3,bpl4
				move.l	d5,(a5)+							; code for copying buffers to screen
					IFEQ	tunnelopt
						tryStoreOff
					ENDC

;				jmp		.cont
;.skipd0														; omit drawing bpl1,bpl2, because empty
;			move.b	#0,$ffffc123
;				move.l	d1,(a6)+							; store bpl3,bpl4
;				move.w	.skipone,(a5)+						; add offset to screen for skippig bpl1,bpl2
;				move.w	d5,(a5)+							; code for copying buffer to screen
;.cont
			add.w	#8,.completeOff
			dbra	d6,.doX
			add.w	#160-((10)+1)*8,d4
			add.w	#160-((10)+1)*8,a4
			IFEQ	tunnelopt
			add.w	#160-((10)+1)*8,.completeOff
			neg.w	.storeOff
			ENDC
	subq.w	#1,.ytimes
	bge		.doY
.end
	move.w	#$4e75,(a5)+									; finish current drawing route by rts

	IFEQ	tunnelopt
	move.l	#-1,(a3)
	lea		notDrawList,a0
	ENDC

	rts
.storeOff		dc.w	-1
.completeOff	dc.w	0
.ytimes	dc.w	0
.times	dc.w	0
.xoff	dc.w	0
.casea
	move.l	(a1)+,d0
	move.l	(a1)+,d0

.applymaskscreen
	move.l	(a6),d7
.applymask
	and.l	d0,d7
	or.l	(a0)+,d7
	move.l	d7,(a6)+

.caseb
	addq.w	#8,a6

.casec
	move.l	(a0)+,(a6)+
	move.l	(a0)+,(a6)+

.leal
.skiph
	lea		160-((12)+1)*8(a6),a6
.skipone
	move.l	a4,(a6)+
.skiponeb
	and.l	d0,(a6)+

.movemlCounter	dc.w	7
.moveml
	movem.l	(a1)+,d0-d6






drawSpriteOptX
	subq.w	#1,.wait
	bge		.no
		lea		spritey,a0
		add.w	sproff,a0
		move.w	(a0),tunnelSpriteOff
		add.w	#2,sproff
		cmp.w	#2*50,sproff
		bne		.no
			move.w	#0,sproff
.no

	move.l	screenpointer2,a6
	add.w	tunnelSpriteOff,a6

	lea		xpointerListCode1,a0
	lea		xpointerListData1,a1
	lea		xpointerListMask1,a2

	move.l	(a0),a5
	move.l	(a1),a0
	move.l	(a2),a1
	move.l	#0,a4
	jmp		(a5)
	rts
.wait	dc.w	193


tunnelSpriteOff	dc.w	48*160+4*8

spritey	include	'tunnel/data/spritey.s'
sproff	dc.w	0

textureMovement		dc.l	4+128*4


;	REPT 3
;	dc.l	-12-128*4*4
;	dc.l	8+128*4*5
;	dc.l	20-128*4*3
;;	dc.l	32+128*4*7
;	dc.l	-8+128*4*4
;	dc.l	-16-128*4*3
;	ENDR

;tunnelOff	dc.w	0
;tunnelOffList
;.x set 0
;;	REPT 8
;		dc.w	.x
;.x set .x+12
;	ENDR


;; calculates a static normal map of the bumpmap effect
;;	so it can be reused for multiple frames
;preCalcBumpOffset
;	lea 	bumpraw,a1											;12
;	lea 	bumpOff,a2											;12
;
;	add.w	#1+18,a1	; miss first px and line				;8
;
;	move.l	a2,a0
;
;	move.l	a1,a4
;	move.l	a1,a5
;	move.l	a1,a6
;
;	add.w	#1,a1
;	sub.w	#1,a4
;	add.w	#128,a5
;	sub.w	#128,a6
;	
;	move.l	#128-1-2,d7										;4
;.doline			
;		add.w	#2,a2		; yeah sure, we skip some offset in destination
;		REPT 128-2
;			; a5 ,a6 are y
;			move.b	(a5)+,d2											;8				; we expect offsets for the overlay;
;			sub.b	(a6)+,d2											;8				; overlay is 4 bytes per pixel, 128x64
;			ext.w	d2													;4				; 64 = 8 
;			lsl.w	#7,d2												;20
;			move.b	(a1)+,d3											;8				; yes we need seperate register
;			sub.b	(a4)+,d3											;8
;			ext.w	d3																	; make sure sign is correct
;			add.w	d3,d2
;			add.w	d2,d2												;4
;			add.w	d2,d2												;4
;			move.w	d2,(a2)+											;8
;			move.w	d2,(a2)+											;8
;			move.w	d2,(a2)+											;8
;			move.w	d2,(a2)+											;8
;		ENDR
;		add.w	#2,a2		; yeah sure, we skip some offset in destination
;		add.l	#2,a1
;		add.l	#2,a4
;		add.l	#2,a5
;		add.l	#2,a6
;
;		dbf	d7,.doline
;	rts


; if we want to be really anal, we can generate these things
c2p12
TAB1:
	DC.B $00,$00,$00,$00		;0		0000 0000 0000 0000		col 0		0000 0000 0000 0000
	DC.B $C0,$00,$00,$00		;4		1100 0000 0000 0000		col 1		1000 0000 0000 0000
	DC.B $00,$C0,$00,$00		;8		0000 1100 0000 0000		col 2		1100 0000 0000 0000
	DC.B $C0,$C0,$00,$00		;12											1000 0100 0000 0000
	DC.B $00,$00,$C0,$00		;16											0000 1100 0000 0000
	DC.B $C0,$00,$C0,$00		;20
	DC.B $00,$C0,$C0,$00		;24
	DC.B $C0,$C0,$C0,$00		;28
	DC.B $00,$00,$00,$C0		;32
	DC.B $C0,$00,$00,$C0		;36
	DC.B $00,$C0,$00,$C0		;40
	DC.B $C0,$C0,$00,$C0		;44
	DC.B $00,$00,$C0,$C0		;48
	DC.B $C0,$00,$C0,$C0		;52
	DC.B $00,$C0,$C0,$C0		;56
	DC.B $C0,$C0,$C0,$C0		;60
c2p34
TAB2:
	DC.B $00,$00,$00,$00		;0
	DC.B $30,$00,$00,$00		;4
	DC.B $00,$30,$00,$00		;8
	DC.B $30,$30,$00,$00		;12
	DC.B $00,$00,$30,$00		;16
	DC.B $30,$00,$30,$00		;20
	DC.B $00,$30,$30,$00		;24
	DC.B $30,$30,$30,$00		;28
	DC.B $00,$00,$00,$30		;32
	DC.B $30,$00,$00,$30		;36
	DC.B $00,$30,$00,$30		;40
	DC.B $30,$30,$00,$30		;44
	DC.B $00,$00,$30,$30		;48
	DC.B $30,$00,$30,$30		;52
	DC.B $00,$30,$30,$30		;56
	DC.B $30,$30,$30,$30		;60
c2p56
TAB3:
	DC.B $00,$00,$00,$00		;0
	DC.B $0C,$00,$00,$00		;4
	DC.B $00,$0C,$00,$00		;8
	DC.B $0C,$0C,$00,$00		;12
	DC.B $00,$00,$0C,$00		;16
	DC.B $0C,$00,$0C,$00		;20
	DC.B $00,$0C,$0C,$00		;24
	DC.B $0C,$0C,$0C,$00		;28
	DC.B $00,$00,$00,$0C		;32
	DC.B $0C,$00,$00,$0C		;36
	DC.B $00,$0C,$00,$0C		;40
	DC.B $0C,$0C,$00,$0C		;44
	DC.B $00,$00,$0C,$0C		;48
	DC.B $0C,$00,$0C,$0C		;52
	DC.B $00,$0C,$0C,$0C		;56
	DC.B $0C,$0C,$0C,$0C		;60
c2p78	
TAB4:
	DC.B $00,$00,$00,$00		;0
	DC.B $03,$00,$00,$00		;4
	DC.B $00,$03,$00,$00		;8
	DC.B $03,$03,$00,$00		;12
	DC.B $00,$00,$03,$00		;16
	DC.B $03,$00,$03,$00		;20
	DC.B $00,$03,$03,$00		;24
	DC.B $03,$03,$03,$00		;28
	DC.B $00,$00,$00,$03		;32
	DC.B $03,$00,$00,$03		;36
	DC.B $00,$03,$00,$03		;40
	DC.B $03,$03,$00,$03		;44
	DC.B $00,$00,$03,$03		;48
	DC.B $03,$00,$03,$03		;52
	DC.B $00,$03,$03,$03		;56
	DC.B $03,$03,$03,$03		;60


;	section text




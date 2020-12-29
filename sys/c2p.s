;;;;;;;;;;; c2p routines

** generate 1:1 c2p masks
** a0 = output buffer

c2p_gen_1to1_masks:

		lea	c2pmask,a1
	;	move.l	pC2Ptab,a1

		moveq	#64-1,d7

.c2ptl:		move.b	(a1)+,d0
A		SET	0
		REPT	8
		move.b	d0,A(a0)
		lsr.b	#1,d0
A		SET	A+64
		ENDR
		lea	1(a0),a0
		dbf	d7,.c2ptl

		rts

	
** generate pairs of pixels for 1:1 c2p
** a0 = 1:1 table
** a2 = address of POINTER to first c2p table!
** a1-a4 = output tables

c2p_gen_1to1_table:

		lea	64(a0),a1		; a1= table for 2nd pix

		moveq	#4-1,d7			; loop for each table

.tl:		move.l	(a2)+,a3		; a3 = next table
		move.l	a0,a4			; a4 = work p for 1st pix
		moveq	#16-1,d6		; 1st pix loop

.1pl:			move.l	(a4)+,d0		; d0 = get first pix
			move.l	a1,a5			; a5 = work p for 2nd pix
			moveq	#16-1,d5		; 2nd pix loop

.2pl:				move.l	d0,d1			; d1 = copy of first pix		
				or.l	(a5)+,d1		; or in 2nd pix
				move.l	d1,(a3)+		; store in table
				dbf	d5,.2pl			; loop for each 2nd pix

			adda.w	#$400-64,a3		; move to next line of table
			dbf	d6,.1pl			; loop for each 1st pix

		lea	128(a0),a0		; move to next pair of pixels
		lea	128(a1),a1	
		dbf	d7,.tl

		rts


** generate 2:1 c2p masks
** a0 = output buffer
c2p_gen_2to1_masks:

		lea	c2pmask,a1
	;	move.l	pC2Ptab,a1

		moveq	#64-1,d7

.c2ptl:		move.b	(a1)+,d0
		move.b	d0,d1
		lsr.b	#1,d1
		or.b	d1,d0

A		SET	0
		REPT	4
		move.b	d0,A(a0)
		lsr.b	#2,d0
A		SET	A+64
		ENDR
		lea	1(a0),a0
		dbf	d7,.c2ptl

		rts


c2p_gen_2to1_table_lm:
;a0 = masks table
;a2 = buffer for backup

		moveq	#2-1,d7
		move.w	#$404,a3

.ml:		lea	64(a0),a1		; a1= table for 2nd pix
		move.l	a0,a4			; a4 = work p for 1st pix
		moveq	#16-1,d6		; 1st pix loop

.1pl:		move.l	(a4)+,d0		; d0 = get first pix
		move.l	a1,a5			; a5 = work p for 2nd pix
		moveq	#16-1,d5		; 2nd pix loop

.2pl:			move.l	d0,d1			; d1 = copy of first pix		
			or.l	(a5)+,d1		; or in 2nd pix
			move.l	(a3),(a2)+		; backup what's there already
			move.l	d1,(a3)+		; store in table
			dbf	d5,.2pl			; loop for each 2nd pix

		adda.w	#$400-64,a3		; move to next line of table
		dbf	d6,.1pl			; loop for each 1st pix	

		lea	128(a0),a0
		move.w	#$6404,a3
		dbf	d7,.ml

		rts



** generate 4:1 c2p masks
** a0 = output buffer

c2p_gen_4to1_masks:

		lea	c2pmask,a1
	;	move.l	pC2Ptab,a1

		moveq	#64-1,d7

.c2ptl:		move.b	(a1)+,d0
		move.b	d0,d1
		REPT	3
		lsr.b	#1,d1
		or.b	d1,d0
		ENDR

		move.b	d0,(a0)
		lsr.b	#4,d0
		move.b	d0,64(a0)

		lea	1(a0),a0
		dbf	d7,.c2ptl

		rts


** generate pairs of pixels for 4:1 c2p
** a0 = 4:1 table
** a2 = address of pairs table

c2p_gen_4to1_table:

		lea	64(a0),a1		; a1= table for 2nd pix
		move.l	a0,a4			; a4 = work p for 1st pix
		moveq	#16-1,d6		; 1st pix loop

.1pl:		move.l	(a4)+,d0		; d0 = get first pix
		move.l	a1,a5			; a5 = work p for 2nd pix
		moveq	#16-1,d5		; 2nd pix loop

.2pl:			move.l	d0,d1			; d1 = copy of first pix		
			or.l	(a5)+,d1		; or in 2nd pix
			move.l	d1,(a2)+		; store in table
			dbf	d5,.2pl			; loop for each 2nd pix

		adda.w	#$400-64,a2		; move to next line of table
		dbf	d6,.1pl			; loop for each 1st pix	

		rts



c2p_gen_4to1_table_lm:
;a0 = masks table
;a2 = buffer for backup

		lea	64(a0),a1		; a1= table for 2nd pix
		move.w	#$404,a3
		move.l	a0,a4			; a4 = work p for 1st pix
		moveq	#16-1,d6		; 1st pix loop

.1pl:		move.l	(a4)+,d0		; d0 = get first pix
		move.l	a1,a5			; a5 = work p for 2nd pix
		moveq	#16-1,d5		; 2nd pix loop

.2pl:			move.l	d0,d1			; d1 = copy of first pix		
			or.l	(a5)+,d1		; or in 2nd pix
			move.l	(a3),(a2)+		; backup what's there already
			move.l	d1,(a3)+		; store in table
			dbf	d5,.2pl			; loop for each 2nd pix

		adda.w	#$400-64,a3		; move to next line of table
		dbf	d6,.1pl			; loop for each 1st pix	

		rts


c2p_lm_restore:
;a0 = buffer for backup

		move.w	#$404,a3
		moveq	#16-1,d6		; 1st pix loop

.1pl:		moveq	#16-1,d5		; 2nd pix loop

.2pl:			move.l	(a0)+,(a3)+		; replace
			dbf	d5,.2pl			; loop for each 2nd pix

		adda.w	#$400-64,a3		; move to next line of table
		dbf	d6,.1pl			; loop for each 1st pix	

		rts


c2p_lm_restore_double:
;a0 = buffer for backup

		moveq	#2-1,d7
		move.w	#$404,a3


.ml:		moveq	#16-1,d6		; 1st pix loop

.1pl:		moveq	#16-1,d5		; 2nd pix loop

.2pl:			move.l	(a0)+,(a3)+		; replace
			dbf	d5,.2pl			; loop for each 2nd pix

		adda.w	#$400-64,a3		; move to next line of table
		dbf	d6,.1pl			; loop for each 1st pix	

		move.w	#$6404,a3
		dbf	d7,.ml

		rts



;;;; SUPERFAST 121zzzz!
; takes colour to flush bg in d0
c2p_flush_buffers_sf:

		;move.l	pC2PSource,a0
		lea	32640(a0),a0
		lea	32640(a0),a1
		lea	32640(a1),a2
		lea	32640(a2),a3
	
		addq.b	#1,d0
		add.b	d0,d0
		add.b	d0,d0
		move.b	d0,-(sp)
		move.w	(sp)+,d1
		move.b	d0,d1
		move.w	d1,d0
		swap	d0
		move.w	d1,d0

		move.l	d0,d1
		move.l	d1,d2
		move.l	d2,d3

		move.l	d3,d4
		addi.l	#$02020202,d4
		move.l	d4,d5
		move.l	d5,d6
		move.l	d6,a4


		move.w	#32640/64-1,d7
.clrloop1:	REPT	4
		movem.l	d0-d3,-(a0)
		movem.l	d4-d6/a4,-(a1)
		ENDR
		dbf	d7,.clrloop1

		
		move.l	d4,d0
		addi.l	#$3a3a3a3a,d0
		move.l	d0,d1
		move.l	d1,d2
		move.l	d2,d3

		move.l	d3,d4
		addi.l	#$02020202,d4
		move.l	d4,d5
		move.l	d5,d6
		move.l	d6,a4


		move.w	#32640/64-1,d7
.clrloop2:	REPT	4
		movem.l	d0-d3,-(a2)
		movem.l	d4-d6/a4,-(a3)
		ENDR
		dbf	d7,.clrloop2


		rts


; a0 = chunky image source
c2p_generate_chunktables_sf:

		;move.l	pC2PSource,a1
		;lea	256*14+LOGO_XWAVE_S/2(a1),a1
		move.l	a1,a2
		adda.l	#32640,a2
		move.l	a2,a3
		adda.l	#32640,a3
		move.l	a3,a4
		adda.l	#32640,a4

		lea	$02020202,a5
		lea	$3a3a3a3a,a6

		;moveq	#IMG_H-1,d7
.spcly:		
A	SET	0
			REPT	32		
;IMG_W/32

			movem.l	(a0)+,d0-d6/a3	; 32 pixels
			movem.l	d0-d6/a3,A(a1)

			add.l	a5,d0
			add.l	a5,d1
			add.l	a5,d2
			add.l	a5,d3
			add.l	a5,d4
			add.l	a5,d5
			add.l	a5,d6
			add.l	a5,a3
			movem.l	d0-d6/a3,A(a2)

			add.l	a6,d0
			add.l	a6,d1
			add.l	a6,d2
			add.l	a6,d3
			add.l	a6,d4
			add.l	a6,d5
			add.l	a6,d6
			add.l	a6,a3
			movem.l	d0-d6/a3,A(a3)

			add.l	a5,d0
			add.l	a5,d1
			add.l	a5,d2
			add.l	a5,d3
			add.l	a5,d4
			add.l	a5,d5
			add.l	a5,d6
			add.l	a5,a3
			movem.l	d0-d6/a3,A(a4)
A	SET	A+32
			ENDR

		lea	256(a1),a1
		lea	256(a2),a2
		lea	256(a3),a1
		lea	256(a4),a2

		dbf	d7,.spcly

		rts



; a0 = 4pl data
; a1 = chunky buffer
; d7 = num pix
c2p_planar_to_chunky:			; thnx spkr

		lsr.w	#4,d7
		subq.w	#1,d7
		;move.w	#320*200/16-1,d7

.bl:
		movem.w	(a0)+,d0-d3	; each plane in a word
		moveq	#16-1,d5
.pr:
		moveq	#0,d4
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4

		move.b	d4,(a1)+

		dbf	d5,.pr
		dbf	d7,.bl

		rts



		section	data

c2pmask:	dc.b	%00000000,%00000000,%00000000,%00000000 ; 0
		dc.b	%10000000,%00000000,%00000000,%00000000 ; 1
		dc.b	%00000000,%10000000,%00000000,%00000000 ; 2
		dc.b	%10000000,%10000000,%00000000,%00000000 ; 3
		dc.b	%00000000,%00000000,%10000000,%00000000 ; 4
		dc.b	%10000000,%00000000,%10000000,%00000000 ; 5
		dc.b	%00000000,%10000000,%10000000,%00000000 ; 6
		dc.b	%10000000,%10000000,%10000000,%00000000 ; 7
		dc.b	%00000000,%00000000,%00000000,%10000000 ; 8
		dc.b	%10000000,%00000000,%00000000,%10000000 ; 9
		dc.b	%00000000,%10000000,%00000000,%10000000 ; 10
		dc.b	%10000000,%10000000,%00000000,%10000000 ; 11
		dc.b	%00000000,%00000000,%10000000,%10000000 ; 12
		dc.b	%10000000,%00000000,%10000000,%10000000 ; 13
		dc.b	%00000000,%10000000,%10000000,%10000000 ; 14
		dc.b	%10000000,%10000000,%10000000,%10000000 ; 15

		even

		section	text
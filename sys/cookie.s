; Synclock demosystem for ST/STe
;
; cookie.s
;
; ae@dhs.nu

maxcookie:	equ	128				;Maximum cookie entries to search


		section	text

detect_machine:	move.l	$5a0.w,d0
		beq.s	.st				;Null pointer = ST
		move.l	d0,a0

		moveq	#maxcookie-1,d7
.search_mch:	tst.l	(a0)
		beq.s	.st				;Null termination of cookiejar, no _MCH found = ST

		cmp.l	#"_MCH",(a0)
		beq.s	.mch_found
		addq.l	#8,a0
		dbra	d7,.search_mch
		bra.s	.st				;Default to ST

.mch_found:	move.l	4(a0),d0
		cmp.l	#$00010000,d0
		beq.s	.ste
		cmp.l	#$00010010,d0
		beq.s	.megaste
		cmp.l	#$00020000,d0
		beq.s	.tt
		cmp.l	#$00030000,d0
		beq.s	.falcon

.st:		move.l	#"ST  ",machine
		rts

.ste:		move.l	#"STe ",machine
		rts

.megaste:	move.l	#"MSTe",machine
		rts

.tt:		move.l	#"TT  ",machine
		rts


.falcon:	;Check if we are on CT60/CT63/CT60e
		move.l	$5a0.w,a0
		moveq	#maxcookie-1,d7
.search_ct60:
		cmp.l	#"CT60",(a0)
		beq.s	.f060
		addq.l	#8,a0
		dbra	d7,.search_ct60

.f030:		move.l	#"F030",machine
		rts
.f060:		move.l	#"F060",machine
		rts


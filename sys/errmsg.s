; Synclock demosystem for ST/STe
;
; errmsg.s
;
; ae@dhs.nu

		section	data

			;0123456789012345678901234567890123456789
errmsg_mch:	dc.b	"Machine found: Atari ",0
errmsg_crlf:	dc.b	13,10,0
errmsg_exit:	dc.b	13,10,"Press any key to exit",13,10,0

		ifne	ste_demo
errmsg_mch_st: dc.b	"Machine required: Atari STe",13,10,0
		else
errmsg_mch_st:	dc.b	"Machine required: Atari ST or STe",13,10,0
		endc

		even

errmsg:		dc.l	0

		section	text

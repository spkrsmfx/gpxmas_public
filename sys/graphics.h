; Synclock demosystem for ST/STe
;
; graphics.h
; File format structs for graphics formats
;
; ae@dhs.nu


;============== Degas Elite lowres (PI1) ===============
		rsreset
pi1h_res:	rs.w	1
pi1h_pal:	rs.w	16
pi1h_bitmap:	rs.b	160*200
pi1h_cyclleft:	rs.w	4
pi1h_cyclright:	rs.w	4
pi1h_cycldir:	rs.w	4
pi1h_cycldelay:	rs.w	4
pi1h_sizeof:	rs.b	0

;============== Neochrome (NEO) =========================
		rsreset
neoh_flag:	rs.w	1
neoh_res:	rs.w	1
neoh_pal:	rs.w	16
neoh_filename:	rs.b	12
neoh_cycllimit:	rs.w	1
neoh_cyclspeed:	rs.w	1
neoh_cyclestep:	rs.w	1
neoh_xofs:	rs.w	1
neoh_yofs:	rs.w	1
neoh_width:	rs.w	1
neoh_height:	rs.w	1
neoh_reserved:	rs.w	33
neoh_bitmap:	rs.b	160*200
neoh_sizeof:	rs.b	0

;============== Spectrum 512/4096 (SPU) ================
		rsreset
spuh_bitmap:	rs.b	160*200
spuh_pal:	rs.w	48*199
spuh_sizeof:	rs.b	0

;============== MPP Mode 1 RAW dual image/palette ======
		rsreset
mpp1h_sizeof:	rs.b	0

;============== MPP Mode 2 RAW dual image/palette ======
		rsreset
mpp2h_sizeof:	rs.b	0

;============== MPP Mode 3 RAW dual image/palette ======
		rsreset
mpp3h_sizeof:	rs.b	0

;============== MPP Mode 4 RAW dual image/palette ======
		rsreset
mpp4h_sizeof:	rs.b	0

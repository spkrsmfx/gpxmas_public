;-------------- evl's syncscroll --------------------------------------
; thanx melcus for the suggestion to count offset size to allow
; hardsyncs in timer B


		section text

sscrl_init:	lea	sscrl_jumplist,a0
		move.l	#sscrl_line0,d0
		move.w	#7-1,d7
.lp:		move.l	d0,(a0)+
		dbf	d7,.lp
		move.w	#160*7,sscrl_count
		clr.l	sscrl_offset
		rts

; d2 = screen address
sscrl_setup_list:
		add.l	sscrl_offset,d2
		and.l	#$000000ff,d2

		lea	sscrl_combo_table,a1		;list of all 256/2 offset combos
		lsr.w	#1,d2				;reduce to 128 combinations
		lsl.w	#3,d2				;align with address list (8 byte boundary)
		add.l	d2,a1

		lea	sscrl_linewidths,a0		;list of routs with different linewidths
		lea	sscrl_jumplist,a2		;

		rept	7
		moveq	#0,d0
		move.b	(a1)+,d0			;get routine to run (0-6)
		lsl.w	#2,d0				;align to address list (4 byte boundary)
		move.l	(a0,d0.w),(a2)+			;write address to list
		endr

		rts

;Linewidth routines

		;160 byte line
sscrl_line0:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3 fetch next address
		add.w	#160,sscrl_count		;6
		dcb.w	119-26-6,$4e71			;
		rts					;4

		;158 byte line
sscrl_line1:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		add.w	#158,sscrl_count		;6
		dcb.w	93-26-6,$4e71			;
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	20,$4e71
		rts					;4

		;184 byte line
sscrl_line2:	nop
		nop
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		add.w	#184,sscrl_count		;6
		dcb.w	86-26-6,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	13,$4e71
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		nop
		rts					;4

		;204 byte line
sscrl_line3:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		add.w	#204,sscrl_count		;6
		dcb.w	95-26-6,$4e71			;
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	17,$4e71
		nop
		rts					;4

		;230 byte line
sscrl_line4:	nop
		nop
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		add.w	#230,sscrl_count		;6
		dcb.w	88-26-6,$4e71
		move.w	d7,$ffff820a.w			;3
		move.b	d7,$ffff820a.w			;3
		dcb.w	11,$4e71
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		nop
		rts					;4

		;186 byte line
sscrl_line5:	nop
		nop
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		add.w	#186,sscrl_count		;6
		dcb.w	105-26-6,$4e71
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		nop
		rts					;4

		;54 byte line
sscrl_line6:	nop
		;music_ymdigi8_play_sample		;23
		dcb.w	23,$4e71			;23
		move.l	(a3)+,a0			;3
		add.w	#54,sscrl_count			;6
		dcb.w	41-26-6,$4e71			;
		move.b	d7,$ffff8260.w			;3
		move.w	d7,$ffff8260.w			;3
		dcb.w	71,$4e71
		nop
		rts					;4


;-------------- syncscroll data -------------------------------

sscrl_offset:	dc.l	0
sscrl_count:	dc.w	0
sscrl_jumplist:	dcb.l	7
sscrl_linewidths:
		dc.l	sscrl_line0			;+000 bytes
		dc.l	sscrl_line1			;-002 bytes
		dc.l	sscrl_line2			;+024 bytes
		dc.l	sscrl_line3			;+044 bytes
		dc.l	sscrl_line4			;+070 bytes
		dc.l	sscrl_line5			;+026 bytes
		dc.l	sscrl_line6			;-106 bytes


sscrl_combo_table:
 dc.b 0,0,0,0,0,0,0,0  ; 0
 dc.b 6,4,3,1,1,1,0,0  ; 2
 dc.b 6,4,3,1,1,0,0,0  ; 4
 dc.b 6,4,3,1,0,0,0,0  ; 6
 dc.b 6,4,3,0,0,0,0,0  ; 8
 dc.b 6,4,2,2,1,0,0,0  ; 10
 dc.b 6,4,2,2,0,0,0,0  ; 12
 dc.b 6,5,4,2,0,0,0,0  ; 14
 dc.b 6,5,5,4,0,0,0,0  ; 16
 dc.b 2,1,1,1,0,0,0,0  ; 18
 dc.b 2,1,1,0,0,0,0,0  ; 20
 dc.b 2,1,0,0,0,0,0,0  ; 22
 dc.b 2,0,0,0,0,0,0,0  ; 24
 dc.b 5,0,0,0,0,0,0,0  ; 26
 dc.b 6,4,4,1,1,1,0,0  ; 28
 dc.b 6,4,4,1,1,0,0,0  ; 30
 dc.b 6,4,4,1,0,0,0,0  ; 32
 dc.b 6,4,4,0,0,0,0,0  ; 34
 dc.b 3,1,1,1,1,0,0,0  ; 36
 dc.b 3,1,1,1,0,0,0,0  ; 38
 dc.b 3,1,1,0,0,0,0,0  ; 40
 dc.b 3,1,0,0,0,0,0,0  ; 42
 dc.b 3,0,0,0,0,0,0,0  ; 44
 dc.b 2,2,1,0,0,0,0,0  ; 46
 dc.b 2,2,0,0,0,0,0,0  ; 48
 dc.b 5,2,0,0,0,0,0,0  ; 50
 dc.b 5,5,0,0,0,0,0,0  ; 52
 dc.b 6,4,4,2,1,1,0,0  ; 54
 dc.b 6,4,4,2,1,0,0,0  ; 56
 dc.b 6,4,4,2,0,0,0,0  ; 58
 dc.b 6,5,4,4,0,0,0,0  ; 60
 dc.b 4,1,1,1,1,0,0,0  ; 62
 dc.b 4,1,1,1,0,0,0,0  ; 64
 dc.b 4,1,1,0,0,0,0,0  ; 66
 dc.b 4,1,0,0,0,0,0,0  ; 68
 dc.b 4,0,0,0,0,0,0,0  ; 70
 dc.b 2,2,2,0,0,0,0,0  ; 72
 dc.b 5,2,2,0,0,0,0,0  ; 74
 dc.b 5,5,2,0,0,0,0,0  ; 76
 dc.b 5,5,5,0,0,0,0,0  ; 78
 dc.b 3,3,1,1,1,1,0,0  ; 80
 dc.b 3,3,1,1,1,0,0,0  ; 82
 dc.b 3,3,1,1,0,0,0,0  ; 84
 dc.b 3,3,1,0,0,0,0,0  ; 86
 dc.b 3,3,0,0,0,0,0,0  ; 88
 dc.b 4,2,1,1,0,0,0,0  ; 90
 dc.b 4,2,1,0,0,0,0,0  ; 92
 dc.b 4,2,0,0,0,0,0,0  ; 94
 dc.b 5,4,0,0,0,0,0,0  ; 96
 dc.b 5,2,2,2,0,0,0,0  ; 98
 dc.b 5,5,2,2,0,0,0,0  ; 100
 dc.b 5,5,5,2,0,0,0,0  ; 102
 dc.b 6,4,4,4,0,0,0,0  ; 104
 dc.b 4,3,1,1,1,1,0,0  ; 106
 dc.b 4,3,1,1,1,0,0,0  ; 108
 dc.b 4,3,1,1,0,0,0,0  ; 110
 dc.b 4,3,1,0,0,0,0,0  ; 112
 dc.b 4,3,0,0,0,0,0,0  ; 114
 dc.b 4,2,2,1,0,0,0,0  ; 116
 dc.b 4,2,2,0,0,0,0,0  ; 118
 dc.b 5,4,2,0,0,0,0,0  ; 120
 dc.b 5,5,4,0,0,0,0,0  ; 122
 dc.b 5,5,2,2,2,0,0,0  ; 124
 dc.b 5,5,5,2,2,0,0,0  ; 126
 dc.b 3,3,3,1,1,0,0,0  ; 128
 dc.b 3,3,3,1,0,0,0,0  ; 130
 dc.b 3,3,3,0,0,0,0,0  ; 132
 dc.b 4,4,1,1,1,0,0,0  ; 134
 dc.b 4,4,1,1,0,0,0,0  ; 136
 dc.b 4,4,1,0,0,0,0,0  ; 138
 dc.b 4,4,0,0,0,0,0,0  ; 140
 dc.b 4,2,2,2,0,0,0,0  ; 142
 dc.b 5,4,2,2,0,0,0,0  ; 144
 dc.b 5,5,4,2,0,0,0,0  ; 146
 dc.b 5,5,5,4,0,0,0,0  ; 148
 dc.b 5,5,5,2,2,2,0,0  ; 150
 dc.b 4,3,3,1,1,1,0,0  ; 152
 dc.b 4,3,3,1,1,0,0,0  ; 154
 dc.b 4,3,3,1,0,0,0,0  ; 156
 dc.b 4,3,3,0,0,0,0,0  ; 158
 dc.b 4,4,2,1,1,0,0,0  ; 160
 dc.b 4,4,2,1,0,0,0,0  ; 162
 dc.b 4,4,2,0,0,0,0,0  ; 164
 dc.b 5,4,4,0,0,0,0,0  ; 166
 dc.b 5,4,2,2,2,0,0,0  ; 168
 dc.b 5,5,4,2,2,0,0,0  ; 170
 dc.b 5,5,5,4,2,0,0,0  ; 172
 dc.b 3,3,3,3,1,0,0,0  ; 174
 dc.b 3,3,3,3,0,0,0,0  ; 176
 dc.b 4,4,3,1,1,1,0,0  ; 178
 dc.b 4,4,3,1,1,0,0,0  ; 180
 dc.b 4,4,3,1,0,0,0,0  ; 182
 dc.b 4,4,3,0,0,0,0,0  ; 184
 dc.b 4,4,2,2,1,0,0,0  ; 186
 dc.b 4,4,2,2,0,0,0,0  ; 188
 dc.b 5,4,4,2,0,0,0,0  ; 190
 dc.b 5,5,4,4,0,0,0,0  ; 192
 dc.b 5,5,4,2,2,2,0,0  ; 194
 dc.b 5,5,5,4,2,2,0,0  ; 196
 dc.b 4,3,3,3,1,1,0,0  ; 198
 dc.b 4,3,3,3,1,0,0,0  ; 200
 dc.b 4,3,3,3,0,0,0,0  ; 202
 dc.b 4,4,4,1,1,1,0,0  ; 204
 dc.b 4,4,4,1,1,0,0,0  ; 206
 dc.b 4,4,4,1,0,0,0,0  ; 208
 dc.b 4,4,4,0,0,0,0,0  ; 210
 dc.b 4,4,2,2,2,0,0,0  ; 212
 dc.b 5,4,4,2,2,0,0,0  ; 214
 dc.b 5,5,4,4,2,0,0,0  ; 216
 dc.b 5,5,5,4,4,0,0,0  ; 218
 dc.b 3,3,3,3,3,0,0,0  ; 220
 dc.b 4,4,3,3,1,1,1,0  ; 222
 dc.b 4,4,3,3,1,1,0,0  ; 224
 dc.b 4,4,3,3,1,0,0,0  ; 226
 dc.b 4,4,3,3,0,0,0,0  ; 228
 dc.b 4,4,4,2,1,1,0,0  ; 230
 dc.b 4,4,4,2,1,0,0,0  ; 232
 dc.b 4,4,4,2,0,0,0,0  ; 234
 dc.b 5,4,4,4,0,0,0,0  ; 236
 dc.b 5,4,4,2,2,2,0,0  ; 238
 dc.b 5,5,4,4,2,2,0,0  ; 240
 dc.b 5,5,5,4,4,2,0,0  ; 242
 dc.b 4,3,3,3,3,1,0,0  ; 244
 dc.b 4,3,3,3,3,0,0,0  ; 246
 dc.b 4,4,4,3,1,1,1,0  ; 248
 dc.b 4,4,4,3,1,1,0,0  ; 250
 dc.b 4,4,4,3,1,0,0,0  ; 252
 dc.b 4,4,4,3,0,0,0,0  ; 254
		even

		section	text
	
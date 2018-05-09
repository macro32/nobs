  	SUBTTL	Disc handling routines

	COMMENT	%

	NOBSDISC v1.0
	All disc traffic handled here

	contents:
	BUFFER_HEX		displays buffer to screen in hex
	BUFFER_ASCII		displays buffer to screen in ascii
	COORDS_ASCII		calculates ascii screen coordinates for cursor
	COORDS_HEX		calculates hex screen coordinates for cursor
	CURSOR_ASCII		highlights current cursor position in ascii screen
	CURSOR_HEX		highlights current cursor position in hex screen
	NORMAL_ASCII		displays current cursor position in normal video as ascii
	NORMAL_HEX		displays current cursor position in normal video as hex

	%

BUFFER_HEX	PROC	NEAR
;displays the disc buffer in hex
;  DISC_BUFFER 	= start of disc table of 512 bytes
;  BX		= row number 0-15
;  SI		= col number 0-15
	XOR	BX,BX				;clear counters
	XOR	AH,AH				;clear high byte
	MOV	AL,LINE_NUMBER			;get offset
	MOV	CL,4				;times 16
	SHL	AX,CL				;to get index...
	MOV	BX,AX				; put in our index register
	MOV	DH,BUFFER$YORG			;start line of display
BH$10:	MOV	DL,BUFFER$XORG			;start column
	CALL	MOVETO				;go there
	MOV	CX,16				;col count
	XOR	SI,SI				;clear offset
BH$20:	MOV	AL, DISC_BUFFER[BX+SI]		;pick up byte
	CALL	OUTHEX_AL			;output it
	OUTPUT					;space to follow
	INC	SI				;count across
	LOOP	BH$20				;loop 16 times across
	ADD	BX,SI				;add to new base
	INC	DH				;increase line number
	CMP	DH,LAST$BUFFER$LINE		;last line reached?
	JNZ	BH$10				;back round to next line
	RET					;finished
BUFFER_HEX	ENDP

BUFFER_ASCII	PROC	NEAR
;displays the buffer in ascii
;  DISC_BUFFER	= start address of disc buffer
;  BX		= row index
;  SI		= col index
	XOR	BX,BX				;clear counters
	XOR	AH,AH				;clear high byte
	MOV	AL,LINE_NUMBER			;get offset
	MOV	CL,4				;times 16
	SHL	AX,CL				;to get index...
	MOV	BX,AX				; put in our index register
	MOV	DH,BUFFER$YORG			;start line of display
BA$10:	MOV	DL,BUFFER$XORG+50		;start column
	CALL	MOVETO				;go there
	MOV	CX,16				;col count
	XOR	SI,SI				;clear offset
BA$20:	MOV	AL, DISC_BUFFER[BX+SI]		;pick up byte
	CALL	OUTPUT_ASC			;output it
	INC	SI				;count across
	LOOP	BA$20				;loop 16 times across
	ADD	BX,SI				;add to new base
	INC	DH				;increase line number
	CMP	DH,LAST$BUFFER$LINE		;last line reached?
	JNZ	BA$10				;back round to next line
	RET					;finished 
BUFFER_ASCII	ENDP

COORDS_ASCII	PROC
; calculates ascii screen coordinates for cursor positioning
;
; enter with:	LINE_INDEX	= current line offset
;		COLUMN_INDEX	= current column offset
; uses:	DX
	MOV	DH, LINE_INDEX			;get line counter
	MOV	DL, COLUMN_INDEX		;and column index
	ADD	DH, ASCII$YORG			;add start line
	ADD	DL, ASCII$XORG			;and column
	CALL	MOVETO				;go there
	RET
COORDS_ASCII	ENDP

COORDS_HEX	PROC
; calculates the screen coordinates for the hex screen from the cursor position
;
; enter with:	LINE_INDEX	= current line offset
;		COLUMN_INDEX	= current column offset
; uses:	AX,DX
	MOV	DH, LINE_INDEX			;get line and column
	MOV	AL, COLUMN_INDEX
	ADD	DH, HEX$YORG			;line = origin + offset
	MOV	DL,3				; column offset * 3
	MUL	DL				;result in AX
	MOV	DL,AL				;answer should be < 255 !
	ADD	DL, HEX$XORG			;add the origin
	CALL	MOVETO
	RET
COORDS_HEX	ENDP

CURSOR_HEX	PROC
; displays the current cursor position highlighted on the hex screen
;
; enter with:	LINE_INDEX	= current line index
;		COLUMN_INDEX	= column index
; uses:	AX,BX,SI
	CALL	COORDS_HEX			;go to the correct screen bit
	XOR	AH,AH				;clear space
	XOR	BX,BX				;
	MOV	BL,LINE_NUMBER			;get start of display line no
	ADD	BL, LINE_INDEX			;get indexes into screen
	SHL	BX,1
	SHL	BX,1				;line number * 16
	SHL	BX,1
	SHL	BX,1
	MOV	AL, COLUMN_INDEX
	MOV	SI,AX
	MOV	AL, DISC_BUFFER[BX+SI]		;retrieve byte
	CALL	REVERSE_HEX			;output reverse video
	RET
CURSOR_HEX	ENDP

CURSOR_ASCII	PROC
; displays the current cursor position on the ascii screen in reverse video
;
; enter with:	LINE_INDEX	= current line offset
;		COLUMN_INDEX	= current column offset
; uses:	AX,BX,SI
	CALL	COORDS_ASCII			;get screen location
	XOR	AH,AH				;clear space
	XOR	BX,BX				;
	MOV	BL,LINE_NUMBER			;get start of display line no
	ADD	BL, LINE_INDEX			;get indexes into screen
	SHL	BX,1
	SHL	BX,1				;line count * 16
	SHL	BX,1
	SHL	BX,1
	MOV	AL, COLUMN_INDEX
	MOV	SI,AX
	MOV	AL, DISC_BUFFER[BX+SI]		;get the character
	CALL	REVERSE_ASCII
	RET
CURSOR_ASCII	ENDP

NORMAL_HEX	PROC
; displays the current cursor position on the hex screen
;
; enter with:	LINE_INDEX	= current line index
;		COLUMN_INDEX	= column index
; uses:	AX,BX,SI
	CALL	COORDS_HEX			;go to correct bit
	XOR	AH,AH				;clear space
	XOR	BX,BX				;
	MOV	BL,LINE_NUMBER			;get start of display line no
	ADD	BL, LINE_INDEX			;get indexes into screen
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1
	MOV	AL, COLUMN_INDEX
	MOV	SI,AX
	MOV	AL, DISC_BUFFER[BX+SI]		;retrieve byte
	CALL	OUTHEX_AL			;output in ordinary video
	RET
NORMAL_HEX	ENDP

NORMAL_ASCII	PROC
; displays the current cursor position on the ascii screen
;
; enter with:	LINE_INDEX	= current line offset
;		COLUMN_INDEX	= current column offset
; uses:	AX,BX,SI
	CALL	COORDS_ASCII			;go to correct bit
	XOR	AH,AH				;clear space
	XOR	BX,BX				;
	MOV	BL,LINE_NUMBER			;get start of display line no
	ADD	BL, LINE_INDEX			;get indexes into screen
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1
	MOV	AL, COLUMN_INDEX
	MOV	SI,AX
	MOV	AL, DISC_BUFFER[BX+SI]		;get the character
	CALL	OUTPUT_ASC			;output in ordinary video
	RET
NORMAL_ASCII	ENDP

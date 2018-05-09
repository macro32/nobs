 	SUBTTL	Input - Output routines 

 
	COMMENT	%

	IO v1.0
	All input and output routines

	contents:

	DIV32			writes DX:AX as 32 bit unsigned integer to CON:
	INPUT_CHAR		reads character from the CON:
	OUTPUT_CHAR		writes a character to CON:
	OUTPUT_DECIMAL		writes AX to CON: as decimal number
	OUTPUT_ASC		writes a character to CON: non print special
	OUTPUT_STRING		writes a character to CON:
	OUTHEX_AL		writes AL as two hex digits
	OUTHEX_AX		writes AX as four hex digits
	MOVETO			moves cursor to screen location

	%

DIV32		PROC	NEAR
; call:	mov	ax,low bytes
;	mov	dx,high bytes
;	call	DIV32
; uses:	ax,bx,cx
	mov	cx,10			;decimal radix
trdxw1: div	cx			;divide it
	push	dx			;save remainder
	xor	dx,dx			;clear remainder
	test	ax,0ffffh		;any number left?
	jz	trdxw2			;no so unwind
	call	trdxw1			;continue to divide
trdxw2:	pop	ax			;get back a digit
	add	al,'0'			;convert to ascii
	call	OUTPUT_CHAR		;type out and return
	RET
DIV32		ENDP

INPUT_CHAR	PROC	NEAR
;reads character from CON: into AL register if one is available
	PUSH	BX			;save registers
	PUSH	CX
	PUSH	DX
	MOV	AH,ZDOS$CONIO		;direct console io function
	MOV	DL,0FFH			;input function required
	INT	BDOS			;make a function call
	POP	DX
	POP	CX
	POP	BX			;restore registers
	RET
INPUT_CHAR	ENDP

OUTPUT_CHAR	PROC	NEAR
;outputs a character from the AL register to CON:
	PUSH	AX
	PUSH	BX			;save the registers
	PUSH	CX
	PUSH	DX
	PUSH	SI			;we use this with string output
	MOV	AH,ZDOS$CONIO		;direct io required
	MOV	DL,AL			;output function required
	INT	BDOS			;make function call
	POP	SI
	POP	DX
	POP	CX
	POP	BX			;restore registers
	POP	AX			;including the character
	RET
OUTPUT_CHAR	ENDP

OUTPUT_ASC	PROC	NEAR
;outputs a character from AL to CON: if character non printing then use '.'
	CMP	AL,DEL			;delete character?
	JNC	ASC_10			;yes it is
	CMP	AL,' '			;control character?
	JNC	ASC_20			;no
ASC_10:	MOV	AL,'.'			;get a substitute
ASC_20:	CALL	OUTPUT_CHAR		;output it
	RET
OUTPUT_ASC	ENDP

OUTPUT_DECIMAL	PROC	NEAR
;outputs AX as decimal number simplistic approach no = 0-99 only
	PUSH	AX			;save number
	PUSH	CX			;save counter
	XOR	CX,CX			;clear counters
OD$10:	CMP	AX,10			;any tens left?
	JC	OD$20			;no so process units
	INC	CH			;tens = tens + 1
	SUB	AX,10			; number = number - 10 decimal
	JMP	OD$10			;keep going
OD$20:	ADD	CH,'0'			;convert tens
	ADD	AL,'0'			;convert units
	PUSH	AX			;save units
	MOV	AL,CH			;output tens
	CALL	OUTPUT_CHAR
	POP	AX			;then units
	CALL	OUTPUT_CHAR
	POP	CX
	POP	AX			;restore status quo
	RET				;finished 
OUTPUT_DECIMAL	ENDP

OUTPUT_STRING	PROC	NEAR
;outputs a string of ascii characters terminated by a '$'
	MOV	AL,[SI]			;get a byte from memory
	CMP	AL,'$'			;is it terminator
	JZ	STR1			;yes so done
	CALL	OUTPUT_CHAR		;output character
	INC	SI			;bump pointer
	JMP	OUTPUT_STRING		;keep going
STR1:	RET				;return
OUTPUT_STRING	ENDP

OUTHEX_AL	PROC	NEAR
;outputs AL as two hex digits
	PUSH	AX			;save a copy
	SHR	AL,1			;shift four bits
	SHR	AL,1
	SHR	AL,1
	SHR	AL,1
	CALL	OH_10_B
	POP	AX			;get next nibble
OH_10_B:AND	AL,0FH			;only bottom nibble
	ADD	AL,90H			;convert to ascii
	DAA
	ADC	AL,40H
	DAA
	CALL	OUTPUT_CHAR		;output character
	RET
OUTHEX_AL	ENDP

OUTHEX_AX	PROC	NEAR
;outputs AX as four hex digits, using OUTHEX_AL
	PUSH	AX			;save a copy
	MOV	AL,AH			;get high byte
	CALL	OUTHEX_AL		;output high byte
	POP	AX			;restore 
	CALL	OUTHEX_AL		;output low byte
	RET
OUTHEX_AX	ENDP

MOVETO		PROC	NEAR
;goes to a screen location DH=col DL=line
	PUSH	AX			;save registers
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CON_ESC2 Y			;macro will output ESC + 'Y'
	MOV	AL,DH			;get line number
	ADD	AL,' '-1		;offset
	CALL	OUTPUT_CHAR		;output line number
	MOV	AL,DL			;get column number
	ADD	AL,' '-1		;add offset
	CALL	OUTPUT_CHAR
	POP	DX
	POP	CX
	POP	BX
	POP	AX			;restore some registers
	RET
MOVETO	ENDP

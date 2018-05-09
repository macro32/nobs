		SUBTTL Library routines for NOBS

	COMMENT	%

	NOBSLIB v1.0
	NOBS Library

	A set of routines for use with NOBS that may
	later prove to be of some general use.

	contents:
	CHECKRECORD		tests for record no in range 0-record_number
	CHECKSECTOR		tests for sector no in range 0-8
	CHECKTRACK		tests for track no in range 0-40
	CLOSEFILE		file close subroutine
	DISPLAY_ABSOLUTE	displays track/sector heading
	DISPLAY_COMMAND		displays command prompt
	DISPLAY_DATE		displays date held in system format
	DISPLAY_FIXED		displays fixed characters to the screen 
	DISPLAY_SECTOR		gets and displays current sector
	DISPLAY_TIME		decodes and displays time held in system format
	DISPLAY_TRACK		gets and displays current track
	ERROR_CLEAR		clears error line
	ERROR_MESSAGE		displays error message to screen
	FILEDETAILS		gets and displays all file details
	LOWER$TO$UPPER		changes lower case to upper
	NIBBLE			checks for valid hex character in AL
	NORMAL$BOTTOM$ARROW	outputs a down pointing arrow
	NORMAL$TOP$ARROW	outputs an up pointing arrow
	OPENFILE		file open subroutine
	PARSEFILENAME		uses Z-DOS function to parse filename
	READFILE		random read of file into 512 byte buffer
	READSECTOR		reads a sector from disc
	REVERSE$BOTTOM$ARROW	outputs a down pointing arrow in reverse video
	REVERSE$UP$ARROW	outputs an upward pointing arrow in reverse video
	REVERSE_ASCII		outputs AL as ascii character in reverse video
	REVERSE_HEX		outputs AL as two hex digits in reverse video
	SAVE_FILERECORD		save a file record question
	SETDTA			sets disc transfer address for reads
	WRITEFILE		write a record to a file
	WRITESECTOR		writes a sector to disc

	%

CHECKRECORD	PROC	NEAR
; checks for valid sector in range 0-record_number
; if valid then number is moved to fcb+fcb_ranrec
	MOV	AX,LOW$BYTES			;get random record number
	CMP	AX,RECORD_NUMBER		;is what we got < = what we permit?
	JZ	CR10				;theyre equal
	JNC	CR11				;no carry = out of range error
CR10:	MOV	FCB+FCB_RANREC,AX		;else set record field
	RET
CR11:	MOV	AL,RE$ROR			;record out of range error
	CALL	ERROR_MESSAGE
	RET
CHECKRECORD	ENDP

CHECKSECTOR	PROC	NEAR
; checks for valid sector no in range 0-7 in LOW$BYTES
; if valid then number is moved to SECTOR_NUMBER
	MOV	AX,LOW$BYTES			;get the number
	TEST	AH,AH				;anything in high byte?
	JNZ	CS10				;error if anything there
	CMP	AL,SECTOR$MAX+1			;is it < 8 ?
	JNC	CS10				;no carry = no
	MOV	SECTOR_NUMBER,AL		;save it as new sector number
	CLC					;flag ok
	RET					;done
CS10:	MOV	AL,SE$SOR			;sector no out of range
	CALL	ERROR_MESSAGE			;give an error message
	STC					;flag error
	RET					;exit
CHECKSECTOR	ENDP

CHECKTRACK	PROC	NEAR
; checks for valid track no in range 0-79 in LOW$BYTES
; if valid then number is moved to TRACK_NUMBER
	MOV	AX,LOW$BYTES			;get the number
	TEST	AH,AH				;anything in high byte?
	JNZ	CT10				;error if anything there
	CMP	AL,TRACK$MAX+1			;is it < 80 ?
	JNC	CT10				;no carry = no
	MOV	TRACK_NUMBER,AL			;save it as new track number
	CLC					;flag ok
	RET					;done
CT10:	MOV	AL,TR$TOR			;track no out of range
	CALL	ERROR_MESSAGE			;give an error message
	STC					;flag error
	RET					;exit
CHECKTRACK	ENDP

CLOSEFILE	PROC	NEAR
; closes a file
; enter with DS:DX pointing to opened FCB
; exit with Z = 0  successful close
;	    Z = 1  close error ( File not found according to manual )
; uses: AX
	MOV	AH,ZDOS$CLOSE				;close file function
	INT	BDOS					;call the system
	INC	AL					;check result
	RET						;zero flag if error
CLOSEFILE	ENDP

DISPLAY_ABSOLUTE	PROC	NEAR
; displays the header for absolute sector/track access
	GOTO	YORG+2,XORG+8				;next location
	MOV	SI, OFFSET TRACK_TITLE			;track counter
	CALL	OUTPUT_STRING
	GOTO	YORG+2,XORG+19				;next bit
	MOV	SI, OFFSET SECTOR_TITLE			;sector counter
	CALL	OUTPUT_STRING
DISPLAY_ABSOLUTE	ENDP

DISPLAY_COMMAND	PROC	NEAR
; displays command prompt
	GOTO	YORG+21,XORG+8				;command prompt
	MOV	SI, OFFSET COMMAND_PROMPT
	CALL	OUTPUT_STRING
	XOR	AL,AL					;flush buffers
	MOV	AH,ZDOS$FLUSH
	INT	BDOS
	CALL	DELETE_EOLN				;clear to end of line
	CALL	CURSOR_ON
	RET
DISPLAY_COMMAND	ENDP

DISPLAY_DATE	PROC	NEAR
;displays the date held in system format in AX
	PUSH	AX					;save a bit
	PUSH	BX
	PUSH	CX
	MOV	BX,AX					;save date
	AND	AX, MASK DAY				;get the day
	MOV	CL, DAY					;shift count
	SHR	AX,CL
	CALL	OUTPUT_DECIMAL				;output day
	OUTPUT	-					;seperator
	MOV	AX,BX					;restore date
	AND	AX, MASK MONTH				;now for month
	MOV	CL, MONTH
	SHR	AX,CL
	CALL	OUTPUT_DECIMAL
	OUTPUT	-
	MOV	AX,BX					;finally year
	AND	AX, MASK YEAR
	MOV	CL, YEAR
	SHR	AX,CL
	ADD	AX,80					;add offset 1980
	CALL	OUTPUT_DECIMAL
	POP	CX					;restore
	POP	BX
	POP	AX
	RET
DISPLAY_DATE	ENDP

DISPLAY_FIXED	PROC	NEAR
;displays the fixed characters to the screen
	CALL	CLEAR_SCREEN
	GOTO	YORG,XORG+38				;position it
	CALL	REVERSE_ON				;switch on reverse
	MOV	SI, OFFSET SCREEN_HEADER		;get screen header
	CALL	OUTPUT_STRING				;output it
	CALL	REVERSE_OFF				;back to normal
	RET
DISPLAY_FIXED	ENDP

DISPLAY_TIME	PROC	NEAR
;displays the time held in system format in AX
; call with:	AX = time in system format
; uses:	none
	PUSH	AX					;save a few
	PUSH	BX
	PUSH	CX
	MOV	BX,AX					;copy time
	AND	AX, MASK HOURS				;start with hours
	MOV	CL, HOURS				;count of bits
	SHR	AX,CL					;hours in low bits
	CALL	OUTPUT_DECIMAL				;output decimal number
	MOV	AL,':'					;seperator
	CALL	OUTPUT_CHAR
	MOV	AX,BX					;start again with mins
	AND	AX, MASK MINS
	MOV	CL, MINS
	SHR	AX,CL
	CALL	OUTPUT_DECIMAL				;output minutes
	POP	CX					;restore everything
	POP	BX
	POP	AX
	RET
DISPLAY_TIME	ENDP

DISPLAY_SECTOR	PROC	NEAR
;displays the sector number to the screen
	GOTO	SECTOR$Y,SECTOR$X			;go to location
	MOV	AL, SECTOR_NUMBER			;get sector number
	XOR	AH,AH					;clear high byte
	CALL	OUTPUT_DECIMAL				;output value
	RET
DISPLAY_SECTOR	ENDP

DISPLAY_TRACK	PROC	NEAR
;displays the track number to the screen
	GOTO	TRACK$Y,TRACK$X				;go to location
	MOV	AL, TRACK_NUMBER			;get track number
	XOR	AH,AH					;clear high byte
	CALL	OUTPUT_DECIMAL				;output number
	RET
DISPLAY_TRACK	ENDP


ERROR_CLEAR	PROC
;clear error message line after new character typed
	PUSH	AX				;used by some routines
	CALL	SAVE_CURSOR			;save cursor position
	GOTO	ERROR$Y,ERROR$X			;use these
	CALL	DELETE_LINE			;clear line function
	CALL	RESTORE_CURSOR			;restore cursor position
	POP	AX
	RET
ERROR_CLEAR	ENDP

ERROR_MESSAGE	PROC
;error message routine
; enter with:	AL = error code = index to error messages
	PUSH	AX
	PUSH	BX
	PUSH	DX
	PUSH	SI
	PUSH	AX
	CALL	SAVE_CURSOR			;remember where we are
	POP	AX
	XOR	AH,AH				;clear high byte
	MOV	BX,AX				;get index
	MOV	SI,ERRORS[BX]			;address of message
	GOTO	ERROR$Y,ERROR$X			;go to screen location
	CALL	OUTPUT_STRING			;output it
	MOV	AL,BELL				;draw attention
	CALL	OUTPUT_CHAR
	CALL	RESTORE_CURSOR			;as you were...
	POP	SI
	POP	DX				;all registers preserved
	POP	BX
	POP	AX			
	RET
ERROR_MESSAGE	ENDP

FILEDETAILS	PROC	NEAR
;displays file details to screen
;	currently these are:	name
;				time created
;				date created
;				size of file in bytes
;				number of 512 byte records
; enter with DS:DX pointing to opened fcb
; uses:	none
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX		;save it
	GOTO	YORG+2,XORG+8	;location for displaying details
	POP	DX
	PUSH	DX
	MOV	BX,DX		;get index
	ADD	BX, FCB_FNAME	;point to name
	MOV	CX,11		;no of characters in name

FD$10:	MOV	AL,[BX]		;get byte
	CALL	OUTPUT_CHAR	;output character
	INC	BX		;move pointer
	CMP	CL,4		;reached end of name?
	JNZ	FD$11		;no so forget
	OUTPUT			;else give an extra space
FD$11:	LOOP	FD$10		;do the lot including spaces

	MOV	AL,HT		;output tab
	CALL	OUTPUT_CHAR
	MOV	BX,DX		;start again for date
	MOV	AX,[BX+FCB_DATE]
	CALL	DISPLAY_DATE

	OUTPUT			;three spaces
	OUTPUT
	OUTPUT
	MOV	BX,DX		;start again
	MOV	AX,[BX+FCB_TIME];get it all
	CALL	DISPLAY_TIME	;show it

	OUTPUT			;three more spaces
	OUTPUT
	OUTPUT
	PUSH	DX		;save base address of fcb
	MOV	BX,DX		;pick up file size
	MOV	AX,[BX+FCB_FILSIZ]
	MOV	DX,[BX+FCB_FILSIZ+2]
	CALL	DIV32		;output it

	GOTO	YORG+2,XORG+52	;move to location
	POP	DX		;get back base address of fcb
	MOV	BX,DX
	MOV	AX,[BX+FCB_FILSIZ]
	MOV	DX,[BX+FCB_FILSIZ+2]
	MOV	CX,FILE$RECORD$SIZE
	DIV	CX		;normally = 512
	TEST	DX,0FFFFH	;any remainder?
	JNZ	FD20		;no so round number
	DEC	AX	;forget about remainder - compensate for divide though
FD20:	XOR	DX,DX		;clear the high bytes
	MOV	RECORD_NUMBER,AX;save the record count
	CALL	DIV32		;output max record number possible

	GOTO	YORG+3,XORG+52			;display current record
	CALL	REVERSE_ON			;show number of record
	MOV	AX,FCB+FCB_RANREC		;get the current record number
	XOR	DX,DX
	CALL	DIV32				;output current record
	CALL	REVERSE_OFF

	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
FILEDETAILS	ENDP

LOWER$TO$UPPER	PROC
; checks for lower case alphabetic character in AL
; if present then folds it to upper case
; call with:	AL		= character
; return with:	AL		= character
;
; uses AL
	CMP	AL,'a'		;see what we have
	JC	LU10		;not interested
	CMP	AL,'z'		;sure?
	JNC	LU10		;yes
	AND	AL,5FH		;fold to upper case
LU10:	RET
LOWER$TO$UPPER	ENDP

NIBBLE	PROC
; checks for a valid hexadecimal value in AL
; call with:	AL		= character 
; return with:	carry		= invalid character
;		carry clear 	= valid character
;				& binary number in AL
; uses:	AL
	SUB	AL,'0'		;ascii bias
	JC	NIB10		;error < '0'
	CMP	AL,'F'-'0'+1	;
	CMC			;invert
	JC	NIB10		;error > 'F'
	CMP	AL,10
	CMC
	JNC	NIB10		;number 0-9
	SUB	AL,'A'-'9'-1	;try for letter
	CMP	AL,10
NIB10:	RET
NIBBLE	ENDP

NORMAL$BOTTOM$ARROW	PROC
; outputs an arrow pointing downwards in normal video
	GOTO	YORG+12,XORG+4	;move to correct location
	CALL	GRAPHICS_ON	;switch on character graphics
	OUTPUT	k		;output arrow
	CALL	GRAPHICS_OFF	;back to normal
	RET
NORMAL$BOTTOM$ARROW	ENDP

NORMAL$TOP$ARROW	PROC
; outputs an arrow pointing upwards in normal video
	GOTO	YORG+10,XORG+4	;move to correct location
	OUTPUT	^		;output arrow
	RET
NORMAL$TOP$ARROW	ENDP

OPENFILE	PROC
;opens file 
; enter with: 	AH = file open function code
;		DS:DX pointing to unopened FCB
; exit with:	Z = 0  open was successful
;		Z = 1  file not found
; uses: AX
	MOV	AH, ZDOS$OPEN			;open function
	INT	BDOS				;call system
	INC	AL				;check
	RET
OPENFILE	ENDP

PARSEFILENAME	PROC
; parses filename and builds unopened fcb
; enter with:	DS:SI	pointing to filename string to parse
;		ES:DI	pointing to area to fill with fcb
;		AH	= parse filename function code 29H
;		AL	= flags to control parsing
; exits with:	Z = 0 then successful parse
;		Z = 1 then filename error
; uses: AX
	MOV	AH,ZDOS$PARSE			;parse filename function
	MOV	AL,00000000B			;may need to change flags
	INT	BDOS				;request the system
	INC	AL				;set non-zero until we know more
	RET
PARSEFILENAME	ENDP

READFILE	PROC	NEAR
; reads a new record into a buffer
; enter with:	DS:DX	  points to opened FCB
;		AH	= random read function
; returns with:	AL	= flag to show result
;			  00 = success
;			  01 = no more data available
;			  02 = not enough room in disc transfer segment
;			  03 = partial record returned filled with zeroes
; uses:	AX
	MOV	AH,ZDOS$READRN		;read random function
	INT	BDOS			;do it
	TEST	AL,AL			;anything there?
	RET				;zero = success
READFILE	ENDP

READSECTOR	PROC	NEAR
; reads an absolute track/sector from disc
; call with:	TRACK_NUMBER	= track number 0-40
;		SECTOR_NUMBER	= sector number 0-8
;
; returns with:	carry clear	= function carried out
;		carry set	= error condition
;			AL	= error code
;				  corresponds to codes ERROR$M1-M6 in messages
; uses:	AL,BX,CX,DX
	MOV	BX, OFFSET DISC_BUFFER		;point DS:BX to transfer area
	XOR	CX,CX				;count of sectors = 1
	INC	CX
	XOR	DH,DH				;clear space
	MOV	DL,TRACK_NUMBER			;get track count
	SHL	DX,1				; times 8
	SHL	DX,1
	SHL	DX,1
	XOR	AH,AH				;clear space
	MOV	AL,SECTOR_NUMBER		;get sector count
	ADD	DX,AX				;track * 8 + sector = logical record
	XOR	AL,AL				;drive A:
	INT	DSK_READ
	POP	DX				;raise stack
	RET
READSECTOR	ENDP

REVERSE$BOTTOM$ARROW	PROC
; outputs an arrow pointing downwards in reverse video
	GOTO	YORG+12,XORG+4	;move to correct location
	CALL	REVERSE_ON	;switch on reverse video
	CALL	GRAPHICS_ON	;switch on character graphics
	OUTPUT	k		;output arrow
	CALL	GRAPHICS_OFF	;back to normal
	CALL	REVERSE_OFF
	RET
REVERSE$BOTTOM$ARROW	ENDP

REVERSE$TOP$ARROW	PROC
; outputs an arrow pointing upwards in reverse video
	GOTO	YORG+10,XORG+4	;move to correct location
	CALL	REVERSE_ON
	OUTPUT	^		;output arrow
	CALL	REVERSE_OFF
	RET
REVERSE$TOP$ARROW	ENDP

REVERSE_ASCII	PROC	NEAR
; outputs AL as ascii character in reverse video
; call with:	AL	= character to output
; uses:		none
	PUSH	AX			;save copy
	CALL	REVERSE_ON		;turn on reverse video
	POP	AX			;get it back
	PUSH	AX
	CALL	OUTPUT_ASC		;output as ascii, '.' if non printing
	CALL	REVERSE_OFF
	POP	AX			;restore
	RET
REVERSE_ASCII	ENDP

REVERSE_HEX	PROC	NEAR
; outputs AL as two hex characters in reverse video
; call with:	AL	= number to output
; uses:		none
	PUSH	AX			;save copy
	CALL	REVERSE_ON		;turn on reverse video
	POP	AX			;get it back
	PUSH	AX
	CALL	OUTHEX_AL		;output as hex characters
	CALL	REVERSE_OFF
	POP	AX			;restore
	RET
REVERSE_HEX	ENDP

SAVE_FILERECORD	PROC	NEAR
; asks whether a record is to be saved to disc as part of a file
;
	GOTO	YORG+21,XORG+8		;use command location
	MOV	SI, OFFSET SAVEQUERY	;put out message
	CALL	OUTPUT_STRING		;output message
	CALL	CURSOR_ON		;show them we're there
	MOV	AH,ZDOS$CONINPUT	;get a character
	INT	BDOS			;ask the system
	CALL	OUTPUT_ASC		;show them
	CMP	AL,'Y'			;see what we got
	JZ	SF_10			;yes we save...
	CMP	AL,'y'
	JZ	SF_10			;definite
	CMP	AL,'N'			;no we dont
	JZ	SF_20
	CMP	AL,'n'
	JZ	SF_20
SF_05:
	MOV	AL,CMD$RNU		;reply not not understood
	CALL	ERROR_MESSAGE		;error message
	GOTO	YORG+21,XORG+8		;reprompt
	CALL	DELETE_EOLN
	JMP	SAVE_FILERECORD		;restart
SF_10:	MOV	AH,ZDOS$CONINPUT
	INT	BDOS
	CMP	AL,CR
	JNZ	SF_05			;error if not return
	GOTO	YORG+21,XORG		;clean up
	CALL	DELETE_LINE
	GOTO	YORG+23,XORG
	CALL	DELETE_LINE
	STC				;set flag to show we save
	RET
SF_20:	MOV	AH,ZDOS$CONINPUT
	INT	BDOS
	CMP	AL,CR
	JNZ	SF_05
	GOTO	YORG+21,XORG		;clean up
	CALL	DELETE_LINE
	GOTO	YORG+23,XORG
	CALL	DELETE_LINE
	CLC				;clear to show we dont
	RET
SAVE_FILERECORD	ENDP

SETDTA		PROC	NEAR
; sets disc transfer address for file reads
; call with	DS:DX	pointing to location for disc transfers
; uses:	AX
	MOV	AH,ZDOS$SETDTA		;load function
	INT	BDOS			;do it
	RET
SETDTA		ENDP

WRITEFILE	PROC	NEAR
; writes a new record into a buffer
; enter with:	DS:DX	  points to opened FCB
;		AH	= random write function
; returns with:	AL	= flag to show result
;			  00 = success
;			  01 = no more data available
;			  02 = not enough room in disc transfer segment
;			  03 = partial record returned filled with zeroes
; uses:	AX
	MOV	AH,ZDOS$WRITERN		;write random function
	INT	BDOS			;do it
	TEST	AL,AL			;anything there?
	RET				;zero = success
WRITEFILE	ENDP

WRITESECTOR	PROC	NEAR
; writes an absolute track/sector from disc
; call with:	TRACK_NUMBER	= track number 0-40
;		SECTOR_NUMBER	= sector number 0-8
;
; returns with:	carry clear	= function carried out
;		carry set	= error condition
;			AL	= error code
;				  corresponds to codes ERROR$M1-M6 in messages
; uses:	AL,BX,CX,DX
	MOV	BX, OFFSET DISC_BUFFER		;point DS:BX to transfer area
	XOR	CX,CX				;count of sectors = 1
	INC	CX
	XOR	DH,DH				;clear space
	MOV	DL,TRACK_NUMBER			;get track count
	SHL	DX,1				; times 8
	SHL	DX,1
	SHL	DX,1
	XOR	AH,AH				;clear space
	MOV	AL,SECTOR_NUMBER		;get sector count
	ADD	DX,AX				;track * 8 + sector = logical record
	XOR	AL,AL				;drive A:
	INT	DSK_WRITE
	POP	DX				;raise stack
	RET
WRITESECTOR	ENDP

 	SUBTTL	Command procedures

	COMMENT	%

	NOBSCMDS	v1.0
	All the command execution procedures

	Control passes to these routines from
	the command tables. The command is
	processed and table pointers may be
	adjusted.

	routines:
	P$EXECUTE			execute a command
	P$CMD$P0 - P$CMD$P4	 	main command table pointer routines
	P$EDT$P0 - P$EDT$P4		edit command table pointer routines

	P$COMMAND$*			procedures to handle commands
	P$EDIT$*			procedures to handle editing
	P$FN$*				procedures to handle filenames
	P$DN$*				procedures to handle decimal numbers

	%

P$EXECUTE		PROC
	CLC				;no carry = signal to main routine
	RET				;to execute a command
P$EXECUTE		ENDP

P$CMD$P0		PROC
	MOV	BX, OFFSET EDIT$TABLE			;go to edit mode
	STC
	RET
P$CMD$P0		ENDP

P$CMD$P1		PROC
	MOV	BX, OFFSET COMMAND$ESCx
	STC
	RET
P$CMD$P1		ENDP

P$CMD$P2		PROC
	MOV	BX, OFFSET COMMAND$ESC?x
	STC
 	RET
P$CMD$P2		ENDP

P$CMD$P3		PROC
	MOV	BX, OFFSET COMMAND$ESC0x
	STC
	RET
P$CMD$P3		ENDP	

P$CMD$P4		PROC
	MOV	BX, OFFSET COMMAND$ESC1x
	STC
	RET
P$CMD$P4		ENDP

P$EDT$P0		PROC
	CLC					;for transfer back to command
	RET
P$EDT$P0		ENDP

P$EDT$P1		PROC
	MOV	BX, OFFSET EDIT$ESCx
	STC
	RET
P$EDT$P1		ENDP

P$EDT$P2		PROC
	MOV	BX, OFFSET EDIT$ESC?x
	STC
	RET
P$EDT$P2		ENDP

P$EDT$P3		PROC
	MOV	BX, OFFSET EDIT$ESC0x
	STC
	RET
P$EDT$P3		ENDP	

P$EDT$P4		PROC
	MOV	BX, OFFSET EDIT$ESC1x
	STC
	RET
P$EDT$P4		ENDP


P$CMD$ABORT			PROC
	CALL	OUTPUT_CHAR
	CALL	CLEAR_SCREEN		;clear up after us
	CLC				;signal drop out
	RET
P$CMD$ABORT			ENDP

P$CMD$BOTTOM		PROC
	MOV	LINE_NUMBER,10H		;display second part of buffer
	CALL	CURSOR_OFF		;make things invisible
	CALL	NORMAL$TOP$ARROW	;reset top arrow
	CALL	REVERSE$BOTTOM$ARROW	;reverse bottom
	CALL	BUFFER_HEX		;redisplay the buffer
	CALL	BUFFER_ASCII
	CALL	DISPLAY_COMMAND
	STC
	RET
P$CMD$BOTTOM		ENDP

P$CMD$CLOSEFILE		PROC
	CALL	OUTPUT_CHAR		;echo command
	TEST	FILE$OPEN$FLAG,TRUE	;see if we have an open file
	JNZ	P$C$CF10		;invalid command if flag not set
	MOV	AL,FN$FNO		;give file not open error
	CALL	ERROR_MESSAGE		;
	JMP	P$C$CF30		;return
P$C$CF10:
	MOV	DX, OFFSET FCB		;point to the FCB
	CALL	CLOSEFILE		;try to close it
	JNZ	P$C$CF20		;non zero = ok
	MOV	AL,FN$FNF		;file not found error - check this
	CALL	ERROR_MESSAGE
	JMP	P$C$CF30
P$C$CF20:
	MOV	FILE$OPEN$FLAG,FALSE	;close file operations down
	CALL	CURSOR_OFF		;disguise our intent
	GOTO	YORG+2,XORG		;clear file detail lines
	CALL	DELETE_LINE
	GOTO	YORG+3,XORG
	CALL	DELETE_LINE
	XOR	AX,AX			;clear random record field
	MOV	FCB+FCB_RANREC,AX
	MOV	TRACK_NUMBER,AL		;reset back track & sector
	MOV	SECTOR_NUMBER,AL
	CALL	DISPLAY_ABSOLUTE	;show absolute track/sector available
	CALL	DISPLAY_TRACK
	CALL	DISPLAY_SECTOR
	CALL	READSECTOR		;get back sector
	JNC	P$C$CF21		;no carry means ok
	CALL	ERROR_MESSAGE		;wrong
	JMP	P$C$CF30		;exit
P$C$CF21:
	CALL	BUFFER_HEX		;redisplay
	CALL	BUFFER_ASCII
P$C$CF30:
	CALL	DISPLAY_COMMAND
	STC
	RET
P$CMD$CLOSEFILE		ENDP

P$CMD$EXIT			PROC
	CALL	OUTPUT_CHAR		;echo command
	CALL	SAVE_FILERECORD		;tidy up?
	JNC	P$C$EX20		;not bothered
	TEST	FILE$OPEN$FLAG,TRUE	;file active?
	JNZ	P$C$EX10		;yes
	CALL	WRITESECTOR		;else write sector
	JMP	P$C$EX20
P$C$EX10:
	CALL	WRITEFILE		;write file record
P$C$EX20:
	CLC				;signal drop out
	RET
P$CMD$EXIT			ENDP

P$CMD$HELP		PROC
	CALL	OUTPUT_CHAR
	MOV	BX, OFFSET HELP$TABLE		;point to new table
P$C$HE10:
	CALL	CLEAR_SCREEN			;clear and output main menu
	GOTO	YORG,XORG+31			;heading
	CALL	REVERSE_ON
	MOV	SI, OFFSET MAIN$MENU1
	CALL	OUTPUT_STRING
	CALL	REVERSE_OFF
	GOTO	YORG+4,XORG+24
	MOV	SI, OFFSET MAIN$MENU2
	CALL	OUTPUT_STRING
	CALL	CURSOR_ON
P$C$HE11:
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$C$HE10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	MOV	BX,OFFSET HELP$TABLE		;point back to table
	JZ	P$C$HE11			;error return
	JC	P$C$HE10			;continue with carry
	CALL	CLEAR_SCREEN			;clear screen ready to ..
	CALL	DISPLAY_FIXED			;rebuild nobs' screen
	TEST	FILE$OPEN$FLAG,TRUE		;is a file active?
	JNZ	P$C$HE20			;yes
	CALL	DISPLAY_ABSOLUTE		;track / sector heading
	CALL	DISPLAY_TRACK			;no so just show track/sector
	CALL	DISPLAY_SECTOR
	JMP	P$C$HE30			;continue
P$C$HE20:
	MOV	DX, OFFSET FCB			;set up..
	CALL	FILEDETAILS			;must be file open then
P$C$HE30:
	TEST	LINE_NUMBER,0FFH		;which half of the buffer?
	JNZ	P$C$HE40			;second half
	CALL	REVERSE$TOP$ARROW		;no first half
	CALL	NORMAL$BOTTOM$ARROW
	JMP	P$C$HE41
P$C$HE40:
	CALL	NORMAL$TOP$ARROW
	CALL	REVERSE$BOTTOM$ARROW
P$C$HE41:
	CALL	BUFFER_HEX
	CALL	BUFFER_ASCII
	CALL	DISPLAY_COMMAND
	STC
	RET
P$CMD$HELP		ENDP

P$CMD$OPENFILE		PROC
	CALL	OUTPUT_CHAR
	TEST	FILE$OPEN$FLAG,TRUE		;already active?
	JZ	P$C$OF00			;no so ok to continue
	MOV	AL,FN$FAO			;file already open
	CALL	ERROR_MESSAGE			;error
	JMP	P$C$OF30			;exit
P$C$OF00:
	MOV	BX, OFFSET FILENAME$TABLE	;change table to parser
	MOV	FN$POINTER,0			;clear pointer
P$C$OF01:
	MOV	AH, ZDOS$CONINPUT		;read characters
	INT	BDOS				;get one
	AND	AL,7FH				;strip high bit
	XOR	AH,AH				;clear high byte
	MOV	SI,AX				;prepare index
	SHL	SI,1				; * 2 for word table
	MOV	CL,[BX+SI]			;pick up command entry only
	XOR	CH,CH				;clear high byte
	MOV	DI,CX				;place into index
	CALL	COMMAND[DI]			;go to command routine
	JC	P$C$OF01			;continue with carry
	JZ	P$C$OF30			;zero means error
	MOV	SI, OFFSET FILENAME$BUFFER	;point to buffer
	MOV	AX,DS				;set up ES:DI
	MOV	ES,AX
	MOV	DI, OFFSET FCB			;point to fcb to set up
	CALL	PARSEFILENAME			;parse the file
	JNZ	P$C$OF10			;zero = error
	MOV	AL, FN$FPE			;file name parse error
	CALL	ERROR_MESSAGE
	JMP	P$C$OF30			;finished now...
P$C$OF10:
	MOV	DX, OFFSET FCB			;now try to open it
	CALL	OPENFILE			;
	JNZ	P$C$OF20			;zero = error
	MOV	AL, FN$FNF			;file not found error
	CALL	ERROR_MESSAGE			;tell them
	JMP	P$C$OF30
P$C$OF20:
	MOV	FILE$OPEN$FLAG,TRUE		;say we have succeeded 
	MOV	FCB+FCB_RECSIZ,FILE$RECORD$SIZE	;set record size to 512 bytes
	MOV	DX, OFFSET DISC_BUFFER		;new transfer address
	CALL	SETDTA				;set disc transfer address
	MOV	RECORD_NUMBER,0			;clear record count for file
	GOTO	YORG+2,XORG			;clear the line
	CALL	DELETE_LINE			;ready for setting up file header
	CALL	CURSOR_OFF			;hide things
	MOV	DX, OFFSET FCB			;set up to...
	CALL	FILEDETAILS			;display all file details
	MOV	AH,ZDOS$READRN			;read first record
	MOV	DX, OFFSET FCB
	INT	BDOS
	CALL	BUFFER_HEX			;display contents
	CALL	BUFFER_ASCII
P$C$OF30: 
	CALL	DISPLAY_COMMAND
	STC
	RET
P$CMD$OPENFILE			ENDP

P$CMD$READFILE			PROC
	CALL	OUTPUT_CHAR
	TEST	FILE$OPEN$FLAG,TRUE		;is a file open?
	JNZ	P$C$RF10			;yes it is
	MOV	AL,FN$FNO			;file not open error
	CALL	ERROR_MESSAGE
	JMP	P$C$RF30			;leave now
P$C$RF10:
	MOV	BX, OFFSET RECORD$TABLE		;initialise pointer

	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$C$RF10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	JC	P$C$RF30			;error if carry set
P$C$RF20:
	MOV	DX, OFFSET FCB			;set up for read
	CALL	READFILE			;read a record
	CALL	CURSOR_OFF			;lose cursor
	GOTO	YORG+3,XORG+52			;display new record number
	OUTPUT					;space over old one
	OUTPUT
	OUTPUT
	GOTO	YORG+3,XORG+52			;now show it
	CALL	REVERSE_ON
	XOR	DX,DX
	MOV	AX,FCB+FCB_RANREC		;get new value
	CALL	DIV32				;output it
	CALL	REVERSE_OFF
	CALL	BUFFER_HEX			;display it
	CALL	BUFFER_ASCII			;in hex and ascii
P$C$RF30:
	CALL	DISPLAY_COMMAND			;reprompt
	STC
	RET
P$CMD$READFILE			ENDP

P$CMD$SECTOR			PROC
	CALL	OUTPUT_CHAR
	TEST	FILE$OPEN$FLAG,TRUE		;is a file open?
	JZ	P$C$SE10			;no so continue else...
	MOV	AL,CMD$FOE			;file open error
	CALL	ERROR_MESSAGE
	JMP	P$C$SE99			;leave now
P$C$SE10:
	MOV	BX, OFFSET SECTOR$TABLE		;initialise pointer
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$C$SE10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	JC	P$C$SE99			;error if carry set
P$C$SE20:
	MOV	DX, OFFSET FCB			;set up for read
	CALL	READSECTOR			;read a sector
	JNC	P$C$SE98			;no carry means ok
	CALL	ERROR_MESSAGE			;wrong
	JMP	P$C$SE99			;exit
P$C$SE98:
	CALL	CURSOR_OFF			;lose cursor
	CALL	BUFFER_HEX			;display it
	CALL	BUFFER_ASCII			;in hex and ascii
	CALL	DISPLAY_TRACK			;and give indexes
	CALL	DISPLAY_SECTOR
P$C$SE99:
	CALL	DISPLAY_COMMAND			;reprompt
	STC
	RET
P$CMD$SECTOR			ENDP

P$CMD$SWITCHTABLES		PROC
	CALL	CURSOR_OFF			;no cursor required for edit
	GOTO	YORG+21,XORG
	CALL	DELETE_LINE
	TEST	ASCII$SCREEN$FLAG,TRUE		;are we in hex?
	JNZ	P$C$ST01			;in ascii
	CALL	CURSOR_HEX			;default to the hex screen
	JMP	P$C$ST02			;continue
P$C$ST01:
	CALL	CURSOR_ASCII			;ok ascii then
P$C$ST02:
	MOV	BX, OFFSET EDIT$TABLE		;for editing
P$C$ST10:
	MOV	AH, ZDOS$CONINPUT		;read characters
	INT	BDOS				;get one
	AND	AL,7FH				;strip high bit
	XOR	AH,AH				;clear high byte
	MOV	SI,AX				;prepare index
	SHL	SI,1				; * 2 for word table
	MOV	CL,[BX+SI+1]			;pick up pointer entry 
	XOR	CH,CH
	MOV	DI,CX				;set up index
	CALL	POINTER[DI]			;change pointer if necessary
	JC	P$C$ST10			;continue with carry
	CALL	ERROR_CLEAR			;get rid of error message
	MOV	CL,[BX+SI]			;else get the routine index
	XOR	CH,CH				;clear high byte
	MOV	DI,CX				;place into index
	CALL	COMMAND[DI]			;go to command routine
	MOV	BX, OFFSET EDIT$TABLE		;reset pointer
	JC	P$C$ST10			;continue
	STC
	RET
P$CMD$SWITCHTABLES		ENDP

P$CMD$TOP		PROC
	MOV	LINE_NUMBER,0		;display first part of buffer
	CALL	CURSOR_OFF		;hide things
	CALL	REVERSE$TOP$ARROW	;reverse top arrow
	CALL	NORMAL$BOTTOM$ARROW	;reset bottom
	CALL	BUFFER_HEX		;redisplay the buffer
	CALL	BUFFER_ASCII
	CALL	DISPLAY_COMMAND
	STC
	RET
P$CMD$TOP		ENDP

P$CMD$TRACK			PROC
	CALL	OUTPUT_CHAR
	TEST	FILE$OPEN$FLAG,TRUE		;is a file open?
	JZ	P$C$TR10			;no so continue else...
	MOV	AL,CMD$FOE			;file open error
	CALL	ERROR_MESSAGE
	JMP	P$C$TR20			;exit
P$C$TR10:
	MOV	BX, OFFSET TRACK$TABLE		;initialise pointer
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$C$TR10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	JC	P$C$TR20			;error if carry set
	CALL	READSECTOR			;read a sector
	CALL	CURSOR_OFF			;keep it hidden
	CALL	BUFFER_HEX			;show what we got
	CALL	BUFFER_ASCII
	CALL	DISPLAY_TRACK			;and where we are
	CALL	DISPLAY_SECTOR
P$C$TR20:
	CALL	DISPLAY_COMMAND			;reshow the command
	STC					;continue at command level
	RET
P$CMD$TRACK			ENDP

P$CMD$UNKNOWN		PROC
	MOV	AL,CMD$ERROR		;signal unknown command
	CALL	ERROR_MESSAGE		;output message
	CALL	DISPLAY_COMMAND		;reprompt for command
	XOR	AL,AL			;signal error with zero flag
	STC				;signal reset command
	RET
P$CMD$UNKNOWN		ENDP

P$DN$READ	PROC
; reads a decimal number from the terminal
; converts it to a binary number in AX
; uses table DN$TABLE to accept only valid decimal numbers
;
	MOV	BX,OFFSET DN$TABLE		;point to number table
	MOV	LOW$BYTES,0			;clear number
DN_10:	MOV	AH, ZDOS$CONINPUT		;read characters
	INT	BDOS				;get one
	AND	AL,7FH				;strip high bit
	XOR	AH,AH				;clear high byte
	MOV	SI,AX				;prepare index
	SHL	SI,1				; * 2 for word table
	MOV	DL,[BX+SI]			;pick up command entry only
	XOR	DH,DH				;clear high byte
	MOV	DI,DX				;place into index
	CALL	COMMAND[DI]			;go to command routine
	JC	DN_10				;continue with carry
	JZ	DN_20				;zero means error
	CLC					;clear carry to say we got no.
	RET
DN_20:	STC					;set carry to show error
	RET
P$DN$READ	ENDP

P$DN$VALID	PROC
; adds a number into the buffer holding the decimal number
; we are recieving from the terminal
	CALL	OUTPUT_CHAR			;echo character
	SUB	AL,'0'				;convert to binary
	PUSH	AX				;save the number to add
	MOV	AX,LOW$BYTES			;get low bytes
	MOV	BX,10				;decimal base
	MUL	BX				;times it
	POP	CX				;get number back
	JC	AN10				;flowed into DX ( ie > 64k )
	XOR	CH,CH				;clear high byte
	ADD	AX,CX				;add lastest number in
	JC	AN10				;no carry = ok
	MOV	LOW$BYTES,AX			;save new number
	STC					;carry=continue
	RET

AN10:	MOV	AL,DN$NOV			;overflow error
	CALL	ERROR_MESSAGE
	XOR	AL,AL				;set zero flag to show error
	CLC					;clear carry = exit command
	RET
P$DN$VALID	ENDP

P$DN$RETURN		PROC
; finishes gathering a number
	XOR	AL,AL				;set none zero to say ok
	INC	AL
	CLC					;exit the loop
	RET
P$DN$RETURN		ENDP

P$DN$INVALID	PROC
;invalid decimal number error routine
	MOV	AL,DN$IDD			;invalid number error
	CALL	ERROR_MESSAGE
	XOR	AL,AL				;zero flag = error
	CLC					;exit
	RET
P$DN$INVALID	ENDP

P$EDT$ABORT			PROC
	CLC
	RET
P$EDT$ABORT			ENDP

P$EDT$ALTER			PROC
	GOTO	YORG+2,XORG+65			;say we're editing
	CALL	REVERSE_ON			;highlight it
	MOV	SI, OFFSET EDITON		;insert on message
	CALL	OUTPUT_STRING
	CALL	REVERSE_OFF			;back to normal
	TEST	ASCII$SCREEN$FLAG,TRUE		;ascii or hex?
	JZ	P$E$AL10			;I know its the long way but if
	JMP	P$E$AL20			;not done like this then out of range
; hex entry routines start here
P$E$AL10:
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS
	CMP	AL,DEL				;escape character - delete?
	JNZ	P$E$AL11			;out of range if not done like this
	JMP	P$E$AL30			;yes so exit
P$E$AL11:
	CALL	LOWER$TO$UPPER			;launder characters first
	CALL	NIBBLE				;check character for 0-9 A-F
	JNC	P$E$AL12			;no error if carry not set
	MOV	AL,BS				;else go back with cursor to
	CALL	OUTPUT_CHAR			;compensate for mistake
	JMP	P$E$AL10			;try again
; here we put the value into the left nibble
P$E$AL12:
	XOR	BH,BH				;clear high byte
	MOV	BL, COLUMN_INDEX		;get column number
	MOV	SI,BX				;set up column number
	MOV	BL, LINE_NUMBER			;get start line no
	ADD	BL, LINE_INDEX			;get line index
	SHL	BX,1				;increase to real index
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1				; index = line no * 16
	MOV	AH,DISC_BUFFER[BX+SI]		;get the byte
	AND	AH,0FH				;mask high nibble
	SHL	AL,1				;move AL to high nibble
	SHL	AL,1
	SHL	AL,1
	SHL	AL,1
	OR	AH,AL				;put value into place
	MOV	DISC_BUFFER[BX+SI],AH		;save the new value
	CALL	NORMAL_ASCII			;display non-highlight value
	CALL	CURSOR_HEX			;display new value
P$E$AL13:					;here for second character
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS
	CMP	AL,DEL				;escape character - delete?
	JNZ	P$E$AL14			;no so continue
	JMP	P$E$AL30			;exit
P$E$AL14:
	CALL	LOWER$TO$UPPER			;fold up if neccesary
	CALL	NIBBLE				;is it 0-9 A-F?
	JNC	P$E$AL15			;yes so continue
	MOV	AL,BS				;else step back cursor
	CALL	OUTPUT_CHAR			;to compensate for error
	JMP	P$E$AL13			;try for another character
; here we put the value into the right nibble
P$E$AL15:
	XOR	BH,BH				;clear high byte
	MOV	BL, COLUMN_INDEX		;get column number
	MOV	SI,BX				;set up column number
	MOV	BL, LINE_NUMBER			;get start line no
	ADD	BL, LINE_INDEX			;get line index
	SHL	BX,1				;increase to real index
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1				; index = line no * 16
	MOV	AH,DISC_BUFFER[BX+SI]		;get the byte
	AND	AH,0F0H				;new low nibble
	OR	AH,AL				;put value into place
	MOV	DISC_BUFFER[BX+SI],AH		;save the new value
	CALL	NORMAL_ASCII			;display non-highlight value
	CALL	NORMAL_HEX			;display new value
	CMP	COLUMN_INDEX,15			;are we at end of line?
	JNZ	P$E$AL16			;not yet
	CMP	LINE_INDEX,15			;perhaps end of display?
	JZ	P$E$AL17			;then just idle round
	INC	LINE_INDEX			;else move to next line
	MOV	COLUMN_INDEX,0			;start of the line
	JMP	P$E$AL17			;refresh screen
P$E$AL16:
	INC	COLUMN_INDEX			;move to next column position
P$E$AL17:
	CALL	CURSOR_HEX			;highlight the hex screen
	JMP	P$E$AL10			;see if another character
; here is the ascii entry routine start
P$E$AL20:
	MOV	AH,ZDOS$CONINPUT		;let have a character then..
	INT	BDOS				;get it
	CMP	AL,DEL				;is it the escape character 7FH?
	JNZ	P$E$AL21			;no so continue
	JMP	P$E$AL30			;else exit
P$E$AL21:
	XOR	BH,BH				;clear high byte
	MOV	BL, COLUMN_INDEX		;get column number
	MOV	SI,BX				;set up column number
	MOV	BL, LINE_NUMBER			;get start line no
	ADD	BL, LINE_INDEX			;get line index
	SHL	BX,1				;increase to real index
	SHL	BX,1
	SHL	BX,1
	SHL	BX,1				; index = line no * 16
	MOV	DISC_BUFFER[BX+SI],AL		;save the new character
	CALL	NORMAL_HEX			;change hex screen
	CALL	NORMAL_ASCII			;change ascii screen
	CMP	COLUMN_INDEX,15			;are we at end of line?
	JNZ	P$E$AL22			;not yet
	CMP	LINE_INDEX,15			;perhaps end of display?
	JZ	P$E$AL23			;then just idle round
	INC	LINE_INDEX			;else move to next line
	MOV	COLUMN_INDEX,0			;start of the line
	JMP	P$E$AL23			;refresh screen
P$E$AL22:
	INC	COLUMN_INDEX			;move to next column position
P$E$AL23:
	CALL	CURSOR_ASCII			;highlight the ascii screen
	JMP	P$E$AL20			;keep going
P$E$AL30:
	GOTO	YORG+2,XORG+65			;exit from insert mode
	CALL	DELETE_EOLN			;tell user
	STC
	RET
P$EDT$ALTER			ENDP
	
P$EDT$CURSORDOWN		PROC
	MOV	AL,LINE_INDEX			;get index
	SUB	AL,0FH				;maximum count
	JZ	P$E$CD30			;if reached then do nothing
	TEST	ASCII$SCREEN$FLAG,TRUE		;is it ascii screen?
	JNZ	P$E$CD10			;yes
	CALL	NORMAL_HEX			;else display old one normally
	INC	LINE_INDEX			;add one to line number
	CALL	CURSOR_HEX			;display new one in reverse
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
	JMP	P$E$CD20			;finished here
P$E$CD10:
	CALL	NORMAL_ASCII			;ascii display normal
	INC	LINE_INDEX			;increase line number
	CALL	CURSOR_ASCII			;display ascii screen cursor
P$E$CD20:
	MOV	AL,BS				;ascii needs one BS
	CALL	OUTPUT_CHAR
P$E$CD30:
	STC
	RET
P$EDT$CURSORDOWN		ENDP

P$EDT$CURSORLEFT		PROC
	MOV	AL,COLUMN_INDEX			;get column index
	TEST	AL,0FH				;anything there?
	JZ	P$E$CL30			;no so do nothing
	TEST	ASCII$SCREEN$FLAG,TRUE		;are we on the ascii screen?
	JNZ	P$E$CL10			;yes
	CALL	NORMAL_HEX			;display old one normally
	DEC	COLUMN_INDEX			;decrease counter
	CALL	CURSOR_HEX			;display new in reverse
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
	JMP	P$E$CL30			;done here
P$E$CL10:
	CALL	NORMAL_ASCII			;display old position normally
	DEC	COLUMN_INDEX			;lower column
	CALL	CURSOR_ASCII			;new one in reverse
P$E$CL20:
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
P$E$CL30:
	STC
	RET
P$EDT$CURSORLEFT		ENDP

P$EDT$CURSORRIGHT		PROC
	MOV	AL,COLUMN_INDEX			;get column index
	SUB	AL,0FH				;see what we have
	JZ	P$E$CR30			;end of the line
	TEST	ASCII$SCREEN$FLAG,TRUE		;are we in ascii?
	JNZ	P$E$CR10			;yes else..
	CALL	NORMAL_HEX			;display old one normally
	INC	COLUMN_INDEX			;decrease counter
	CALL	CURSOR_HEX			;display new in reverse
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
	JMP	P$E$CR20			;done here
P$E$CR10:
	CALL	NORMAL_ASCII			;display old one normally
	INC	COLUMN_INDEX
	CALL	CURSOR_ASCII
P$E$CR20:
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
P$E$CR30:
	STC
	RET
P$EDT$CURSORRIGHT		ENDP

P$EDT$CURSORUP			PROC
	MOV	AL,LINE_INDEX			;get index
	TEST	AL,0FH				;see if we have a count
	JZ	P$E$CU30			;if not then do nothing
	TEST	ASCII$SCREEN$FLAG,TRUE		;are we in ascii?
	JNZ	P$E$CU10			;yes
	CALL	NORMAL_HEX			;else display old one normally
	DEC	LINE_INDEX			;move line counter up
	CALL	CURSOR_HEX			;display new one in reverse
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
	JMP	P$E$CU20			;done here
P$E$CU10:
	CALL	NORMAL_ASCII
	DEC	LINE_INDEX
	CALL	CURSOR_ASCII
P$E$CU20:
	MOV	AL,BS				;back space
	CALL	OUTPUT_CHAR			;to align cursor at start of block
P$E$CU30:
	STC
	RET
P$EDT$CURSORUP			ENDP

P$EDT$SWITCHTABLES		PROC
	CALL	NORMAL_HEX			;clear editing cursor
	CALL	NORMAL_ASCII			;whichever it is
	CALL	DISPLAY_COMMAND			;show the command
	CLC					;indicate to leave edit mode
	RET					;back to command via switch
P$EDT$SWITCHTABLES		ENDP

P$EDT$TOGGLE			PROC
	XOR	ASCII$SCREEN$FLAG,TRUE		;switch screens
	CALL	NORMAL_ASCII			;switch screens
	CALL	NORMAL_HEX			;dont bother testing here
	TEST	ASCII$SCREEN$FLAG,TRUE		;what have we done?
	JNZ	P$E$TO10			;set ascii thats what
	CALL	CURSOR_HEX			;set to hex
	JMP	P$E$TO20			;exit
P$E$TO10:
	CALL	CURSOR_ASCII			;ascii cursor
P$E$TO20:
	STC
	RET
P$EDT$TOGGLE			ENDP

P$EDT$UNKNOWN		PROC
	MOV	AL,CMD$ERROR		;signal unknown command
	CALL	ERROR_MESSAGE		;output message
	STC				;signal reset command
	RET
P$EDT$UNKNOWN		ENDP

P$FN$CONVERT			PROC
	CALL	OUTPUT_CHAR
	MOV	DI,FN$POINTER			;get pointer to buffer
	AND	AL,5FH				;convert to upper case
	MOV	FILENAME$BUFFER[DI],AL		;place it
	INC	FN$POINTER			;bump pointer 
	CMP	FN$POINTER,15			;max character count
	JNZ	P$F$CV10			;zero = error
	MOV	AL,FN$FTL			;filename too long
	CALL	ERROR_MESSAGE			;error
	CLC					;signal to discontinue
	XOR	AL,AL				;zero flag is an error
	RET					;done now
P$F$CV10:
	STC
	RET
P$FN$CONVERT			ENDP

P$FN$INVALID			PROC
	MOV	AL, FN$ICF			;invalid character in filename
	CALL	ERROR_MESSAGE
	CLC					;signal discontinue processing
	XOR	AL,AL				;signal error
	RET					;done
P$FN$INVALID			ENDP

P$FN$RETURN			PROC
	MOV	AH,ZDOS$FLUSH			;flush type ahead buffer
	XOR	AL,AL				;only...
	INT	BDOS
	OR	AH,0FFH				;clear zero flag to say ok
	CLC					;signal filename complete
	RET
P$FN$RETURN			ENDP

P$FN$VALID			PROC
	CALL	OUTPUT_CHAR			;give some feedback...
	MOV	DI, FN$POINTER			;get buffer pointer
	MOV	FILENAME$BUFFER[DI],AL		;character in AL
	INC	FN$POINTER			;increase pointer
	CMP	FN$POINTER,15			;if pointer = 15 then too
	JNZ	P$F$VA10			;many characters	
	MOV	AL,FN$FTL			;file name too long error
	CALL	ERROR_MESSAGE
	CLC					;clear continuation flag
	XOR	AL,AL				;set error flag
	RET					;finish processing
P$F$VA10:
	STC
	RET
P$FN$VALID			ENDP

P$RE$MINUS			PROC
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT	;get next character
	INT	BDOS
	CMP	AL,CR			;should be return
	JZ	P$R$MI10		;ok we go backwards
	MOV	AL,CMD$ERROR		;command error if neither
	CALL	ERROR_MESSAGE
	STC				;carry = error
	RET
P$R$MI10:
	CALL	SAVE_FILERECORD		;do we save last record?
	JNC	P$R$MI11		;no carry = no save
	MOV	DX, OFFSET FCB
	CALL	WRITEFILE		;save it
P$R$MI11:
	MOV	BX,FCB_RANREC
	TEST	FCB[BX],0FFFFH		;any thing there?
	JNZ	P$R$MI12		;yes so ok
	MOV	AX,RECORD_NUMBER	;get max record number
	MOV	FCB[BX],AX		;wrap record number round
	JMP	P$R$MI20		;exit
P$R$MI12:
	DEC	WORD PTR FCB[BX]	;point to previous record
P$R$MI20:
	CLC				;clear carry flag to exit routine
	RET
P$RE$MINUS		ENDP

P$RE$PLUS		PROC
; reads next record from a file
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT	;got to get a character
	INT	BDOS			;from the system
	CMP	AL,CR			;is it end of line?
	JZ	P$R$PL10		;on to next test
	MOV	AL,CMD$ERROR		;command error if neither
	CALL	ERROR_MESSAGE
	STC				;indicate error
	RET
P$R$PL10:
	CALL	SAVE_FILERECORD		;save the last record?
	JNC	P$R$PL11		;no carry = no save
	MOV	DX, OFFSET FCB
	CALL	WRITEFILE		;save it
P$R$PL11:
	MOV	BX,FCB_RANREC
	MOV	AX,RECORD_NUMBER	;check to see if end of file
	CMP	AX,FCB[BX]		;current record = maximum?
	JZ	P$R$PL12		;yes so do something different
	INC	WORD PTR FCB[BX]	;else go to next record
	JMP	P$R$PL20		;finish off
P$R$PL12:
	XOR	AX,AX			;wrap record count back to zero
	MOV	FCB[BX],AX
P$R$PL20:
	CLC				;say no problems
	RET
P$RE$PLUS		ENDP

P$RE$VALID		PROC
	MOV	LOW$BYTES,0			;clear counter in case	
	CALL	P$DN$VALID			;save the number that got us here
	MOV	BX, OFFSET DN$TABLE		;initialise pointer
P$R$VA10:
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$R$VA10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	MOV	BX, OFFSET DN$TABLE		;reset pointer
	JC	P$R$VA10			;continue if carry set
	JZ	P$R$VA20			;zero means error
	CALL	CHECKRECORD			;see if we have a valid record
	CLC					;say we're ok
	RET
P$R$VA20:
	STC
	RET					;carry = error to read routine
P$RE$VALID		ENDP

P$SE$MINUS		PROC
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT	;get input
	INT	BDOS
	CMP	AL,CR			;should be return
	JZ	P$S$MI10		;ok we go backwards
	MOV	AL,CMD$ERROR		;command error if neither
	CALL	ERROR_MESSAGE
	STC				;say we had an error
	RET				;exit immediately
P$S$MI10:
	CALL	SAVE_FILERECORD		;do they want to save?
	JNC	P$S$MI11		;no carry = no
	CALL	WRITESECTOR		;write out the sector then
	JNC	P$S$MI11		;no carry = ok
	CALL	ERROR_MESSAGE		;else error
	STC				;flag error
	RET				;exit rapidly
P$S$MI11:
	TEST	SECTOR_NUMBER,0FFH	;any count here?
	JNZ	P$S$MI13		;yes so not bothered about track
	MOV	SECTOR_NUMBER,SECTOR$MAX	;no so wrap round sector
	TEST	TRACK_NUMBER,0FFH	;first track?
	JNZ	P$S$MI12		;no so simply wrap round track
	MOV	TRACK_NUMBER,TRACK$MAX		;else wrap track number to end
	JMP	P$S$MI20		;and continue
P$S$MI12:
	DEC	TRACK_NUMBER		;reduce track number
	JMP	P$S$MI20		;and continue
P$S$MI13:
	DEC	SECTOR_NUMBER		;decrease sector count
P$S$MI20:
	CLC				;flag success
	RET
P$SE$MINUS		ENDP

P$SE$PLUS		PROC
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT	;got to get a character
	INT	BDOS			;from the system
	CMP	AL,CR			;is it end of line?
	JZ	P$S$PL10		;on to next test
	MOV	AL,CMD$ERROR		;error if not return
	CALL	ERROR_MESSAGE		;tell them
	STC
	RET				;exit
P$S$PL10:
	CALL	SAVE_FILERECORD		;do they want to save?
	JNC	P$S$PL11		;no carry = no
	CALL	WRITESECTOR		;write out the sector then
	JNC	P$S$PL11		;no carry = ok
	CALL	ERROR_MESSAGE		;else error
	STC				;flag error
	RET				;exit
P$S$PL11:
	CMP	SECTOR_NUMBER,SECTOR$MAX	;last sector?
	JNZ	P$S$PL13		;no so not bothered about track
	MOV	SECTOR_NUMBER,0		;but reset sector
	CMP	TRACK_NUMBER,TRACK$MAX		;last track?
	JNZ	P$S$PL12		;no so simply wrap round track
	MOV	TRACK_NUMBER,0		;else clear track number
	JMP	P$S$PL20		;and continue
P$S$PL12:
	INC	TRACK_NUMBER		;bump track number
	JMP	P$S$PL20		;and continue
P$S$PL13:
	INC	SECTOR_NUMBER		;increase sector count
P$S$PL20:
	CLC
	RET
P$SE$PLUS		ENDP

P$SE$VALID		PROC
	MOV	LOW$BYTES,0			;clear counter in case	
	CALL	P$DN$VALID			;save the number that got us here
	MOV	BX, OFFSET DN$TABLE		;initialise pointer
P$S$VA10:
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$S$VA10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	MOV	BX, OFFSET DN$TABLE		;reset pointer
	JC	P$S$VA10			;continue if carry set
	JZ	P$S$VA20			;zero means error
	CALL	CHECKSECTOR			;see if we have a valid sector
	JC	P$S$VA20			;error if carry set
	CLC
	RET
P$S$VA20:
	STC
	RET					;carry = error to read routine
P$SE$VALID		ENDP

P$TR$MINUS		PROC
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT	;got to get a character
	INT	BDOS			;from the system
	CMP	AL,CR			;is it end of line?
	JZ	P$T$MI10		;ok we go backwards
	MOV	AL,CMD$ERROR		;command error if neither
	CALL	ERROR_MESSAGE
	STC
	RET				;flag error and exit
P$T$MI10:
	CALL	SAVE_FILERECORD		;do they want to save?
	JNC	P$T$MI11		;no carry = no
	CALL	WRITESECTOR		;write out the sector then
	JNC	P$T$MI11		;no carry = ok
	CALL	ERROR_MESSAGE		;else error
	STC
	RET				;flag it and exit
P$T$MI11:
	TEST	TRACK_NUMBER,0FFH	;any count here?
	JNZ	P$T$MI12		;yes so not bothered about sector
	MOV	TRACK_NUMBER,TRACK$MAX		;else wrap track number to end
	JMP	P$T$MI20		;and continue
P$T$MI12:
	DEC	TRACK_NUMBER		;reduce track number
P$T$MI20:
	CLC
	RET
P$TR$MINUS		ENDP

P$TR$PLUS		PROC
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT	;get next character
	INT	BDOS
	CMP	AL,CR			;should be return
	JZ	P$T$PL10		;ok 
	MOV	AL,CMD$ERROR		;command error if neither
	CALL	ERROR_MESSAGE
	STC
	RET				;flag error and exit
P$T$PL10:
	CALL	SAVE_FILERECORD		;do they want to save?
	JNC	P$T$PL11		;no carry = no
	CALL	WRITESECTOR		;write out the sector then
	JNC	P$T$PL11		;no carry = ok
	CALL	ERROR_MESSAGE		;else error
	STC
	RET				;exit
P$T$PL11:
	CMP	TRACK_NUMBER,TRACK$MAX		;last track ?
	JNZ	P$T$PL12		;no - not bothered about sector
	MOV	TRACK_NUMBER,0		;it was last track - reset track
	JMP	P$T$PL20		;and continue
P$T$PL12:
	INC	TRACK_NUMBER		;else add one
P$T$PL20:
	CLC
	RET
P$TR$PLUS		ENDP

P$TR$VALID		PROC
	MOV	LOW$BYTES,0			;clear counter in case	
	CALL	P$DN$VALID			;save the number that got us here
	MOV	BX, OFFSET DN$TABLE		;initialise pointer
P$T$VA10:
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	XOR	AH,AH				;and high byte
	MOV	SI,AX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	XOR	CH,CH				;use cx to preserve character
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	P$T$VA10			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	MOV	BX, OFFSET DN$TABLE		;reset pointer
	JC	P$T$VA10			;continue if carry set
	JZ	P$T$VA20			;zero means error
	CALL	CHECKTRACK			;test for valid track number
	JC	P$T$VA20			;error
	CLC
	RET
P$T$VA20:
	STC
	RET					;carry = error to read routine
P$TR$VALID		ENDP

P$HLP$RETURN		PROC
	CLC
	RET
P$HLP$RETURN		ENDP

P$HLP$SCREEN1		PROC
	CALL	CLEAR_SCREEN			;set up for new screen
	CALL	CURSOR_OFF
	GOTO	YORG,XORG+31
	MOV	SI, OFFSET HELP$MENU1
	CALL	OUTPUT_STRING
	GOTO	YORG+8,XORG+27			;fill missing characters
	MOV	AL,'$'
	CALL	OUTPUT_CHAR
	GOTO	YORG+11,XORG+27
	MOV	AL,','
	CALL	OUTPUT_CHAR
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS				;any character..
	TEST	AL,AL				;set non-zero
	PUSHF					;save flags
	MOV	AH,ZDOS$FLUSH			;in case
	INT	BDOS
	POPF
	STC					;then return
	RET
P$HLP$SCREEN1		ENDP

P$HLP$SCREEN2		PROC
	CALL	CLEAR_SCREEN			;set up for new screen
	CALL	CURSOR_OFF
	GOTO	YORG,XORG+31
	MOV	SI, OFFSET HELP$MENU2
	CALL	OUTPUT_STRING
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS				;any character..
	TEST	AL,AL				;set non-zero
	PUSHF					;save flags
	MOV	AH,ZDOS$FLUSH			;in case
	INT	BDOS
	POPF
	STC
	RET
P$HLP$SCREEN2		ENDP

P$HLP$SCREEN3		PROC
	CALL	CLEAR_SCREEN			;set up for new screen
	CALL	CURSOR_OFF
	GOTO	YORG,XORG+31
	MOV	SI, OFFSET HELP$MENU3
	CALL	OUTPUT_STRING
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS				;any character..
	TEST	AL,AL				;set non-zero
	PUSHF					;save flags
	MOV	AH,ZDOS$FLUSH			;in case
	INT	BDOS
	POPF
	STC
	RET
P$HLP$SCREEN3		ENDP

P$HLP$SCREEN4		PROC
	CALL	CLEAR_SCREEN			;set up for new screen
	CALL	CURSOR_OFF
	GOTO	YORG,XORG+31
	MOV	SI, OFFSET HELP$MENU4
	CALL	OUTPUT_STRING
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS				;any character..
	TEST	AL,AL				;set non-zero
	PUSHF					;save flags
	MOV	AH,ZDOS$FLUSH			;in case
	INT	BDOS
	POPF
	STC
	RET
P$HLP$SCREEN4		ENDP

P$HLP$SCREEN5		PROC
	CALL	CLEAR_SCREEN			;set up for new screen
	CALL	CURSOR_OFF
	GOTO	YORG,XORG+31
	MOV	SI, OFFSET HELP$MENU5
	CALL	OUTPUT_STRING
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS				;any character..
	TEST	AL,AL				;set non-zero
	PUSHF					;save flags
	MOV	AH,ZDOS$FLUSH			;in case
	INT	BDOS
	POPF
	STC
	RET
P$HLP$SCREEN5		ENDP

P$HLP$SCREEN6		PROC
	CALL	CLEAR_SCREEN			;set up for new screen
	CALL	CURSOR_OFF
	GOTO	YORG,XORG+31
	MOV	SI, OFFSET HELP$MENU6
	CALL	OUTPUT_STRING
	MOV	AH,ZDOS$CONINPUT		;get a character
	INT	BDOS				;any character..
	TEST	AL,AL				;set non-zero
	PUSHF					;save flags
	MOV	AH,ZDOS$FLUSH			;in case
	INT	BDOS
	POPF
	STC
	RET
P$HLP$SCREEN6		ENDP

P$HLP$UNKNOWN		PROC
	MOV	AL,CMD$ERROR			;invalid command
	CALL	ERROR_MESSAGE			;give error
	MOV	AH,ZDOS$FLUSH			;flush other characters
	INT	BDOS
	XOR	AL,AL				;signal error
	STC
	RET
P$HLP$UNKNOWN		ENDP
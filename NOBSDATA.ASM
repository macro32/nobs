      		SUBTTL	Data area

	COMMENT	%

	NOBSDATA v1.0
	Data area for NOBS

	%

DATASEG	SEGMENT		PUBLIC	'DATA'

; location to return to the system

RETURN_ADDRESS		DD	0

; fixed screen messages

SCREEN_HEADER		DB	'NOBS$'			; title of screen
TRACK_TITLE		DB	'Track:$'		; Track:
SECTOR_TITLE		DB	'Sector:$'		; Sector:
COMMAND_PROMPT		DB	'Command: $'		; Command:
EDITON			DB	'INSERT ON$'		; indicate insert mode

; save a number from the terminal here

LOW$BYTES		DW	0

; start line number of screen display
; this can be 00 or 10H as the buffer is arranged as 32 row x 16 columns
 
LINE_NUMBER		DB	0			; start line number

; the counts of the track and sector numbers

SECTOR_NUMBER		DB	0			; current sector
TRACK_NUMBER		DB	0			; current track
RECORD_NUMBER		DW	0			; holds max record count for current file

; disc buffer and pointers

LINE_INDEX		DB	0			; start at line 0
COLUMN_INDEX		DB	0			; column 0
ASCII$SCREEN$FLAG	DB	FALSE			; and use hex screen
DISC_BUFFER		DB	512	DUP (0)		; disc buffer area

; messages for prompts

SAVEQUERY		DB	'Save ? Y/N :$'

; error messages
X	MACRO	ADDRESS,MESSAGE
ADDRESS	EQU	$
IRPC	C,MESSAGE
DB	'&C'			;;string of characters
ENDM
ENDM

;define the messages
.SALL
MESSAGES
.XALL

;now the table of message addresses

ERRORS		EQU	$
X	MACRO	ADDRESS,MESSAGE
DW	&ADDRESS
ENDM

;now the address table
MESSAGES

; table of command entries
X	MACRO	COMMAND$NAME
DW	OFFSET	P$&COMMAND$NAME
ENDM

; here is the table
COMMAND	EQU	$
COMMANDS

; table of pointer entries
X	MACRO	PTRS$NAME,TABLE$NAME
DW	OFFSET	P$&PTRS$NAME
ENDM

; here is the table
POINTER	EQU	$
PTRS

; all the data for file handling is here

FILE$OPEN$FLAG	DB	FALSE	;set to true on a successful open command 

;filename buffer index/counter
FN$POINTER	DW	0	;set to zero initially

;the filename buffer for the open file command
FILENAME$BUFFER	EQU	$
DB	16	DUP (20H)	;initialise to spaces 15 char filespec + ov

;the file control block
FCB	EQU	$
DB	36	DUP (0)		;clear it to start

DATASEG		ENDS

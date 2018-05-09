   	SUBTTL	All Macros  

	COMMENT	%

	MACLIB v1.0
	Macro Library

	Routines here are:

	COMMANDS	generates the commands tables
	CON_ESC2	outputs two character escape sequence
	CON_ESC3	outputs three character escape sequence
	OUTPUT		outputs a character to the screen
	GOTO		moves cursor to screen location
	MESSAGES	defines (error) messages
	PTRS		generates command pointer tables and a little more

	%


CON_ESC2		MACRO	A
;outputs two character escape sequence
	MOV	AL,ESC			;; get escape character
	CALL	OUTPUT_CHAR		;; output the character
	MOV	AL,'&A'			;; get control character
	CALL	OUTPUT_CHAR		;; output this
	ENDM

CON_ESC3		MACRO	A,B
;outputs three character escape sequence
	MOV	AL,ESC			;; get escape character
	CALL	OUTPUT_CHAR		;; output this
	MOV	AL,'&A'			;; get set/reset character ( x or y )
	CALL	OUTPUT_CHAR		;; output this
	MOV	AL,'&B'			;; get control character
	CALL	OUTPUT_CHAR		;; output this
	ENDM

;so define the messages here
MESSAGES	MACRO
X	ERROR$M1,<<? Attempt to write on write protected disc$>>
X	ERROR$M2,<<? Data error$>>
X	ERROR$M3,<<? Seek error$>>
X	ERROR$M4,<<? Sector not found$>>
X	ERROR$M5,<<? Write fault$>>
X	ERROR$M6,<<? General disc failure$>>
X	ERROR$M7,<<? I am very confused$>>
X	ERROR$M8,<<? You have not set write enable$>>
X	ERROR$M9,<<? Invalid track number$>>
X	ERROR$M10,<<? Invalid sector number$>>
X	ERROR$M11,<<? Invalid command$>>
X	ERROR$M12,<<? Invalid edit command$>>
X	ERROR$M13,<<? Disc will be unchanged$>>
X	ERROR$M14,<<? A file has not been opened yet$>>
X	ERROR$M15,<<? File not found$>>
X	ERROR$M16,<<? Filename parsing error$>>
X	ERROR$M17,<<? Filename too long$>>
X	ERROR$M18,<<? Invalid character in filename$>>
X	ERROR$M19,<<? File already open$>>
X	ERROR$M20,<<? Already at beginning of file$>>
X	ERROR$M21,<<? Reply not understood$>>
X	ERROR$M22,<<? Invalid command whilst a file is open$>>
X	ERROR$M23,<<? Invalid decimal digit in number$>>
X	ERROR$M24,<<? Number too big for a word$>>
X	ERROR$M25,<<? Sector number out of range$>>
X	ERROR$M26,<<? Track number out of range$>>
X	ERROR$M27,<<? Record number out of range$>>
ENDM

OUTPUT			MACRO	A
IFNB	<A>
	MOV	AL,'&A'			;; get a character if there is one
ELSE
	MOV	AL,' '			;; space otherwise
ENDIF
	CALL	OUTPUT_CHAR		;; output character
	ENDM

GOTO			MACRO	A,B
	MOV	DH,A			;; place line number
	MOV	DL,B			;; and column number
	CALL	MOVETO			;; go there
	ENDM

PTRS	MACRO
; shows table pointer routines and associated tables
	X	EXECUTE,COMMAND$TABLE
	X	CMD$P0,COMMAND$TABLE
	X	CMD$P1,COMMAND$ESCx
	X	CMD$P2,COMMAND$ESC?x
	X	CMD$P3,COMMAND$ESC0x
	X	CMD$P4,COMMAND$ESC1x
	X	EDT$P0,EDIT$TABLE
	X	EDT$P1,EDIT$ESCx
	X	EDT$P2,EDIT$ESC?x
	X	EDT$P3,EDIT$ESC0x
	X	EDT$P4,EDIT$ESC1x
ENDM

COMMANDS	MACRO
	X	CMD$UNKNOWN
	X	CMD$ABORT
	X	CMD$BOTTOM
	X	CMD$CLOSEFILE
	X	CMD$EXIT
	X	CMD$HELP
	X	CMD$OPENFILE
	X	CMD$READFILE
	X	CMD$SECTOR
	X	CMD$SWITCHTABLES
	X	CMD$TOP
	X	CMD$TRACK
	X	EDT$ABORT
	X	EDT$ALTER
	X	EDT$CURSORDOWN
	X	EDT$CURSORLEFT
	X	EDT$CURSORRIGHT
	X	EDT$CURSORUP
	X	EDT$SWITCHTABLES
	X	EDT$TOGGLE
	X	EDT$UNKNOWN
	X	FN$CONVERT
	X	FN$INVALID
	X	FN$RETURN
	X	FN$VALID
	X	DN$INVALID
	X	DN$RETURN
	X	DN$VALID
	X	RE$MINUS
	X	RE$PLUS
	X	RE$VALID
	X	SE$MINUS
	X	SE$PLUS
	X	SE$VALID
	X	TR$MINUS
	X	TR$PLUS
	X	TR$VALID
	X	HLP$RETURN
	X	HLP$SCREEN1
	X	HLP$SCREEN2
	X	HLP$SCREEN3
	X	HLP$SCREEN4
	X	HLP$SCREEN5
	X	HLP$SCREEN6
	X	HLP$UNKNOWN
ENDM

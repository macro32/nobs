	PAGE	40,132

	TITLE	NOBS - No Bad Sectors

	COMMENT	%

	NOBS	v1.0
	Disc maintenance program

	Enables the maintenance of floppy discs on the Zenith Z-100
	computer under Z-DOS. It uses standard function calls to 
	allow the user to modify and inspect a disc.

	Files used:

	%

	PAGE	+

	.XLIST
	INCLUDE	ASCII.ASM
	INCLUDE CMDDEF.ASM
	INCLUDE	FCBDEF.ASM
	INCLUDE	MACLIB.ASM
	INCLUDE	NOBSDEF.ASM
	INCLUDE	PUBLICS.ASM
	INCLUDE	ZDOSFUNC.ASM
	INCLUDE	ZDOSINT.ASM
	.LIST

	PAGE	+

EXTRN	COMMAND$TABLE:NEAR
EXTRN	COMMAND$ESCx:NEAR
EXTRN	COMMAND$ESC?x:NEAR
EXTRN	COMMAND$ESC0x:NEAR
EXTRN	COMMAND$ESC1x:NEAR
EXTRN	DN$TABLE:NEAR
EXTRN	EDIT$TABLE:NEAR
EXTRN	EDIT$ESCx:NEAR
EXTRN	EDIT$ESC?x:NEAR
EXTRN	EDIT$ESC0x:NEAR
EXTRN	EDIT$ESC1x:NEAR
EXTRN	FILENAME$TABLE:NEAR
EXTRN	RECORD$TABLE:NEAR
EXTRN	SECTOR$TABLE:NEAR
EXTRN	TRACK$TABLE:NEAR
EXTRN	HELP$TABLE:NEAR

EXTRN	MAIN$MENU1:NEAR
EXTRN	MAIN$MENU2:NEAR
EXTRN	HELP$MENU1:NEAR
EXTRN	HELP$MENU2:NEAR
EXTRN	HELP$MENU3:NEAR
EXTRN	HELP$MENU4:NEAR
EXTRN	HELP$MENU5:NEAR
EXTRN	HELP$MENU6:NEAR

	PAGE	+

	SUBTTL	Stack area

STACK_SEG	SEGMENT	STACK

DW	80H	DUP	(?)			;space for stack
STACK_START		EQU	THIS WORD	;start of stack

STACK_SEG	ENDS

	SUBTTL

	PAGE	+

	SUBTTL	Data area

	INCLUDE	NOBSDATA.ASM


	PAGE	+

	SUBTTL	Code start


PROGRAM		SEGMENT
	ASSUME	CS:PROGRAM,DS:DATASEG,SS:STACK_SEG,ES:NOTHING

	.XLIST

	INCLUDE	ESCAPE.ASM

	INCLUDE	IO.ASM

	.LIST

	INCLUDE	NOBSLIB.ASM

	INCLUDE	NOBSDISC.ASM

	INCLUDE	NOBSCMDS.ASM

MAIN:	MOV	AX,DATASEG			;initialise things
	MOV	DS,AX
	MOV	AX,STACK_SEG
	MOV	SS,AX
	MOV	SP,OFFSET STACK_START
	MOV	WORD PTR RETURN_ADDRESS+2,ES


	CALL	DISPLAY_FIXED			;clear and set up screen
	CALL	DISPLAY_ABSOLUTE		;assume track/sector mode

	CALL	BUFFER_HEX			;show what we got in hex
	CALL	BUFFER_ASCII			;and in ascii

	CALL	REVERSE$TOP$ARROW		;start in top part of buffer
	CALL	NORMAL$BOTTOM$ARROW

	CALL	DISPLAY_COMMAND			;start in command mode

	MOV	BX, OFFSET COMMAND$TABLE	;initialise pointer

COMMAND_LOOP:
	MOV	AH,ZDOS$CONINPUT		;console input
	INT	BDOS				;perform function
	MOV	CL,AL				;use cx to preserve character
	XOR	CH,CH				;and high byte
	MOV	SI,CX				;save index
	SHL	SI,1				;index * 2 for word table
	MOV	CL, [BX+SI+1]			;get first byte
	MOV	DI,CX				;index into pointer routines
	CALL	POINTER[DI]			;go do it
	JC	COMMAND_LOOP			;no significance so idle...
						;else continue
	MOV	CL,[BX+SI]			;get routine index
	MOV	DI,CX				;go service it
	CALL	ERROR_CLEAR			;clear error line before new...
	CALL	COMMAND[DI]			;execute command
	MOV	BX, OFFSET COMMAND$TABLE	;reset pointer to main table
	JC	COMMAND_LOOP			;not done if carry set

	JMP	RETURN_ADDRESS			;else finish


PROGRAM		ENDS

	END	MAIN

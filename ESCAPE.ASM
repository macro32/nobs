	
	SUBTTL	Escape sequence subroutines
  
	COMMENT	%

	ESCAPES v1.0
	Escape sequence routines

	contents:

	CLEAR_SCREEN		clears screen and homes cursor
	CURSOR_ON		turns cursor on
	CURSOR_OFF		turns cursor off
	DELETE_EOLN		erases from cursor to end of line
	DELETE_LINE		erases line cursor is on
	GRAPHICS_ON		switches on character graphics
	GRAPHICS_OFF		switched off character graphics
	REVERSE_ON		turns inverse video on
	REVERSE_OFF		turns inverse video off
	RESTORE_CURSOR		restores saved cursor position
	SAVE_CURSOR		saves current cursor position

	%


CLEAR_SCREEN	PROC	NEAR
	CON_ESC2	E
	RET
CLEAR_SCREEN	ENDP

CURSOR_ON	PROC	NEAR
	CON_ESC3	y,5
	RET
CURSOR_ON	ENDP

CURSOR_OFF	PROC	NEAR
	CON_ESC3	x,5
	RET
CURSOR_OFF	ENDP

DELETE_EOLN	PROC	NEAR
	CON_ESC2	K
	RET
DELETE_EOLN	ENDP

DELETE_LINE	PROC	NEAR
	CON_ESC2	l
	RET
DELETE_LINE	ENDP

GRAPHICS_ON	PROC	NEAR
	CON_ESC2	F
	RET
GRAPHICS_ON	ENDP

GRAPHICS_OFF	PROC	NEAR
	CON_ESC2	G
	RET
GRAPHICS_OFF	ENDP

REVERSE_ON	PROC	NEAR
	CON_ESC2	p
	RET
REVERSE_ON	ENDP

REVERSE_OFF	PROC	NEAR
	CON_ESC2	q
	RET
REVERSE_OFF	ENDP

RESTORE_CURSOR	PROC	NEAR
	CON_ESC2	k
	RET
RESTORE_CURSOR	ENDP

SAVE_CURSOR	PROC	NEAR
	CON_ESC2	j
	RET
SAVE_CURSOR	ENDP
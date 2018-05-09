 	ZDOS$CONIO	EQU	06H	;direct CON: input/output
 	ZDOS$CONINPUT	EQU	07H	;direct CON: input missing ^C
	ZDOS$FLUSH	EQU	0CH	;flush type ahead buffer
	ZDOS$OPEN	EQU	0FH	;open a file
	ZDOS$CLOSE	EQU	10H	;close a file
	ZDOS$SETDTA	EQU	1AH	;set disc transfer address
	ZDOS$READRN	EQU	21H	;random read
	ZDOS$PARSE	EQU	29H	;parse file name

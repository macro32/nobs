; definitions of the routine offsets in the command tables
; first table is the pointer altering routines
EXECUTE			EQU	0
CMD$P0			EQU	2
CMD$P1			EQU	4
CMD$P2			EQU	6
CMD$P3			EQU	8
CMD$P4			EQU	10
EDT$P0			EQU	12
EDT$P1			EQU	14
EDT$P2			EQU	16
EDT$P3			EQU	18
EDT$P4			EQU	20

; second table is the command routine entries

CMD$UNKNOWN		EQU	0

CMD$ABORT		EQU	2
CMD$BOTTOM		EQU	4
CMD$CLOSEFILE		EQU	6
CMD$EXIT		EQU	8
CMD$HELP		EQU	10
CMD$OPENFILE		EQU	12
CMD$READFILE		EQU	14
CMD$SECTOR		EQU	16
CMD$SWITCHTABLES	EQU	18
CMD$TOP			EQU	20
CMD$TRACK		EQU	22

; edit command entries

EDT$ABORT		EQU	24
EDT$ALTER		EQU	26
EDT$CURSORDOWN		EQU	28
EDT$CURSORLEFT		EQU	30
EDT$CURSORRIGHT		EQU	32
EDT$CURSORUP		EQU	34
EDT$SWITCHTABLES	EQU	36
EDT$TOGGLE		EQU	38
EDT$UNKNOWN		EQU	40

; filename routines

FN$CONVERT		EQU	42
FN$INVALID		EQU	44
FN$RETURN		EQU	46
FN$VALID		EQU	48

; decimal number routines

DN$INVALID		EQU	50
DN$RETURN		EQU	52
DN$VALID		EQU	54

; record routines

RE$MINUS		EQU	56
RE$PLUS			EQU	58
RE$VALID		EQU	60

; sector routines

SE$MINUS		EQU	62
SE$PLUS			EQU	64
SE$VALID		EQU	66

; track routines

TR$MINUS		EQU	68
TR$PLUS			EQU	70
TR$VALID		EQU	72

; help routines

HLP$RETURN		EQU	74
HLP$SCREEN1		EQU	76
HLP$SCREEN2		EQU	78
HLP$SCREEN3		EQU	80
HLP$SCREEN4		EQU	82
HLP$SCREEN5		EQU	84
HLP$SCREEN6		EQU	86
HLP$UNKNOWN		EQU	88

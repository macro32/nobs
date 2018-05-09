	TRUE		EQU	1			;boolean flag
	FALSE		EQU	0			;and converse

	XORG		EQU	1			;screen x org
	YORG		EQU	1			;screen y org

 	SECTOR$X	EQU	XORG+27			;track and sector
	SECTOR$Y	EQU	YORG+2			;display locations
	TRACK$X		EQU	XORG+15
	TRACK$Y		EQU	YORG+2
	TRACK$MAX	EQU	79			;40 tracks per side
	SECTOR$MAX	EQU	7			;8 sectors per track

	BUFFER$XORG		EQU	XORG+8		;display buffer
	BUFFER$YORG		EQU	YORG+4
	LAST$BUFFER$LINE	EQU	YORG+20		;last line
	ASCII$XORG		EQU	XORG+58		;ascii origin
	ASCII$YORG		EQU	YORG+4
	HEX$XORG		EQU	XORG+8		;hex origin
	HEX$YORG		EQU	YORG+4

	ERROR$X			EQU	XORG+8		;error message line
	ERROR$Y			EQU	YORG+23

	CMD$ERROR		EQU	20		;command error
	FN$FNO			EQU	26		;file not opened
	FN$FNF			EQU	28		;file not found
	FN$FPE			EQU	30		;file parse error
	FN$FTL			EQU	32		;filename too long
	FN$ICF			EQU	34		;invalid char in name
	FN$FAO			EQU	36		;file already open
	FN$AAB			EQU	38		;already at beginning
	CMD$RNU			EQU	40		;reply not understood
	CMD$FOE			EQU	42		;file already open
	DN$IDD			EQU	44		;invalid decimal digit
	DN$NOV			EQU	46		;number too big for word
	SE$SOR			EQU	48		;sector no out of range
	TR$TOR			EQU	50		;track no out of range
	RE$ROR			EQU	52		;record no out of range


	FILE$RECORD$SIZE	EQU	512		;size of record for files

; here we have definitions for the date and time

TIME	RECORD	HOURS:5, MINS:6, SECS:5

DATE	RECORD	YEAR:7, MONTH:4, DAY:5

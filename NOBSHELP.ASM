	COMMENT	%

	NOBSHELP v1.0
	Help screens for the data area

	there are six screens:

	0.  Main help menu
	1.  Ascii code summary
	2.  NOBS command mode commands
	3.  NOBS edit mode commands
	4.  File header format
	5.  Directory entry format
	6.  General Zenith disc information

	these are all kept in the data area DATASEG segment

	%

PUBLIC		MAIN$MENU1
PUBLIC		MAIN$MENU2
PUBLIC		HELP$MENU1
PUBLIC		HELP$MENU2
PUBLIC		HELP$MENU3
PUBLIC		HELP$MENU4
PUBLIC		HELP$MENU5
PUBLIC		HELP$MENU6

INCLUDE		ASCII.ASM


DATASEG	SEGMENT		PUBLIC	'DATA'
	ASSUME	DS:DATASEG

MAIN$MENU1	DB	'NOBS Help Screens$'
MAIN$MENU2	DB	'0. Return to NOBS',CR,LF,HT,HT,HT
		DB	'1. Ascii codes',CR,LF,HT,HT,HT
		DB	'2. NOBS command mode commands',CR,LF,HT,HT,HT
		DB	'3. NOBS edit mode commands',CR,LF,Ht,HT,HT
		DB	'4. Directory entry format',CR,LF,HT,HT,HT
		DB	'5. File header format',CR,LF,HT,HT,HT
		DB	'6. General disc information',CR,LF,LF,HT,HT
		DB	'To select your choice press the number :$'

HELP$MENU1	DB	'NOBS Help Screen 1',CR,LF,LF,HT,HT,HT,HT
		DB	'   ASCII codes',CR,LF,LF,HT
		DB	'00 NUL  10 DLE  20 SP   30 0    40 @    50 P    60 `    70 p',CR,LF,HT
		DB	'01 SOH  11 DC1  21 !    31 1    41 A    51 Q    61 a    71 q',CR,LF,HT
		DB	'02 STX  12 DC2  22 "    32 2    42 B    52 R    62 b    72 r',CR,LF,HT
		DB	'03 ETX  13 DC3  23 #    33 3    43 C    53 S    63 c    73 s',CR,LF,HT
		DB	'04 EOT  14 DC4  24      34 4    44 D    54 T    64 d    74 t',CR,LF,HT
		DB	'05 ENQ  15 NAK  25 %    35 5    45 E    55 U    65 e    75 u',CR,LF,HT
		DB	'06 ACK  16 SYN  26 &    36 6    46 F    56 V    66 f    76 v',CR,LF,HT
		DB	'07 BEL  17 ETB  27      37 7    47 G    57 W    67 g    77 w',CR,LF,HT
		DB	'08 BS   18 CAN  28 (    38 8    48 H    58 X    68 h    78 x',CR,LF,HT
		DB	'09 HT   19 EM   29 )    39 9    49 I    59 Y    69 i    79 y',CR,LF,HT
		DB	'0A LF   1A SUB  2A *    3A :    4A J    5A Z    6A j    7A z',CR,LF,HT
		DB	'0B VT   1B ESC  2B +    3B ;    4B K    5B [    6B k    7B {',CR,LF,HT
		DB	'0C FF   1C FS   2C ,    3C <    4C L    5C \    6C l    7C |',CR,LF,HT
		DB	'0D CR   1D GS   2D -    3D =    4D M    5D ]    6D m    7D }',CR,LF,HT
		DB	'0E SO   1E RS   2E .    3E >    4E N    5E ^    6E n    7E ~',CR,LF,HT
		DB	'0F SI   1F US   2F /    3F ?    4F O    5F _    6F o    7F DEL',CR,LF,LF,HT
		DB	'Press any key to return to the main menu$'

HELP$MENU2	DB	'NOBS Help screen 2',CR,LF,LF,HT,HT,HT
		DB	'     Command mode commands',CR,LF,LF,HT
		DB	'A	Abort			O<fn>	Open file',CR,LF,HT
		DB	'C	Close current file	R<arg>	Read file record',CR,LF,HT
		DB	'E	Exit			S<arg>	Read disc sector',CR,LF,HT
		DB	'H,HELP	Help screens		T<arg>	Read sector changing track',CR,LF,HT
		DB	'LF	Change to edit mode',CR,LF,LF,HT
		DB	'The cursor keys, up arrow and down arrow are used for toggling',CR,LF,HT
		DB	'between the two halves of the display buffer',CR,LF,LF,HT
		DB	'Key:',CR,LF,LF,HT
		DB	'<fn>	= valid Z-DOS filespec (may include disc id)',CR,LF,HT
		DB	'<arg>	= either +	: next',CR,LF,HT
		DB	'		 -	: previous',CR,LF,HT
		DB	'	    decimal no.	: absolute',CR,LF,LF,HT
		DB	'Press any key to return to the main menu$'

HELP$MENU3	DB	'NOBS Help screen 3',CR,LF,LF,HT,HT,HT
		DB	'     Edit mode commands',CR,LF,LF,HT
		DB	'DEL	Toggle insert on/off',CR,LF,HT
		DB	'LF	Change to command mode',CR,LF,HT
		DB	'TAB	Toggle ascii/hex screens',CR,LF,LF,HT
		DB	'All the cursor keys can be used to move around the screen',CR,LF,LF,HT
		DB	'With INSERT on, the hex screen will only accept valid hexadecimal',CR,LF,HT
		DB	'characters, but the ascii screen will accept any character generated',CR,LF,HT
		DB	'by the keyboard',CR,LF,LF,HT
		DB	'Press any key to return to the main menu$'

HELP$MENU4	DB	'NOBS Help screen 4',CR,LF,LF,HT,HT,HT
		DB	'   Directory entry structure',CR,LF,LF,HT
		DB	'A disc directory entry contains a lot of useful information',CR,LF,HT
		DB	'about the file it is associated with. The format and contents',CR,LF,HT
		DB	'of a directory entry are given here.',CR,LF,LF,HT,HT,HT
		DB	'Offset',HT,HT,HT,'Contents',CR,LF,LF,HT,HT,HT
		DB	' 0000H',HT,HT,HT,'File name',CR,LF,HT,HT,HT
		DB	' 0008H',HT,HT,HT,'File extension',CR,LF,HT,HT,HT
		DB	' 000BH',HT,HT,HT,'File attribute',CR,LF,HT,HT,HT,HT,HT
		DB	'2   =   hidden file',CR,LF,HT,HT,HT,HT,HT
		DB	'4   =   system file',CR,LF,HT,HT,HT
		DB	' 000CH',HT,HT,HT,'Reserved',CR,LF,HT,HT,HT
		DB	' 0016H',HT,HT,HT,'Time the file was created',CR,LF,HT,HT,HT
		DB	' 0018H',HT,HT,HT,'Date the file was created',CR,LF,HT,HT,HT
		DB	' 001AH',HT,HT,HT,'Starting sector of file',CR,LF,HT,HT,HT
		DB	' 001CH',HT,HT,HT,'File size in bytes',CR,LF,HT,HT,HT
		DB	' 0020H',HT,HT,HT,'Size of directory entry',CR,LF,LF,HT,HT
		DB	'Press any key to return to the main menu$'


HELP$MENU5	DB	'NOBS Help screen 5',CR,LF,LF,HT,HT,HT
		DB	'  EXE file header structure',CR,LF,LF,HT
		DB	'Each EXE file has a 100H byte header at the beginning of the',CR,LF,HT
		DB	'file. This header contains addresses of interrupt handlers and',CR,LF,HT
		DB	'entry points. The known location definitions are:',CR,LF,LF,HT,HT,HT
		DB	'Offset',HT,HT,'Contents',CR,LF,LF,HT,HT,HT
		DB	' 000H		Termination point ( INT 20 )',CR,LF,HT,HT,HT
		DB	' 002H		Memory size',CR,LF,HT,HT,HT
		DB	' 005H		Alternate function entry point',CR,LF,HT,HT,HT
		DB	' 00AH		Exit handler address',CR,LF,HT,HT,HT
		DB	' 00EH		^C handler address',CR,LF,HT,HT,HT
		DB	' 012H		Fatal error handler address',CR,LF,HT,HT,HT
		DB	' 05BH		End of stack area',CR,LF,HT,HT,HT
		DB	' 05CH		First program argument',CR,LF,HT,HT,HT
		DB	' 06CH		Second program argument',CR,LF,HT,HT,HT
		DB	' 080H		Default disc transfer area',CR,LF,HT,HT,HT
		DB	' 100H		Start of code',CR,LF,LF,HT,HT
		DB	'Press any key to return to the main menu$'

 

HELP$MENU6	DB	'NOBS Help screen 6',CR,LF,LF,HT,HT,HT
		DB	'General Zenith disc information',CR,LF,LF,HT
		DB	'Each disc is double sided, double density, and has:',CR,LF,LF,HT,HT,HT
		DB	'40	tracks per side (0-39=side 0, 40-79=side 1)',CR,LF,HT,HT,HT
		DB	'8	sectors per track (0-7)',CR,LF,HT,HT,HT
		DB	'512	bytes per sector',CR,LF,LF,HT
		DB	'giving a total capacity of 327680 bytes.',CR,LF,LF,HT,HT
		DB	'Press any key to return to the main menu$'

DATASEG		ENDS

	END

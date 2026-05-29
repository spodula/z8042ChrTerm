;*************************************************************************************
;Spectrum 48 ROM system variables
;*************************************************************************************
KSTATE:		equ	$5C00    ; Used in reading the keyboard
LAST-K:		equ	$5C08    ; Last key pressed
REPDEL:		equ	$5C09    ; Time that a key must be held down before it repeats
REPPER:		equ	$5C0A    ; Delay between successive repeats of a key held down
DEFADD:		equ	$5C0B    ; Address of arguments of user defined function
K-DATA:		equ	$5C0D    ; Second byte of colour controls entered from keyboard
TVDATA:		equ	$5C0E    ; Colour,  AT and TAB controls going to television 
STRMS:		equ	$5C10    ; Addresses of channels attached to streams
CHARS:		equ	$5C36    ; 256 less than address of character set
RASP:		equ	$5C38    ; Length of warning buzz
PIP:		equ	$5C39    ; Length of keyboard click
ERR-NR:		equ	$5C3A    ; One less than the error report code
FLAGS:		equ	$5C3B    ; Various flags to control the BASIC system
TV-FLAG:	equ	$5C3C    ; Flags associated with the television
ERR-SP:		equ	$5C3D    ; Address of item on machine stack to use as error return
LIST-SP:	equ	$5C3F    ; Return address from automatic listing
MODE:		equ	$5C41    ; Specifies K,L,C,E or G cursor
NEWPPC:		equ	$5C42    ; Line to be jumped to
NSPPC:		equ	$5C44    ; Statement number in line to be jumped to
PPC:		equ	$5C45    ; Line number of statement being executed
SUBPPC:		equ	$5C47    ; Number within line of statement being executed
BORDCR:		equ	$5C48    ; Border colour
E-PPC:		equ	$5C49    ; Number of current line
VARS:		equ	$5C4B    ; Address of variables
DEST:		equ	$5C4D    ; Address of variable in assignment
CHANS:		equ	$5C4F    ; Address of channel data
CURCHL:		equ	$5C51    ; Address of information used for input and output
PROG:		equ	$5C53    ; Address of BASIC program
NXTLIN:		equ	$5C55    ; Address of next line in program
DATADD:		equ	$5C57    ; Address of terminator of last DATA item
E-LINE:		equ	$5C59    ; Address of command being typed in
K-CUR:		equ	$5C5B    ; Address of cursor
CH-ADD:		equ	$5C5D    ; Address of the next character to be interpreted
X-PTR:		equ	$5C5F    ; Address of the character after the '?' marker
WORKSP:		equ	$5C61    ; Address of temporary work space
STKBOT:		equ	$5C63    ; Address of bottom of calculator stack
STKEND:		equ	$5C65    ; Address of start of spare space
BREG:		equ	$5C67    ; Calculator's B register
MEM:		equ	$5C68    ; Address of area used for calculator's memory
FLAGS2:		equ	$5C6A    ; More flags
DF-SZ:		equ	$5C6B    ; The number of lines in the lower part of the screen
S-TOP:		equ	$5C6C    ; The number of the top program line in automatic listings
OLDPPC:		equ	$5C6E    ; Line number to which CONTINUE jumps
OSPCC:		equ	$5C70    ; Number within line of statement to which CONTINUE jumps
FLAGX:		equ	$5C71    ; Various flags
STRLEN:		equ	$5C72    ; Length of string type destination in assignment
T-ADDR:		equ	$5C74    ; Address of next item in parameter table
SEED:		equ	$5C76    ; The seed for RND
FRAMES:		equ	$5C78    ; Frame counter
UDG:		equ	$5C7B    ; Address of first user defined graphic
COORDS:		equ	$5C7D    ; Coordinates of last point plotted
P-POSN:		equ	$5C7F    ; Column number of printer position
PR-CC:		equ	$5C80    ; Address of next position for LPRINT to print at
ECHO-E:		equ	$5C82    ; Column and line number of end of input buffer
DF-CC:		equ	$5C84    ; Address in display file of PRINT position
DF-CCL:		equ	$5C86    ; Like DF-CC for lower part of screen
S-POSN:		equ	$5C88    ; Column and line number for PRINT position
S-POSNL:	equ	$5C8A    ; Like S-POSN for lower part of screen
SCR-CT:		equ	$5C8C    ; Scroll counter
ATTR-P:		equ	$5C8D    ; Permanent current colours
MASK-P:		equ	$5C8E    ; Used for transparent colours
ATTR-T:		equ	$5C8F    ; Temporary current colours
MASK-T:		equ	$5C90    ; Temporary transparent colours
P-FLAG:		equ	$5C91    ; More flags
MEMBOT:		equ	$5C92    ; Calculator's memory area
NMIADD:		equ	$5CB0    ; Non-maskable interrupt address
RAMTOP:		equ	$5CB2    ; Address of last byte of BASIC system area
P-RAMT:		equ	$5CB4    ; Address of last byte of physical RAM
CHANS		equ	$5CB6    ; channel information

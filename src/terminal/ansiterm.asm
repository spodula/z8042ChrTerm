;*******************************************************************************
; Implementation of the display part of an ANSI terminal for the ZX-Spectrum. 
; GDS March 2023    <ESC> = 0x1b
;
; Limitations: Not a full ANSI implementation. (Not sure thats possible)
;              This is a 42x24 terminal. 
;              As such, colour clash between some characters
;              ESC[ buffer is limited to 10 characters.
;*******************************************************************************
;Supported: 
;Characters:
;   \b (0x07) - Bell
;   ?  (0x08) - Backspace - Back one character to Start of line.
;   \t (0x09) - Tab to the next column (Tabs are currently always 8)
;   \r (0x0a) - if Bit 1,(IX+3)=0, Next line+Start of line, else just next line
;   \n (0x0d) - Go to the start of the line
;   ?  (0x7f) - Delete character
;   ?  (0x0b or 0x0c) VT and FF treated as LF (0x0a) as per Vt-100.
;   ?  (0x18) - Cancel escape string
;   ?  (0x1A) - Cancel escape string with error
;------------------------------------------------------------------------------
;Set Attribute Mode	<ESC>[{attr1};...;{attrn}m
;------------------------------------------------------------------------------
;  Sets or resets multiple display attribute settings. The following lists supported attributes:
; Set clr
;  0   -    Reset or normal	All attributes off
;  1  21    Bold  
;  2  22    Bold off (Both 2 and 22 are bold off)
;  3  23    Italic	
;  4  24    Underline
;  7  27    invert
;  8  28    Conceal
;  9  29    Strikeout
;
;  Foreground colour = 30+(Speccy Colour) (Not the same colourset as ANSI)
;  Background colour = 40+(Speccy Colour) (Not the same colourset as ANSI)
;   49 = default background colour (White). 39 = Default foregound colour (Black)
;    +0 black, +1 Blue, +2 red, +3 magenta, +4 green, +5 cyan, +6 yellow, +7 white
;------------------------------------------------------------------------------
; Clear block: <ESC>[xJ
;------------------------------------------------------------------------------
;  0 (Or blank) - Clear from cursor to End of screen
;  1 Clear from cursor to start of screen
;  2 Clear entire screen
;------------------------------------------------------------------------------
; Clear line: <ESC>[xK
;------------------------------------------------------------------------------
;  0 (Or blank) - Clear from cursor to End of line
;  1 Clear from cursor to start of line
;  2 Clear entire line
;------------------------------------------------------------------------------
; Set Cursor: <ESC>[{Y}{;X}H <ESC>[{Y}{;X}f
;------------------------------------------------------------------------------
; Set the cursor location Up to two parameters. Missing parameters default to 0
;   <ESC>[H  - Set cursor to 0,0
;   <ESC>[{y}H  - Set cursor to 0,y
;   <ESC>[{y};{x}H  - Set cursor to x,y
;------------------------------------------------------------------------------
;reset terminal <ESC>c or <esc>[c or <esc>[p
;------------------------------------------------------------------------------
; Reset to default state. Cursor=0,0, all flags reset,screen cleared
; Note, usually p is soft reset, whereas C is hard reset. Treated the same here
;------------------------------------------------------------------------------
; Move Cursor <ESC>[<x>[A|B|C|D]
;------------------------------------------------------------------------------
; Move the cursor X characters in the given direction.  Will Max at the edges of the screen
; A=up B=Down, C=Right, D=Left  <X> is not present will default to 1 EXCEPT for D which will scroll up
;------------------------------------------------------------------------------
; Move Cursor Up or down with NL <ESC><x>[E|F] .
;------------------------------------------------------------------------------
; Move the cursor X characters in the given direction and move cursor to start of line
;  Will Max at the edges of the screen  ; E=Down, F=Up. If <X> is not present will default to 1
;------------------------------------------------------------------------------
; Move cursor to column n                <ESC>[<n>G
;------------------------------------------------------------------------------
; Move the cursor the the given column. If column >41, column = 41
;------------------------------------------------------------------------------
; Font height  <ESC>#[3|4|5]
;------------------------------------------------------------------------------
;Set the font height 3=dbl height top, 4=dbl height bottom, 5=normal
;------------------------------------------------------------------------------
;Save and restore cursor <ESC>[s  <esc>[u   OR   <ESC>7 <ESC>8
;------------------------------------------------------------------------------
;Note this is only a single level store.
;------------------------------------------------------------------------------
;Scroll window up one line ^D
;Scroll window down one line ^M
;------------------------------------------------------------------------------
;Scrolls the window appropriately.
;------------------------------------------------------------------------------
;Set terminal mode
;------------------------------------------------------------------------------
;setnl LMN             Set new line mode                      <ESC>[20h
;setwrap DECAWM        Set auto-wrap mode                     <ESC>[?7h
;------------------------------------------------------------------------------
;reset terminal modes
;------------------------------------------------------------------------------
;setlf LMN             Set line feed mode                     <ESC>[20l
;resetwrap DECAWM      Reset auto-wrap mode                   <ESC>[?7l
;------------------------------------------------------------------------------
; Not Supported:
; faint attribute - slow/fast blink / Font changes - All attributes > 50 
;------------------------------------------------------------------------------

ORG $F4c6

;*******************************************************************************
; Print the string referenced in DE
;******************************************************************************
PRINTSTRING:
; Fetch the next character, 0 terminates
ps_loop:
	LD A,(DE)
	CP 0	  ;$0 terminates
	RET Z

    CP $18    ; CANCEL character,Cancel escape without error.
    JR NZ, ANSITERM_NOTCANCEL
    XOR A
    LD (TERMINALBUFFER),A                 ; Next character in buffer = 1
    JR ANSITERM_CONTINUE
ANSITERM_NOTCANCEL:
    CP $1A    ; SUBSTITUTE character, Cancel any escape with error
    JR Z, ANSITERM_ERROR
; Check if we are in an escape sequence..
    LD IX,TERMINALVARS
    LD A,(TERMINALBUFFER)
    CP 0
    JR NZ,ANSITERM_IN_ESCAPE
;Re-fetch the character and see if its the start of an escape sequence
	LD A,(DE)
    CP $1B
    JR Z,ANSITERM_STARTESCAPE
;Ok, just display the character
    CALL DISPLAYANSICHAR_A
ANSITERM_CONTINUE:
;Next character
	INC DE
    JR ps_loop

;*******************************************************************************
;Start the escape
;*******************************************************************************
ANSITERM_STARTESCAPE: 
    LD HL,TERMINALBUFFER
    LD (HL),1                 ; Next character in buffer = 1
    INC HL
    LD (HL),0                 ; Set the terminator in the buffer
    JR ANSITERM_CONTINUE
;*******************************************************************************
;Waiting for the end of an escape. This is a letter
;*******************************************************************************
ANSITERM_IN_ESCAPE:
    LD A,(DE)
;check if the character and see if its a letter (Or '#') (These terminate escapes)
    CALL ANSITERM_IS_CHAR
    PUSH DE
    JR C, ANSITERM_DECODE_ESCAPE 
    POP DE
    EX AF,AF'
    LD A,(TERMINALBUFFER)
;Check for the special case of beginning with numbers 7 or 8   
    CP 1
    JR NZ, ANSITERM_INESCAPE_NOTSPECIAL
    PUSH DE
    EX AF,AF'
    CP $37 
    JP Z,ANSITERM_STORE_CURSOR
    CP $38
    JP Z,ANSITERM_RESTORE_CURSOR
    EX AF,AF'
    POP DE
;Next check if we have space in the buffer?
ANSITERM_INESCAPE_NOTSPECIAL:
    CP 10
    JR NC, ANSITERM_ERROR
;Now put the character in the buffer
    LD HL, TERMINALBUFFER
    LD B,0
    LD C,A
    ADD HL,BC
    EX AF,AF'
    LD (HL),A
    INC HL
    LD (HL),0
; and update the next location
    LD A,(TERMINALBUFFER)
    INC A
    LD (TERMINALBUFFER),A
;Next character
    JR ANSITERM_CONTINUE

;*******************************************************************************
; Escape code error
;*******************************************************************************
ANSITERM_ERROR:
;Reset the escape code  
    XOR A
    LD (TERMINALBUFFER),A
;Output "?" character
    LD A,$3f   ; '?'
    CALL DISPLAYANSICHAR_A
;Next character
    JR ANSITERM_CONTINUE

;*******************************************************************************
;Decode an escape string
; A = last character (Operation)
;*******************************************************************************
ANSITERM_DECODE_ESCAPE:
    CP $6D             ; "m" for <ESC>[xm (Set textattributes)
    JP Z,ANSITERM_SET_ATTR
    CP $4A             ; "J" for <ESC>[xJ (Clear part/full screen)
    JP Z,ANSITERM_CLR_SCREEN 
    CP $4B             ; "K" for <ESC>[xK (Clear part/full line)
    JP Z,ANSITERM_CLR_LINE
    CP $48             ; "H" for <ESC>[x,yH (Move cursor)
    JP Z,ANSITERM_SET_CURSOR
    CP $66             ; "f" for <ESC>[x,yf (Move cursor)
    JP Z,ANSITERM_SET_CURSOR
    CP $63             ; "c" for <ESC>c ; Hard Reset terminal state
    JP Z,ANSITERM_RESET_TERMINAL
    CP $70             ; "p" for <ESC>c ; Soft Reset terminal state
    JP Z,ANSITERM_RESET_TERMINAL
    CP $41             ; "A" for <ESC>[nA ; Cursor up N lines
    JP Z,ANSITERM_CURSOR_UP
    CP $42             ; "B" for <ESC>[nB ; Cursor down N lines
    JP Z,ANSITERM_CURSOR_DOWN
    CP $43             ; "C" for <ESC>[nC ; Cursor Right N lines
    JP Z,ANSITERM_CURSOR_RIGHT
    CP $44             ; "D" for <ESC>[nD ; Cursor Left N lines
    JP Z,ANSITERM_CURSOR_LEFT
    CP $45             ; "E" for <ESC>[nE ; Cursor Down N lines and start line
    JP Z,ANSITERM_CURSOR_DOWN_NL
    CP $46             ; "F" for <ESC>[nF ; Cursor Up N line  and start line
    JP Z,ANSITERM_CURSOR_UP_NL
    CP $47             ; "G" for <ESC>[nG ; Move to the given column
    JP Z,ANSITERM_CURSOR_TO_COL
    CP $23             ; "#" for <ESC>[#x ; Single/Dbl height
    JP Z,ANSITERM_TEXT_HEIGHT
    CP $73             ; "s" for <ESC>[s ; Store cursor
    JP Z,ANSITERM_STORE_CURSOR
    CP $75             ; "u" for <ESC>[u ; Restore cursor
    JP Z,ANSITERM_RESTORE_CURSOR
    CP $4D             ; "M" for <ESC>[M ; scroll down
    JP Z,ANSITERM_SCROLL_DOWN
    CP $68             ; "h" for <ESC>[xh; 20=Set NL mode, ?7 = set auto-wrap           
    JP Z,ANSITERM_SET_MODE  
    CP $6C             ; "l" for <ESC>[xl; 20=Set LF mode, ?7 = reset auto-wrap           
    JP Z,ANSITERM_RESET_MODE
    POP DE
    JR ANSITERM_ERROR
;*******************************************************************************
; A = character 
; Carry = yes if A-Z
; No registers corrupted.
;*******************************************************************************
ANSITERM_IS_CHAR:
;A-Z?
    CP $23  
    JR Z, PC_UC_ISHASH
    CP $41
    JR C, ANSITERM_UC_NOTAZ
    CP $5B 
    RET C
;a-z?
    CP $61
    JR C, ANSITERM_UC_NOTAZ
    CP $7B
    RET C
ANSITERM_UC_NOTAZ:
    SCF
    CCF
    RET
PC_UC_ISHASH:
    SCF
    RET
;*******************************************************************************
; Get the Integer at HL. terminated by either a ";" or #0
; On Enter:
;   HL = address
; On Exit:
;   C=1 of not end of string, C=0 End of string encountered
;   HL=Address of the character after the seperator
;   B=Decoded integer
; Corrupted: 
;   AF,BC,HL
;*******************************************************************************
ANSITERM_GET_INTEGER:
    LD BC,0   ; B(total) = 0, C(Return value) = 0
ANSITERM_GET_INT_LOOP:
    LD A,(HL)                       ; Fetch the byte
    INC HL                          ; Point at the next byte
    CP 0                            ; Is it an EOF?
    RET Z                           ; If so just return with C=0
    CP $3B ; ";"                    ; Terminator char?
    JR Z, ANSITERM_GET_INT_NOT_FINISHED   ; If yes, finish with C=1
    CP $3F ; "?"
    JR Z,ANSITERM_GET_INT_LOOP
    CP $30                          ; Check to see if the character >="0"
    JP C, ANSITERM_ERROR                  ; Error if not
    CP $3A                          ; Character < ("9"+1) ?
    JP NC, ANSITERM_ERROR                 ; Error if not
;Character is is in the range "0".."9", Add it in to the total
    PUSH DE                         ; Preserve DE
    SUB A, $30                      ; Convert "0".."9" to 0-9
    LD E,A                          
; Multiply B by 10 = (B * 8) + (B * 2)
    LD A,B
    ADD A,A   ;x2
    LD D,A                          ; D = B * 2
    ADD A,A   ;x4
    ADD A,A   ;x8                   ; D = B * 8
    ADD D                           ; So D = B*10
;Add in new byte to the total. 
    ADD E
    LD B,A
; Next byte
    POP DE
    JR ANSITERM_GET_INT_LOOP

;Called if a seperator is found.
ANSITERM_GET_INT_NOT_FINISHED:
    LD C,1
    RET

;*******************************************************************************
; Decode the <ESC>[xM Where X can have multiple values. Eg <ESC>[2;3;4m
;*******************************************************************************
ANSITERM_SET_ATTR:
; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
    INC HL                          ; Next char
ANSITERM_SETATTR_DECODE_LOOP: 
    CALL ANSITERM_GET_INTEGER             ;Get the integer 
    PUSH BC                         ;Preserve the C register (Last number) as we will need it later
    LD A,B                          ;Get the Read Value into A
;*******************************************************************************
; This is where we decode the individual values
    CP 0                            ; 0 = Reset all attributes
    JR NZ, ANSITERM_SETATTR_DECODE_SKIP1          ; Nope?
    LD (IX+2), 0                    ; Reset the font attribute flags
    LD (IX+4), $38                  ; Reset the colours to Black on white
ANSITERM_SETATTR_DECODE_SKIP1:
    CP 1                            ; 1 = Bold           
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP2           ; Nope?
    SET 4,(IX+2)                    ; Set the flag in the Font attribute bytes       
ANSITERM_SETATTR_DECODE_SKIP2:
    CP 2                            ; 2 = not Bold           
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP3           ; Nope?
    RES 4,(IX+2)                    ; Set the flag in the Font attribute bytes       
ANSITERM_SETATTR_DECODE_SKIP3:
    CP 3                            ; 3 = Italic
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP4           ; Nope?
    SET 3,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP4:
    CP 4                            ; 4 = Underscore
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP5           ; Nope?
    SET 0,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP5:
    CP 7                            ; 7 = inverse
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP6           ; Nope?
    SET 1,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP6:
    CP 8                            ; 8 = Hidden
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP7           ; Nope?
    SET 7,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP7:
    CP 9                            ; 9 = Strikeout
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP8           ; Nope?
    SET 2,(IX+2)                    ; Set the flag in the Font attribute bytes
; **************************Turn off functions
ANSITERM_SETATTR_DECODE_SKIP8:
    CP 21                           ; 21 = Bold off
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP9           ; Nope?
    RES 4,(IX+2)                    ; reset the flag in the Font attribute bytes       
ANSITERM_SETATTR_DECODE_SKIP9:
    CP 22                           ; 22 = Normal intensity
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP10          ; Nope?
    RES 4,(IX+2)                    ; reset the flag in the Font attribute bytes       
ANSITERM_SETATTR_DECODE_SKIP10:
    CP 23                           ; 23 = not Italic
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP11          ; Nope?
    RES 3,(IX+2)                    ; reset the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP11:
    CP 24                            ; 24 = not Underscore
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP12          ; Nope?
    RES 0,(IX+2)                    ; reset the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP12:
    CP 27                            ; 27 = not inverse
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP13          ; Nope?
    RES 1,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP13:
    CP 28                            ; 28 = not Hidden
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP14          ; Nope?
    RES 7,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP14:
    CP 29                            ; 29 = not Strikeout
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP15          ; Nope?
    RES 2,(IX+2)                    ; Set the flag in the Font attribute bytes
ANSITERM_SETATTR_DECODE_SKIP15:
    CP 49                           ; 49 = Default background colour
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP16          ; Nope?
    LD A,(IX+4)
    OR %00111000
    LD (IX+4),A
    JR ANSITERM_SETATTR_DECODE_SKIP_COLOURS
ANSITERM_SETATTR_DECODE_SKIP16:
    CP 39                           ; 39 = Default foreground colour
    JR NZ,ANSITERM_SETATTR_DECODE_SKIP17          ; Nope?
    LD A,(IX+4)
    AND %11111000               
    LD (IX+4),A
    JR ANSITERM_SETATTR_DECODE_SKIP_COLOURS 
ANSITERM_SETATTR_DECODE_SKIP17:
;*******************************************************************************
; Colour flags
; Foreground (INK) colour 30-37?
    CP 30                           ; 30 or above?
    JR C, ANSITERM_SETATTR_DECODE_SKIP_COLOURS    ; Nope?
    CP 38                           ; Below 38?
    JR NC, ANSITERM_SETATTR_DECODE_SKIP_FG         ; Nope?
    PUSH AF                         ; Preserve A as we need to do math...
    SUB 30                          ; Convert 30-37 to 0-7
    PUSH DE                         ; Preserve DE
    LD D,A                          ; A = colour value
    LD A,(IX+4)                     ; Get current attribute byte
    AND %11111000                   ; Mask out the old INK value
    OR D                            ; Merge in the new INK value
    LD (IX+4),A                     ; and put it back.
    POP DE                          ; Restore preserved values.
    POP AF
    JR ANSITERM_SETATTR_DECODE_SKIP_COLOURS       ; and just skip the next bit.
; Background (PAPER) colour 40-47?
ANSITERM_SETATTR_DECODE_SKIP_FG:
    CP 40                           ; 40 or above?
    JR C, ANSITERM_SETATTR_DECODE_SKIP_COLOURS          ; Nope?
    CP 48                           ; Below 48?
    JR NC, ANSITERM_SETATTR_DECODE_SKIP_COLOURS         ;Nope?
    PUSH AF                         ; Preserve AF and DE for math
    PUSH DE
    SUB 40                          ; Convert 40-47 to 0-7
    RLA                             ; 00000xxx -> 00xxx000
    RLA
    RLA
    AND %00111000                   ; Mask out the value
    LD D,A                          ; And keep for later
    LD A,(IX+4)                     ; Get current attribute byte
    AND %11000111                   ; Mask out the old PAPER value
    OR D                            ; Merge in the new PAPER value
    LD (IX+4),A                     ; and put it back
    POP DE                          ; Restore preserved values.
    POP AF
ANSITERM_SETATTR_DECODE_SKIP_COLOURS:
    POP BC                          ; and get C (Final character flag)
    XOR A                           ; Is it 0?
    CP C
    JP NZ,ANSITERM_SETATTR_DECODE_LOOP            ; If not,go back for the next value.
; End of the loop
PD_SET_ATTR_END:
    POP DE                          ; Restore DE
    XOR A
    LD (TERMINALBUFFER),A           ; Reset the cache pointer
    JP ANSITERM_CONTINUE                  ; and back to the main loop

;*******************************************************************************
; Decode the <ESC>[xJ  Eg <ESC>[2J
;*******************************************************************************
ANSITERM_CLR_SCREEN:
; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
    INC HL                          ; Next char
CS_DECODE_LOOP: 
    CALL ANSITERM_GET_INTEGER             ;Get the integer 
    LD A,B                          ;Get the Read Value into A
; This is where we decode the individual values
    PUSH BC
    PUSH DE
    PUSH HL
    CP 0
    JR Z, CS_CLS_CURSOR_DOWN
    CP 1    
    JR Z, CS_CLS_CURSOR_UP
    CP 2
    JR Z, CS_CLS_ALL
CS_DECODE_SKIP:
    POP HL
    POP DE
    POP BC                          ; and get C (Final character flag)
    XOR A                           ; Is it 0?
    CP C
    JP NZ,CS_DECODE_LOOP            ; If not,go back for the next value.
; End of the loop
    JP PD_SET_ATTR_END
;******************************************************************************
; Clear from the cursor DOWN
CS_CLS_CURSOR_DOWN:
    LD L,(IX+0); X
    LD H,(IX+1); Y
    LD C,(IX+2); Flags
    LD B,(IX+4); Colour

CS_CLS_CURSOR_DOWN_LOOP:
    LD A,$20 ; space
    PUSH BC
    PUSH HL
    CALL DISPLAYCHAR
    POP HL
    POP BC
    INC L
    LD A,42
    CP L
    JR NZ,CS_CLS_CD_1
    LD L,0
    INC H
CS_CLS_CD_1:
    LD A,24
    CP H
    JR NZ,CS_CLS_CURSOR_DOWN_LOOP
    JR CS_DECODE_SKIP
;******************************************************************************
; Clear from the cursor UP
CS_CLS_CURSOR_UP:
    LD L,(IX+0); X
    LD H,(IX+1); Y
    LD C,(IX+2); Flags
    LD B,(IX+4); Colour
CS_CLS_CURSOR_UP_LOOP:
    LD A,$20 ; space
    PUSH BC
    PUSH HL
    CALL DISPLAYCHAR
    POP HL
    POP BC
    DEC L
    JP P,CS_CLS_UP_1
    LD L,41
    DEC H
CS_CLS_UP_1:
    JP P,CS_CLS_CURSOR_UP_LOOP
    JR CS_DECODE_SKIP
;******************************************************************************
; Clear all screen
; We can use a slightly more efficient method for this bypassing DISPLAYCHAR.
;******************************************************************************
CS_CLS_ALL:
    LD HL,$4000
    LD DE,$4001
    LD BC,$17ff
    LD (HL),$00             ; all bits off
    BIT 1, (IX+2)           ; inverse flag?
    JR Z,CS_CLS_ALL_SKIP
    LD (HL), $FF            ; set all bits on.
CS_CLS_ALL_SKIP:
    LDIR
;Sort out attributes
    LD HL, $5800
    LD DE, $5801
    LD BC, $2ff
    LD A,(IX+4)             ; Current terminal attributes
    LD (HL),A
    LDIR
    JR CS_DECODE_SKIP

;*******************************************************************************
; Decode the <ESC>[xK  Eg <ESC>[2K
;*******************************************************************************
ANSITERM_CLR_LINE:
; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
    INC HL                          ; Next char
CL_CLR_LINE_DECODE_LOOP: 
    CALL ANSITERM_GET_INTEGER       ; Get the integer 
    LD A,B                          ; Get the Read Value into A
; decode the individual values (0,1,2)
    PUSH BC
    PUSH DE
    PUSH HL
    CP 0
    JR Z, CL_CLS_CURSOR_EOL
    CP 1    
    JR Z, CL_CLS_CURSOR_SOL
    CP 2
    JR Z, CL_CLS_LINE
CL_DECODE_SKIP:
    POP HL
    POP DE
    POP BC                          ; and get C (Final character flag)
    XOR A                           ; Is it 0?
    CP C
    JR NZ,CL_CLR_LINE_DECODE_LOOP   ; If not,go back for the next value. 
; End of the loop
    JP PD_SET_ATTR_END

;******************************************************************************
; delete a line from the current position to EOL
;******************************************************************************
CL_CLS_CURSOR_EOL:
    LD L,(IX+0); X
    LD H,(IX+1); Y
    LD C,(IX+2); Flags
    LD B,(IX+4); Colour

CL_CLS_CURSOR_EOL_LOOP:
    LD A,$20 ; space
    PUSH BC
    PUSH HL
    CALL DISPLAYCHAR
    POP HL
    POP BC
    INC L
    LD A,42
    CP L
    JR NZ,CL_CLS_CURSOR_EOL_LOOP
    JP CL_DECODE_SKIP
;******************************************************************************
; delete a line from the current position to SOL
;******************************************************************************
CL_CLS_CURSOR_SOL:
    LD L,(IX+0); X
    LD H,(IX+1); Y
    LD C,(IX+2); Flags
    LD B,(IX+4); Colour

CL_CLS_CURSOR_SOL_LOOP:
    LD A,$20 ; space
    PUSH BC
    PUSH HL
    CALL DISPLAYCHAR
    POP HL
    POP BC
    DEC L           ; If L is still Positive, go again
    JP P, CL_CLS_CURSOR_SOL_LOOP
    JP CL_DECODE_SKIP
;******************************************************************************
CL_CLS_LINE:
;******************************************************************************
    LD L,41    ; X
    LD H,(IX+1); Y
    LD C,(IX+2); Flags
    LD B,(IX+4); Colour

CL_CLS_LINE_LOOP:
    LD A,$20 ; space
    PUSH BC
    PUSH HL
    CALL DISPLAYCHAR
    POP HL
    POP BC
    DEC L                   ; If L is still Positive, go again
    JP P, CL_CLS_LINE_LOOP
    JP CL_DECODE_SKIP

;******************************************************************************
; Set the cursor location. This can have up to 2 parameters, Y and X These default to 0
;******************************************************************************
ANSITERM_SET_CURSOR:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
    INC HL                          ; Next char
    PUSH BC
   ;Try to get an integer 
    CALL ANSITERM_GET_INTEGER 
    LD (IX+0),0
    LD (IX+1),B
   ;See if there is a second one
    XOR A
    CP C    
    JR Z, ANSITERM_SET_CURSOR_SKIP
    CALL ANSITERM_GET_INTEGER 
    LD (IX+0),B
ANSITERM_SET_CURSOR_SKIP:
    POP BC
    JP PD_SET_ATTR_END
;******************************************************************************
; Reset the terminal Set 0,0, reset attributes, clear screen
;******************************************************************************
ANSITERM_RESET_TERMINAL:
    LD (IX+0),0 ; X = 0
    LD (IX+1),0 ; Y = 0
    LD (IX+2),0 ; Display flags = 0
    LD (IX+3),0 ; Terminal flags = 0
    LD (IX+4),%00111000 ; Black on white
    LD HL,$4000
    LD DE,$4001
    LD BC,$17ff
    LD (HL),$00
    LDIR
    LD HL, $5800
    LD DE, $5801
    LD BC, $2ff
    LD (HL), %00111000 ; Black on white
    LDIR
    JP PD_SET_ATTR_END
    
;******************************************************************************
; Cursor up N lines
;******************************************************************************

ANSITERM_CURSOR_UP:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
ANSITERM_CURSOR_UP_NOTBRACKET:
    INC HL                          ; Next char
   ;Try to get an integer 
    CALL ANSITERM_GET_INTEGER      
    XOR A                           ;Zero or blank should just be made to 1
    CP B
    JR NZ,ANSITERM_CURSORUP_DONTINC
    INC B
ANSITERM_CURSORUP_DONTINC:
    LD A,(IX+1)
    SUB B
    JP P,ANSITERM_CURSOR_UP_SKIP
    XOR A
ANSITERM_CURSOR_UP_SKIP:
    LD (IX+1),A
    JP PD_SET_ATTR_END
;******************************************************************************
; Cursor down N lines
;******************************************************************************

ANSITERM_CURSOR_DOWN:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
ANSITERM_CURSORDOWN_NOTBRACKET:
    INC HL                          ; Next char
   ;Try to get an integer 
    CALL ANSITERM_GET_INTEGER 
    XOR A
    CP B
    JR NZ,ANSITERM_CURSORDOWN_DONTINC
    INC B
ANSITERM_CURSORDOWN_DONTINC:
    LD A,(IX+1)
    ADD B
    CP 24
    JR C,ANSITERM_CURSOR_DOWN_SKIP
    LD A,23
ANSITERM_CURSOR_DOWN_SKIP:
    LD (IX+1),A
    JP PD_SET_ATTR_END
;******************************************************************************
; Cursor right N lines
;******************************************************************************

ANSITERM_CURSOR_RIGHT:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
    INC HL                          ; Next char
   ;Try to get an integer 
    CALL ANSITERM_GET_INTEGER 
    XOR A
    CP B
    JR NZ,ANSITERM_CURSORRIGHT_DONTINC
    INC B
ANSITERM_CURSORRIGHT_DONTINC:
    LD A,(IX+0)
    SUB B
    JR NC,ANSITERM_CURSOR_RIGHT_SKIP
    XOR A
ANSITERM_CURSOR_RIGHT_SKIP:
    LD (IX+0),A
    JP PD_SET_ATTR_END
;******************************************************************************
; Cursor down N lines
;******************************************************************************

ANSITERM_CURSOR_LEFT:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_SCROLL_UP              ; if not found, Its a scroll up
    INC HL                          ; Next char
   ;Try to get an integer 
    CALL ANSITERM_GET_INTEGER 
    XOR A
    CP B
    JP NZ,ANSITERM_CURSORLEFT_DONTINC
    INC B
ANSITERM_CURSORLEFT_DONTINC:
    LD A,(IX+0)
    ADD B
    CP 42
    JR C,ANSITERM_CURSOR_LEFT_SKIP
    LD A,41
ANSITERM_CURSOR_LEFT_SKIP:
    LD (IX+0),A
    JP PD_SET_ATTR_END
;******************************************************************************
; Cursor down N lines and start of line.
;******************************************************************************

ANSITERM_CURSOR_DOWN_NL:
    LD (IX+0),0
    LD HL,TERMINALBUFFER            ; Start of buffer
    JR ANSITERM_CURSORDOWN_NOTBRACKET;
;******************************************************************************
; Cursor Up N lines and start of line.
;******************************************************************************

ANSITERM_CURSOR_UP_NL:
    LD (IX+0),0
    LD HL,TERMINALBUFFER            ; Start of buffer
    JP ANSITERM_CURSOR_UP_NOTBRACKET;
;******************************************************************************
; Move the cursor to the stated column
;******************************************************************************

ANSITERM_CURSOR_TO_COL:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR                  ; if not found, error out.
    INC HL                          ; Next char
   ;Try to get an integer 
    CALL ANSITERM_GET_INTEGER 
    LD (IX+0),B 
    LD A,41
    CP B
    JP NC,PD_SET_ATTR_END
    LD (IX+0),41
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_TEXT_HEIGHT:
;******************************************************************************
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    POP DE
    INC DE
    PUSH DE
    LD A,(DE)
    CP $33      ; Double height - top
    JR NZ, ANSITERM_TEXT_HEIGHT1
    SET 5,(IX+2)                    ; Set "Upper" flag in the Font attribute bytes
    RES 6,(IX+2)                    ; Reset "Lower" flag in the Font attribute bytes
ANSITERM_TEXT_HEIGHT1:
    CP $34      ; Double height - bottom
    JR NZ, ANSITERM_TEXT_HEIGHT2
    RES 5,(IX+2)                    ; Reset "Upper" flag in the Font attribute bytes
    SET 6,(IX+2)                    ; Set "Lower" flag in the Font attribute bytes
ANSITERM_TEXT_HEIGHT2:
    CP $35      ; Normal
    JR NZ, ANSITERM_TEXT_HEIGHT3
    RES 5,(IX+2)                    ; Reset "Upper" flag in the Font attribute bytes
    RES 6,(IX+2)                    ; Reset "Lower" flag in the Font attribute bytes
ANSITERM_TEXT_HEIGHT3:
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_STORE_CURSOR:              ;Copy the current location to the cursor store
    LD A,(IX+0)
    LD (IX+5),A
    LD A,(IX+1)
    LD (IX+6),A
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_RESTORE_CURSOR:            ;Copy the cursor store back to the current location
    LD A,(IX+5)
    LD (IX+0),A
    LD A,(IX+6)
    LD (IX+1),A
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_SCROLL_UP:
    LD A,(IX+4)
    CALL SCROLL_UP
    DEC (IX+6)
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_SCROLL_DOWN:
    LD A,(IX+4)
    CALL SCROLL_DOWN
    INC (IX+6)
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_SET_MODE:  
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR            ; if not found, error out.
;Check if the second char is "?" and skip it if so.
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $3F
    JR NZ,ANSITERM_SET_MODE1
    INC HL
ANSITERM_SET_MODE1:
    CALL ANSITERM_GET_INTEGER
    LD A,B
    CP 20   ;newline mode
    JR NZ,ANSITERM_SET_MODE2
    RES 1,(IX+3)
ANSITERM_SET_MODE2:
    CP 7    ;auto-wrap mode
    JR NZ,ANSITERM_SET_MODE3
    RES 0,(IX+3)
ANSITERM_SET_MODE3:
    JP PD_SET_ATTR_END
;******************************************************************************
ANSITERM_RESET_MODE:
    ; Sanity check, First character should be "["
    LD HL,TERMINALBUFFER            ; Start of buffer
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $5b  ; "["                   ; Check for "["
    JP NZ,ANSITERM_ERROR            ; if not found, error out.
;Check if the second char is "?" and skip it if so.
    INC HL                          ; Get char
    LD A,(HL)                       
    CP $3F
    JR NZ,ANSITERM_RES_MODE1
    INC HL
ANSITERM_RES_MODE1:
    CALL ANSITERM_GET_INTEGER
    LD A,B
    CP 20                           ;newline mode
    JR NZ,ANSITERM_RES_MODE2
    SET 1,(IX+3)
ANSITERM_RES_MODE2:
    CP 7                            ;auto-wrap mode
    JR NZ,ANSITERM_RES_MODE3
    SET 0,(IX+3)
ANSITERM_RES_MODE3:
    JP PD_SET_ATTR_END

;******************************************************************************
; This is called each 50'th of a second to flash the cursor. It inverts every 50/16th Sec
;******************************************************************************
CURSOR_INTERRUPT:   
    LD A, (IX+7)            ; Get the current counter
    AND %11110000           ; Mask out the counter
    ADD %00010000           ; subtract 1 from the counter
    JR NZ, CI_DONTINVERT    ; skip If it doesnt roll over.
; At this stage, we need to invert the current character at the cursor      
    LD L,(IX+0); X          ; Get the cursor location
    LD H,(IX+1); Y
    LD A, (IX+3)
    AND %00000001           ; Mask the "Cursor type" bit from the counter flag
    CALL INVERTCHAR         ; Do it
    LD A, (IX+3);           ; invert the "Cursor being displayed" flag
    XOR %00001000           
    LD (IX+3), A
CI_DONTINVERT:
    LD A, (IX+7)            ;Subtract one from the counter
    ADD %00010000
    LD (IX+7), A
    RET
    
include "terminal/basictext.asm"

;*******************************************************************************
; BasicText.asm
;   This unit contains a very basic terminal with 24x42. Handles EOL, Scrolling.
; Supported characters:
;   \b (0x07) - Bell
;   ?  (0x08) - Backspace - Back one chacter to Start of line.
;   \t (0x09) - Tab to the next column (Tabs are currently always 8)
;   \r (0x0a) - if Bit 1,(IX+3)=0, Next line+Start of line, else just next line
;   \n (0x0d) - Go to the start of the line
;   ?  (0x7f) - Delete character
;   ?  (0x0b, 0x0c) VT and FF treated as LF (0x0a) as per Vt-100.
;*******************************************************************************
;include "terminal/const.i"
;ORG $F9d0

TERMINALBUFFERSIZE: equ 10
;*******************************************************************************
; Storage for one terminal session
; Note, some of these are placeholders for ANSI emulation. (*)
;*******************************************************************************
TERMINALVARS:
CURSORLOC:
    defb 0  ; x
    defb 0  ; y
    defb 0  ; currently set display flags as passed into DISP
    defb 0  ; bit 0 = wrap mode (0=yes, 1=no) 
            ; bit 1 = CR mode (0=cr, 1=crlf)
            ; bit 2 = Caps lock (0=off, 1=on)
            ; bit 3 = Cursor invert state 
    defb %00111000 ; Attribute byte
    defb 0  ; Stored X (Save cursor command) (*)
    defb 0  ; Stored Y (Save cursor command) (*)
    defb 0  ; CursorCounter bit 4-7: Cursor counter ; Bit 0 = cursor mode (0 = block, 1 = underline)
TERMINALBUFFER:
    defb 0  ; Pointer to the next entry in terminalbuffer
;         0123456789 ; Storage for when decoding escape characters
    defs TERMINALBUFFERSIZE,0

;*******************************************************************************
; Same as DISPLAYANSICHAR but preserves registers
;*******************************************************************************
DISPLAYANSICHAR_A:
    PUSH BC
    PUSH DE
    PUSH HL
    PUSH AF
    CALL DISPLAYANSICHAR
    POP AF
    POP HL
    POP DE
    POP BC
    RET
;*******************************************************************************
; Print the character in A
; IX = terminal variables
; Supports \b \t \n \r
;*******************************************************************************
DISPLAYANSICHAR:
;Undo the cursor
    PUSH AF
    CALL DC_UndoCurrentCursor
    POP AF
DISPLAYCHAR_SKIP_UNDOCURSOR:
;Display the character
    CP 32               ;Characters below 32 are control codes
    JR C,DC_CONTROLCODE
    CP $7F              ;Special case for character 127 (delete)
    JR Z,DC_DELETE
    LD L,(IX+0); X
    LD H,(IX+1); Y
    LD C,(IX+2); Flags
    LD B,(IX+4); Colour
    PUSH HL
	CALL DISPLAYCHAR
    POP HL
;Point to next character in string and Move cursor along one character
	INC L
; Line wrapping:
;Check for EOL and wrap if required
PS_CHECKLINEWRAP:
    LD A,41
    CP L
    JR NC,PS_WRAPDONE
;Check for the line wrap mode
    BIT 0,(IX+3) ;Check for line  wrap.
    JR Z, PS_LINERAP
; No line wrap - Just set to last character
    DEC L
    JR PS_WRAPDONE
PS_LINERAP:
; Do a line wrap...
    LD L,0  ;x=0
    INC H   ;Next line
; Last line?
    LD A,24
    CP H
    JR NZ,PS_WRAPDONE
    LD A,(IX+4)
    CALL DC_SC_UP
    DEC H
;Update the Cursor location.
PS_WRAPDONE:
    LD (IX+0),L
    LD (IX+1),H
	RET
;Control codes
DC_CONTROLCODE:
    CP 7 ; BEL
    JP Z,DC_BELL            ; Bell
    CP 8 ;
    JR Z,DC_BACKSPACE       ; Backspace
    CP 9 ; 
    JR Z,DC_TAB             ; Tab
    CP 10 ; 
    JR Z,DC_LF              ; Linefeed
    CP 11 ;     
    JR Z,DC_LF              ; VT - treated as LF
    CP 12 ; 
    JR Z,DC_LF              ; FF - Treated as LF
    CP 13 ; 
    JR Z,DC_CR              ; CR
;Rest of the control codes unused
    RET

;*******************************************************************************
; delete the character
;*******************************************************************************
DC_DELETE:
    CALL DC_UndoCurrentCursor
DC_DONTUNDOCURSOR:
    CALL DC_BACKSPACE
    ;Now just display a space at that location.
    LD L,(IX+0)     ; X
    LD H,(IX+1)     ; Y
    LD C,(IX+2)     ; Flags
    LD B,(IX+4)     ; Colour
    LD A,32
   	JP DISPLAYCHAR

;*******************************************************************************
;*******************************************************************************
DC_UndoCurrentCursor:
    LD A,(IX+3)
    BIT 3,A
    RET Z
    RES 3,A
    ld (IX+3),A
    LD L,(IX+0); X          ; Get the cursor location
    LD H,(IX+1); Y
    LD A,(IX+3)
    JP INVERTCHAR         ; Do it
    
;*******************************************************************************
; Backspace
;*******************************************************************************
DC_BACKSPACE:
    LD A,(IX+0)
    CP 0    ;Dont backspace past 0
    RET Z
    DEC A
    LD (IX+0),A
    RET
;*******************************************************************************
; Carrage return
;*******************************************************************************
DC_CR:
    LD (IX+0),0; 
    RET
;*******************************************************************************
; Linefeed - if in LF mode (Unix mode), this does a CRLF. Else, just new line
;*******************************************************************************
DC_LF:
    ;newline
    LD L,(IX+0); X
    LD H,(IX+1); Y  
    INC H   ;Next line
; Last line?
    LD A,24
    CP H
    JR NZ,DC_LF_DONTSCROLL
    LD A,(IX+4)
    CALL DC_SC_UP
    DEC H
DC_LF_DONTSCROLL:
    BIT 1,(IX+3) 
    JR NZ,DC_LF_FINISHED
    LD L,0    
DC_LF_FINISHED:
    LD (IX+0),L
    LD (IX+1),H
    RET

;*******************************************************************************
; Tab - Move the cursor the the next multiple of 8
;*******************************************************************************
DC_TAB:
    LD HL,(CURSORLOC)    
    LD A,8
    ADD L
    AND %11111000
    LD (IX+0),A
    LD L,A
    JP PS_CHECKLINEWRAP

;*******************************************************************************
;Short beep along with making the border black.
;*******************************************************************************
DC_BELL:
    LD DE,30        ;length
    LD HL,122       ;frequency
   	LD A,(23624)    ;Get the original border colour and store it
    PUSH AF         ;
    XOR 56          ;reverse the border colour
   	LD (23624),A    ;and set it back for the duration of the beep
    CALL 949        ; Rom beeper
    POP AF          ;Restore the original border colour
   	LD (23624),A    ;
    AND 56          ;and OUT it.
    RRCA
    RRCA
    RRCA
    OR 8
    OUT ($FE),A
    RET
;*******************************************************************************
;*******************************************************************************
DC_SC_UP:
    CALL DC_UndoCurrentCursor
    DEC (IX+6)
    LD A,(IX+4)
    JP SCROLL_UP

include "terminal/scroll.asm"

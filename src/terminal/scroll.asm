;*******************************************************************************
; Scroll up one line. A contains attribute byte for new bottom.
; F corrupt. All other registers preserved.
;*******************************************************************************
SCROLL_UP: 
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF
    LD HL,$4020 ; Address of the second line
SCROLLUP_LINELOOP:
    PUSH HL
;Calculate the address of the next line up to DE.
    LD D,H
    LD A,L
    SUB $20
    LD E,A
    JR NC,SCROLLUP_NEXT
    LD A,D
    SUB 8
    LD D,A
SCROLLUP_NEXT:
    ;Copy the line from HL to DE
    CALL SCROLL_COPYLINE
    POP HL
;Point to the next line.
    LD A,L
    ADD $20
    LD L,A
    JR NC,SCROLLUP_LINELOOP
    LD A,H
    ADD 8
    LD H,A
;If we have reached $5800, we are done.
    CP $58
    JR Z,SCROLLUP_FINISH
    JR SCROLLUP_LINELOOP
SCROLLUP_FINISH:    
;Erase the bottom line.
    LD B,8
    LD HL,$50E0
SCROLLUP_EL_LOOP:
    PUSH BC
    LD D,H
    LD E,L
    INC DE
    LD BC,$001f
    LD (HL),0
    LDIR
    LD L,$E0
    INC H
    POP BC
    DJNZ SCROLLUP_EL_LOOP
;Scroll the attributes
    LD HL,$5820
    LD DE,$5800
    LD BC,$02E0
    LDIR
;Set the attribute line for the new blank line
    POP AF
    LD HL,$5AE0
    LD DE,$5AE1
    LD BC,$001f
    LD (HL),A
    LDIR
    POP BC
    POP DE
    POP HL
    RET

;*******************************************************************************
; Scroll down one line. A contains attribute byte for new top line.
; F corrupt. All other registers preserved.
;*******************************************************************************
SCROLL_DOWN:    
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF
    LD HL,$50C0 ; Address of the last line-1
SCROLLDOWN_LINELOOP:
    PUSH HL
;Calculate the address of the next line down to DE.
    LD D,H
    LD A,L
    ADD $20
    LD E,A
    CP 0
    JR NZ,SCROLLDOWN_NEXT
    LD A,$8
    ADD D
    LD D,A
SCROLLDOWN_NEXT:
;Copy the line from HL to DE
    CALL SCROLL_COPYLINE
    POP HL
;Point to the previous line.
    LD A,L
    SUB $20
    LD L,A
    JR NC,SCROLLDOWN_LINELOOP
    LD A,H
    SUB 8
    LD H,A
;If we are now below $4000, we are done.
    CP $40
    JR C,SCROLLDOWN_FINISH
    JR SCROLLDOWN_LINELOOP
SCROLLDOWN_FINISH:
;Erase the top line.
    LD B,8
    LD HL,$4000
SCROLLDOWN_EL_LOOP:
    PUSH BC
    LD D,H
    LD E,L
    INC DE
    LD BC,$001f
    LD (HL),0
    LDIR
    LD L,0
    INC H
    POP BC
    DJNZ SCROLLDOWN_EL_LOOP
;Scroll the attributes
    LD HL,$5ADF
    LD DE,$5AFF
    LD BC,$02E0
    LDDR
;Set the attribute line for the new blank line
    POP AF
    LD HL,$5800
    LD DE,$5801
    LD BC,$001f
    LD (HL),A
    LDIR
    POP BC
    POP DE
    POP HL
    RET
    

;*******************************************************************************
;Copy one line from HL to DE
; AF, BC, DE, HL corrupt.
;*******************************************************************************
SCROLL_COPYLINE:
    LD C,8                  ;Pixel lines to copy
SCROLL_COPY_PXLINE_LOOP1:
    LD B,32                 ;Bytes in a line
    PUSH HL
    PUSH DE
SCROLL_COPY_PXLINE_LOOP:    
    LD A,(HL)               ;Copy byte
    LD (DE),A
    INC L                   ;Next byte in src   (Note, only inc LSB as pixel lines dont straddle bytes)
    INC E                   ;Next byte in dest
    DJNZ SCROLL_COPY_PXLINE_LOOP
    POP DE                  ; Get the details back
    POP HL
    INC H                   ;Point at the next line (src)
    INC D                   ;Next line (target) 
    DEC C                   ;Pixel Line counter
    JR NZ,SCROLL_COPY_PXLINE_LOOP1
    RET 

include "terminal/charout.asm"

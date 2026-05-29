;*******************************************************************
;* Terminal initialisiaton                                         *
;*                                                                 *
;* Note, if you must call TERMINAL_DISABLE before returning to     *
;*        128/+3 Basic OR using +3DOS, as the first thing it does  *
;*        is page out the interrupt code, which isnt ideal.        *
;*                                                                 *
;* The following memory is used:                                   *
;*        f100-f201 - Interrupt vector table                       *
;*        f0f0-f0f4 - Jump to interrupt                            *
;*                                                                 *
;* IM2 notes for the speccy:                                       *
;*   As you cant guarantee the bus content during the interrupt    *
;*   response (As there is nothing to actually reply to an IM2),   *
;*   your interrupt table has to be populated from 00 to 100       *
;*   and must therefore be a doubled byte, Eg, F0F0 A0A0 ect.      *
;*                                                                 *
;*   Here, we have chosen F100-F200 for the interrupt table        *
;*   and F0F0 for the interrupt location to waste least memory.    *
;*   (The space from F201-F23b and F0F4-F0FF remains free).        *
;*                                                                 *
;*   on the +2A/+3 with the +3E roms, which is is initially aimed  *
;*   at, We could probably get away with just populating F0FF and  *
;*   F100, as the bus is always $FF, but may cause issues on       *
;*   things like the Harlequin 128 with the +3E roms which can     *
;*   implement floating bus for better 48k compatibility.          *
;*                                                                 *
;*   As noted above, this must be disabled whenver the top page is *
;*   changed for any reason (EG, disk operation, or return to      *
;*   128/+3 basic), and IM1 restored.                              *
;*   This is done by the TERMINAL_DISABLE function..               *          
;*                                                                 *
;*   This is of course not applicable to 48k machines which cant   *
;*   page out the upper ram.                                       *
;*******************************************************************
include "terminal/const.i"


INTERUPT_VECTORS:  equ $F100

ORG $F000
    JP TERMINAL_INIT         ;f000
    JP TERMINAL_DISABLE      ;f003
    JP TERMINAL_ENABLE       ;f006
    JP PRINTSTRING           ;f009
    JP GETNEXTCHAR           ;f00c
    JP RESET_KEYBOARD_BUFFER ;f00f
    JP SCROLL_UP             ;f012
    JP SCROLL_DOWN           ;f015
    JP GET_TERMINALVARS      ;f018
    JP DISPLAYANSICHAR_A     ;f01b

GET_TERMINALVARS:
    ld ix,TERMINALVARS
    ret

;*****************************************************************
; Perform the 50hz terminal interrupt, read the keyboard and 
; flash the cursor
;*****************************************************************
TERMINAL_INTERRUPT2:
    PUSH IX
    PUSH BC
    PUSH DE
    PUSH HL
    PUSH AF
    LD IX, TERMINALVARS
    LD A,(IX+3)     ;Get Caps lock value
    OR %11111011
    CALL KEYBOARD_INTERRUPT
    CALL CURSOR_INTERRUPT
    POP AF
    POP HL 
    POP DE
    POP BC
    POP IX    
    JP $38

;*****************************************************************\
; This code is copied to the Interrupt vector location
; (Currently F0F0) 
;*****************************************************************
TERMINAL_INTERRUPT:
    JP TERMINAL_INTERRUPT2

;*****************************************************************
; This will clear the terminal variables, including reset the
; keyboard buffer. It will then setup the interrupts required
; for the cursor.
;*****************************************************************
TERMINAL_INIT:
    LD HL,TERMINALVARS
    LD D,H
    LD E,L
    INC DE
    LD (HL),0
    LD BC,16
    LDIR
    LD IX, TERMINALVARS
    LD (IX+4),%00111000 ; Black on white
;Interrupts
; Setup the interrupt handler. This needs 256 bytes at $F100
; and an interrupt handler at $F0f0
    DI
    LD HL,INTERUPT_VECTORS
    LD A,H
    LD I,A
    LD (HL),$F0
    LD DE,INTERUPT_VECTORS+1
    LD BC,$0101
    LDIR
    LD HL,TERMINAL_INTERRUPT
    LD DE,$F0F0
    LD BC,3
    LDIR
    IM 2
    EI
    RET

;*****************************************************************
; Restore the old interrupt handler
;*****************************************************************
TERMINAL_DISABLE:
    IM 1
    RET
;*****************************************************************
; re-enable interrupt without wiping terminal state
;*****************************************************************
TERMINAL_ENABLE:
    LD A,$F1
    LD I,A
    IM 2
    EI
    RET    
;*****************************************************************

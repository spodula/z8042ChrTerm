;*******************************************************************************
;Raw key layout:
;    1  2  3  4  5    6  7  8  9  0
;    Q  W  E  R  T    Y  U  I  O  P 
;    A  S  D  F  G    H  J  K  L  Ent
;    CS Z  X  C  V    B  N  M  SS Spc
;Key codes: 
;    16 17 18 19 20   25 24 23 22 21
;    11 12 13 14 25   30 29 28 27 26
;    06 07 08 09 10   35 34 33 32 31
;    -- 02 03 04 05   40 39 38 -- 36
;Note, shift keys are not outputted by themselves but modify the resultant value
;CAPS = +40
;SYMB = +80
; Note, symbol shift has priority, so if both keys are pressed, you will get the
; SYMBOL shift variant. This is so CAPS LOCK functionality doesnt interfere
; with symbols.
;*******************************************************************************
ORG $F208
KEYBOARDBUFFER_WRITEPTR:
    defb 0  ; pointer to the next entry in the keyboard buffer
KEYBOARDBUFFER_READPTR:
    defb 0  ; pointer to the next entry to be read from the keyboard buffer
KEYBOARDBUFFER_REPCTR:
    defb 0  ; repeat counter
KEYBOARDBUFFER_LASTK:
    defb 0  ; last key pressed
KEYBOARDBUFFER:
    defs 256,0 ;keyboard buffer

;*******************************************************************************
;Key repeat variables. These are in 50ths/sec
;*******************************************************************************
KEY_INITIALDELAY: equ 20
KEY_REPEATDELAY:  equ 5

;*************************************************************************
; Extract the currently pressed key. 
; On Entry:
; On Exit:
;  A = key code OR 0
; BC, DE, HL, AF corrupted, all other registers preserved.
;*************************************************************************
GET_KEYBOARD:
    CALL GET_RAW_KEYBOARD
    CP 0
    RET Z
    DEC A
    LD HL,GKB_KEYBOARDTABLE
    LD C,A
    LD B,0
    ADD HL,BC
    LD A,(HL)
;Extra check for top row of caps shifted keys
    ld h,a
;Check for caps shift
    ld bc,$fefe
    in a,(c)
    bit 0,a
    jr nz,GKB_ENDOFKEYBOARD
;Check for 0-9
    ld a,h
    cp '0'
    jr c,GKB_ENDOFKEYBOARD
    cp '9'+1
    jr nc,GKB_ENDOFKEYBOARD
;Key in the range 0-9
    sub '0'
    ld e,a
    ld d,0
    ld hl,IMMEDIATE_TOP_ROW
    add hl,de
    ld h,(hl)
GKB_ENDOFKEYBOARD:
    ld a,h
    RET

;*************************************************************************
; Keyboard lookup table
;*************************************************************************
GKB_KEYBOARDTABLE:
;Unshifted characters
    defb " zxcv"
    defb "asdfg"
    defb "qwert"
    defb "12345"
    defb "09876"
    defb "poiuy"
    defb $0d,"lkjh"
    defb "  mnb"
;Symbol Shifted characters
    defb " ",":",$60,"?","/"
    defb $E2,$C3,$CD,$CC,$CB
    defb $C7,$C9,$C8,"<",">"
    defb "!","@","#","$","%"
    defb "_",")","(","'","&"
    defb $22,";",$AC,$C5,$C6
    defb " ","=","+","-",$5E
    defb " "," ",".",",","*"
;CAPS shifted characters
    defb " ZXCV"
    defb "ASDFG"
    defb "QWERT"
    defb "12345"
    defb "09876"
    defb "POIUY"
    defb $0d,"LKJH"
    defb $1b," MNB"

;***********************************************************************
;Immediate Caps shifted characters when caps shift is immediately pressed
;This is because even when CAPS-LOCK is enabled, these keys should still
;return 0-9 UNLESS caps shift is pressed.
;Order 0123456789 rather than port order as above
;*************************************************************************
IMMEDIATE_TOP_ROW:
    defb $7f  ;0 -> Delete
    defb $11  ;1 -> Edit (PF1)
    defb $12  ;2 -> Caps lock (PF2)
    defb "3"  ;3 -> no change
    defb "4"  ;4 -> no change
    defb $08  ;5 -> Left
    defb $10  ;6 -> Down
    defb $11  ;7 -> Up
    defb $09  ;8 -> Right
    defb "9"  ;9 -> no change
;*************************************************************************
; Extract the raw keyboard value. 
; On Entry: 
;  A = $FF caps lock
; On Exit:
;  A = raw key
;  B = inverted shifts (bit 0=Caps shift, Bit 1=Symbol shift)
; BC, DE, HL, AF corrupted, all other registers preserved.
;
; Shift keys will not be outputted as keycodes but used to modify the 
; keycode appropriately.
; This will be:
;   0 = No key pressed (Or just shifts)
;   1-40 (Unshifted) 
;  41-80 (Symbol shift)
;  81-120 (Caps shift)
; Note, if both shifts are pressed, SYMBOL shift will have the priority
;   If this is required for any reason, B will still register both.
;*************************************************************************
GET_RAW_KEYBOARD:
;extract the shift keys for later use.
    LD BC,$FEFE     ;CAPS shift port
    CP $FF
    JR NZ, GRK_DONTFORCECAPS
    LD D, %11111110
    JR GRK_TEST_SS
GRK_DONTFORCECAPS:
    IN A,(C)
    OR %11111110    ;Mask caps shift
    LD D,A          ;Store it 
GRK_TEST_SS:
    LD B,$7F        ;SYMBOL shift port
    IN A,(C)
    OR %11111101    ;Mask symbol shift
    AND D           ;merge in CAPS shift
    PUSH AF         ;And store it for later use.
; Now to process each keyboard line
    LD BC,$FEFE     ; Start port (1111 1110 1111 1110)
    LD HL,KEYBOARD_MASKS    ; Keys to mask out.
    LD D,1          ; row counter.
GRK_READLOOP:
    IN A,(C)        ; read value
    OR (HL)         ; mask value
    INC HL          ; Next mask
    CP $FF          ; are any keys pressed?
    JR NZ,GRK_DECODEKEY ;if keys are pressed, decode and return key
    INC D           ; Next row
    LD A,B          ; Shift B over 1 bit to point to the next row.
    SCF
    RLA
    LD B,A
    CP $FF          ;Have we shifted the zero bit out?
    JR NZ,GRK_READLOOP  ;If not, still more rows
    ;If we get here, no keys have been pressed, so just unstack the shifts and return
    POP BC
    XOR A
    RET
GRK_DECODEKEY:
    ;Decode bit into a raw number
    LD E,1          ;bit number counter
GRK_NEXTBIT:
    RRA             ;rotate bit 0 into carry flag
    JR NC,GRK_FOUNDKEY  ;If zero, we have found a key
    INC E           ;If not, just increment the bit number and try again
    JR GRK_NEXTBIT
GRK_FOUNDKEY:
    ;D=Row, E = Column and B = shifts
    POP BC          ;Get the shifts back
    LD A,D          ;Multiply the Row counter by 5
    ADD A ; x2
    ADD A ; x4
    ADD D ; x5
    ADD E           ;Add in column counter
    SUB 6           ;And Sub 6 (As this is the first value generated so value is 0-39
;Modify the value with the shifts
    BIT 1,B         ;Is Symbol shift set?
    JR NZ,GRK_NOTCAPS
    ADD 40          ;Add 40
    JR GRK_KEYB_END
GRK_NOTCAPS:
    BIT 0,B         ; is caps shift set?
    JR NZ,GRK_KEYB_END   
    ADD 80          ; Add80
GRK_KEYB_END:   
    INC A   ;Value is now 1-40 (or 41-80 or 81-120)
    RET

KEYBOARD_MASKS:
;These are used to mask out the shift keys to avoid
;these registering by themselves.
    DEFB %11100001,%11100000,%11100000,%11100000
    DEFB %11100000,%11100000,%11100000,%11100010

;*****************************************************************
; Get the next character from the keyboard buffer or 0
;*****************************************************************
GETNEXTCHAR:
;Check to see if there is anything in the buffer
    LD A,(KEYBOARDBUFFER_WRITEPTR)
    LD B,A
    LD A,(KEYBOARDBUFFER_READPTR)
    CP B
    JR Z,GNC_BUFFER_EMPTY
;Get the next item from the keyboard buffer
    LD HL, KEYBOARDBUFFER
    LD D,0
    LD E,A
    ADD HL,DE
    LD C,(HL)
;Point to the next character and save the pointer.
    INC A
    LD (KEYBOARDBUFFER_READPTR),A
    LD A,C
    RET
GNC_BUFFER_EMPTY:
    XOR A
    RET

;*************************************************************************
; Reset the keyboard buffer. 
;*************************************************************************
RESET_KEYBOARD_BUFFER:
    XOR A
    LD (KEYBOARDBUFFER_WRITEPTR),A
    LD (KEYBOARDBUFFER_READPTR),A
    RET
;*************************************************************************
; Keyboard interrupt. To a full keyscan, apply key delay.
;*************************************************************************
KEYBOARD_INTERRUPT: 
    ld a,(KB_CAPSLOCK)
    call GET_KEYBOARD           ;Get key pressed
    ;Check to see if its the same as the last one.
    LD B,A
    LD A,(KEYBOARDBUFFER_LASTK) 
    CP B
    JR Z,KBINT_KEYNOTCHANGED    ;If it is, see if we have timeed out
    ;If key has changed, set the last key variable
    LD A,B
    LD (KEYBOARDBUFFER_LASTK),A
    ;if the key has changed to 0, then just return
    CP 0
    RET Z
    ;Else add the new key
    LD A,KEY_INITIALDELAY
    JR KBINT_ADDKEY
KBINT_KEYNOTCHANGED:        
;If b = 0, just return
    XOR A
    CP B
    RET Z
;B contains key
;Decrement the repeat counter
    LD A, (KEYBOARDBUFFER_REPCTR)
    DEC A
    LD (KEYBOARDBUFFER_REPCTR),A
    CP 0
    RET NZ
;Reset the repeat counter
    LD A,KEY_REPEATDELAY
KBINT_ADDKEY:
    LD (KEYBOARDBUFFER_REPCTR), A
;Check caps lock
;screwing things up. 
    ld a,$12
    cp b
    jr nz,KBINT_NOTCAPSLOCK
    ld a,(KB_CAPSLOCK)
    XOR $FF
    ld (KB_CAPSLOCK),a
    ret

KBINT_NOTCAPSLOCK:
    jr KBINT_NOTCURSOR
    ld a,$08
    cp b
    jr c,KBINT_NOTCURSOR
    ld a,$11+1
    cp b
    jr c,KBINT_EXPAND_CURSORKEYS
KBINT_NOTCURSOR:
;Add the key (In B) to the keyboard buffer
    call KBINT_ADDBTOBUFFER

    LD B,255
KBINT_DELLOOP:
    NOP
    DJNZ KBINT_DELLOOP
    LD A, ($5C48)
    RRA
    RRA
    RRA
    AND $7
    OUT ($FE),A
    RET

KBINT_EXPAND_CURSORKEYS:
    push bc
    ld b,$1b
    call KBINT_ADDBTOBUFFER
    ld b,'['
    call KBINT_ADDBTOBUFFER
    pop bc
    ld a,b
    sub 8
    ld e,a
    ld d,0
    ld hl,KBINT_CURSOR_LOOKUP
    add hl,de
    ld b,(hl)
    call KBINT_ADDBTOBUFFER
    ret
KBINT_CURSOR_LOOKUP:
    defb "CBAD"

KBINT_ADDBTOBUFFER:
    LD HL,KEYBOARDBUFFER
    LD D,0
    LD A,(KEYBOARDBUFFER_WRITEPTR)
    LD E,A
    ADD HL,DE
    LD (HL),B
    INC A
    LD (KEYBOARDBUFFER_WRITEPTR), A
    ret    

KB_CAPSLOCK:
    defb $00
    




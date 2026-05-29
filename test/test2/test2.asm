;**********************************************************
;* Test program 2 - Takes the value in s$ and outputs it
;* in 42 column mode
;**********************************************************
include "terminal.i"

CH_ADD:     equ 23645      ; Next input to basic parser address
LOOK_VARS:  equ $28B2      ; Address of LOOK_VARS rom routine.

;Entry point at 61000
org $EE48
    ld a,7                  ; border 7
    out($fe),a
    call TERMINAL_INIT      ; Initialise terminal variables

    ld a,'S'                ; Variable name to find
    call FindString         ; Get string
    jp nc,notfound          ; If string not found, just exit out
    push hl                 ; preserve address of string

    add hl,bc               ; Add in length so we are at the end
    ld (TmpHackAdddress),hl ; Store address of the item after the
    ld a,(hl)               ; string and its contents for later
    ld (TmpHackContents),a
    ld (hl),$0              ; Change this to be a null (End of string)
            
    pop de                  ; Get back the address of the string and display
    call PRINTSTRING        ; the (now) zero terminated string

    ld hl,(TmpHackAdddress) ; Get back the address we overwrote with NULL
    ld a,(TmpHackContents)  ; And its original contents
    ld (hl),a               ; and write them back. 

    call TERMINAL_DISABLE   ;Turn off terminal interrupts
    ret

notfound:
    ld de,msg_NotFound      ; just display s$ not found message
    call PRINTSTRING
    call TERMINAL_DISABLE
    ret

msg_NotFound:
    defb "S$ not found",$0

TmpHackAdddress:
    defw $0000
TmpHackContents:
    defb $00


;*****************************************************
;Find the given String Variable and return a pointer
;to it and its length.
;*****************************************************
; On Entry:
;    A = variable name ('A'->'Z')
; On exit, 
; If variable found:
;    Carry = true
;    HL = address of string 
;    BC = length
; If not found:
;    Carry = false
;    HL,BC invalid
;*****************************************************
FindString:
    ld (fs_varname),a
    
    ld HL,(CH_ADD)       ; Preserve the existing CH_ADD variable. If we dont, basic will get confused
    push hl

    ld hl,fs_varname     ; point CH_ADD to our variable name
    ld (CH_ADD),hl        

    call LOOK_VARS

    push af              ; Preserve the Carry flag
    inc hl               ; HL will point to the end of the variable name, so point at the LSB of the length
    ld c,(hl)            ; LSB to C
    inc hl               ; point to length MSB
    ld b,(hl)            ; MSB to B
    inc hl               ; point to first character in string
    pop af               ; Get back returned flags
    ccf                  ; invert Carry so CARRY=TRUE when variable found
    
    pop de               ; Get back the old CH_ADD system variable
    ld (CH_ADD),de       ; Put it back.
    
    ret

fs_varname:
    defb "X$",$0


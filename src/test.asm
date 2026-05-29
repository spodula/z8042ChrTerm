;**********************************************************
;* Main 
;**********************************************************
include "terminal.i"

org $8000
    ld a,7
    out($fe),a
    call TERMINAL_INIT
    call RESET_KEYBOARD_BUFFER

    ld de,DEFAULTMESSAGE
    call PRINTSTRING
    ld de,dummy
    call PRINTSTRING


MAINLOOP:
    call GETNEXTCHAR
    cp $00
    jr z,MAINLOOP
    cp $1b
    jr z,finish
    cp $0d
    jr z,docrlf
    cp $11
    jr z,edit
    ld (inputbuf),a
    ld de,inputbuf
    call PRINTSTRING
    jr MAINLOOP

finish:
    call TERMINAL_DISABLE
    ret

dummy:
    defb "012345678]",$0

docrlf:
    ld de,crlf
    call PRINTSTRING
    jr MAINLOOP

edit:
    ld de,xedit
    call PRINTSTRING
    jr MAINLOOP

capslock:
    ld de,xcapslock
    call PRINTSTRING
    jr MAINLOOP

inputbuf:
    defb " ",$0
crlf:
    defb $0d,$0a,$0
xedit:
    defb "<edit>",$0
xcapslock:
    defb "<capslock>",$0


DEFAULTMESSAGE:
    defb $1b,"[p"             ;Terminal reset
    defb $1b,"[#3"            ;Double height,top
    defb $1b,"[21;36;40m"     ;Bold, FG: 6, BG:0
    defb "WELCOME TO THE TERMINAL"
    defb $1b,"[0K",$0d,$0a    ;Clear to EOL
    defb $1b,"[#4"            ;Double height, bottom
    defb "WELCOME TO THE TERMINAL"
    defb $1b,"[0K",$0d,$0a,$0d,$0a ;Clear to EOL
    defb $1b,"[#5"            ;Normal height
    defb $1b,"[0;30;47m"      ;normal char, FG: 0, BG: 7
    defb $1b,"[20l"           ;Wrap will wrap onto a new line
    defb $0                   ;end of string




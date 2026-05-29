;**********************************************************
;* Main 
;**********************************************************
include "terminal.i"

org $8000
    ld a,7
    out($fe),a
    call TERMINAL_INIT

    ld de,DEFAULTMESSAGE
    call PRINTSTRING
loop:
    halt
    call GETNEXTCHAR
    cp 0
    jr z,loop
    cp $0c  
    jr z,finish
    cp $0d
    jr z,docrlf
    ld (inputbuf),a
    ld de,inputbuf
    call PRINTSTRING
    jr loop
finish:
    call TERMINAL_DISABLE
    ret

docrlf:
    ld de,crlf
    call PRINTSTRING
    jr loop



inputbuf:
    defb " ",$0
crlf:
    defb $0d,$0a,$0

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




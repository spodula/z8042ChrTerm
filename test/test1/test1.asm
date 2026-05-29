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

    call TERMINAL_DISABLE
    ret

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
    defb "Normal",$0d,$0a
    defb $1b,"[0;1mBold",$0d,$0a
    defb $1b,"[0;3mItalic",$0d,$0a
    defb $1b,"[0;4mUnderline",$0d,$0a
    defb $1b,"[0;7mInvert",$0d,$0a
    defb $1b,"[0;9mStrikeout",$0d,$0a
    defb $1b,"[0m",$0d,$0a
    defb $1b,"[0;30mX "
    defb $1b,"[0;31mX "
    defb $1b,"[0;32mX "
    defb $1b,"[0;33mX "
    defb $1b,"[0;34mX "
    defb $1b,"[0;35mX "
    defb $1b,"[0;36mX "
    defb $1b,"[0;37mX ",$0d,$a
    defb $1b,"[0;40mX "
    defb $1b,"[0;41mX "
    defb $1b,"[0;42mX "
    defb $1b,"[0;43mX "
    defb $1b,"[0;44mX "
    defb $1b,"[0;45mX "
    defb $1b,"[0;46mX "
    defb $1b,"[0;47mX ",$0d,$a


    defb $0                   ;end of string




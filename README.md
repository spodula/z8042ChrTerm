;*******************************************************************************
; Implementation of the display part of an ANSI terminal for the ZX-Spectrum.  *
; GDS March 2026    <ESC> = 0x1b                                               *
;                                                                              *
; Limitations: Not a full ANSI implementation. (Not sure thats possible)       *
;              This is a 42x24 terminal.                                       *
;              As such, colour clash between some characters                   *
;              ESC[ buffer is limited to 10 characters.                        *
;*******************************************************************************

Supported Characters:
   \b (0x07) - Bell
   ?  (0x08) - Backspace - Back one character to Start of line.
   \t (0x09) - Tab to the next column (Tabs are currently always 8)
   \r (0x0a) - if Bit 1,(IX+3)=0, Next line+Start of line, else just next line
   \n (0x0d) - Go to the start of the line
   ?  (0x7f) - Delete character
   ?  (0x0b or 0x0c) VT and FF treated as LF (0x0a) as per Vt-100.
   ?  (0x18) - Cancel escape string
   ?  (0x1A) - Cancel escape string with error
------------------------------------------------------------------------------
Set Attribute Mode	<ESC>[{attr1};...;{attrn}m
------------------------------------------------------------------------------
  Sets or resets multiple display attribute settings. The following lists supported attributes:
 Set clr
  0   -    Reset or normal	All attributes off
  1  21    Bold  
  2  22    Bold off (Both 2 and 22 are bold off)
  3  23    Italic	
  4  24    Underline
  7  27    invert
  8  28    Conceal
  9  29    Strikeout

  Foreground colour = 30+(Speccy Colour) (Not the same colourset as ANSI)
  Background colour = 40+(Speccy Colour) (Not the same colourset as ANSI)
   49 = default background colour (White). 39 = Default foregound colour (Black)
    +0 black, +1 Blue, +2 red, +3 magenta, +4 green, +5 cyan, +6 yellow, +7 white
------------------------------------------------------------------------------
 Clear block: <ESC>[xJ
------------------------------------------------------------------------------
  0 (Or blank) - Clear from cursor to End of screen
  1 Clear from cursor to start of screen
  2 Clear entire screen
------------------------------------------------------------------------------
 Clear line: <ESC>[xK
------------------------------------------------------------------------------
  0 (Or blank) - Clear from cursor to End of line
  1 Clear from cursor to start of line
  2 Clear entire line
------------------------------------------------------------------------------
 Set Cursor: <ESC>[{Y}{;X}H <ESC>[{Y}{;X}f
------------------------------------------------------------------------------
 Set the cursor location Up to two parameters. Missing parameters default to 0
   <ESC>[H  - Set cursor to 0,0
   <ESC>[{y}H  - Set cursor to 0,y
   <ESC>[{y};{x}H  - Set cursor to x,y
------------------------------------------------------------------------------
 Reset terminal <ESC>c or <esc>[c or <esc>[p
------------------------------------------------------------------------------
 Reset to default state. Cursor=0,0, all flags reset,screen cleared
 Note, usually p is soft reset, whereas C is hard reset. Treated the same here
------------------------------------------------------------------------------
 Move Cursor <ESC>[<x>[A|B|C|D]
------------------------------------------------------------------------------
 Move the cursor X characters in the given direction.  Will Max at the edges of the screen
 A=up B=Down, C=Right, D=Left  <X> is not present will default to 1 EXCEPT for D which will scroll up
------------------------------------------------------------------------------
 Move Cursor Up or down with NL <ESC><x>[E|F] .
------------------------------------------------------------------------------
 Move the cursor X characters in the given direction and move cursor to start of line
  Will Max at the edges of the screen  ; E=Down, F=Up. If <X> is not present will default to 1
------------------------------------------------------------------------------
 Move cursor to column n                <ESC>[<n>G
------------------------------------------------------------------------------
 Move the cursor the the given column. If column >41, column = 41
------------------------------------------------------------------------------
 Font height  <ESC>#[3|4|5]
------------------------------------------------------------------------------
Set the font height 3=dbl height top, 4=dbl height bottom, 5=normal
------------------------------------------------------------------------------
Save and restore cursor <ESC>[s  <esc>[u   OR   <ESC>7 <ESC>8
------------------------------------------------------------------------------
Note this is only a single level store.
------------------------------------------------------------------------------
Scroll window up one line ^D
Scroll window down one line ^M
------------------------------------------------------------------------------
Scrolls the window appropriately.
------------------------------------------------------------------------------
Set terminal mode
------------------------------------------------------------------------------
setnl LMN             Set new line mode                      <ESC>[20h
setwrap DECAWM        Set auto-wrap mode                     <ESC>[?7h
------------------------------------------------------------------------------
reset terminal modes
------------------------------------------------------------------------------
setlf LMN             Set line feed mode                     <ESC>[20l
resetwrap DECAWM      Reset auto-wrap mode                   <ESC>[?7l
------------------------------------------------------------------------------
 Not Supported:
 faint attribute - slow/fast blink / Font changes - All attributes > 50 
------------------------------------------------------------------------------




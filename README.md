# Implementation of the display part of an ANSI terminal for the ZX-Spectrum. 
 
 \<ESC> = 0x1b                                             
                                                                              
# Limitations: 
* Not a full ANSI implementation. (Not sure thats possible)
* This is a 42x24 terminal. As such, colour clash can occur between some characters
* ESC[ buffer is limited to 10 characters.                        

# Supported Characters:
| Chr | Code | Desc |
| --- | --- | --- |
| \b |0x07 | Bell|
| ?|0x08 | Backspace - Back one character to Start of line.|
| \t |0x09 | Tab to the next column (Tabs are currently always 8)|
| \r |0x0a | if Bit 1,(IX+3)=0, Next line+Start of line, else just next line|
| \n |0x0d | Go to the start of the line|
| ?|0x7f | Delete character|
| ?|0x0b or 0x0c |VT and FF treated as LF (0x0a) as per Vt-100.|
| ?|0x18 | Cancel escape string|
| ?|0x1A | Cancel escape string with error|

# Set Attribute Mode \<ESC>[{attr1};...;{attrn}m
| Set | Clear | Description |
| --- | --- | --- |
|0| -|Reset or normal	All attributes off|
|1|21|Bold|
|2|22|Bold off (Both 2 and 22 are bold off)|
|3|23|Italic|
|4|24|Underline|
|7|27|invert|
|8|28|Conceal|
|9|29|Strikeout|

Colours:

| Number | Paper/ink | Colour |
| --- | --- | --- |
| 30 | Ink | 0 (black) |
| 31 | Ink | 1 (Navy) |
| 32 | Ink | 2 (Red) |
| 33 | Ink | 3 (Magenta) |
| 34 | Ink | 4 (Green) |
| 35 | Ink | 5 (Cyan) |
| 36 | Ink | 6 (Yellow) |
| 37 | Ink | 7 (White) |
| 39 | Ink | 7 (White) (Default) |
| 40 | Paper | 0 (black) |
| 41 | Paper | 1 (Navy) |
| 42 | Paper | 2 (Red) |
| 43 | Paper | 3 (Magenta) |
| 44 | Paper | 4 (Green) |
| 45 | Paper | 5 (Cyan) |
| 46 | Paper | 6 (Yellow) |
| 47 | Paper | 7 (White) |
| 49 | Paper | 7 (White)  (Default)|

EG:
  \<ESC>[21;40;37m
 Bold, Paper 0 ink 7
  

# Clear block: \<ESC>[xJ
| X | Meaning |
| --- | --- |
|\<ESC>[J |  Clear from cursor to End of screen|
|\<ESC>[0J |  Clear from cursor to End of screen|
|\<ESC>[1J |Clear from cursor to start of screen|
|\<ESC>[2J |Clear entire screen|

# Clear line: \<ESC>[xK
| X | Meaning |
| --- | --- |
|  \<ESC>[K | Clear from cursor to End of line|
|  \<ESC>[0K | Clear from cursor to End of line|
|  \<ESC>[1K |Clear from cursor to start of line|
|  \<ESC>[2K |Clear entire line|

# Set Cursor: \<ESC>[{Y}{;X}H \<ESC>[{Y}{;X}f
 Set the cursor location Up to two parameters. Missing parameters default to 0
| Code | Meaning | 
| --- | --- |
|\<ESC>[H | Set cursor to 0,0|
|\<ESC>[{y}H  | Set cursor to 0,y|
|\<ESC>[{y};{x}H | Set cursor to x,y|

# Reset terminal \<ESC>c or \<esc>[c or \<esc>[p
 Reset to default state. Cursor=0,0, all flags reset,screen cleared
 Note, usually p is soft reset, whereas C is hard reset. Treated the same here

# Move Cursor \<ESC>[\<x>[A|B|C|D]
 Move the cursor X characters in the given direction.  Will Max at the edges of the screen
 If X is blank, EG \<ESC>[A  , X is treated as 1

| Code | Direction |
| --- | --- |
|\<ESC>[\<x>A|Up |
|\<ESC>[\<x>B|Down|
|\<ESC>[\<x>C|Left|
|\<ESC>[\<x>D|Right|

# Move Cursor Up or down with NL \<ESC>[\<x>[E|F] .
 Move the cursor X characters in the given direction and move cursor to start of line
  Will Max at the edges of the screen  ; E=Down, F=Up. If <X> is not present will default to 1
  
# Move cursor to column n                \<ESC>[<n>G
 Move the cursor the the given column. If column >41, column = 41

# Font height  \<ESC>#[3|4|5]
Set the font height 3=dbl height top, 4=dbl height bottom, 5=normal
| Code | Meaning |
| --- | --- |
|\<ESC>#[3|Top half of double height character|
|\<ESC>#[4|Bottom half of double height character|
|\<ESC>#[5|Normal height|

# Save and restore cursor \<ESC>[s  \<esc>[u   OR   \<ESC>7 \<ESC>8
Note this is only a single level store.
# Scroll window up one line ^D

# Scroll window down one line ^M

# Set terminal mode
setnl LMN             Set new line mode                      <ESC>[20h
setwrap DECAWM        Set auto-wrap mode                     <ESC>[?7h

# reset terminal modes
setlf LMN             Set line feed mode                     <ESC>[20l
resetwrap DECAWM      Reset auto-wrap mode                   <ESC>[?7l

# Not Supported:
 faint attribute - slow/fast blink / Font changes - All attributes > 50 


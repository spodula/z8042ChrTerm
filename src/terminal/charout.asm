;*******************************************************************************
; charout.asm
;   This prints a character on a 42x24 character grid with the character 
;   in A, at XY=HL, with display modifiers specified in C and colour attributes in B
;   Characters < $20 are printed as "?"
; This also contains the code used to invert the current cursor location.
; In this case, ; HL=XY, if A=0 block cursor, else line cursor
;*******************************************************************************

;******************************************************************************
;Display a character
;H = X, L = Y  target on screen 0->N
;A = Character
;B = Colour attribute (FBPPPIII) where F=Flash, B=Bright, PPP=Paper, III=Ink
;C = Font Attribute
;  0 - Underline
;  1 - Inverse
;  2 - Strikeout
;  3 - Italic
;  4 - Bold
;  5 - Large (top half)
;  6 - Large (bottom half)
;  7 - Hidden
; HL,DE,AF,BC registers corrupted,
; all other registers preserved.
; Stack usage: 6 bytes + call
;*******************************************************************************
DISPLAYCHAR:
;Firstly we need to convert the character code to an address in DE. This is just
;basically DE := ((A-32) * 8) +FONTSTART
;This is because the printable characters start at #32
        SUB $20
        JR NC,DC_PRINTABLECHAR
        LD A, $1F ; "?"-$20
DC_PRINTABLECHAR:
        BIT 7,C
        JR Z,DC_NOTHIDDENCHAR
        LD A,$0A              ; ($2a="*")
DC_NOTHIDDENCHAR:
        PUSH HL              ;Store HL so we can use it
        LD h,0
        LD l,A
        add hl,hl	         ;hl = hl * 8
        add hl,hl
        add hl,hl
        LD de,FONTSTART       ;Get start UDG
        ADD HL,DE            ;Add in the value of a * 8

        BIT 6,C		          ;If we set Bit 6, we want to display the bottom half of the
        JR Z,DC_NOTBOTTOMHALF ;character, so add 4 to the start location. 
        LD DE,$0004
        ADD HL,DE
DC_NOTBOTTOMHALF:
        EX DE,HL             ;Transfer back to DE
        POP HL               ;Restore HL

;Next we need to generate a raster Y coordinate and a shift from Y.
;In Pascal this code would be: L := L * 6; A := L mod 8; L := l div 8
        SLA L    ;L = l * 2
        LD A,L   ; a = l * 2
        SLA L    ;l = l * 4
        ADD A,L  ;A = a+l  so A now contains original L * 6
        LD L,A   ;L now contains number of pixels
        SRA L    ;Divide L by 8 to get number of bytes
        RES 7,L  ;Ensure last bit of L is zero so we dont add mysterious
        SRA L    ;crap into the L register
        SRA L
        AND %00000111 ;Required shift is the remainder.

;************************************************************************
;The next stage is to convert the absolute X and Y into a raster Address.
;************************************************************************
         PUSH AF     ;Stack previously worked out shift
         LD A,H      ;Get H (Y)
         RRCA                ; Shift xxxxxCCC -> CCCxxxxx
         RRCA
         RRCA
         AND %11100000       ;Extract bits required   CCCxxxxx-> CCC00000
         OR L                ;Merge them into CCC0000 + 000yyyyy -> CCCyyyyy
         LD L,A              ;Put L back.
         LD A,%00011000      ;Extract bits of H for aa,
         AND H               ;  000aa000 -> A
         OR %01000000        ;Add in %01000000   010aa000 ->a
         LD H,A              ;Put back. Now HL = 010aa000 CCCyyyyy
         POP AF              ;Get shift back.
;************************************************************************
;*Now we know the location and the shift we need to apply to that location.
;************************************************************************
;First clean out the old character at that location.
         PUSH HL             ;Stack all items so they aren't corrupted
         PUSH AF
         PUSH DE
         PUSH BC
         LD DE,$03FF         ;Load DE with the mask  (%00000011 11111111)
         XOR A
         CP B               ;See if shift is zero.
         JR Z,DC_NOSHIFT2    ;If it is, dont shift
DC_SHIFT2:
         SCF                 ;We want to shift '1' into MSB of D
         RR D                ;Rotate D, putting LSB -> carry flag
         RR E                ;Rotate E, putting carry flag -> MSB
         DJNZ DC_SHIFT2      ;Continue for 'B' shifts
DC_NOSHIFT2:
         POP BC

;********************************Set the character attributes*****************
; de= MASK, hl=PIXEL ADDRESS
         PUSH HL
;Convert the pixel address (HL) to a attribute address.
; 010AA000 BBBY YYYY ->   010110AA BBBYYYYY
; Basically no modifications required for L, but shift H
         LD A,H 
         RRA 
         RRA 
         RRA
         AND %00000011
         OR  %01011000
         LD H,A
; Now check to see if there is anything needs changing in the first attribute byte
         XOR A
         CP D
         JR Z,DC_DONTCHANGEATTR1
         LD (HL),B
DC_DONTCHANGEATTR1:
; Check to see if there is anything in the second attribute byte
         INC HL
         XOR A
         CP E
         JR Z,DC_DONTCHANGEATTR2
         LD (HL),B
DC_DONTCHANGEATTR2:
         POP HL 

;*******************************************************************************
;We now have the mask for that particular shift, now we should use it to
; blank the old character
         LD B,8              ;want to do 8 scan lines
DC_SCANLOOP1:
         LD A,D              ;Get first part of mask
         AND (HL)            ;remove all bits inside the mask at that scanline
         LD (HL),A           ;Put back the character
         INC HL              ;Point to next character location
         LD A,E              ;Get second part of mask
         AND (HL)            ;Remove all bits inside the mask at that scanline
         LD (HL),A           ;put back
         DEC HL              ;Point back at the original character location
         INC H               ;Point at next scan line
         DJNZ DC_SCANLOOP1   ;Decrement B and loop if B <> 0
         POP DE
         POP AF
         POP HL
;****************************Now, display the character itself****************
         LD B,8           ;Outer loop
DC_CHARLINELOOP:
         PUSH AF
         PUSH DE
         PUSH BC
         LD B,A          ;Transfer shift Counter to B
         LD A,(DE)       ;Now, put character line into D
;******************************************************************************
; This section of code is responsible for mangling the character data  
; according to the attribute class in 'C'
; See the top of the code for the definitions.
;******************************************************************************
; Bit: 2       Summary: Strikeout
; How: check for the bit line. If the 5th raster line (4 counting from 8), set to all on.
;******************************************************************************
         BIT 2,C         ;check for strikeout
         JR Z,DC_SkipStrikeout
         LD D,A
         LD E,B
         POP BC
         PUSH BC
         LD A,4
         CP B
         JR NZ, DispNot8
         LD A,%11111100
         LD B,E
         JR DC_SkipStrikeout
DispNot8:
         LD A,D
         LD B,E
DC_SkipStrikeout:
;******************************************************************************
; Bit: 0       Summary: Underline
; How: check for the bit line. If the 8th raster line (1 counting from 8), set to all on.
;******************************************************************************
         BIT 0,C    ;check for underline
         JR Z,DC_SkipUnderLine
         LD D,A
         LD E,B
         POP BC
         PUSH BC
         LD A,1
         CP B
         JR NZ, DispNotLast
         LD A,%11111100
         LD B,E
         JR DC_SkipUnderLine
DispNotLast:
         LD A,D
         LD B,E
DC_SkipUnderLine:
;******************************************************************************
; Bit: 3       Summary: Italic
; How: check for the bit line. Rotate items left if bit line > 3.
;******************************************************************************
         BIT 3,C    ;check for italic
         JR Z,DC_SkipItalic
         LD D,A
         LD E,B
         POP BC
         PUSH BC
         LD A,3
         CP B
         JR C, Disptop
         LD A,D
         RLA
         LD B,E
         JR DC_SkipItalic
Disptop:
         LD A,D
         LD B,E
DC_SkipItalic:
;******************************************************************************
; Bit: 4       Summary: Bold
; How: If on, merge with shifted version
;******************************************************************************
         BIT 4,C  ;Check for Bold
         JR Z, DC_SkipBold
         PUSH BC
         LD B,A
         RL B
         OR B
         POP BC
DC_SkipBold:
;******************************************************************************
; Bit: 1       Summary: Inverse
; How: If on, do a Logical XOR of the raster line.
;  Note, this is deliberately applied last. otherwise, inverse italics wont work.
;******************************************************************************
         BIT 1,C    ;Check for inverse
         JR Z,DC_SkipInverse
         XOR %11111100
DC_SkipInverse:
;******************************************************************************
;Display the character.
;******************************************************************************
         AND %11111100
         LD D,A
         LD E,0         ;Blank E, so DE = %xxxxxx00 00000000
         XOR A          ;Compare B with zero, to see if shifting required.
         CP B
         JR Z,DC_NOCHRSHIFT ;If no shifting required, jump over the shift
DC_SHIFTCHRDATA:
         SCF
         CCF
         RR D            ;Move D left one character
         RR E            ;Ditto with E, except any Carry from D will go into the
         DJNZ DC_SHIFTCHRDATA ;MSB of E and Decrement B and Loop if B is not zero

;*********Now, merge in the shifted character line onto the screen*************
DC_NOCHRSHIFT:
         LD A,D          ;Get first part of mask
         OR (HL)         ;Merge target location
         LD (HL),A       ;Put back target location
         INC HL          ;Point to next location
         LD A,E          ;Get second part of mask
         OR (HL)         ;Merge in location
         LD (HL),A       ;Put back
         DEC HL          ;This restores HL to the initial location
         INC H           ;Point to next target line
         POP BC          ;get all items back off the stack
         POP DE
; if bit 5/6 of c set then only write every other character line
         LD A, %01100000
         AND C
; one of the bits are set, check to see if an even line.
         JR Z,JustInc
         BIT 0,B
         JR NZ,JustInc
         DEC DE
JustInc:
         INC DE           ;Point to next character line
         POP AF
         DJNZ DC_CHARLINELOOP ;Loop to do the next character line

         RET


;******************************************************************************
; Invert the character at X/Y
; H=X L=Y if A=0 block cursor, else line cursor
;******************************************************************************
INVERTCHAR:
        PUSH AF
;Next we need to generate a raster Y coordinate and a shift from Y.
;In Pascal this code would be: L := L * 6; A := L mod 8; L := l div 8
        SLA L    ;L = l * 2
        LD A,L   ; a = l * 2
        SLA L    ;l = l * 4
        ADD A,L  ;A = a+l  so A now contains original L * 6
        LD L,A   ;L now contains number of pixels
        SRA L    ;Divide L by 8 to get number of bytes  
        res 7,l
        SRA L    
        SRA L
        AND %00000111 ;Required shift is the remainder.
;************************************************************************
;Work out location
;************************************************************************
         PUSH AF             ;Stack previously worked out shift
         LD A,H              ;Get H (Y)
         RRCA                ; Shift xxxxxCCC -> CCCxxxxx
         RRCA
         RRCA
         AND %11100000       ;Extract bits required   CCCxxxxx-> CCC00000
         OR L                ;Merge them into CCC0000 + 000yyyyy -> CCCyyyyy
         LD L,A              ;Put L back.
         LD A,%00011000      ;Extract bits of H for aa,
         AND H               ;  000aa000 -> A
         OR %01000000        ;Add in %01000000   010aa000 ->a
         LD H,A              ;Put back. Now HL = 010aa000 CCCyyyyy
         POP BC              ;Get shift back.
;************************************************************************
;*Now we know the location and the shift we need to apply to that location.
;************************************************************************
;Convert the shift into a set of mask bytes
         LD DE,%1111110000000000 ;Load DE with the mask  
         XOR A
         CP B                ;See if shift is zero.
         JR Z,IC_DONTSHIFT   ;If it is, dont shift
         CCF                 ;reset the carry flag
IC_SHIFT1:
         RR D                ;Rotate D, putting LSB -> carry flag
         RR E                ;Rotate E, putting carry flag -> MSB
         DJNZ IC_SHIFT1      ;Continue for 'B' shifts
IC_DONTSHIFT:
;*******************************************************************************
;We now have the mask for that particular shift, now we should use it to
; blank the old character
         POP AF
         LD B,8
         BIT 0,A
         JR Z, IC_BLOCKCURSOR
         LD B,1              ;want to do 1 scan line
         LD A,H              ;At the bottom
         ADD 7
         LD H,A
IC_BLOCKCURSOR:
IC_INVERTLOOP:
         LD A,D              ;Get first part of mask
         XOR (HL)            ;invert the bits at that scanline
         LD (HL),A           ;Put back the character
         INC HL              ;Point to next character location
         LD A,E              ;Get second part of mask
         XOR (HL)            ;invert the bits at that scanline
         LD (HL),A           ;put back
         DEC HL              ;Point back at the original character location
         INC H               ;Point at next scan line
         DJNZ IC_INVERTLOOP  ;Decrement B and loop if B <> 0
         RET
    
include "terminal/font.asm"



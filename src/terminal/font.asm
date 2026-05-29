;******************************************************************************
;THis area of the code provides the chacter maps.
;******************************************************************************
FONTSTART:
         DEFB %00000000        ;space
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; !
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00000000
         DEFB %00010000
         DEFB %00000000

         DEFB %00000000 ; "
         DEFB %00101000
         DEFB %00101000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; #
         DEFB %00101000
         DEFB %01111100
         DEFB %00101000
         DEFB %00101000
         DEFB %01111100
         DEFB %00101000
         DEFB %00000000

         DEFB %00010000 ;$
         DEFB %00111000
         DEFB %01010000
         DEFB %00111000
         DEFB %00010100
         DEFB %00111000
         DEFB %00010000
         DEFB %00000000

         DEFB %00000000 ; %
         DEFB %01100100 
         DEFB %01101000
         DEFB %00010000
         DEFB %00010000
         DEFB %00101100
         DEFB %01001100
         DEFB %00000000

         DEFB %00000000 ;&
         DEFB %00110000
         DEFB %01001000
         DEFB %00110000
         DEFB %01001100
         DEFB %01001100
         DEFB %00110100
         DEFB %00000000

         DEFB %00000000 ; '
         DEFB %00011000
         DEFB %00110000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; (
         DEFB %00001000
         DEFB %00010000
         DEFB %00100000
         DEFB %00100000
         DEFB %00010000
         DEFB %00001000
         DEFB %00000000

         DEFB %00000000 ; )
         DEFB %01000000
         DEFB %00100000
         DEFB %00010000
         DEFB %00010000
         DEFB %00100000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000 ; *
         DEFB %01010100
         DEFB %00111000
         DEFB %01111100
         DEFB %00111000
         DEFB %01010100
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; +
         DEFB %00010000
         DEFB %00010000
         DEFB %01111100
         DEFB %00010000
         DEFB %00010000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; ,
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00001100
         DEFB %00011000
         DEFB %00000000

         DEFB %00000000 ; -
         DEFB %00000000
         DEFB %00000000
         DEFB %01111100
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; .
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00011000
         DEFB %00011000
         DEFB %00000000

         DEFB %00000000 ; /
         DEFB %00000100
         DEFB %00001000
         DEFB %00010000
         DEFB %00010000
         DEFB %00100000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000 ;0 #30
         DEFB %00111000
         DEFB %01000100
         DEFB %01010100
         DEFB %01010100
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ;1
         DEFB %00011000
         DEFB %00101000
         DEFB %00001000
         DEFB %00001000
         DEFB %00001000
         DEFB %00111100
         DEFB %00000000

         DEFB %00000000 ;2
         DEFB %00111000
         DEFB %01000100
         DEFB %00001000
         DEFB %00010000
         DEFB %00100000
         DEFB %01111110
         DEFB %00000000

         DEFB %00000000 ;3
         DEFB %00111000
         DEFB %01000100
         DEFB %00001000
         DEFB %00001000
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ;4
         DEFB %00011000
         DEFB %00101000
         DEFB %01111100
         DEFB %00001000
         DEFB %00001000
         DEFB %00001000
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100 ;5
         DEFB %01000000
         DEFB %01111000
         DEFB %00000100
         DEFB %00000100
         DEFB %01111000
         DEFB %00000000

         DEFB %00000000 ;6
         DEFB %00111000
         DEFB %01000000
         DEFB %01111000
         DEFB %01000100
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ;7
         DEFB %01111100
         DEFB %00000100
         DEFB %00001000
         DEFB %00010000
         DEFB %00100000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000 ;8 #38
         DEFB %00111000
         DEFB %01000100
         DEFB %00111000
         DEFB %01000100
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ;9
         DEFB %00111000
         DEFB %01000100
         DEFB %00111100
         DEFB %00000100
         DEFB %00000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ; :
         DEFB %00110000
         DEFB %00110000
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %00110000
         DEFB %00000000

         DEFB %00000000 ; ;
         DEFB %00110000
         DEFB %00110000
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %00110000
         DEFB %01100000

         DEFB %00000000 ; <
         DEFB %00001100
         DEFB %00110000
         DEFB %01000000
         DEFB %01000000
         DEFB %00110000
         DEFB %00001100
         DEFB %00000000

         DEFB %00000000 ; =
         DEFB %00000000
         DEFB %01111100
         DEFB %00000000
         DEFB %01111100
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000 ; >
         DEFB %01100000
         DEFB %00011000
         DEFB %00000100
         DEFB %00000100
         DEFB %00011000
         DEFB %01100000
         DEFB %00000000

         DEFB %00000000 ; ?
         DEFB %00111000
         DEFB %01000100
         DEFB %00001000
         DEFB %00010000
         DEFB %00000000
         DEFB %00010000
         DEFB %00000000

         DEFB %00000000 ; @ #40
         DEFB %00110000
         DEFB %01001000
         DEFB %01010100
         DEFB %01001000
         DEFB %01000000
         DEFB %00111100
         DEFB %00000000

         DEFB %00000000
         DEFB %00111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01111100
         DEFB %01000100
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %01111000
         DEFB %01000100
         DEFB %01111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01111000
         DEFB %00000000

         DEFB %00000000
         DEFB %00111000
         DEFB %01000100
         DEFB %01000000
         DEFB %01000000
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000
         DEFB %01111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %01111000
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100
         DEFB %01000000
         DEFB %01111100
         DEFB %01000000
         DEFB %01000000
         DEFB %01111100
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100
         DEFB %01000000
         DEFB %01111100
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00111000
         DEFB %01000100
         DEFB %01000000
         DEFB %01001100
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ; #48
         DEFB %01000100
         DEFB %01000100
         DEFB %01111100
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %01111100
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100
         DEFB %00001000
         DEFB %00001000
         DEFB %00001000
         DEFB %01001000
         DEFB %00110000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000100
         DEFB %01001000
         DEFB %01010000
         DEFB %01110000
         DEFB %01001000
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01111100
         DEFB %00000000

         DEFB %00000000
         DEFB %01000100
         DEFB %01101100
         DEFB %01010100
         DEFB %01010100
         DEFB %01000100
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %01000100
         DEFB %01100100
         DEFB %01010100
         DEFB %01001100
         DEFB %01000100
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %00111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ; #50
         DEFB %01111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01111000
         DEFB %01000000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %01010100
         DEFB %00111000
         DEFB %00000100

         DEFB %00000000
         DEFB %01111000
         DEFB %01000100
         DEFB %01000100
         DEFB %01111000
         DEFB %01000100
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %00111000
         DEFB %01000000
         DEFB %00111000
         DEFB %00000100
         DEFB %00000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %01000100
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000100
         DEFB %01000100
         DEFB %00101000
         DEFB %00101000
         DEFB %00010000
         DEFB %00010000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000100
         DEFB %01000100
         DEFB %01010100
         DEFB %01010100
         DEFB %01010100
         DEFB %00101000
         DEFB %00000000

         DEFB %00000000 ;
         DEFB %01000100
         DEFB %00101000
         DEFB %00010000
         DEFB %00010000
         DEFB %00101000
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000 ; #58
         DEFB %01000100
         DEFB %00101000
         DEFB %00010000
         DEFB %00010000
         DEFB %00100000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000
         DEFB %01111100
         DEFB %00001000
         DEFB %00010000
         DEFB %00100000
         DEFB %01000000
         DEFB %01111100
         DEFB %00000000

         DEFB %00000000 ; [
         DEFB %00111000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000 ; \
         DEFB %01000000
         DEFB %00100000
         DEFB %00010000
         DEFB %00010000
         DEFB %00001000
         DEFB %00000100
         DEFB %00000000

         DEFB %00000000 ; ]
         DEFB %01110000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %01110000
         DEFB %00000000


         DEFB %00000000
         DEFB %00110000
         DEFB %01001000
         DEFB %10000100
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %11111100


         DEFB %00000000	;#60 
         DEFB %01000000
         DEFB %01000000
         DEFB %00100000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %00001000
         DEFB %00111000
         DEFB %01001000
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01110000
         DEFB %01001000
         DEFB %01001000
         DEFB %01110000
         DEFB %00000000

         DEFB %00000000	
         DEFB %00000000
         DEFB %00111000
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000	
         DEFB %00001000
         DEFB %00001000
         DEFB %00111000
         DEFB %01001000
         DEFB %01001000
         DEFB %00111000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %01001000
         DEFB %01110000
         DEFB %01000000
         DEFB %00110000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00011000
         DEFB %00100000
         DEFB %01110000
         DEFB %00100000
         DEFB %00100000
         DEFB %00000000

         DEFB %00000000 
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %01001000
         DEFB %00111000
         DEFB %00001000
         DEFB %00110000

         DEFB %00000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %01110000
         DEFB %01001000
         DEFB %01001000
         DEFB %00000000

         DEFB %00000000
         DEFB %00100000
         DEFB %00000000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00000000

         DEFB %00000000
         DEFB %00010000
         DEFB %00000000
         DEFB %00010000
         DEFB %00010000
         DEFB %00010000
         DEFB %01100000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000000
         DEFB %01001000
         DEFB %01010000
         DEFB %01100000
         DEFB %01010000
         DEFB %01001000
         DEFB %00000000

         DEFB %00000000
         DEFB %01100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00101000
         DEFB %01010100
         DEFB %01010100
         DEFB %01010100
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %01110000
         DEFB %01001000
         DEFB %01001000
         DEFB %01001000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %01001000
         DEFB %01001000
         DEFB %00110000
         DEFB %00000000

         DEFB %00000000	;$70
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %01001000
         DEFB %01110000
         DEFB %01000000
         DEFB %01000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000 
         DEFB %01001000
         DEFB %00111000
         DEFB %00001000
         DEFB %00001100

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %01000000
         DEFB %01000000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00110000
         DEFB %01000000
         DEFB %00100000
         DEFB %00010000
         DEFB %01100000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %01000000
         DEFB %11110000
         DEFB %01000000
         DEFB %01000000
         DEFB %00110000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %01001000
         DEFB %01001000
         DEFB %01001000
         DEFB %00110000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %01010000
         DEFB %01010000
         DEFB %01010000
         DEFB %00100000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %10101000
         DEFB %10101000
         DEFB %10101000
         DEFB %01010000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %01000100
         DEFB %00101000
         DEFB %00010000
         DEFB %00101000
         DEFB %01000100
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %01000100
         DEFB %00101000
         DEFB %00010000
         DEFB %00100000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %01111000
         DEFB %00010000
         DEFB %00100000
         DEFB %01111000
         DEFB %00000000

         DEFB %00000000
         DEFB %00001000
         DEFB %00010000
         DEFB %00110000
         DEFB %00110000
         DEFB %00010000
         DEFB %00001000
         DEFB %00000000

         DEFB %00000000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00100000
         DEFB %00000000

         DEFB %00000000
         DEFB %01000000
         DEFB %00100000
         DEFB %00110000
         DEFB %00110000
         DEFB %00100000
         DEFB %01000000
         DEFB %00000000

         DEFB %00000000
         DEFB %00000000
         DEFB %00101000
         DEFB %01010000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000
         DEFB %00000000

         DEFB %00110000 ; (C)
         DEFB %01001000
         DEFB %10110100
         DEFB %10100100
         DEFB %10100100
         DEFB %10110100
         DEFB %01001000
         DEFB %00110000

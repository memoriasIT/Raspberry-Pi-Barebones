.include "configuration.inc" // Set GPIO as I/O

ldr  r0, =0x3F20001C  
ldr  r1, =0x200    
str  r1,[r0]
end:
b end


/*
N      N  OOO  TTTTT EEE  SSSS
NN    N  O  O      T    E     S
N  N  N  O  O      T    EEE  SSSS
N    NN  O  O      T    E            S
N      N  OOO      T    EEE  SSSS

--------{ BIN TO HEX FAST }--------

0x200 = 0010 0000 0000
31 30 29 28 27 ... 11 10 9 8 7 6 5 4 3 2 1 0
			  |0 0 1 0||0 0 0 0||0 0 0 0|
			  |---2---| |---0---||---0---|
			  
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
|0   0  0   0||0   0   0  0||0   1   0   0||0   0   0   0||1   0   0   0||0  0  0 1||0 0 0 0||0 0 0 0|
|------0----||-----0------||------0-----||-----0------||------0-----||---1-----||---0----||---0----|									    



------------{ SWITCH ON }----------


ldr  r0, =0x3F20001C  	// ON address
ldr  r1, =0x200    	 	// Bit 9
str  r1,[r0]		 		// Execute r1 -> r0

----------{ SWITCH OFF }-----------

ldr  r0, =0x3F200028  	// OFF address
ldr  r1, =0x200    	 	// Bit9
str  r1,[r0]		 		// Exec
*/
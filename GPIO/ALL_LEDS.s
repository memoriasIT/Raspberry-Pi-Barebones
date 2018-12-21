// Turn on all leds

.include "configuration.inc" 
 	ldr  r0, =0x3F20001C  	
	ldr  r1, =0x08420E00		
	str  r1,[r0]
loop:
	ldr  r1, =0x00E00		
	str  r1,[r2]
END:	B END
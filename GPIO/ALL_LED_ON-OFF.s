// all leds on , when button pressed leds start to switch off one by one

3F200008 -> 22, 7
3F200004 -> 22, 4, 1
3F200000 -> 28

.data
tam: .word 6
led: .word 500000, 250000, 125000
address: .word 3F200000, 3F200004

.include "configuration.inc" 
 	ldr  r0, =0x3F20001C  	
	ldr  r1, =0x08420E00		
	str  r1,[r0]
main:
	ldr  r1, =0x00E00		
	str  r1,[r2]
	mov  r5, #1

loop:
	tst r8, #0b00100
	lsleq r5, #1					/* Shift left 1  */
	streq r5, [r0]					/* Switch off led*/
	b loop
	
END:	B END
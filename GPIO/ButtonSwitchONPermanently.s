// both on permanently

.include "configuration.inc" 
	ldr  r0, =0x3F20001C		/* On Address */
	ldr  r1, =0x3F200028	 	/* Off Address */
	ldr  r3, =0x3F200034  


loop:
	ldr  r8,[r3]
	tst r8, #0b001000		
	ldr  r4,=0x400000
	streq  r4,[r0] 			/* Switch on led */
	
	ldr r5, =0b100000100000000000
	tst r8, #0b00100
	streq r5, [r0]			/* Switch off led*/
	b loop
END:	B END

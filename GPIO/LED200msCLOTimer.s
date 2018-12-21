// led on 0'2 s

.include "configuration.inc" 
	ldr  r6, =0x3F20001C		/* On Address */
	ldr  r1, =0x3F200028	 	/* Off Address */
	ldr  r3, =0x3F200034  

loop:
	ldr  r5,=0x200
	str  r5,[r6] 			/* Switch on led */
	bl wait
	str r5, [r1]	
	bl wait
	b loop
	
wait:
	ldr r0, =0x3F003004
	ldr r3,[r0]
	ldr r4, =200000
	add r4, r3, r4
ret1:    
	ldr r3,[r0]
	cmp  r3,r4
	blt ret1
	bx   lr	

END:	B END
// led on 500 then 250 and then 125

.data
tam: .word 3
time: .word 500000, 250000, 125000

.include "configuration.inc" 
	ldr  r1, =0x3F20001C		/* On Address */
	ldr  r2, =0x3F200028	 	/* Off Address */
	ldr  r3, =0x3F200034  	/* CLK */

main:
	ldr r4, =time
	ldr r5, =tam
	ldr r5, [r5]

loop:
	cmp r5, #0			/* if tam = 0 reload loop */
	beq main
	
	ldr  r7,=0x200			/* red led */
	str  r7,[r1] 			/* Switch on led */
	
	ldr r6, [r4], #4			/* load array content */
	bl wait
	
	str r7, [r2]				/* Switch off led */
	bl wait
	
	sub r5, #1
	b loop
	
wait:
	ldr r0, =0x3F003004
	ldr r3,[r0]
	mov r8, r6				/* Wait current array content*/
	add r8, r3, r8
ret1:    
	ldr r3,[r0]
	cmp  r3,r8
	blt ret1
	bx   lr	

END:	B END
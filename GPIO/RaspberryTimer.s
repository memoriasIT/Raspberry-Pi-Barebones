/* CONFIG */
	/* Stack init for SVC mode
	mov     r0, #0b11010011
	msr     cpsr_c, r0
	mov     sp, #0x8000000 */ 
	/* GPIO config */
	.include "configuration.inc"
	.set GPBASE, 0x3F200000
	.set GPSET0, 0X01C
	.set GPCLR0, 0X028
	ldr  r5, =GPBASE
	ldr  r1, =0x08400000
	ldr  r6, =0x200


loop: str  r1, [r5,#GPSET0]		/* HIGH */
	bl  wait
	str  r1,[r5,#GPCLR0]		/* LOW */
	bl  wait			
	push {lr}
	b   loop


wait: ldr r0, =0x3F003004		/* CLO Address */
	ldr r3,[r0]				/* CLO Value */
	ldr r4, =500000			/* r4 = 0.5s */
	add r4, r3, r4			/* CLO + 0.5 = endtime*/
ret1: ldr r3,[r0]				/* Read CLO */
	cmp  r3,r4				/* Cmp endtime - CLO */
	blt ret1				/* Not yet */
	pop  lr    
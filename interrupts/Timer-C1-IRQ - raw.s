	.include "configuration.inc" 
	.include "inter.inc"

main:
	/* Vector Table inicialization */ 
	mov r0,#0
	ADDEXC 0x18, IRQ

	/* Start IRQ Mode*/
	mov r0, #0b01010010    
	msr cpsr_c, r0
	mov sp, #0x8000 

	/* Interrupt with falling edge */
	ldr r0, =GPBASE
	mov r1, #0b01100
	str r1, [r0, #GPFEN0]
	
	/* Enable local interrupt by comparator C1 */
	ldr r0, =INTBASE
	mov r1, #0b0010
	str r1, [r0, #INTENIRQ1]
	
	/* global interrupt */
	mov r1, #0b01010011
	msr cpsr_c, r1
	
	/* XORS and SOUND*/
	mov r6, #1
	ldr  r1, =0x08400000
	
	/* interrupt after 500 microseconds */
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, #500
	str r1, [r0, #STC1]

x: 	b x

IRQ:
	push {r0}

sound: 
	eors r6, #1
	
	ldr r0, =GPBASE
	mov r1, #0x010
	streq  r1, [r0,#GPSET0]			/* HIGH */
	strne r1,[r0,#GPCLR0]				/* LOW */
	
	/* interrupt after 500 microseconds */
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, #500
	str r1, [r0, #STC1]
	
	/* Reset interrupt IRQ2 */
	ldr r0, =STBASE
	mov r1, #0b0010
	str r1, [r0, #STCS]
	
	pop {r0}
	subs pc, lr, #4

















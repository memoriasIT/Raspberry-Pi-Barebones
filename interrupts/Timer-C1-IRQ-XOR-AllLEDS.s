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
	
	/* XORS and LED Config */
	mov r6, #1
	mov r7, #2
	mov r8, #0x100
 	ldr  r9, =0x3F20001C  	/* On */
	ldr r10, =0x3F200028	/* Off */	
	
	/* interrupt after 0.5 s */
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r2
	str r1, [r0, #STC1]

x: 	b x

IRQ:
	push {r0}
	
	// Change multiply
	cmp r8, #0x400
	movgt r7, #200
	movlt r7, #2
	
	// Switch OFF last LED
	str  r8,[r10]
	
	// Switch ON next LED
	mul r3, r8, r7
	mov r8, r3 	// First	
	str  r8,[r9]

	
	/* interrupt after 0.5 s */
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r2
	str r1, [r0, #STC1]
	
	/* Reset interrupt IRQ2 */
	ldr r0, =STBASE
	mov r1, #0b0010
	str r1, [r0, #STCS]
	
	pop {r0}
	subs pc, lr, #4

















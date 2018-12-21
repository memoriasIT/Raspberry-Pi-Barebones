	.include "configuration.inc" 
	.include "inter.inc"

main:
	/* Vector Table inicialization */ 
	mov r0,#0
	ADDEXC 0x1C, vvv

	/* Stack init for FIQ mode */   
	mov r0, #0b01010001  
	msr cpsr_c, r0
	mov sp, #0x4000         

	/* Interrupt with falling edge */
	ldr r0, =GPBASE
	mov r1, #0b01100
	str r1, [r0, #GPFEN0]
	
	/* Enable local interrupt FIQ */
	ldr r0, =INTBASE
	ldr r8, =0x0B4
	str r8, [r0, #INTFIQCON]
	
	/* global interrupt */
	mov r1, #0b10010011
	msr cpsr_c, r1
	
x: b x

vvv:
	/* Check GPIO2 */
	ldr r0, =GPBASE
	ldr r1, [r0, #GPLEV0]
	tst r1,#0b00100
	
	/* Switch on led */
	ldr  r0, =0x3F20001C  
	ldr  r1, =0x400000    
	str  r1,[r0]
	
	/* Reset interrupt IRQ2 */
	ldr r0, =GPBASE
	mov r1, #0b01100
	str r1, [r0, #GPEDS0]
	subs pc, lr, #4






















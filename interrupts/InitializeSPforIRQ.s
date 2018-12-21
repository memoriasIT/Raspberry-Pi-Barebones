	#include "configuration.inc"
	#include "inter.inc"

// Set Vector Table
	mov r0, #0
	 ADDEXC 0x18, irq_handler
	 ADDEXC 0x1c, fiq_handler

// Enter IRQ mode
//10001 Fast interrupt (FIQ) 
//10010 Regular interrupt (IRQ) 
//10011 Supervisor (SVC)
	mov r0, #0b11010001
	msr cpsr_c, r0

// SP with value 0x8 000 000
	mov sp, #0x8000000


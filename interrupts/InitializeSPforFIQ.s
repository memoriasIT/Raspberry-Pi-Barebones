#include "configuration.inc"
#include "inter.inc"

// Set Vector Table
mov r0, #0
ADDEXC 0x18, irq_handler
ADDEXC 0x1c, fiq_handler

// Enter IRQ mode
mov r0, #0b11010001
msr cpsr_c, r0

// SP with value 0x4000
mov sp, #0x4000


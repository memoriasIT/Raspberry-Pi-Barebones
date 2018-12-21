/*CONFIG */
	.include "configuration.inc"
	.set GPBASE, 0x3F200000
	.set GPSET0, 0X01C
	.set GPCLR0, 0X028
	ldr  r0, =GPBASE
	ldr  r1, =0x08400000


loop: str  r1, [r0,#GPSET0]		/* HIGH */
	bl  wait			
	str  r1,[r0,#GPCLR0]		/* LOW */
	bl  wait			
	b    loop

wait: ldr  r8, =833333
time:subs r8, #1
	bne  time
	bx lr
	

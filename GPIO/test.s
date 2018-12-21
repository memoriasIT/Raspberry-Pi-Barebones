wait: ldr r0, =0x3F003004		/* CLO Address */
	ldr r3,[r0]				/* CLO Value */
	ldr r4, =500000			/* r4 = 0.5s */
	add r4, r3, r4			/* CLO + 0.5 = endtime*/
ret1: ldr r3,[r0]				/* Read CLO */
	cmp  r3,r4				/* Cmp endtime - CLO */
	blt ret1				
	bx   lr    
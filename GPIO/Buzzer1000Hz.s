/*CONFIG */
.include "configuration.inc"

/* RED LED */
ldr  r0, =0x3F20001C  
ldr  r1, =0x200    
str  r1,[r0]

/* BUZZER */
ldr  r0, =0x3F20001C  	/* r0 HIGH */
ldr  r2, =0x3F200028   	/* r2 LOW   */
ldr  r1, =0x010 

loop: str  r1,[r0] 		/* HIGH */
	bl  wait			/* Wait 200 ms */
	str  r1,[r2]			/* LOW */
	bl  wait			/* Wait 200 ms */
	b    loop

wait: ldr  r8, =770  
time:subs r8, #1
	bne  time
	bx lr
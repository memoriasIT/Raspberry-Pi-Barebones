	.include "configuration.inc"
	.include "inter.inc"
	mov r0,#0
	ADDEXC 0x18, regular_interrupt
	ADDEXC 0x1C, fast_interrupt 
	ldr r2, =7						// Counter for LED and corresponding sound
	ldr r3, =0x3F20001C				// ON Address
	ldr r4, =0x3F200028				// OFF Address
	ldr r5, =1000000				// Interrupt Time (1 second)
	ldr r6, =1						// XOR Buzzer
		
	/* Stack init for IRQ mode */
	mov r0, #0b11010010
	msr cpsr_c, r0
	mov sp, #0x8000
	/* Stack init for FIQ mode */
	mov r0, #0b11010001
	msr cpsr_c, r0
	mov sp, #0x4000
	/* Stack init for SVC mode */
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000
		
	/*COMPARATOR C1*/
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, r5 
	str r1, [r0, #STC1]
	
	// Enable IRQ (SVC Mode)
	mov r1, #0b01010011
	msr cpsr_c, r1
		
	// Enable time interrupt by C1
	ldr r0,=INTBASE
	mov r1, #0b0010 
	str r1,[r0,#INTENIRQ1]
		
	/*COMPARATOR C3*/
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, #1536 
	str r1, [r0, #STC3]
	
	// Enable FIQ with C3
	ldr    r0,  =INTBASE
	ldr    r1, =0x083 
	str    r1, [r0, #INTFIQCON]
	
	// Enable FIQ (SVC Mode)
	mov r1, #0b00010011 
	msr cpsr_c, r1   
		
x: 	b x
	
regular_interrupt:
	push {r12}
	
	// LED 1
	cmp r2,#7
	ldreq r8, =0x200
	streq r8,[r3]
	
	// LED 2
	cmp r2,#6
	streq r8,[r4]
	ldreq r8, =0x400
	streq r8,[r3]
	
	// LED 3
	cmp r2,#5
	streq r8,[r4]
	ldreq r8, =0x800
	streq r8,[r3]
	
	// LED 4
	cmp r2,#4
	streq r8,[r4]
	ldreq r8, =0x20000
	streq r8,[r3]

	// LED 5
	cmp r2,#3
	streq r8,[r4]
	ldreq r8, =0x400000
	streq r8,[r3]

	// LED 6
	cmp r2,#2
	streq r8,[r4]
	ldreq r8, =0x8000000
	streq r8,[r3]

	// LED 7
	cmp r2,#1
	streq r8,[r4]
	
	// Reset LED Counter
	cmp r2,#0
	addeq r2,r2,#8
	
	// Counter-- for next interrupt
	sub r2,r2,#1
	
	// Prepare C1 for next interrupt
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, r5
	str r1, [r0, #STC1]
	
	// Reset C1 comparator
	ldr r0, =STBASE
	mov r1, #0b0010 
	str r1,[r0,#STCS]
	
	// Back
	pop {r12}
	subs pc, lr, #4 
		
fast_interrupt:
	push {r12}
	ldr r8, =0x010 // Buzzer Address
	
	// XOR On-Off routine
	eors r6,#1
	streq r8,[r3]
	strne r8,[r4]
	
	// LED 1
	cmp r2,#7
	ldreq r10, =1136
	
	// LED 2
	cmp r2,#6
	ldreq r10, =2272
	
	// LED 3
	cmp r2,#5
	ldreq r10, =4544
	
	// LED 4
	cmp r2,#4
	ldreq r10, =9088
	
	// LED 5
	cmp r2,#3
	ldreq r10, =12176
	
	// LED 6
	cmp r2,#2
	ldreq r10, =1706
	
	// LED 7
	cmp r2,#1
	ldreq r10, =1984
	
	// LED 8
	cmp r2,#0
	ldreq r10, =851
	
	// Prepare C3 for next interrupt
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	add r1, r10
	str r1, [r0, #STC3]
	
	// Reset interrupt
	ldr r0, =STBASE
	mov r1, #0b01000 
	str r1,[r0,#STCS]
	
	// Back
	pop {r12}
	subs pc, lr, #4 
		
		
		
		
		
		
		
		
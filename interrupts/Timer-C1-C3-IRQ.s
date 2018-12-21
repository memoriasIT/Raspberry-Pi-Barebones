.include "configuration.inc" 
.include "inter.inc"

	// Vector Table inicialization
	mov r0,#0
	ADDEXC 0x18, IRQ 

	// Stack init for IRQ mode
	mov r0, #0b11010010    
	msr cpsr_c, r0
	mov sp, #0x8000 

	// Stack init for FIQ mode
	mov r0, #0b11010001 
	msr cpsr_c, r0
	mov sp, #0x4000         

	// Stack init for SVC mode
	mov r0, #0b11010011
	msr  cpsr_c, r0
	mov sp, #0x8000000
	
	// Wait time for comparator
	ldr r7, =0x30D40
	ldr r10, =0x470
	
	// Interrupt 200ms
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO] 
	add   r1, r7
	str r1, [r0, #STC1] 
	
	// Interrupt 440Hz
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO] 
	add   r1, r10
	str r1, [r0, #STC3] 
	
	// Enable local interrupt by both comparators
	ldr r0,=INTBASE
	mov r1, #0b1010
	str r1,[r0,#INTENIRQ1] 
	
	// Global interrupt
	mov r1, #0b01010011 
	msr cpsr_c, r1   
	
	// Addresses used as variables
	ldr r6, =0x0 	// Led Counter
	ldr r8, =0x0 	// XOR LED On-Off
	ldr r11, =0x0	// XOR Buzzer On-Off
	
x:	b x

IRQ:
	// Check Interrupt trigger
	push {r7} 			
	ldr  r0, =STBASE
	ldr  r2, [r0, #STCS]
	tst r2, #0b1000
	
	beq leds
	bne sound

sound:
	ldr r3, =0x3F20001C 	//On
	ldr r9, =0x3F200028 // Off
	ldr r5, =0x010		// Buzzer
	
	// On-Off loop
	eors r11, #1		
	streq r5, [r3]
	strne r5, [r9]
	
	// Interrupt buzzer 440Hz
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO] 
	add   r1, r10
	str r1, [r0, #STC3]

	// Reset interrupt with comparator3
	ldr   r0, =STBASE
	mov r1, #0b1010   
	str   r1,[r0,#STCS]	
	
	b back
	
back:					
	pop {r7}	
	subs   pc, lr , #4


leds:	
	ldr r3, =0x3F20001C 	//On
	ldr r9, =0x3F200028	//Off

	// interrupt after 200ms
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO] 
	add   r1, r7
	str r1, [r0, #STC1]
	
	//Reset interrupt
	ldr   r0, =STBASE
	mov    r1, #0b1010   
	str   r1,[r0,#STCS]	
	
	cmp r6,#0
	beq red1

	cmp r6,#1
	beq red2
	
	cmp r6,#2
	beq yellow1
	
	cmp r6,#3
	beq yellow2

	cmp r6,#4
	beq green1
	
	cmp r6,#5
	beq green2

red1:
	ldr r5, =0x200	// Red 1 address
	eors r8, #0	// XOR
	streq r5, [r3] 	// 1st loop -> ON
	ldreq r8, =0x1	// Set r8 = 1 for next loop
	
	strne r5, [r9]	// 2nd loop -> OFF
	ldrne r8, =0x0	// 2nd loop -> r8 to 0 again
	ldrne r6, =0x1	// Set r6 counter for next LED
	b back

red2:
	ldr r5, =0x400	// Red 2 address
	eors r8, #0	// XOR
	streq r5, [r3]	// 1st loop -> ON
	ldreq r8, =0x1	// Set r8 = 1 for next loop
	
	strne r5, [r9]	// 2nd loop -> OFF
	ldrne r8, =0x0	// 2nd loop -> r8 to 0 again 
	ldrne r6, =0x2	// Set counter to 2 for next LED
	b back

yellow1:
	ldr r5, =0x800	// Yellow 1 address
	eors r8, #0	// XOR
	streq r5, [r3]	// 1st loop -> ON
	ldreq r8, =0x1	// Set r8 = 1 for next loop
	
	strne r5, [r9]	// 2nd loop -> OFF
	ldrne r8, =0x0	// 2nd loop -> r8 to 0 again 
	ldrne r6, =0x3	// Set counter to 3 for next LED
	b back
			
yellow2:
	ldr r5, =0x20000 // Yellow 2 address
	eors r8, #0	 // XOR
	streq r5, [r3]	 // 1st loop -> ON
	ldreq r8, =0x1	 // Set r8 = 1 for next loop
	
	strne r5, [r9]	// 2nd loop -> OFF
	ldrne r8, =0x0	// 2nd loop -> r8 to 0 again 
	ldrne r6, =0x4	// Set counter to 4 for next LED
	b back

green1:
	ldr r5, =0x400000
	eors r8, #0
	streq r5, [r3]
	ldreq r8, =0x1
	strne r5, [r9]
	
	ldrne r8, =0x0
	ldrne r6, =0x5
	b back

green2:
	ldr r5, =0x8000000
	eors r8, #0
	streq r5, [r3]
	ldreq r8, =0x1			
	ldrne r5, =0x08420E00	
	
	strne r5,[r9]
	ldrne r8, =0x0
	ldrne r6, =0x0
	b back
// --{ INCLUDES }--
.include "configuration.inc"
.include "inter.inc"

// --{ SETUP }--
// Raspberry pi 3 Hypervisor
.text
mrs r0,cpsr
mov r0, #0b11010011   
msr spsr_cxsf,r0
add r0,pc,#4
msr ELR_hyp,r0
eret


// Startup Melody
b startup_melody
endmelody:

// --{ SET CONTROLS }--
// Time first 1 second (in microseconds)
ldr r1, =0x0100590
// Button 1 - Player 1
ldr r3, =0x3F200034
// Button 2 - Player 2
ldr r4, =0x3F200038

// --{ GAME START }--
start:
    // SET ADDRESS
    ldr  r0, =0x3F20001C  
    // LED P1
    ldr r7, =0x200
    // LED P2
    ldr r8, =0x800
    // Clean registers
    sub r5, r5, r5
    sub r6, r6, r6
    sub r2, r2, r2


start_loop:
    // Player 1 Ready
    ldr r9, [r3]
    tst r9, #0b00100                // Test Buton
    moveq r5, #0b01                 // Set P1 = Ready
    streq r7, [r0]                  // LED ON

    // Player 2 Ready
    tst r9, #0b001000               // Test Button2
    moveq r6, #0b01                 // Set P2 = Ready
    streq r8, [r0]                  // LED ON


    // Both players ready?
    cmp r5, #0b01                   // Test P1
    beq p2_test                     // Test P2
    b start_loop                    // Not ready yet

p2_test:
    cmp r6, #0b01
    beq next_round   // P2 also ready
    b start_loop    // Not ready yet




// --{ NEXT_ROUND }--
next_round:
    // Wait half a second
    ldr r0, =0x3F003004     // CLO Address
	ldr r3,[r0]             // Current time
    ldr r4, =200000              
	add r4, r3, r4          // Calculate end time (current + 500)

    waithalfsec:
        // Check time
        ldr r3,[r0]
        cmp  r3,r4
        blt waithalfsec

    // time = time - 50 ms
    ldr r0, =0x0C350
    sub r1, r0
    // If time = 0      -> GOTO end_game
    cmp r1, #0
    //beq end_game
    // Score++
    add r2, #1
    // TODO NewRound Sound
    // Start new Round
    b loop_time



// --{ LOOP TIME }--
loop_time:


    // Set up time
    ldr r0, =0x3F003004     // CLO Address
	ldr r3,[r0]             // Current time
    mov r4, r1              
	add r4, r3, r4          // Calculate end time (current + round)

    // Switch light
    // All off
    ldr r5, =0x3F200028
    ldr r6, =0x08420E00		
	str r6,[r5]

    // Random on by seeding clock
    bl switch_light

playing_setup:
    // Button 1 - Player 1
    ldr r8, =0x3F200034
    // Button 2 - Player 2
    ldr r9, =0x3F200038

playing:    
    // Check if button was pulsed 
    // r7 < 3 -> P1
    // r7 > 2 -> P2

    // Player 1 Press
    ldr r10, [r8]
    tst r10, #0b00100                // Test Buton
    bleq check_move1


    // Player 2 Press
    tst r10, #0b001000               // Test Button2
    bleq check_move2


    // Check time
	ldr r3,[r0]
	cmp  r3,r4
	blt playing
    b end_game


// Check if the button pressed by P1 was a good move or not
check_move1:
    cmp r7, #4
    blt next_round  // Correct
    beq end_game_p1
    bgt end_game_p1    // Incorrect

    bx lr


// Check if the button pressed by P2 was a good move or not
check_move2:
    cmp r7, #4
    beq next_round
    bgt next_round  // Correct
    blt end_game_p2    // Incorrect

    bx lr




//--{ SWITCH RANDOM LIGHT }--
switch_light:
    ldr r5, =0x3F20001C	
    and r7, r3, #0b00111

    // LED 1
	cmp r7,#0
	ldreq r8, =0x200
	streq r8,[r5]
    	
    cmp r7,#1
	ldreq r8, =0x200
	streq r8,[r5]
	
	// LED 2
	cmp r7,#2
	ldreq r8, =0x400
	streq r8,[r5]
	
	// LED 3
	cmp r7,#3
	ldreq r8, =0x800
	streq r8,[r5]
	
	// LED 4
	cmp r7,#4
	ldreq r8, =0x20000
	streq r8,[r5]

	// LED 5
	cmp r7,#5
	ldreq r8, =0x400000
	streq r8,[r5]

	// LED 6
	cmp r7,#6
	ldreq r8, =0x8000000
	streq r8,[r5]

    cmp r7,#7
	ldreq r8, =0x8000000
	streq r8,[r5]

    bx lr


// --{ END GAME }--
// P1 Loses
end_game_p1:
    // Switch on and off lights
    bl flash_lights
    
    // Switch left red led
    cmp r7, #4
    ldr r3, =0x3F20001C // ON Address
    ldr r8, =0x400    // Left red led
    str r8,[r3]

    b score_draw

    // P2 Loses
end_game_p2:
    // Switch on and off lights
    bl flash_lights
    // Switch light
    // All off
    ldr r5, =0x3F200028
    ldr r6, =0x08420E00		
	str r6,[r5]

    // Switch left red led
    cmp r7, #4
    ldr r3, =0x3F20001C // ON Address
    ldr r8, =0x200    // Left red led
    str r8,[r3]

    b score_draw


flash_lights:

    // Switch light
    // All off
    ldr r5, =0x3F200028
    ldr r6, =0x08420E00		
	str r6,[r5]

    // Wait half a second
    ldr r0, =0x3F003004     // CLO Address
	ldr r3,[r0]             // Current time
    ldr r4, =200000              
	add r4, r3, r4          // Calculate end time (current + 500)

    waitflashsec:
        // Check time
        ldr r3,[r0]
        cmp  r3,r4
        blt waitflashsec
    
    // All on
    ldr  r0, =0x3F20001C  	/*r0 contents the port address for ON */
	ldr  r1, =0x08420E00		
	str  r1,[r0]

    
    // Wait half a second
    ldr r0, =0x3F003004     // CLO Address
	ldr r3,[r0]             // Current time
    ldr r4, =200000              
	add r4, r3, r4          // Calculate end time (current + 500)

    waitflashsec2:
        // Check time
        ldr r3,[r0]
        cmp  r3,r4
        blt waitflashsec2

    // Switch light
    // All off
    ldr r5, =0x3F200028
    ldr r6, =0x08420E00		
	str r6,[r5]


    bx lr

// --{ SCORE DRAW PINOUT }--

// DEC  BIN    LEDS          NUMBERS                FULL_ADDRESS
//  0  (0000)                -                 00000000000000000000000000000000
//  1  (0001) - GR           - 27              00001000000000000000000000000000
//  2  (0010) - GL           - 22              00000000010000000000000000000000    
//  3  (0011) - GL GR        - 27 22           00001000010000000000000000000000
//  4  (0100) - YR           - 17              00000000000000100000000000000000
//  5  (0101) - YR GR        - 17 27           00001000000000100000000000000000
//  6  (0110) - YR GL        - 17 22           00000000010000100000000000000000
//  7  (0111) - YR GL GR     - 17 27 22        00001000010000100000000000000000
//  8  (1000) - YL           - 11              00000000000000000000100000000000
//  9  (1001) - YL GR        - 11 27           00001000000000000000100000000000
//  10 (1010) - YL GL        - 11 22           00000000010000000000100000000000
//  11 (1011) - YL GL GR     - 11 22 27        00001000010000000000100000000000
//  12 (1100) - YL YR        - 11 17           00000000000000100000100000000000
//  13 (1101) - YL YR GR     - 11 17 27        00001000000000100000100000000000
//  14 (1110) - YL YR GL     - 11 17 22        00000000010000100000100000000000
//  15 (1111) - YL YR GL GR  - 11 17 22 27     00001000010000100000100000000000


score_draw:
    ldr r0, =0x3F20001C
    sub r2, #1

    cmp r2, #0
    ldreq  r1, =0b00000000000000000000000000000000    
    streq r1,[r0]

    cmp r2, #1
    ldreq  r1, =0b00001000000000000000000000000000
    streq r1,[r0]

    cmp r2, #2
    ldreq  r1, =0b00000000010000000000000000000000     
    streq r1,[r0]

    cmp r2, #3
    ldreq  r1, =0b00001000010000000000000000000000    
    streq r1,[r0]

    cmp r2, #4
    ldreq  r1, =0b00000000000000100000000000000000    
    streq r1,[r0]

    cmp r2, #5
    ldreq  r1, =0b00001000000000100000000000000000  
    streq r1,[r0]

    cmp r2, #6
    ldreq  r1, =0b00000000010000100000000000000000    
    streq r1,[r0]
    
    cmp r2, #7
    ldreq  r1, =0b00001000010000100000000000000000    
    streq r1,[r0]

    cmp r2, #8
    ldreq  r1, =0b00000000000000000000100000000000    
    streq r1,[r0]

    cmp r2, #9
    ldreq  r1, =0b00001000000000000000100000000000    
    streq r1,[r0]

    cmp r2, #10
    ldreq  r1, =0b00000000010000000000100000000000    
    streq r1,[r0]

    cmp r2, #11
    ldreq  r1, =0b00001000010000000000100000000000    
    streq r1,[r0]

    cmp r2, #12
    ldreq  r1, =0b00000000000000100000100000000000    
    streq r1,[r0]

    cmp r2, #13
    ldreq  r1, =0b00001000000000100000100000000000    
    streq r1,[r0]

    cmp r2, #14
    ldreq  r1, =0b00000000010000100000100000000000    
    streq r1,[r0]
    
    cmp r2, #15
    ldreq  r1, =0b00001000010000100000100000000000    
    streq r1,[r0]


    b halt


end_game:

    bl flash_lights


// Play sound
endsound: 
    ldr  r5, =1200           /* Note     */
    ldr  r3, =500           /* Duracion */

    ldr  r0, =0x3F20001C  	/* r0 HIGH  */
    ldr  r6, =0x3F200028   	/* r2 LOW   */
    ldr  r1, =0x010         // Buzzer
loopnoteend: 
    str  r1,[r0] 		/* HIGH */
	bl  waitnoteend			/* Wait 200 ms */
	str  r1,[r6]		/* LOW */
	bl  waitnoteend			/* Wait 200 ms */

    sub r3, #1
    cmp r3, #0
    beq note_endsound        // Note length
	bne loopnoteend

waitnoteend: mov  r4, r5
timeend:subs r4, #1
	bne  timeend
	bx lr

note_endsound:

    // Correct
    // r7 < 3 -> P1
    // r7 > 2 -> P2
    cmp r7, #4
    blt end_game_p1  // P1 Loses
    b   end_game_p2  // P2 Loses


    
    
halt: b halt



// Startup Melody
    //-------------------
startup_melody:

push {r0-r5}
note1: 
    ldr  r5, =500           /* Note     */
    ldr  r3, =500           /* Duracion */

    ldr  r0, =0x3F20001C  	/* r0 HIGH  */
    ldr  r2, =0x3F200028   	/* r2 LOW   */
    ldr  r1, =0x010         // Buzzer
loopnote1: 
    str  r1,[r0] 		/* HIGH */
	bl  waitnote1			/* Wait 200 ms */
	str  r1,[r2]		/* LOW */
	bl  waitnote1			/* Wait 200 ms */

    sub r3, #1
    cmp r3, #0
    beq note_1end        // Note length
	bne loopnote1

waitnote1: mov  r4, r5
time1:subs r4, #1
	bne  time1
	bx lr

note_1end:
//--------------------------

note2: 
    ldr  r5, =900           /* Note     */
    ldr  r3, =300           /* Duracion */

    ldr  r0, =0x3F20001C  	/* r0 HIGH  */
    ldr  r2, =0x3F200028   	/* r2 LOW   */
    ldr  r1, =0x010         // Buzzer
loopnote2: 
    str  r1,[r0] 		/* HIGH */
	bl  waitnote2			/* Wait 200 ms */
	str  r1,[r2]		/* LOW */
	bl  waitnote2			/* Wait 200 ms */

    sub r3, #1
    cmp r3, #0
    beq note_2end        // Note length
	bne loopnote2

waitnote2: mov  r4, r5
time2:subs r4, #1
	bne  time2
	bx lr

note_2end:

//--------------------------

note3: 
    ldr  r5, =1200           /* Note     */
    ldr  r3, =200           /* Duracion */

    ldr  r0, =0x3F20001C  	/* r0 HIGH  */
    ldr  r2, =0x3F200028   	/* r2 LOW   */
    ldr  r1, =0x010         // Buzzer
loopnote3: 
    str  r1,[r0] 		/* HIGH */
	bl  waitnote3			/* Wait 200 ms */
	str  r1,[r2]		/* LOW */
	bl  waitnote3			/* Wait 200 ms */

    sub r3, #1
    cmp r3, #0
    beq note_3end        // Note length
	bne loopnote3

waitnote3: mov  r4, r5
time3:subs r4, #1
	bne  time3
	bx lr

note_3end:

pop {r0-r5}

b endmelody
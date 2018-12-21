.include "configuration.inc"
.include "inter.inc"

main:
    // Vector table inicialization
    mov r0, #0
    ADDEXC 0x1C, fast_interrupt
    
    // Stack init for IRQ
    mov     r0, #0b11010010    
    msr     cpsr_c, r0
    mov     sp, #0x8000
    
    // Stack Init for FIQ
    mov     r0, #0b11010001    
    msr     cpsr_c, r0
    mov     sp, #0x4000
    
    // Stack Init SVC mode
    mov     r0, #0b11010011
    msr     cpsr_c, r0
    mov     sp, #0x8000000
    
    // Send interrupt after 500 microseconds
    ldr r0, =STBASE
    ldr r1, [r0, #STCLO]
    add   r1, #500  
    str r1, [r0, #STC3]
    
    // Enable FIQ
    ldr r0,=INTBASE
    ldr r1, =0x083 
    str r1,[r0,#INTFIQCON]
    
    // Enable FIQ (SVC mode)
    mov r1, #0b10010011
    msr cpsr_c, r1  
        
    ldr r2, =0x0
       
x:  b x
       
fast_interrupt: 
    push {r8}

    ldr r3,= 0x010      // Buzzer
    ldr r4, =0x3F20001C // ON
    ldr r5, =0x3F200028 // OFF
   
    // XOR loop
    eors  r2, #1
    streq r3, [r4]
    strne r3, [r5]
    
    // Send interrupt with C3 after 500 microseconds
    ldr r0, =STBASE
    ldr r1, [r0, #STCLO]
    add r1, #500
    str r1, [r0, #STC3]
    
    // Reset interrupt by C3
    ldr r0, =STBASE
    mov r1, #0b01000  
    str r1,[r0,#STCS]
    
    pop {r8}
    subs    pc, lr , #4
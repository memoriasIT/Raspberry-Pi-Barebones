.include "configuration.inc" // Set GPIO as I/O

ldr  r0, =0x3F20001C  
ldr  r1, =0x400000    
str  r1,[r0]
end:
b end

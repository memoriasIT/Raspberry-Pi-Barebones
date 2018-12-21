.include "configuration.inc"

loop:ldr r0, =0x3F200034
	ldr r8, [r0]
	tst r8, #0b00100
	beq btn2
	b loop

btn2: ldr  r0,=0x3F20001C
	 ldr  r1, =0x200
	 str  r1,[r0]
	 
        .syntax unified
        
        .text
        .align  2


__vectors:
        .long   __stack
        .long   Reset_Handler
        .size   __vectors, . - __vectors

        .equ    PORT,   0x41008000
        .equ    PORTA,  PORT
        .equ    PORTB,  PORT + 0x80
        .equ    DIR,    0x00
        .equ    DIRCLR, 0x04
        .equ    DIRSET, 0x08
        .equ    DIRTGL, 0x0c
        .equ    OUT,    0x10
        .equ    OUTCLR, 0x14
        .equ    OUTSET, 0x18
        .equ    OUTTGL, 0x1c
        .equ    IN,     0x20
        .equ    CTRL,   0x24
        .equ    WRCONF, 0x28
        .equ    EVCTRL, 0x2c

        .globl  Reset_Handler
        .thumb_func
Reset_Handler:
        @@@     Set PA16 to OUTPUT
        LDR     R0, =PORTA
        MOVS    R2, #1
        LSLS    R2, #16
        STR     R2, [R0, DIRSET]

toggle:
        STR     R2, [R0, OUTTGL]
        MOVS    R3, #1
        LSLS    R3, #20

delay:
        SUBS    R3, R3, #1
        BNE     delay
        B       toggle

.end

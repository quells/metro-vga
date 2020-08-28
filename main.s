        .syntax unified

        .text
        .align  2

__vectors:
        .long   __stack
        .long   Reset_Handler
        .size   __vectors, . - __vectors

        .equ    PORT,   0x41008000
        .equ    PORTA,  PORT
        @@@@    TODO: find PORTB pins
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

        .equ    INTERVAL, 0x16

        .equ    VSYNC, 0x00010000 @ D13
        .equ    HSYNC, 0x00000004 @ A0
        .equ    VGA_R, 0x00000020 @ A1
        .equ    VGA_G, 0x00000040 @ A2
        .equ    VGA_B, 0x00000010 @ A3
        .equ    VGA_A, 0x00010074

        .globl  Reset_Handler
        .thumb_func
Reset_Handler:
        @@@     Set pins A0-3, D13 to output
        LDR     R0, =PORTA
        LDR     R2, =VGA_A
        STR     R2, [R0, DIRSET]

        LDR     R2, =VSYNC
        STR     R2, [R0, OUTSET]
loop:
        LDR     R2, =VSYNC
        LDR     R3, =HSYNC
        ADD     R2, R2, R3
        STR     R2, [R0, OUTTGL]
        MOV     R3, #1
        LSL     R3, INTERVAL
        BL      delay

        LDR     R2, =HSYNC
        LDR     R3, =VGA_R
        ADD     R2, R2, R3
        STR     R2, [R0, OUTTGL]
        MOV     R3, #1
        LSL     R3, INTERVAL
        BL      delay

        LDR     R2, =VGA_R
        LDR     R3, =VSYNC
        ADD     R2, R2, R3
        STR     R2, [R0, OUTTGL]
        MOV     R3, #1
        LSL     R3, INTERVAL
        BL      delay

        B       loop

delay:
        SUBS    R3, R3, #1
        BNE     delay
        MOV     PC, LR

.end

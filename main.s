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

        .equ    INTERVAL, 0x17

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
        LDR     R6, =PORTA
        LDR     R2, =VGA_A
        STR     R2, [R6, DIRSET]

        LDR     R7, =VSYNC
        LDR     R8, =HSYNC
        LDR     R9, =VGA_R
        STR     R7, [R6, OUTSET]
loop:
        EOR     R0, R7, R8              @ R0 = VSYNC | HSYNC
        STR     R0, [R6, OUTTGL]        @ Toggle PORTA from VSYNC to HSYNC
        MOV     R3, #1
        LSL     R3, INTERVAL
        BL      delay

        EOR     R0, R8, R9              @ R0 = HSYNC | VGA_R
        STR     R0, [R6, OUTTGL]        @ Toggle PORTA from HSYNC to VGA_R
        MOV     R3, #1
        LSL     R3, INTERVAL
        BL      delay

        EOR     R0, R9, R7
        STR     R0, [R6, OUTTGL]
        MOV     R3, #1
        LSL     R3, INTERVAL
        BL      delay

        B       loop

delay:
        SUBS    R3, R3, #1
        BNE     delay
        MOV     PC, LR

.end

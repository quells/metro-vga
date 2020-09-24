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

        @@@@    PORTA
        .equ    A0,  0x00000004 @ PA02
        .equ    A1,  0x00000020 @ PA05
        .equ    A2,  0x00000040 @ PA06
        .equ    A3,  0x00000010 @ PA04
        .equ    D00, 0x00800000 @ PA23
        .equ    D01, 0x00400000 @ PA22
        .equ    D08, 0x00200000 @ PA21
        .equ    D09, 0x00100000 @ PA20
        .equ    D10, 0x00040000 @ PA18
        .equ    D11, 0x00080000 @ PA19
        .equ    D12, 0x00020000 @ PA17
        .equ    D13, 0x00010000 @ PA16

        @@@@    PORTB
        .equ    A4,  0x00000100 @ PB08
        .equ    A5,  0x00000200 @ PB09
        .equ    D02, 0x00020000 @ PB17
        .equ    D03, 0x00010000 @ PB16
        .equ    D04, 0x00002000 @ PB13
        .equ    D05, 0x00004000 @ PB14
        .equ    D06, 0x00008000 @ PB15
        .equ    D07, 0x00001000 @ PB12

        @@@@    VGA
        .equ    VGA_PINS, 0x0003F300 @ All GPIO pins on PORTB
        .equ    HSYNC, A4
        .equ    VSYNC, A5
        .equ    PORCH, 0x00000300 @ porches = HSYNC | VSYNC (unless during V sync pulse)
        .equ    HSYNCP, VSYNC     @ H sync pulse = VSYNC    (unless during V sync pulse)
        .equ    VSP_HP, HSYNC     @ V sync pulse = HSYNC    (unless during H sync pulse)
        .equ    VSP_HS, 0         @ V sync pulse = 0               (during H sync pulse)
        @@@@    TODO: make variables for rgb colors using digital pins on PORTB
        .equ    WHITE, 0x0003F000
        .equ    BLACK, 0x00000300

        .globl  Reset_Handler
        .thumb_func
Reset_Handler:
        @@@     Enable and clear output for all VGA pins
        LDR     R9, =PORTB
        LDR     R8, =VGA_PINS
        STR     R8, [R9, DIRSET]
        STR     R8, [R9, OUTCLR]

        @@@     HSYNC and VSYNC normally high
        LDR     R0, =PORCH
        STR     R0, [R9, OUTSET]

        @@@     600 lines
        MOV     R7, #150
        LSL     R7, R7, #2

loop:
        @@@     Visible pixels for 20us
        LDR     R1, =WHITE
        STR     R1, [R9, OUTSET]
        MOV     R0, #315
        BL      delay
        BL      hblank
        @@@     Check line number
        SUBS    R7, R7, #1
        BNE     loop

vblank:
        @@@     RGB is off for entire vblank - assume we fell through from loop
        @@@     V front porch for 1 line
        BL      vblank_line
        @@@     V sync pulse for 4 lines
        BL      vsync_pulse
        @@@     V back porch for 23 lines
        MOV     R4, 23
vblank_back_porch:
        BL      vblank_line
        SUBS    R4, R4, #1
        BNE     vblank_back_porch
        @@@     Reset line counter and start next frame
        MOV     R7, #150
        LSL     R7, R7, #2
        B       loop

vblank_line:
        PUSH    {LR}
        @@@     H front porch for 21us (only HSYNC | VSYNC high)
        MOV     R0, #330
        BL      delay
        @@@     H sync pulse for 3.2us (only VSYNC high)
        LDR     R1, =HSYNC
        STR     R1, [R9, OUTCLR]
        MOV     R0, #48
        BL      delay
        @@@     H back porch for 2.2us (only HSYNC | VSYNC high)
        STR     R1, [R9, OUTTGL]
        MOV     R0, #29
        BL      delay
        @@@     return
        POP     {PC}

vsync_pulse:
        PUSH    {LR}
        @@@     VSYNC is low for entire sync pulse
        LDR     R1, =VSYNC
        STR     R1, [R9, OUTCLR]
        MOV     R3, #4
vsync_pulse_loop:
        @@@     H front porch for 21us (only HSYNC high)
        MOV     R0, #330
        BL      delay
        @@@     H sync pulse for 3.2us (all low)
        LDR     R2, =HSYNC
        STR     R2, [R9, OUTCLR]
        MOV     R0, #48
        BL      delay
        @@@     H back porch for 2.2us (only HSYNC high)
        STR     R2, [R9, OUTTGL]
        MOV     R0, #29
        BL      delay
        @@@     Loop 4 times
        SUBS    R3, R3, 1
        BNE     vsync_pulse_loop
        @@@     Reset VSYNC to high
        LDR     R1, =VSYNC
        STR     R1, [R9, OUTSET]
        @@@     return
        POP     {PC}

hblank:
        PUSH    {LR}
        @@@     H front porch for 1us (only HSYNC | VSYNC high)
        LDR     R0, =WHITE
        STR     R0, [R9, OUTCLR]
        MOV     R0, #12
        BL      delay
        @@@     H sync pulse for 3.2us (only VSYNC high)
        LDR     R1, =HSYNC
        STR     R1, [R9, OUTCLR]
        MOV     R0, #48
        BL      delay
        @@@     H back porch for 2.2us (only HSYNC | VSYNC high)
        STR     R1, [R9, OUTTGL]
        MOV     R0, #29
        BL      delay
        @@@     return
        POP     {PC}

delay:
delay_loop:
        SUBS    R0, #1
        BNE     delay_loop
        BX      LR

.end

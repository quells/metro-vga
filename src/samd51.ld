MEMORY
{
        BOOT(r)   : ORIGIN = 0x00000000, LENGTH =  16K
        FLASH(rx) : ORIGIN = 0x00004000, LENGTH = 512K - 16K
        SRAM(rwx) : ORIGIN = 0x20000000, LENGTH = 192K
}

ENTRY(Reset_Handler);

SECTIONS
{
        . = ORIGIN(FLASH);

        .text : {
                . = ALIGN(4);
                KEEP(*(.isr_vectors));
                __vec_end__ = .;

                * (.text*);
        } > FLASH

        . = ALIGN(4);
        __text_end__ = .;

        __data_start__ = .;
        .data : AT(__data_start__) {
                . = ALIGN(4);
                * (.bss);
        } > SRAM

        __data_end__ = .;

        __bss_start__ = .;
        .bss (NOLOAD): AT(__bss_start__) {
                . = ALIGN(4);
                * (.bss);
        } > SRAM

        . = ALIGN(4);
        __bss_end__ = .;

        __stack = ORIGIN(SRAM) + LENGTH(SRAM);
}

__end = .;
PROVIDE(end = .);

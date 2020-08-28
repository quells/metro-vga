CC=arm-none-eabi-gcc
AS=arm-none-eabi-as
LD=arm-none-eabi-ld
OBJCOPY=arm-none-eabi-objcopy
OBJDUMP=arm-none-eabi-objdump

BASE=0x4000
ASFLAGS=-g -mthumb -mcpu=cortex-m4
LDFLAGS=-T samd51.ld

OUTDIR=/media/$(shell whoami)/METROM4BOOT/
EXE=metro_vga

SRC=main.s
OBJ=$(SRC:.s=.o)
ELF=$(OBJ:.o=.elf)
BIN=$(ELF:.elf=.bin)
UF2=$(BIN:.bin=.uf2)

all: $(SRC) $(UF2)

.s.o:
	$(CC) $(ASFLAGS) -c $< -o $@

%.elf: %.o samd51.ld
	$(LD) $(LDFLAGS) $< -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.uf2: %.bin
	uf2conv $< --base $(BASE) --output $@

dump: $(ELF)
	$(OBJDUMP) -d $<

install: $(UF2)
	cp $< $(OUTDIR)

.PHONY: clean
clean:
	-rm -f $(OBJ) $(ELF) $(BIN) $(UF2)

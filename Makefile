EXE = metro-vga
BASE = 0x4000
TARGET = /media/$(shell whoami)/METROM4BOOT/

build/%.bin: src/*.rs Cargo.toml
	mkdir -p $(@D)
	cargo objcopy --bin $(EXE) --release -- -O binary $@

build/%.uf2: build/%.bin
	uf2conv $< --base $(BASE) --output $@

install: build/$(EXE).uf2
	cp build/$(EXE).uf2 $(TARGET)

.PHONY: clean
clean:
	-rm -rf build

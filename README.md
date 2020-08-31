# metro-vga

## Dependencies

* apt install binutils-arm-none-eabi gcc-arm-none-eabi
* cargo install uf2conv

## Acknowledgements

Based heavily on [this article](https://castlerock.se/2019/10/forth-for-cortex-m4-part-i-blinkenlights/) by Johan Liseborn.

NOTE that the memory layout appears to be wrong in that article. According to [this file](https://github.com/atsamd-rs/atsamd/blob/efaa858/boards/metro_m4/memory.x) in the Rust crate for this board, the RAM portion starts at 0x20000000 instead of 0x00008000. I had trouble with the stack until I made this change.

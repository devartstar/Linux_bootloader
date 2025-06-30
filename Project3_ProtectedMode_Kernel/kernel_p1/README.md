## Stage2 Bootloader

Modifying Stage2 to :
- Load C kernel (kernel.bin) into memory
- Enable A20 line - to access memory above 1Mb
- Load and ste up the GDP (Global Desc Table)
- Switch to 32 bit protected mode
- Jump to the loaded kernel_main in C


### Target Memory Layout

| Component    | Loaded To   | Size Estimate     |
| ------------ | ----------- | ----------------- |
| stage2.asm   | 0x0600:0000 | 512B              |
| `kernel.bin` | 0x1000:0000 | 1024B (2 sectors) |

We’ll load 2 sectors from disk starting at LBA = 4 into segment 0x1000, offset
0x0000.

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

### Testing

1. Compile satge1.asm and stage2.asm:

```bash
nasm -f bin stage1.asm -o stage1.bin
nasm -f bin stage2.asm -o stage2.bin
```

2. Prepare kernel.bin with dummy data:

```bash
echo -n "HELLOKERNEL" > kernel.bin
truncate -s 1024 kernel.bin
```


3. Build disk.img:

```bash
dd if=/dev/zero of=disk.img bs=512 count=20
dd if=stage1.bin of=disk.img bs=512 count=1 conv=notrunc
dd if=stage2.bin of=disk.img bs=512 seek=2 conv=notrunc    # Write to sector 3
dd if=kernel.bin of=disk.img bs=512 seek=4 conv=notrunc
```

4. Run in QEMU:

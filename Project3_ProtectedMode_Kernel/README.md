# Enter Protected Mode + Run C Kernel


## Learnings in this Stage:

- A bootloader (stage2) that:
    - Enables A20 line
    - Loads a small C kernel (kernel.bin) to memory
    - Switches to 32-bit protected mode
    - Jumps to the kernel

- A minimal C "kernel" that:
    - Prints something like "Welcome to DevOS!"
    - Maybe clears the screen and shows some info

## Components:

|  Prt             | Description                              |
| ---------------- | ---------------------------------------- |
| `bootloader.asm` | Sets up real mode                        |
| `stage2.asm`     | Loads kernel, switches to protected mode |
| `kernel.c`       | Minimal C entry code                     |
| `link.ld`        | Linker script for kernel                 |
| `Makefile`       | Automate build + run with QEMU           |


## Stage Layout

```bash
project/
├── bootloader.asm      # MBR (stage1) — already done
├── stage2.asm          # Stage2 — modify to enter protected mode
├── kernel.c            # Your C kernel
├── linker.ld           # Linker script
├── Makefile            # Build everything
├── disk.img            # Output bootable disk
```

## Step-by-step Plan:

### Stage1: 

- Loads stage2 from disk sector 2

### Stage2:

- Load kernel.bin from sector 3+
- Set up GDT (Global Descriptor Table)
- Enable A20
- Enter protected mode
- Far jump to 32-bit kernel_main

### Kernel (in C):

- Just write to video memory in 0xB8000
- No libc, no headers — this is freestanding!

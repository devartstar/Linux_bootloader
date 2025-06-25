## Debugging QEMU with GDB Stub!

### 1. Starting QEMU with GDB Stub.

```shell
qumu-system-x86_64 \
  -hda test_disk.img \
  -S -s \
  -display curses
```

-S : Don’t start CPU automatically (paused at reset).
-s : Open GDB server on TCP port 1234.

### 2. Start GDB

```shell
gdb
```

- Inside gdb connect to QEMU's stub.
```shell
target remote localhost:1234
```

- Connection Success Message:
```shell
Remote debugging using localhost:1234
0x000000000000fff0 in ?? () 
```

- Loading symbols [While Compiling]
    - To load .elf synbols file in .asm comment out `org 0x7c00`
    - let the linker handel it using -Ttext
```shell
nasm -f elf32 -g mybootloader.asm -o mybootloader.o
ld -m elf_i386 -Ttext 0x7C00 -o mybootloader.elf mybootloader.o
objcopy -O binary mybootloader.elf mybootloader.bin
```

```shell
symbol-file mybootloader.elf
```

- Setting Breakpoints
```shell
b start
b *0x7c00
```

- Disambeling Instructions
Inspect 10 instructions starting at address 0x7c00
```shell
x/10i 0x7c00
x/20i $rip # disamble around instruction pointer
```

- Start Execution `c`

- Inspect While paused `info registers`

- dump memory `x/32bx 0x7c00`

- Window for sam file `layout asm`

- Window for regs `layout regs`

- Step Through `si`

- Step Over `ni`

- Print char (si) of lodsb `print/c $al`

## Project Setup

boot.asm        ->  [nasm]  ->  boot.bin
nasm -f bin boot.asm -o boot.bin

boot.bin        ->  [dd]    ->  test_disk.img
dd -ip boot.bin of=test_disk.img bs=512 count=1 conv=notrunc

test_disk.img   ->  [qemu]  ->  Boot + Print
qemu-system-x86_64 -drive format=raw,file=test_disk.img -display curses 
(or -display -nographic)

### Project Task

BIOS loads 512 Bytes to Memory at 0x7C00
To do anything beyond 512 Bytes use the BIOS interrupt INT 13h - BIOS Disk Service

LBA = 1
C = 0, H = 0, S = 2

| Register | Purpose | Value |
|---|---|---|
| AH | Function Code = 0x02(Read) | 0x02 |
| AL | Number of sectors to read (1-127) | 0x01 |
| CH | cylinder Number (lower 8 bits) | 0x00 |
| CL | sector Number (bits 0-5) + 2 cylinder upper bits (bits 6-7) | 0x02 |
| DH | Head Number (0 - 15) | 0x00 |
| DL | Drive Number (0x00 Floppy, 0x80 HDD) | 0x80 |
| ES:BX | Segment:Offset to store the data | 0000:0500 |

Cylinder(10) = CH (0-8) + CL (6-7)
Sector(5) = CL (0-5)

### LBA <-> CHS Conversion Formulae

C = LBA / (HPC × SPT)
H = (LBA / SPT) % HPC
S = (LBA % SPT) + 1

### CHS Layout

Drive Surface (Platters)
 ┌────────────────────────────┐
 │ Cylinder 0                 │
 │ ┌────────────┐             │
 │ │ Head 0     │             │
 │ │ ┌────────┐ │             │
 │ │ │Sector 1│ │             │
 │ │ │Sector 2│ │ <───■ LBA 1 │
 │ │ │...     │ │             │
 │ │ └────────┘ │             │
 │ └────────────┘             │
 │ ┌────────────┐             │
 │ │ Head 1     │             │
 │ └────────────┘             │
 └────────────────────────────┘


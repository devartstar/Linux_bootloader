## Chainloading a .bin from Sector 3 (LBA = 2) Bootloader

### Project Setup

boot.asm        ->  [nasm]  ->  boot.bin
nasm -f bin boot.asm -o boot.bin

boot.bin        ->  [dd]    ->  test_disk.img
dd -ip boot.bin of=test_disk.img bs=512 count=1 conv=notrunc

test_disk.img   ->  [qemu]  ->  Boot + Print
qemu-system-x86_64 -drive format=raw,file=test_disk.img -display curses 
(or -display -nographic)

### Project Task

BIOS loads 512 Bytes to Memory at 0x7C00
Instead of printing data from a sector, we will load a second program
Sector 1 is read form the Disk into memory
(stage2.bin) from sector 3 (LBA 2)
f=stage2.bin of=test_disk.img bs=512 seek=2 conv=notrunc


nasm stage2.asm -o stage2.bin

Inject stage 2 in Sector 3 (LBA=2)
dd if=stage2.bin of=test_disk.img bs=512 seek=2 conv=notrunc


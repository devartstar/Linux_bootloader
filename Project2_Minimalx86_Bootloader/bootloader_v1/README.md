## Project Setup

boot.asm        ->  [nasm]  ->  boot.bin
nasm -f bin boot.asm -o boot.bin

boot.bin        ->  [dd]    ->  test_disk.img
dd -ip boot.bin of=test_disk.img bs=512 count=1 conv=notrunc

test_disk.img   ->  [qemu]  ->  Boot + Print
qemu-system-x86_64 -drive format=raw,file=test_disk.img -display curses 
(or -display -nographic)

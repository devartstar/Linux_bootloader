## Own MBR Sector Reader & Parser

1. Create a personal disk image in ./test/disk.img
    - dd command - compies from input file to output file 
        - In block size bs = 512
        - Number of sectors mentioned count = 1
        - if = /dev/zero - gives stream of null bytes as required


2. DISK LAYOUT:
We have a disk file of 512 byte (1 sector)

| Offset (bytes) | Size | Description             |
| -------------- | ---- | ----------------------- |
| 0x000          | 446  | Bootloader code         |
| 0x1BE (446)    | 16   | Partition Entry 1       |
| 0x1CE (462)    | 16   | Partition Entry 2       |
| 0x1DE (478)    | 16   | Partition Entry 3       |
| 0x1EE (494)    | 16   | Partition Entry 4       |
| 0x1FE (510)    | 2    | Boot Signature `0x55AA` |

    
Focus: Partition Entry 1 & Boot Signature

3. 
Boot Header
Create a Partition Structure
Boot Signature

4. Verify: Run the COmmands
>> make

>> mbr_inspect$ dd if=/dev/zero of=test/disk.img bs=512 count=1
1+0 records in
1+0 records out
512 bytes copied, 0.000134502 s, 3.8 MB/s
mbr_inspect$ python3 inject_partition.py
mbr_inspect$ ls -lh test/disk.img
-rw-rw-r-- 1 azureuser azureuser 512 Jun 22 10:35 test/disk.img

>> mbr_inspect$ xxd test/disk.img | tail -n 4
000001c0: 0200 8300 fe3f 0008 0000 0040 0600 0000  .....?.....@....
000001d0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000001e0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000001f0: 0000 0000 0000 0000 0000 0000 0000 55aa  ..............U.

>> mbr_inspect$ ./mbr_inspect test/disk.img
MBR successfully read from test/disk.img
Boot Signature: 0xAA55
Partition 1:
        Bootable: YES
        Type: 0x83
        Start LBA: 2048
        Sectors: 409600

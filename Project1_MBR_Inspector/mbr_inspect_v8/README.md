## Detect BootLoader Presence

The first 440 bytes(0x000 - 0x1b7) in first sector is for bootloader code.
1. If this region is all 0. No Bootloader installed.
2. if Non zero. Bootloader likely present.

Task: Verify Bootloaders' Presence!

Testing: Created a disk with overlapped partition
Using the python script inject_overlapped_partitons.py

Output:

MBR successfully read from test/disk_overlapped_partitions.img
Boot Signature: 0xAA55

Boot Signature OK
Partition 1:
	Bootable: YES
	Type: 0x83
	Start LBA: 2048
	Sectors: 100
	CHS Start: C=0 H=0 S=0
	CHS End: C=0 H=0 S=0
	LBA Start: 4294967295
	Warning: Mismatch between CHS and LBA start! CHS->LBA=4294967295, Start LBA=2048
Partition 2:
	Bootable: NO
	Type: 0x83
	Start LBA: 2050
	Sectors: 50
	CHS Start: C=0 H=0 S=0
	CHS End: C=0 H=0 S=0
	LBA Start: 4294967295
	Warning: Mismatch between CHS and LBA start! CHS->LBA=4294967295, Start LBA=2050
Bootloader likely missing (only 0/440 bytes non-zero) 

--- Partition Overlap Check ---
Partitions 0(0-99) and 1(2-51) overlap!

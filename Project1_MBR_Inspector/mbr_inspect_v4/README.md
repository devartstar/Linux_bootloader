## CHS <> LBA Match

Ensures that the CHS (Cylinder-Head-Sector) and LBA (Logical Block Address) values in each partition entry point to the same location — a common source of disk corruption and BIOS/bootloader issues.

Convert CHS to LBA using BIOS assumptions.
LBA = (cylinder * heads_per_cylinder + head) * sectors_per_track + (sector - 1);

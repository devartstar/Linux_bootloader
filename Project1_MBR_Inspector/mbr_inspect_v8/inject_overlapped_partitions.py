import struct
import os

# Create empty disk image of 1MB if not exists
os.makedirs("test", exist_ok=True)
with open("test/disk_overlapped_partitions.img", "wb") as f:
    f.write(b"\x00" * 1024 * 1024)  # 1MB disk image

with open("test/disk_overlapped_partitions.img", "r+b") as f:
    # Jump to partition table area (offset 0x1BE)
    f.seek(0x1BE)

    # Partition 1 — Starts at LBA 2048, 100 sectors
    part1 = bytearray(16)
    part1[0] = 0x80  # Bootable
    part1[4] = 0x83  # Linux partition type
    part1[8:12] = struct.pack("<I", 2048)
    part1[12:16] = struct.pack("<I", 100)
    f.write(part1)

    # Partition 2 — Starts at LBA 2050 (overlaps with part1), 50 sectors
    part2 = bytearray(16)
    part2[0] = 0x00  # Not bootable
    part2[4] = 0x83
    part2[8:12] = struct.pack("<I", 2050)
    part2[12:16] = struct.pack("<I", 50)
    f.write(part2)

    # Pad rest of partition table
    f.write(b"\x00" * (16 * 2))  # Remaining two partition entries

    # Write valid boot signature
    f.seek(510)
    f.write(b"\x55\xAA")


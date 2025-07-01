## Memory Map (Real Mode Boot SO Far)

### InMemory Layout

+-----------------------------+
|  VT (Interrupt Vector Tbl)  |
| 1024 bytes                  |
+-----------------------------+
| BIOS Data Area              |
| (0x0400 - 0x0500)           |
+-----------------------------+
| Free Real Mode RAM          |
|                             |
| 0x0500: Magic Number Sector |
|      → loaded by Stage 1    |
|                             |
| 0x0600: Stage 2 Bootloader  |  ← ORG 0x0600, loaded from CHS=(0,0,3)
|                             |
+-----------------------------+
|                             |
| 0x1000: Kernel              |  ← Kernel loaded by Stage 2
|                             |
+-----------------------------+
|                             |
| 0x7C00: Stage 1 Bootloader  |  ← BIOS loads MBR to here (ORG 0x7C00)
|                             |
+-----------------------------+
| 0x9FC00: Stack Area         |
+-----------------------------+
| 0xA0000: Video Memory       |
+-----------------------------+
| 0xFFFFF: BIOS ROM           |
+-----------------------------+

### Disk Layout

| Sector | Content       | Written Using |
| ------ | ------------- | ----------------------------------------------------|
| 0      | Stage 1 (MBR) | `dd if=stage1.bin of=disk.img bs=512 seek=0` |
| 2      | Stage 2       | `dd if=stage2.bin of=disk.img bs=512 seek=2` |
| 4–5    | Kernel        | `dd if=kernel.bin of=disk.img bs=512 seek=4 count=2`|


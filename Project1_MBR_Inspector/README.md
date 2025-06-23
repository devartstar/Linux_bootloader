## MBR Inspector Project.

Features build in this Project:

| Feature                          | Description                                                                       |
| -------------------------------- | --------------------------------------------------------------------------------- |
| 🧠 CHS Decoding                  | Reads BIOS-style geometry and converts to Cyl-Head-Sec                            |
| 🧾 Raw MBR Dump                  | 512-byte hex dump with labeled sections (bootloader, table, signature)            |
| 🧮 CHS–LBA Check                 | Validates that CHS and LBA fields match logically                                 |
| 🔍 Boot Signature Check          | Ensures `0xAA55` is present                                                       |
| 🚀 Bootloader Presence Detection | Detects real bootloaders using entropy + signatures (`GRUB`, `LILO`, etc.)        |
| ⚠️ Partition Analysis            | Detects empty MBR, multiple bootable flags, and overlapping partition ranges      |
| 🧪 Disk Injector                 | Custom Python script to generate test MBR images with valid or corrupt structures |


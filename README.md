
## 🧠 **Learning Strategy Overview**

You're going to master MBR and GPT through **incremental, code-first projects**. We’ll go from:

1. Raw disk manipulation ➜
2. Parsing actual MBR/GPT layouts ➜
3. Creating a bootable disk with a custom layout ➜
4. Writing a minimal bootloader that can read a GPT partition ➜
5. Comparing legacy BIOS and UEFI flows in practice

---

## 📚 Phase 1: Fundamentals via Hex + Code

### 🔍 Goal:

Understand disk structure by viewing and modifying the first 512 bytes of a disk image.

### 📁 Project 1: Hex Editor + MBR Parser

#### 📌 Objectives:

* Read raw sectors from a disk (using a file as a disk image).
* Parse and print the MBR fields (boot signature, partition table, etc.)
* Build a CLI tool like: `./mbr_inspect <disk.img>`

#### 🛠️ Key Concepts:

* **MBR Layout**: First 512 bytes of the disk

  * Bytes 0–445: Bootloader
  * Bytes 446–509: 4 Partition entries (16 bytes each)
  * Bytes 510–511: Boot Signature (should be `0x55AA`)
* **Partition Entry**:

  * Status byte, CHS addresses, partition type, LBA start, size

#### 🧠 Learn:

* Hexadecimal notation, little-endian encoding
* CHS vs LBA addressing
* Disk signatures
* Legacy BIOS boot rules

#### 📂 Tools:

* C/C++ or Rust
* `fopen`/`read` or `mmap`
* `xxd` and `qemu-img` to create test images

#### 🚀 Stretch:

* Modify an MBR to insert a custom partition layout.
* Write unit tests for each field in your parser.

---

## 🌀 Phase 2: GPT Deep Dive

### 📁 Project 2: GPT Parser + Validator

#### 📌 Objectives:

* Load a disk image with GPT (use `gdisk` or `parted` to create).
* Parse GPT Header, Partition Entries.
* Verify the CRC32 checksum and validity.
* CLI: `./gpt_inspect <disk.img>`

#### 🛠️ Key Concepts:

* GPT stored at sector 1 (512 bytes), plus backup at end of disk.
* Contains a **protective MBR** at sector 0.
* Header contains:

  * Signature `EFI PART`, revision, header size
  * GUID of disk
  * Starting and ending LBA of usable blocks
  * Partition entry array info (start, count, size)

#### 🧠 Learn:

* Why GPT replaces MBR
* How UEFI systems use GPT
* Endianness for GUIDs (unusual format!)
* CRC checksum calculation

---

## ⚙️ Phase 3: Build a Disk Layout from Scratch

### 📁 Project 3: Disk Layout Creator

#### 📌 Objectives:

* Given a config file (`disk.json`), generate a valid disk image:

```json
{
  "partitions": [
    {"type": "FAT32", "size_mb": 100, "bootable": true},
    {"type": "ext4", "size_mb": 400}
  ]
}
```

* Choose between MBR or GPT layout
* Output: a bootable `.img` file

#### 🧠 Learn:

* Aligning partitions (sector boundaries)
* Filesystem type codes (MBR) vs partition GUIDs (GPT)
* Bootable flags and implications for BIOS/UEFI

---

## 🚀 Phase 4: Writing a Bootloader

### 📁 Project 4: MBR Bootloader in Assembly

#### 📌 Objectives:

* Write a 16-bit x86 bootloader in NASM
* It prints "Hello from MBR!"
* Load via QEMU with `-drive file=disk.img,format=raw`

#### 🛠️ Tools:

* NASM, QEMU
* BIOS interrupt 0x10 for printing
* 512-byte limit (watch out!)

#### 🧠 Learn:

* Real mode limitations (segment\:offset)
* Boot signature necessity (0x55AA)
* How BIOS reads the first sector to RAM at 0x7C00

---

## 🛡️ Phase 5: UEFI Bootloader + GPT Boot

### 📁 Project 5: UEFI Hello World

#### 📌 Objectives:

* Build a UEFI `.efi` binary (C + UEFI headers)
* Load it via QEMU + GPT disk
* Print "Hello from UEFI"

#### 🧠 Learn:

* UEFI boot process
* UEFI system table
* EFI file paths, partition structure
* Use `efibootmgr`, `mkfs.fat`, `mount`, `cp`

---

## 📖 Additional Resources (to refer alongside projects)

* Intel BIOS/MBR Layout Spec
* UEFI Spec from uefi.org
* `parted`, `gdisk`, `sfdisk` source code
* Hex editors like `wxHexEditor`, `GHex`

---

## 🏁 Final Goal Project: Dual Bootable Disk Generator

Make a tool that:

* Takes a Linux ISO + a dummy second OS (say, another kernel binary)
* Creates a disk image:

  * MBR + one bootable ext4 partition
  * GPT layout for UEFI boot
  * Loads Linux kernel from partition
* Boots both in BIOS and UEFI using QEMU

---


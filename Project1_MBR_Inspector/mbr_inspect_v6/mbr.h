/**
 * Header Guard
 * Ensure file included only once during compilation.
 */
#ifndef MBR_H
#define MBR_H

#include <stdint.h>

/**
 * C compiler uses padding for performance
 * Tell the compiler to align all fields to 1 byte boundaries
 * MBR - byte aligned on disk - so we need to match exact layout
 */
#pragma pack(1)

typedef struct {

  // 1 Byte - 0x80(bootable) | 0x00(not bootable)
  uint8_t boot_indicator;

  // Cylinder header sector of partition start
  uint8_t start_chs[3];

  // FileSystem ID - 0x83(Linux) | 0x07(NTFS)
  uint8_t partition_type;

  // Cylinder header sector of partition end
  uint8_t end_chs[3];

  // Start sector (Logical Block Addressing)
  uint32_t start_lba;

  // Number of sectors in partition snaps
  uint32_t num_sectors;

} PartitionEntry; // 16B

typedef struct {

  // BIOS Bootloader code = 446B
  uint8_t bootloader[446];

  // Partition Entries = 16 * 4 B
  PartitionEntry partitions[4];

  // Boot Signature - Magic Number 0x55AA for BIOS to be bootable
  uint16_t boot_signature;

} MBR; // 512B

// End 1 byte alignment directive
#pragma pack(pop)

// parses the raw 512B into MBR struct
int parse_mbr(const char *filepath, MBR *out_mbr);

// decode and print the chs for each partition
void decode_chs(const uint8_t chs[3], int *cylinder, int *head, int *sector);

// dump the raw value of mbr in hex format
void dump_mbr_raw(const MBR *mbr);
void dump_mbr_raw_distinguished(const MBR *mbr);

uint32_t convert_chs_to_lba(int cylinder, int head, int sector);

// print the MBR info
void print_mbr_info(const MBR *mbr);

#endif

#include "mbr.h"
#include <stdio.h>
#include <stdlib.h>

int parse_mbr(const char *filepath, MBR *out_mbr) {
  // Opens the file in read binary mode
  FILE *f = fopen(filepath, "rb");
  if (!f)
    return -1;

  size_t read = fread(out_mbr, 1, 512, f);
  fclose(f);

  // Ensure MBR is fully read
  return (read == 512) ? 0 : -2;
}

void decode_chs(const uint8_t chs[3], int *cylinder, int *head, int *sector) {
  *cylinder = ((chs[1] & 0xC0) << 2) | chs[2];
  *head = chs[0];
  *sector = chs[1] & 0x3F;
}

void dump_mbr_raw(const MBR *mbr) {
  const uint8_t *bytes = (const uint8_t *)mbr;

  printf("\n--- Raw MBR Dump (512 bytes) ---\n");
  for (int i = 0; i < 512; ++i) {
    if (i % 16 == 0) {
      printf("\n%04X: ", i);
    }
    printf("%02X ", bytes[i]);
  }
  printf("\n");
}

void dump_mbr_raw_distinguished(const MBR *mbr) {
  const uint8_t *bytes = (const uint8_t *)mbr;

  printf("\n--- Raw MBR Layout ---\n");
  printf("[Bootloader Area: 0000–01BD]");

  for (int i = 0; i < 512; ++i) {
    if (i == 0x1BE)
      printf("\n[Partition Table: 01BE–01FD]\n");
    if (i == 0x1FE)
      printf("\n[Boot Signature: 01FE–01FF]\n");

    if (i % 16 == 0)
      printf("\n%04X: ", i);

    printf("%02X ", bytes[i]);
  }

  printf("\n");
}

uint32_t convert_chs_to_lba(int cylinder, int head, int sector) {
  const int sectors_per_track = 63;
  const int heads_per_cylinder = 255;
  return (cylinder * heads_per_cylinder + head) * sectors_per_track +
         (sector - 1);
}

void check_bootloader_present(const MBR* mbr) {
  const uint8_t* bytes = (const uint8_t*) mbr;
  int zeros = 0;
  for(int i=0; i < 440; i++) {
    if(bytes[i] == 0) {
      zeros++;
    }
  }

  if(zeros > 430) {
    printf("Bootloader likely missing (only %d/440 bytes non-zero) \n", 440 - zeros);
  } else {
    printf("Bootloader likely present\n");
  }
}

void print_mbr_info(const MBR *mbr) {
  
  printf("Boot Signature: 0x%X\n", mbr->boot_signature);

  if(mbr->boot_signature != 0xAA55) {
    printf("\nInvalid Boot Signature: 0x%04X (expected 0xAA55)\n", mbr->boot_signature);
  } else {
    printf("\nBoot Signature OK\n");
  }

  int bootable_count = 0;
  int valid_count = 0;
  for (int i = 0; i < 4; i++) {
    const PartitionEntry *pe = &mbr->partitions[i];
    if (pe->partition_type != 0) {
  
      // Checks for valid Partition
      valid_count++;
      if(pe->boot_indicator == 0x80) {
        bootable_count++;
      }

      int cyl_start, head_start, sec_start;
      int cyl_end, head_end, sec_end;

      decode_chs(pe->start_chs, &cyl_start, &head_start, &sec_start);
      decode_chs(pe->end_chs, &cyl_end, &head_end, &sec_end);

      printf("Partition %d:\n", i + 1);
      printf("\tBootable: %s\n", (pe->boot_indicator == 0x80) ? "YES" : "NO");
      printf("\tType: 0x%X\n", pe->partition_type);
      printf("\tStart LBA: %u\n", pe->start_lba);
      printf("\tSectors: %u\n", pe->num_sectors);
      printf("\tCHS Start: C=%d H=%d S=%d\n", cyl_start, head_start, sec_start);
      printf("\tCHS End: C=%d H=%d S=%d\n", cyl_end, head_end, sec_end);

      const uint32_t lba_start =
          convert_chs_to_lba(cyl_start, head_start, sec_start);
      printf("\tLBA Start: %u\n", lba_start);
      if (pe->start_lba != lba_start) {
        printf("\tWarning: Mismatch between CHS and LBA start! CHS->LBA=%u, Start LBA=%u\n", lba_start, pe->start_lba);
      } else {
        printf("\tCHS and LBA start match.\n");
      }
    }
  }

  if(valid_count == 0) {
    printf("Warning: No Valid Partition\n");
  }
  if(bootable_count > 1) {
    printf("Warning: Multiple bootale partitions %d\n", bootable_count);
  }
}


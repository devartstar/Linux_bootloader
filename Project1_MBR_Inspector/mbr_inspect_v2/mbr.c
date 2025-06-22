#include <stdio.h>
#include <stdlib.h>
#include "mbr.h"

int parse_mbr(const char* filepath, MBR* out_mbr)
{
	// Opens the file in read binary mode
	FILE* f = fopen(filepath, "rb");
	if(!f) return -1;

	size_t read = fread(out_mbr, 1, 512, f);
	fclose(f);

	// Ensure MBR is fully read
	return (read == 512) ? 0 : -2;
}

void decode_chs(const uint8_t chs[3], int* cylinder, int* head, int* sector)
{
	*cylinder = ((chs[1] & 0xC0) << 2) | chs[2];
	*head = chs[0];
	*sector = chs[1] & 0x3F;
}

void print_mbr_info(const MBR* mbr)
{
	printf("Boot Signature: 0x%X\n", mbr->boot_signature);

	for(int i=0; i<4; i++)
	{
		const PartitionEntry* pe = &mbr->partitions[i];
     		if(pe->partition_type != 0)
     		{
			int cyl_start, head_start, sec_start;
			int cyl_end, head_end, sec_end;

			decode_chs(pe->start_chs, &cyl_start, &head_start, &sec_start);
			decode_chs(pe->end_chs, &cyl_end, &head_end, &sec_end);

     			printf("Partition %d:\n", i+1);
			printf("\tBootable: %s\n", (pe->boot_indicator == 0x80) ? "YES" : "NO");
			printf("\tType: 0x%X\n", pe->partition_type);
			printf("\tStart LBA: %u\n", pe->start_lba);
			printf("\tSectors: %u\n", pe->num_sectors);
			printf("\tCHS Start: C=%d H=%d S=%d\n", cyl_start, head_start, sec_start);
			printf("\tCHS End: C=%d H=%d S=%d\n", cyl_end, head_end, sec_end);
		}
	}
}


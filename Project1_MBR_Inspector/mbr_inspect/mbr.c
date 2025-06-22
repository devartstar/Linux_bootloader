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

void print_mbr_info(const MBR* mbr)
{
	printf("Boot Signature: 0x%X\n", mbr->boot_signature);

	for(int i=0; i<4; i++)
	{
		const PartitionEntry* pe = &mbr->partitions[i];
     		if(pe->partition_type != 0)
     		{
     			printf("Partition %d:\n", i+1);
			printf("\tBootable: %s\n", (pe->boot_indicator == 0x80) ? "YES" : "NO");
			printf("\tType: 0x%X\n", pe->partition_type);
			printf("\tStart LBA: %u\n", pe->start_lba);
			printf("\tSectors: %u\n", pe->num_sectors);
		}
	}
}


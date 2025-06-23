#include <stdio.h>
#include <string.h>
#include "mbr.h"

int main(int argc, char* argv[])
{
	if(argc < 2)
	{
		printf("Usage: %s <disk image>\n", argv[0]);
		return 1;
	}

	const char* filepath = argv[1];
	int show_raw = 0;

	if(argc == 3 && strcmp(argv[2], "--raw") == 0)
	{
		show_raw = 1;
	}

	MBR mbr;
	if(parse_mbr(argv[1], &mbr) != 0)
	{
		fprintf(stderr, "Failed to read MBR form %s\n", argv[1]);
		return 1;
	}

	printf("MBR successfully read from %s\n", argv[1]);
	print_mbr_info(&mbr);

	if(show_raw)
	{
		// dump_mbr_raw(&mbr);
		dump_mbr_raw_distinguished(&mbr);
	}

  check_bootloader_present(&mbr);

  check_partition_overlap(&mbr);

	return 0;
}

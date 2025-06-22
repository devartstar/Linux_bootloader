#include <stdio.h>
#include "mbr.h"

int main(int argc, char* argv[])
{
	if(argc < 2)
	{
		printf("Usage: %s <disk iamge>\n", argv[0]);
		return 1;
	}

	MBR mbr;
	if(parse_mbr(argv[1], &mbr) != 0)
	{
		fprintf(stderr, "Failed to read MBR form %s\n", argv[1]);
		return 1;
	}
	printf("MBR successfully read from %s\n", argv[1]);
	print_mbr_info(&mbr);
	return 0;
}

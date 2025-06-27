## Task 

Pass parameters from bootloader (stage1) to stage2 using register or memory.
- memory map info
- magic number

### Steps

1. Modify stage1 bootloader to: Set a magic number in memory at 0x0500
2. Read and print that number from 0x0500

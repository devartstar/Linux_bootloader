CHS - Cylinder Header Sector

Each Partition Store:
chs_start[3]    - CHS Address where the partition starts
chs_end[3]      - CHS Address where the partition ends

chs[0] = HEAD
chs[1] = Sector bits(0-5) + High bits of Cylinder(6-7)
chs[2] = Low bits of Cylinder(8)

Task: Decode a CHS address and Print for each partition.



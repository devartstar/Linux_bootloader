with open("test/disk.img", "r+b") as f:

    # move to start of parition table
    f.seek(446); 

    # Partiton Entry
    entry = bytes([
        0x80, 0x00, 0x02, 0x00,
        0x83,
        0x00, 0xFE, 0x3F,
        0x00, 0x08, 0x00, 0x00,
        0x00, 0x40, 0x06, 0x00
    ])

    f.write(entry)

    # move to boot signature offset
    f.seek(510)
    f.write(b'\x55\xAA')


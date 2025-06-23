## Detect BootLoader Presence

The first 440 bytes(0x000 - 0x1b7) in first sector is for bootloader code.
1. If this region is all 0. No Bootloader installed.
2. if Non zero. Bootloader likely present.

Task: Verify Bootloaders' Presence!


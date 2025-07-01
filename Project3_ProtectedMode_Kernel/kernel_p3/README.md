## Switching to Protected Mode

1. [Done] Load the 32 bit kernel to memory
2. [Done] Enable A20 Line
3. Load a minimal GDP (Global Descriptor Table)
4. Set CR0[0] = 1 -> this enters the protected mode
5. Perform a Far Jump to flush prefetch queue and switch segment registers
6. Jump to the 32 bit kernel


### Minimal GDT Layout

| Index | Description     | Selector | Flags/Granularity               |
| ----- | --------------- | -------- | ------------------------------- |
| 0     | Null descriptor | 0x00     | All zero                        |
| 1     | Code Segment    | 0x08     | base=0x0, limit=0xFFFFF, 32-bit |
| 2     | Data Segment    | 0x10     | base=0x0, limit=0xFFFFF, RW     |


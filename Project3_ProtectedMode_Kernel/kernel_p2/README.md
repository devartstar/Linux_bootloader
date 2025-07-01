## Next Stage: Enabling A20 Line + Entering Protected Mode

---

### **Stage 3 Goals**

1. Enable A20 Line
    - In Real Mode, memory wraps around at 1Mb (20-bit addressing)
    - This allows access to memory beyond the 1MB barrier.
    - Required before entering protected mode.
    - Why needed ? 
        To jump to addr 0x100000 32bit protected mode kernel
        Else CPU will wrap it as > 1Mb

2. Switch to Protected Mode
    - Set up GDT (Global Descriptor Table).
    - Load it using `lgdt`.
    - Set PE (Protection Enable) bit in CR0.
    - Perform far jump to 32-bit code segment.

3. Verify Protected Mode Works
    - Print something using BIOS first, then test a simple
    - infinite loop or memory move in 32-bit mode.

---

### 🧱 Files We’ll Work With

1. `stage1.asm` — loads stage2
2. `stage2.asm` — loads stage3
3. `stage3.asm` — enables A20 + protected mode
4. `kernel32.asm` or `kernel.c` (after switch) — later to be loaded in protected mode


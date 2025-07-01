[BITS 16]
[ORG 0x0600]                   ; Stage2 gets loaded by Stage1 at 0x0600:0000

start:
    cli
    ; Fix the DS segment issue - keep DS pointing to our load address
    mov ax, 0x0600             ; Set DS to where we're loaded
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00                 ; Set up stack
    sti

    ; Debug: Print stage2 boot message
    mov si, msg_stage2 - 0x0600    ; Adjust offset since DS=0x0600
    call print_str

    ; Enable A20 Line (Method 1: Fast A20)
    call enable_a20

    ; Load 2 sectors from LBA=4 (CHS=0,0,5) into ES:BX = 0x1000:0000
    mov ax, 0x1000             ; segment = 0x1000 (means physical 0x10000)
    mov es, ax
    xor bx, bx                 ; offset = 0

    mov ah, 0x02               ; BIOS read sector function
    mov al, 2                  ; number of sectors
    mov ch, 0                  ; cylinder
    mov cl, 5                  ; sector (CHS: sector=5 → LBA=4)
    mov dh, 0                  ; head
    mov dl, 0x80               ; boot from HDD

    int 0x13
    jc disk_error

    ; Print success message
    mov si, msg_loaded - 0x0600    ; Adjust offset
    call print_str

    ; Wait a moment before switching modes
    mov cx, 0xFFFF
delay_loop:
    loop delay_loop

    ; Disable interrupts before protected mode switch
    cli

    ; Set up GDT for protected mode
    lgdt [gdt_descriptor]      ; Load Global Descriptor Table

    ; Set CR0 bit 0 (PE - Protected Mode Enable)
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Perform far jump to clear prefetch queue and switch to protected mode
    jmp 0x08:protected_mode_entry

; --------------------------------------------------------------------------------
; Enable A20 Line using Fast A20 method
enable_a20:
    push ax
    in al, 0x92                ; Read from Fast A20 port
    test al, 2                 ; Check if A20 is already enabled
    jnz .a20_done             ; If bit 1 is set, A20 is enabled
    or al, 2                   ; Set bit 1 to enable A20
    and al, 0xFE              ; Clear bit 0 (don't reset)
    out 0x92, al              ; Write back to enable A20
.a20_done:
    pop ax
    ret

; --------------------------------------------------------------------------------
; Real Mode: Error handler if disk fails to load
disk_error:
    mov si, msg_error - 0x0600     ; Adjust offset
    call print_str
    jmp $

; --------------------------------------------------------------------------------
; Print null-terminated string from DS:SI
print_str:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

; --------------------------------------------------------------------------------
; Protected Mode Segment Starts Here
[BITS 32]
protected_mode_entry:
    ; Set up segment registers to 0x10 (data segment)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Set up protected mode stack
    mov esp, 0x90000           ; Set stack pointer to a safe location

    ; Don't clear screen immediately - first write a test message
    ; Write 'P' at top-left to confirm we're in protected mode
    mov dword [0xB8000], 0x4F504F50  ; 'PP' in white on red background

    ; Write the success message starting from second line
    mov edi, 0xB8000 + 160     ; Second line (80 chars * 2 bytes per char)
    
    ; Write each character of our message manually for debugging
    mov word [edi], 0x0F50     ; 'P' white on black
    add edi, 2
    mov word [edi], 0x0F52     ; 'R' white on black  
    add edi, 2
    mov word [edi], 0x0F4F     ; 'O' white on black
    add edi, 2
    mov word [edi], 0x0F54     ; 'T' white on black
    add edi, 2
    mov word [edi], 0x0F45     ; 'E' white on black
    add edi, 2
    mov word [edi], 0x0F43     ; 'C' white on black
    add edi, 2
    mov word [edi], 0x0F54     ; 'T' white on black
    add edi, 2
    mov word [edi], 0x0F45     ; 'E' white on black
    add edi, 2
    mov word [edi], 0x0F44     ; 'D' white on black
    add edi, 2
    mov word [edi], 0x0F20     ; ' ' white on black
    add edi, 2
    mov word [edi], 0x0F4D     ; 'M' white on black
    add edi, 2
    mov word [edi], 0x0F4F     ; 'O' white on black
    add edi, 2
    mov word [edi], 0x0F44     ; 'D' white on black
    add edi, 2
    mov word [edi], 0x0F45     ; 'E' white on black

    ; Stop here - don't jump to kernel yet
    jmp $

; --------------------------------------------------------------------------------
; Global Descriptor Table (GDT) - Must be in 16-bit section

[BITS 16]                     ; Back to 16-bit for GDT setup

align 4                       ; Ensure GDT is aligned
gdt_start:
gdt_null:
    dq 0                      ; 8 bytes of zeros (null descriptor)

gdt_code:                     ; Code Segment Descriptor
    dw 0xFFFF                 ; Limit Low (0-15)
    dw 0x0000                 ; Base Low (0-15)
    db 0x00                   ; Base Mid (16-23)
    db 10011010b              ; Access: P=1, DPL=00, S=1, Type=1010 (code, readable)
    db 11001111b              ; Flags: G=1, D=1, L=0, AVL=0, Limit High=1111
    db 0x00                   ; Base High (24-31)

gdt_data:                     ; Data Segment Descriptor
    dw 0xFFFF                 ; Limit Low
    dw 0x0000                 ; Base Low
    db 0x00                   ; Base Mid
    db 10010010b              ; Access: P=1, DPL=00, S=1, Type=0010 (data, writable)
    db 11001111b              ; Flags: G=1, D=1, L=0, AVL=0, Limit High=1111
    db 0x00                   ; Base High

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; Limit (size - 1)
    dd gdt_start                  ; Base address (assembler calculates this correctly with ORG)

; --------------------------------------------------------------------------------
; Strings
msg_stage2:   db "Stage2: Enabling A20, Loading Kernel...", 0x0D, 0x0A, 0
msg_loaded:   db "Kernel Loaded! Switching to Protected Mode...", 0x0D, 0x0A, 0
msg_error:    db "Disk Read Error: Cannot Load Kernel!", 0x0D, 0x0A, 0

; Protected mode message (null-terminated for our custom writer)
pmode_msg:    db "PROTECTED MODE ACTIVE - SUCCESS!", 0

; --------------------------------------------------------------------------------
; Pad to 512 bytes
times 512-($-$$) db 0
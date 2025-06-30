[BITS 16]
[ORG 0x0000]                  ; Because Stage1 loads this to 0x0600:0000

start:
    ; Print debug character to ensure Stage2 starts
    mov ah, 0x0E
    mov al, 'x'
    int 0x10

    ; Set up segment registers
    cli
    mov ax, 0x0600           ; This must match the segment where Stage2 was loaded
    mov ds, ax
    mov es, ax
    sti

    ; Print confirmation message from Stage2
    mov si, msg
    call print_str

    ; Load 2 sectors from LBA=4 (CHS=0,0,5) into 0x1000:0000
    mov ax, 0x1000           ; Segment where kernel will be loaded
    mov es, ax
    xor bx, bx               ; Offset = 0

    mov ah, 0x02             ; BIOS function 0x02 = Read sectors
    mov al, 2                ; Number of sectors to read = 2
    mov ch, 0                ; Cylinder = 0
    mov cl, 5                ; Sector = 5 (CHS = 0,0,5 → LBA=4)
    mov dh, 0                ; Head = 0
    mov dl, 0x80             ; Drive = First Hard Disk

    int 0x13                 ; Call BIOS to read disk
    jc disk_error            ; If CF=1, there was an error

    ; Confirm successful kernel load
    mov si, loaded_msg
    call print_str

    ; Jump to the loaded kernel (0x1000:0000)
    jmp 0x1000:0000

disk_error:
    mov si, err_msg
    call print_str
    jmp $

; ---------------------------------------------
; Print null-terminated string at DS:SI
print_str:
    push ax
    push si
.loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    pop si
    pop ax
    ret

; ---------------------------------------------
; Strings
msg:         db "[Stage2 Bootloader] Loading Kernel...", 0x0D, 0x0A, 0
loaded_msg:  db "[Stage2 Bootloader] Kernel Loaded Successfully!", 0x0D, 0x0A, 0
err_msg:     db "[Stage2 Bootloader] Disk Read Error!", 0x0D, 0x0A, 0

; Pad to 512 bytes
times 512 - ($ - $$) db 0

[BITS 16]
[ORG 0x0000]  ; We are loaded at 0x0600:0000, so offset should be 0

; This file is loaded by Stage1 into 0x0600:0000

start:
    ; Print single debug character
    mov ah, 0x0E
    mov al, 'x'
    int 0x10

    ; Set up data segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    ; Debug message: Stage 2 active
    mov si, msg
    call print_str

    ; Load 2 sectors from CHS = (0,0,5) → LBA = 4
    ; Destination = 0x1000:0000
    mov ax, 0x1000        ; Segment 0x1000
    mov es, ax
    xor bx, bx            ; Offset 0

    mov ah, 0x02          ; BIOS function: read sectors
    mov al, 2             ; Number of sectors = 2
    mov ch, 0             ; Cylinder = 0
    mov cl, 5             ; Sector = 5 (LBA = 4)
    mov dh, 0             ; Head = 0
    mov dl, 0x80          ; First hard disk

    int 0x13              ; Call BIOS disk service
    jc disk_error         ; If error, jump to error handler

    ; Confirm kernel loaded
    mov si, loaded_msg
    call print_str

    ; Stop execution for now
    jmp $

disk_error:
    mov si, err_msg
    call print_str
    jmp $

; Subroutine: Print null-terminated string at DS:SI
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

; Messages
msg:         db "[Stage2 Bootloader] Loading Kernel...", 0x0D, 0x0A, 0
loaded_msg:  db "[Stage2 Bootloader] Successfully loaded Kernel!", 0x0D, 0x0A, 0
err_msg:     db "[Stage2 Bootloader] Disk Read Error! Kernel not loaded.", 0x0D, 0x0A, 0

; Pad to 512 bytes
times 512 - ($ - $$) db 0

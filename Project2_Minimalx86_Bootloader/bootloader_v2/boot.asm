[BITS 16]
[ORG 0x7C00]

start:
    cli                 ; Disable interrupts
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti                 ; Enable interrupts

    ; Print hello message from boot sector
    mov si, hello_msg
    call print_str

    ; Load 1 sector from CHS=(0,0,2) into ES:BX = 0x0500:0x0000 => physical 0x05000
    mov ax, 0x0500
    mov es, ax
    mov bx, 0x0000
    mov ah, 0x02        ; BIOS: read sectors
    mov al, 1           ; number of sectors
    mov ch, 0           ; cylinder
    mov cl, 2           ; sector (starts from 1)
    mov dh, 0           ; head
    mov dl, 0x80        ; first hard disk
    int 0x13
    jc disk_error       ; if carry set, read failed

    ; Print the 16 bytes from the loaded sector
    mov ax, 0x0000
    mov ds, ax
    mov si, 0x5000
    mov cx, 16

print_loop:
    lodsb
    cmp al, 0
    je halt
    mov ah, 0x0E
    int 0x10
    loop print_loop

halt:
    jmp $

disk_error:
    mov si, err_msg
    call print_str
    jmp $

print_str:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print_str
.done:
    ret

hello_msg:
    db "Hello Boot", 0

err_msg:
    db "Disk Read Error!", 0

times 510 - ($ - $$) db 0
dw 0xAA55

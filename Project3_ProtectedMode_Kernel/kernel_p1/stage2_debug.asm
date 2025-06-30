[BITS 16]
[ORG 0x0600]

start:
    ; Print 'X' to confirm entry
    mov ah, 0x0E
    mov al, 'X'
    int 0x10

    ; Print 'Y' to confirm we continue -
    mov al, 'Y'
    int 0x10

    ; Set up segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    ; Print 'Z' to confirm segment setup
    mov ah, 0x0E
    mov al, 'Z'
    int 0x10

    ; Test simple string printing with hardcoded address
    mov si, test_msg
    call print_str_debug

    ; Infinite loop
    jmp $

print_str_debug:
    mov ah, 0x0E
.loop:
    lodsb                ; Load byte from [DS:SI] into AL, increment SI
    cmp al, 0           ; Check for null terminator
    je .done
    int 0x10            ; Print character
    jmp .loop
.done:
    ret

test_msg: db "OK!", 0

times 512-($-$$) db 0

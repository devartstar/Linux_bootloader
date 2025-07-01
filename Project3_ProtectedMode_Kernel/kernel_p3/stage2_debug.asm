[BITS 16]
[ORG 0x0600]

start:
    ; Immediate test - print 'S' for Stage2
    mov ah, 0x0E
    mov al, 'S'
    int 0x10
    
    ; Print '2'
    mov al, '2'
    int 0x10
    
    ; Print ':'
    mov al, ':'
    int 0x10
    
    ; Print ' '
    mov al, ' '
    int 0x10

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Print full message
    mov si, msg_stage2
    call print_str

    ; Don't do anything else for now - just infinite loop
    jmp $

print_str:
    push ax
    push si
.next:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp .next
.done:
    pop si
    pop ax
    ret

msg_stage2: db "Stage2 is running!", 0x0D, 0x0A, 0

times 512-($-$$) db 0
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

    ; DON'T reset DS - keep it pointing to where we're loaded
    cli
    mov ax, 0x0600      ; Set DS to our load segment
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Now try string print
    mov si, msg_stage2 - 0x0600  ; Adjust offset since DS=0x0600
    call print_str

    jmp $

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

msg_stage2: db "Stage2 is running!", 0x0D, 0x0A, 0

times 512-($-$$) db 0
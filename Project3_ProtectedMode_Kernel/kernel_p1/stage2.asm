[BITS 16]
[ORG 0x0600]  ; FIX 1: Uncomment this line
; stage2 bootloader will be loaded at 0x0600 mem loc by stage1

start:
    mov ah, 0x0E
    mov al, 'x'
    int 0x10

    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    sti

    ; Debug Print to check if we reach here
    mov si, msg
    call print_str

    ; Load 2 sectors from LBA=4 CHS=(0,0,5) into 0x1000:0000(segment:offset)
    mov ax, 0x1000	; segment = 0x1000
    mov es, ax
    xor bx, bx	; offset = 0

    mov ah, 0x02	; sets up the function (0x02) 
            ; to be called on BIOS interrupt
    ; 0x02 means read sectors form the disk
    ; set up the location for read
    mov al, 2	; read 2 sectors
    mov ch, 0	; cylinder
    mov cl, 5	; sector = 5 (LBA=4 (0,0,5))
    mov dh, 0
    mov dl, 0x80	; Read deom Hard Disk

    int 0x13	; BIOS interrupt for read
    jc disk_error	; Error reading disk

    ; Debug Print to confirm contents loaded from disk
    mov si, loaded_msg
    call print_str

    jmp $

disk_error:
    mov si, err_msg
    call print_str
    jmp $

print_str:
    push ax              ; Save registers
    push si
.loop:
    lodsb               ; Load byte from [DS:SI] into AL
    cmp al, 0           ; Check for null terminator
    je .done
    mov ah, 0x0E        ; Make sure AH is set for each character
    int 0x10            ; Print character
    jmp .loop
.done:
    pop si              ; Restore registers
    pop ax
    ret

; FIX 2: Remove this duplicate .done label
; .done:
;	ret

msg: 		db "Stage2: Loading Kernel...", 0x0D, 0x0A, 0
loaded_msg:	db "Kernel Loaded into Memory!", 0x0D, 0x0A, 0
err_msg:	db "Disk Read Error! Failed to Load kernel", 0x0D, 0x0A, 0

times 512-($-$$) db 0
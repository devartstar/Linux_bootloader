[BITS 16]
[ORG 0x0000]                  ; Because Stage1 loads this to 0x0600:0000

start:

    ; Set up segment registers
    cli
    mov ax, 0x0600           ; This must match the segment where Stage2 was loaded
    mov ds, ax
    mov es, ax
    sti

    ; Print confirmation message from Stage2
    mov si, msg
    call print_str

    ; Enable A20
    call enable_a20

    mov si, a20_msg
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

    ; We loaded the kernel by not yet jumping to it
	; Reason: We are still in 16 bit real mode, 
	; kernel is a 32 bit program (in protected mode)
    ; Jump to the loaded kernel (0x1000:0000)
    ; jmp 0x1000:0000

	; Next: set up GDT and switch to protected mode
	jmp $

disk_error:
    mov si, err_msg
    call print_str
    jmp $

; ---------------------------------------------
; Enable A20 line
enable_a20:
	in al, 0x92		; Read value system control port A
	or al, 0x02		; bit 1 set to 1 is for A 20 enablement
	out 0x92, al
	ret

; ---------------------------------------------
; Load a Minimal GDP
gdt_start:
gdt_null:				dq 0	; Null Descriptor

gdt_code:				dw 0xFFFF			; limit low (bits 0-15)
								dw 0x0000			; base low	(bits 0-15)
								db 0x00				; base mid	(bits 16-23)
								db 10011010b	; access (present, ring 0, code)
								db 11001111b	;	granularity (4k, 32bit)
								db 0x00				; base high	(bits 24-31)

gdt_data:				dw 0xFFFF
								dw 0x0000
								db 0x00
								db 10010010b	; access (present, ring 0, data)
								db 11001111b
								db 0x00

gdt_end:

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
a20_msg:		db "[Stage2 Bootloader] Enabled A20 Line!", 0x0D, 0x0A, 0

; Pad to 512 bytes
times 512 - ($ - $$) db 0

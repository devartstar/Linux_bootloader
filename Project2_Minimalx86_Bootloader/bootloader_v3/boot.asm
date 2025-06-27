[BITS 16]
[ORG 0x7C00]

start:
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	sti

	; Hello from Sector 1
	mov si, msg
	call print_str

	; Load sector at CHS (0,0,3) into ES:BX = 0x0600:0000
	mov ax, 0x0600
	mov es, ax
	xor bx, bx

	mov ah, 0x02    ; Read sector(s)
	mov al, 1       ; 1 sector
	mov ch, 0       ; Cylinder
	mov cl, 3       ; Sector (starts at 1)
	mov dh, 0       ; Head
	mov dl, 0x80    ; First hard disk

	int 0x13
	jc disk_error

	; If successful
	mov si, load_ok
	call print_str

	; Jump to loaded stage2
	jmp 0x0600:0000

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

msg:      db "Hello From Sector 1", 0
load_ok:  db " [Stage 2 loaded]", 0
err_msg:  db " [Disk Read Error!]", 0

times 510 - ($ - $$) db 0
dw 0xAA55

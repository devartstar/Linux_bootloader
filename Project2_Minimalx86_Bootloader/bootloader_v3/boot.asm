[BITS 16]
[ORG 0x7C00]

start:
	cli
	xor ax,ax
	mov ds,ax
	mov es,ax
	sti

	; Debug, Hello From Sector 1
	mov si, msg
	call print_str

	; Read stage2.bin from LBS=2 CHS = (0,0,3) -> 0x0600:0000
	mov ax, 0x0600
	mov es, ax
	xor bx, bx

	; int 0x13 - disk reads es:bx as the buffer

	; 0x02 is for read operation
	; 1 sector
	mov ah, 0x02
	mov al, 1

	; cylinder info
	mov ch, 0
	mov cl, 3

	; header info
	mov dh, 0
	mov dl, 0x80

	int 0x13
	jc disk_error

	; jmp to sector 2
	jmp 0x0600:0x0000

disk_error:
	mov si, err_msg
	call print_str
	jmp $	

print_str:
	lodsb
	cmp al,0
	je .done
	mov ah,0x0e
	int 0x10
	jmp print_str

.done
	ret
	
msg:
	db "Hello From Sector 1", 0

err_msg:
	db "Disk Read Error", 0

times 510-($-$$) db 0
dw 0xAA55

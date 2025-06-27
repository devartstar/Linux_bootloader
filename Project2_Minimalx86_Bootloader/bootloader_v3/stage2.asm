[BITS 16]
[ORG 0x0000]

start:
	mov si, msg
	call print_str
	jmp $

print_str:
	lodsb
	cmp al,0
	je .done

	mov ah,0x0e
	int 0x10
	jmp print_str

.done:
	ret

msg:
	db "Hello From Sector 3 of disk", 0

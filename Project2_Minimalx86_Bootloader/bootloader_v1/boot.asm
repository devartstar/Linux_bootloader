[BITS 16]

[ORG 0x7C00]

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	; message to print
	mov si, message

print_char:
	; loads byte from SI to AL
	lodsb
	
	; if the character is null then jump to done
	cmp al, 0
	je done
	
	; BIOS teletype output
	mov ah, 0x0E
	; prints the character in AI on the screen using teletype mode
	; shift al by 1 bit
	int 0x10	

	jmp print_char

done:
	; jumps to the current address, ie. haults the program
	jmp $

message:
	db "Hello, Welcome to the World!", 0

; pad to 510 bytes
times 510-($-$$) db 0

; Boot Signature
dw 0xAA55


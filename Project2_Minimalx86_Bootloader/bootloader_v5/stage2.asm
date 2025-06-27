[BITS 16]
[ORG 0x6000]

strat:
	mov si, msg
	call print_str

	; Read the magic number from memory location
	mov ax, [0x0500]
	call print_hex16

	; prompt
	mov si, prompt_msg
	call print_str

	; BIOS: Wait for key press 
	; ah = 0 and int 0x16
	; al = ASCII of the key pressed
	xor ax, ax
	int 0x16

	; Print the pressed key
	mov ah, 0x0E
	int 0x10

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

; Print ax in hex format
print_hex16:
	push ax
	push bx
	push cx
	push dx

	mov cx, 4

.next_nibble:

	; Rotate left by 4 bits
	rol ax, 4
	mov bl, al
	and bl, 0x0F
	add bl, '0'
	cmp bl, '9'

	; if val - 0 to 9 then print it directly
	jbe .print

	; if val > 9 - ASCII conversion '9' + 7 = 'A'
	add bl, 7

.print:
	mov ah, 0x0E
	mov al, bl
	int 0x10
	loop .next_nibble

	pop dx
	pop cx
	pop bx
	pop ax
	ret

msg: db "Magic Number: 0x", 0
prompt_msg: db 13, 10, "Press Key: ",0

[BITS 16]

; [ORG 0x7C00]

start:
	; disable interrupts
	; Clearning Interrupt flag in Flags Register
	; CPU ignores all maskable interupts
	cli	

	xor ax, ax
	mov ds, ax
	mov es, ax
	
	; enables Hardware interrupts
	sti

	; debugging
	mov si, hello_msg
	call print_str

	; BIOS Reads and load 1 sector at CHS = (0,0,2) into Memory 0x0500
	mov ah, 0x02
	mov al, 1
	mov ch, 0
	mov cl, 2
	mov dh, 0
	mov dl, 0x80
	mov bx, 0x0500
	mov es, ax
	int 0x13

	jc disk_error

	; print the 16 bytes in the sector at (0, 0, 2)
	mov si, 0x0500
	mov cx, 16

print_loop:
	lodsb
	cmp al,0
	je halt
	mov ah,0x0E
	int 0x10
	loop print_loop

halt:
	jmp $

disk_error:
	mov si, err_msg
	call print_str
	jmp $

print_str:
	; loads byte form si to al
	; then increments si++
	lodsb

	; if loaded byte = 0
	cmp al,0
	jmp .done

	; points to the BIOS TTY teletype output function
	mov ah, 0x0E

	; calss BIOS video interrupt
	; prints the character in the screen and advances cursor
	int 0x10

	; loop
	jmp print_str

.done:
	ret

hello_msg:
	db "Hello Boot", 0

err_msg:
	db "Disk Read Error!", 0

; Pad boot sector
times 510-($-$$) db 0
dw 0xAA55


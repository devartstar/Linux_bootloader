[BITS 16]
[ORG 0x6000]

start:
	mov si, msg
	call print_str

	; Read the magic number from memory location
	mov ax, [0x0500]
	call print_hex16

	; prompt
	mov si, prompt_msg
	call print_str

	; Read the line of input into 0x7000
	mov di, 0x7000	; input buffer start
	xor cx, cx	; character count = 0
	; di will point to where the type character stored
	; cx tracks the number of characters typed

.read_loop:
	xor ax,ax
	; 0x16 is BIOS keyboard service
	int 0x16
	; ah = 0, it waits for key press
	; value stored in al

	cmp al, 0x0D	; if <ENTER> is pressed
	je .done_input

	cmp al, 0x08	; if <BACKSPACE> is pressed
	je .handle_backspace

	; Regular character is pressed
	mov [di], al
	inc di
	inc cx

	; Print the character pressed in input line
	mov ah, 0x0E
	int 0x10
	jmp .read_loop

.handle_backspace:
	cmp cx, 0	; if nothing is typed
	je .read_loop	; ignore and continue reading

	; di points to the current input buffer location
	dec di		; move a step back in inp. buffer location	
	dec cx		; decrement number of characters

	; TRICK: FOR HANDELLING BACKSPACE
	; 1. Move the cursor back
	mov ah, 0x0E
	mov al, 0x08	; 0x08 is for backspace
	int 0x10
	; 2. Print Space
	mov al, ' '
	int 0x10
	; 3. Move the cursor back again
	mov al, 0x08
	int 0x10
	jmp .read_loop

.done_input:
	mov al, 0
	mov [di], al	; terminate the string with null

	; print new line - so output in new line
	mov ah, 0x0E
	mov al, 13
	int 0x10
	mov al, 10
	int 0x10

	mov si, echo_msg
	call print_str

	mov si, 0x7000
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

msg: 		db "Magic Number: 0x", 0
prompt_msg: 	db 13, 10, "Enter your Name: ", 0
echo_msg:	db 13, 10, "You Typed: ", 0

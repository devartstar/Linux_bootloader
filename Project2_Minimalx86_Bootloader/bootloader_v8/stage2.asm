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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		STRING COMPARISION		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; String Comaprision
.str_cmp:
	.next:
		lodsb		; Loads the byte in [si] in al
		scasb		; compare byte in al with one in [bi]
		; if the current byte from both string matches - zf=1
		jne .fail

		; test if al == 0, ie. reached end of string
		test al, al
		jnz .next	; if not zero continue the loop

		clc		; cleare the carry flag - ie. success
		ret

	.fail:
		stc		; set the carry flag means failure
		ret

.str_compare_name:
	mov di, cmd_name
	call .str_cmp
	ret

.str_compare_help:
	mov di, cmd_help
	call .str_cmp
	ret

.str_compare_clear:
	mov di, cmd_clear
	call .str_cmp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		COMMAND HANDELLING		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.cmd_name:
	mov si, msg_hello
	call print_str
	jmp .reset

.cmd_help:
	mov si, msg_help
	call print_str
	jmp .reset

.cmd_clear:
	mov ax, 0x0600		; Move the screen up
	mov bh, 0x07		; attribute: light grey on black
	mov cx, 0x0000		; upper left corner
	mov dx, 0x184F		; lower right corner
	int 0x10

	mov ax, 0x0200		; set the cursor at 0,0
	mov bx, 0x0000
	mov dx, 0x0000
	int 0x10
	jmp .reset


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		PRINT HANDELLING		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_str:
	lodsb
	cmp al, 0
	je .done
	mov ah, 0x0E
	int 0x10
	jmp print_str

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		 INPUT HANDELLING		;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

	; Input is "name"
	mov si, input_buf
	call str_compare_name
	je .cmd_name

	; Input is "help"
	mov si, input_buf
	call str_compare_help
	je .cmd_help		; carry falg = 0, ie. success operation
	
	; Input is "clear"
	mov si, input_buf
	call str_compare_clear
	je .cmd_clear

	; Default message for invalid input
	mov si, msg_help
	call print_str
	jmp .reset


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.reset:
	jmp start

.done:
	ret


cmd_name:	db "name",0
cmd_help:	db "help",0
cmd_clear:	db "clear",0

msg_hello:	db "Hello Devjit!", 0x0D, 0x0A, 0
msg_help:	db "Commands: name, help, clear", 0x0D, 0x0A, 0
msg_unknown:	db "Unknown Command!", 0x0D, 0x0A, 0

msg: 		db "Magic Number: 0x", 0
prompt_msg: 	db 13, 10, "Enter your Name: ", 0
echo_msg:	db 13, 10, "You Typed: ", 0

input_buf:  	times 64 db 0

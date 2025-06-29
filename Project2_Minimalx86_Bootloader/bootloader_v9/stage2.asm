[BITS 16]
[ORG 0x6000]

start:
	mov si, msg
	call print_str

	; Print magic number from 0x0500
	mov ax, [0x0500]
	call print_hex16

	; Prompt
	mov si, prompt_msg
	call print_str

	; Clear input buffer first
	mov di, input_buf
	mov cx, 64
	xor al, al
	rep stosb

	; Prepare to read user input
	mov di, input_buf	; Input buffer start
	xor cx, cx		; Reset character counter

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Read Input Character-by-Character	   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.read_loop:
	xor ax, ax
	int 0x16		; BIOS: wait for keypress → AL

	cmp al, 0x0D	; ENTER pressed?
	je .done_input

	cmp al, 0x08	; BACKSPACE?
	je .handle_backspace

	; Store typed char in buffer
	mov [di], al
	inc di
	inc cx

	; Echo to screen
	mov ah, 0x0E
	int 0x10
	jmp .read_loop

.handle_backspace:
	cmp cx, 0
	je .read_loop

	dec di
	dec cx

	mov ah, 0x0E
	mov al, 0x08
	int 0x10
	mov al, ' '
	int 0x10
	mov al, 0x08
	int 0x10
	jmp .read_loop

.done_input:
	mov byte [di], 0	; Null-terminate string

	; Echo newline
	mov ah, 0x0E
	mov al, 0x0D
	int 0x10
	mov al, 0x0A
	int 0x10

	; Split input into command and argument
	call split_input

	; Check for empty command first
	mov si, cmd_buf
	mov al, [si]
	cmp al, 0
	je cmd_name_handler  ; Empty input -> show hello

	; Compare with "name"
	mov si, cmd_buf
	mov di, cmd_name
	call str_cmp
	jnc cmd_name_handler

	; Compare with "help"
	mov si, cmd_buf
	mov di, cmd_help
	call str_cmp
	jnc cmd_help_handler

	; Compare with "clear"
	mov si, cmd_buf
	mov di, cmd_clear
	call str_cmp
	jnc cmd_clear_handler

	; Unknown input
	mov si, msg_unknown
	call print_str
	jmp reset

reset:
	jmp start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		 Command Handlers				       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cmd_name_handler:
	mov si, msg_hello
	call print_str
	
	; Check if there's an argument
	mov si, arg_buf
	mov al, [si]
	cmp al, 0
	je .no_arg
	
	; Print the argument
	call print_str
	jmp .finish

.no_arg:
	mov si, default_name
	call print_str

.finish:
	call newline
	jmp reset

cmd_help_handler:
	mov si, msg_help
	call print_str
	jmp reset

cmd_clear_handler:
	mov ax, 0x0600	; Scroll screen
	mov bh, 0x07
	mov cx, 0x0000
	mov dx, 0x184F
	int 0x10

	; Move cursor to top
	mov ax, 0x0200
	mov bx, 0x0000
	mov dx, 0x0000
	int 0x10
	jmp reset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	       String Comparison Routine		     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Compare strings pointed by SI and DI
; Returns CF=0 if match, CF=1 if no match
str_cmp:
.next:
	lodsb           ; Load byte at [SI] → AL
	mov ah, [di]    ; Load byte at [DI] → AH
	inc di          ; Increment DI manually
	cmp al, ah      ; Compare characters
	jne .fail

	test al, al     ; If AL == 0 → end of string
	jnz .next

	clc             ; Match → clear carry
	ret

.fail:
	stc             ; Mismatch → set carry
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	     Print Hex of AX Register		       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_hex16:
	push ax
	push bx
	push cx
	push dx

	mov cx, 4

.next_nibble:
	rol ax, 4
	mov bl, al
	and bl, 0x0F
	add bl, '0'
	cmp bl, '9'
	jbe .print
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
;	     Print Null-Terminated String		       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_str:
	lodsb
	cmp al, 0
	je .done
	mov ah, 0x0E
	int 0x10
	jmp print_str
.done:
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	       Input Splitting Routine		       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Splits input_buf into cmd_buf and arg_buf
split_input:
	push si
	push di
	push cx
	push ax

	; Clear both buffers first
	mov di, cmd_buf
	mov cx, 16
	xor al, al
	rep stosb
	
	mov di, arg_buf
	mov cx, 48
	xor al, al
	rep stosb

	mov si, input_buf
	mov di, cmd_buf
	mov cx, 0

.copy_cmd:
	lodsb
	cmp al, 0
	je .done
	cmp al, ' '
	je .skip_space
	mov [di], al
	inc di
	inc cx
	cmp cx, 15
	je .done
	jmp .copy_cmd

.skip_space:
	mov byte [di], 0	; null-terminate cmd_buf
	jmp .copy_arg

.copy_arg:
	mov di, arg_buf
.skip_ws:
	lodsb
	cmp al, ' '
	je .skip_ws
	cmp al, 0
	je .done
	mov [di], al
	inc di
	jmp .copy_arg

.done:
	mov byte [di], 0
	pop ax
	pop cx
	pop di
	pop si
	ret

; Helper function for newline
newline:
	mov ah, 0x0E
	mov al, 13
	int 0x10
	mov al, 10
	int 0x10
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		    Data Segment				       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cmd_name:      db "name", 0
cmd_help:      db "help", 0
cmd_clear:     db "clear", 0

msg:           db "Magic Number: 0x", 0
prompt_msg:    db 13, 10, "Enter your Name: ", 0
msg_hello:     db 13, 10, "Hello ", 0
msg_help:      db 13, 10, "Commands: name, help, clear", 0
msg_unknown:   db 13, 10, "Unknown Command!", 0
default_name:  db "Devjit!", 0

input_buf:     times 64 db 0
cmd_buf:       times 16 db 0
arg_buf:       times 48 db 0
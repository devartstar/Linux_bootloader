[BITS 16]
[ORG 0x6000]              ; Load address for stage 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;             STAGE 2 BOOTLOADER ENTRY POINT               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
	; Print initial message
	mov si, msg
	call print_str

	; Read and print 16-bit "magic number" from memory 0x0500
	mov ax, [0x0500]
	call print_hex16

	; Prompt for user input
	mov si, prompt_msg
	call print_str

	; Set DI to input buffer and clear CX (character count)
	mov di, input_buf
	xor cx, cx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                 KEYBOARD INPUT HANDLING                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.read_loop:
	xor ax, ax
	int 0x16                  ; BIOS keyboard read (wait for key)

	; Check if user pressed ENTER (0x0D)
	cmp al, 0x0D
	je .done_input

	; Check if BACKSPACE (0x08)
	cmp al, 0x08
	je .handle_backspace

	; Regular character
	mov [di], al             ; Store character in buffer
	inc di
	inc cx

	mov ah, 0x0E             ; BIOS teletype output
	int 0x10
	jmp .read_loop

.handle_backspace:
	cmp cx, 0                ; If no characters, ignore
	je .read_loop

	; Move cursor and pointer one step back
	dec di
	dec cx

	; Trick: backspace visually and erase character
	mov ah, 0x0E
	mov al, 0x08             ; Backspace
	int 0x10
	mov al, ' '             ; Space to erase
	int 0x10
	mov al, 0x08             ; Move back again
	int 0x10
	jmp .read_loop

.done_input:
	; Null terminate the string
	mov byte [di], 0

	; Check input against known commands
	mov si, input_buf
	mov di, cmd_name
	call str_cmp
	jnc cmd_name_handler     ; Match found

	mov si, input_buf
	mov di, cmd_help
	call str_cmp
	jnc cmd_help_handler

	mov si, input_buf
	mov di, cmd_clear
	call str_cmp
	jnc cmd_clear_handler

	; No match = unknown command
	mov si, msg_unknown
	call print_str
	jmp reset

reset:
	jmp start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                    COMMAND HANDLERS                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cmd_name_handler:
	mov si, msg_hello
	call print_str
	jmp reset

cmd_help_handler:
	mov si, msg_help
	call print_str
	jmp reset

cmd_clear_handler:
	; Scroll screen up (clear)
	mov ax, 0x0600           ; BIOS scroll function
	mov bh, 0x07             ; Attribute: light grey on black
	mov cx, 0x0000           ; Top-left corner
	mov dx, 0x184F           ; Bottom-right corner
	int 0x10

	; Move cursor to (0,0)
	mov ax, 0x0200
	mov bx, 0x0000
	mov dx, 0x0000
	int 0x10
	jmp reset

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                PRINT HELPER ROUTINES                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Print null-terminated string from [SI]
print_str:
	lodsb
	cmp al, 0
	je .done
	mov ah, 0x0E
	int 0x10
	jmp print_str
.done:
	ret

; Print 16-bit AX as hex (uses BIOS int 0x10)
print_hex16:
	push ax
	push bx
	push cx
	push dx

	mov cx, 4                ; 4 hex digits (16-bit)

.next_nibble:
	rol ax, 4                ; Rotate left 4 bits
	mov bl, al
	and bl, 0x0F
	add bl, '0'
	cmp bl, '9'
	jbe .print
	add bl, 7               ; Convert to 'A'-'F'

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;              STRING COMPARISON ROUTINE                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Compares strings at [SI] and [DI]
; CF = 0 if match (use JNC to branch)
str_cmp:
.next:
	lodsb                  ; Load from SI → AL, SI++
	scasb                  ; Compare AL with [DI], DI++
	jne .fail
	test al, al            ; End of string?
	jnz .next
	clc                    ; Strings matched
	ret
.fail:
	stc                    ; Strings differ
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                  DATA SECTION (STRINGS)                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

msg:           db "Magic Number: 0x", 0
prompt_msg:    db 13, 10, "Enter your Name: ", 0

msg_hello:     db 13, 10, "Hello Devjit!", 0
msg_help:      db 13, 10, "Commands: name, help, clear", 0
msg_unknown:   db 13, 10, "Unknown Command!", 0

cmd_name:      db "name", 0
cmd_help:      db "help", 0
cmd_clear:     db "clear", 0

input_buf:     times 64 db 0         ; Max input length = 64

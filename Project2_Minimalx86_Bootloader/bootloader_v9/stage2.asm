; ========================================
; Stage 2 Bootloader - Command Line Interface
; ========================================
; This is the second stage of a minimal x86 bootloader that provides
; a simple command-line interface with basic commands.
; 
; Memory Layout:
; - Loaded at 0x6000 (24KB mark)
; - Uses 16-bit real mode
; ========================================

[BITS 16]				; Assemble for 16-bit real mode
[ORG 0x6000]			; Code starts at memory address 0x6000

start:
	; Print welcome message to introduce the bootloader
	mov si, welcome_msg
	call print_str

	; Display command prompt to user
	mov si, prompt_msg
	call print_str

	; Initialize input buffer for reading user commands
	mov di, input_buf		; DI points to input buffer
	xor cx, cx				; CX = character counter (start at 0)

; ----------------------------------------
; Main Input Reading Loop
; ----------------------------------------
; Continuously reads keyboard input until Enter is pressed
; Handles backspace for editing and echoes characters to screen

read_loop:
	xor ax, ax				; Clear AX register
	int 0x16				; BIOS keyboard interrupt - wait for keypress
							; Returns: AL = ASCII character, AH = scan code

	cmp al, 0x0D			; Check if Enter key (carriage return) was pressed
	je process_input		; If Enter, go process the complete input

	cmp al, 0x08			; Check if Backspace was pressed
	je handle_backspace	; If Backspace, handle character deletion

	; Store the typed character in input buffer
	mov [di], al			; Store character at current buffer position
	inc di					; Move to next buffer position
	inc cx					; Increment character count

	; Echo the character to screen (visual feedback)
	mov ah, 0x0E			; BIOS teletype output function
	int 0x10				; Display character in AL
	jmp read_loop			; Continue reading input

; ----------------------------------------
; Backspace Handling
; ----------------------------------------
; Removes the last character from input buffer and screen

handle_backspace:
	cmp cx, 0				; Check if there are any characters to delete
	je read_loop			; If buffer is empty, ignore backspace
	
	; Remove character from buffer
	dec di					; Move buffer pointer back one position
	dec cx					; Decrease character count
	
	; Visual backspace on screen (move cursor back, print space, move back again)
	mov ah, 0x0E			; BIOS teletype function
	mov al, 0x08			; Backspace character (move cursor left)
	int 0x10
	mov al, ' '				; Space character (overwrite previous char)
	int 0x10
	mov al, 0x08			; Another backspace (final cursor position)
	int 0x10
	jmp read_loop			; Continue reading input

; ----------------------------------------
; Input Processing and Command Parsing
; ----------------------------------------
; Processes the complete input line and separates command from arguments

process_input:
	mov byte [di], 0		; Null-terminate the input string

	; Clear command buffer (32 bytes)
	mov di, cmd_buf			; Point to command buffer
	mov cx, 32				; Buffer size
	xor al, al				; Fill with zero bytes
	rep stosb				; Repeat store byte (clear buffer)

	; Clear argument buffer (64 bytes)
	mov di, arg_buf			; Point to argument buffer
	mov cx, 64				; Buffer size
	xor al, al				; Fill with zero bytes
	rep stosb				; Repeat store byte (clear buffer)

	; Parse command part (first word before space)
	mov si, input_buf		; Source: input buffer
	mov di, cmd_buf			; Destination: command buffer
.copy_cmd:
	lodsb					; Load byte from [SI] into AL, increment SI
	cmp al, 0				; Check for end of string
	je parse_args			; If end of string, start parsing arguments
	cmp al, ' '				; Check for space (command separator)
	je parse_args			; If space found, start parsing arguments
	stosb					; Store byte from AL into [DI], increment DI
	jmp .copy_cmd			; Continue copying command

; ----------------------------------------
; Argument Parsing
; ----------------------------------------
; Extracts arguments (everything after the command) from input

parse_args:
	cmp al, 0				; Check if we're at end of input
	je compare				; If so, no arguments to parse

	; Skip any extra spaces between command and arguments
.next_space:
	lodsb					; Load next character
	cmp al, 0				; Check for end of string
	je compare				; If end, start command comparison
	cmp al, ' '				; Check if still on space
	je .next_space			; If space, continue skipping

	; Copy argument to argument buffer
	mov di, arg_buf			; Point to argument buffer
.copy_arg:
	cmp al, 0				; Check for end of string
	je compare				; If end, start command comparison
	stosb					; Store argument character
	lodsb					; Load next character
	jmp .copy_arg			; Continue copying argument

; ----------------------------------------
; Command Recognition and Dispatch
; ----------------------------------------
; Compares parsed command with known commands and executes appropriate handler

compare:
	; Check if command is "name"
	mov si, cmd_buf			; Source: parsed command
	mov di, str_name		; Destination: "name" string
	call str_cmp			; Compare strings
	jnc cmd_name			; If match (carry clear), execute name command

	; Check if command is "help"
	mov si, cmd_buf			; Source: parsed command
	mov di, str_help		; Destination: "help" string
	call str_cmp			; Compare strings
	jnc cmd_help			; If match (carry clear), execute help command

	; Check if command is "clear"
	mov si, cmd_buf			; Source: parsed command
	mov di, str_clear		; Destination: "clear" string
	call str_cmp			; Compare strings
	jnc cmd_clear			; If match (carry clear), execute clear command

	; No command matched - show error message
	mov si, msg_unknown		; Load "unknown command" message
	call print_str			; Display error message
	jmp reset				; Reset and show prompt again

; ----------------------------------------
; Command Handlers
; ----------------------------------------

; NAME Command Handler
; Usage: name <yourname>
; Displays "Hello <yourname>" greeting
cmd_name:
	mov si, msg_hello		; Load "Hello " message
	call print_str			; Display greeting prefix
	mov si, arg_buf			; Load the name argument
	call print_str			; Display the provided name
	mov si, newline			; Load newline characters
	call print_str			; Move to next line
	jmp reset				; Return to command prompt

; HELP Command Handler
; Usage: help
; Displays available commands and their usage
cmd_help:
	mov si, msg_help		; Load help text with command list
	call print_str			; Display help information
	jmp reset				; Return to command prompt

; CLEAR Command Handler
; Usage: clear
; Clears the screen and resets cursor to top-left corner
cmd_clear:
	; Clear screen using BIOS scroll function
	mov ax, 0x0600			; AH=06 (scroll window up), AL=00 (clear entire window)
	mov bh, 0x07			; Attribute: light grey text on black background
	mov cx, 0x0000			; Upper-left corner: row 0, column 0
	mov dx, 0x184F			; Lower-right corner: row 24 (0x18), column 79 (0x4F)
	int 0x10				; BIOS video interrupt

	; Reset cursor position to top-left corner
	mov ax, 0x0200			; AH=02 (set cursor position), AL=00
	mov bx, 0x0000			; Page 0
	mov dx, 0x0000			; Row 0, Column 0
	int 0x10				; BIOS video interrupt
	jmp reset				; Return to command prompt

; ----------------------------------------
; Program Flow Control
; ----------------------------------------

; Reset function - returns to the main command prompt
reset:
	jmp start				; Jump back to start for next command

; ========================================
; Utility Functions
; ========================================

; String Comparison Function
; Compares two null-terminated strings
; Input: SI = pointer to first string, DI = pointer to second string
; Output: Carry flag clear if strings match, set if different
str_cmp:
.next:
	lodsb					; Load byte from [SI] into AL, increment SI
	scasb					; Compare AL with byte at [DI], increment DI
	jne .fail				; If bytes don't match, strings are different
	test al, al				; Check if we reached null terminator (end of string)
	jnz .next				; If not end, continue comparing
	clc						; Clear carry flag (strings match)
	ret						; Return to caller
.fail:
	stc						; Set carry flag (strings don't match)
	ret						; Return to caller

; String Printing Function
; Prints a null-terminated string to screen
; Input: SI = pointer to string
; Uses BIOS teletype function for character output
print_str:
	lodsb					; Load character from [SI] into AL, increment SI
	cmp al, 0				; Check if null terminator (end of string)
	je .done				; If end of string, finish printing
	mov ah, 0x0E			; BIOS teletype output function
	int 0x10				; Display character in AL
	jmp print_str			; Continue with next character
.done:
	ret						; Return to caller

; ========================================
; Data Section
; ========================================
; Contains all strings, messages, and buffers used by the bootloader

; User Interface Messages
welcome_msg:	db 13, 10, "Welcome to Stage 2", 13, 10, 0		; Startup message with CRLF
prompt_msg: 	db 13, 10, "Enter command: ", 0					; Command prompt
newline:		db 13, 10, 0									; Carriage return + line feed

; Command Response Messages
msg_hello:		db "Hello ", 0									; Greeting prefix for name command
msg_help:		db "Commands: name <yourname>, help, clear", 13, 10, 0	; Help text listing available commands
msg_unknown:	db "Unknown command!", 13, 10, 0				; Error message for invalid commands

; Command String Constants (for comparison)
str_name:		db "name", 0									; "name" command string
str_help:		db "help", 0									; "help" command string
str_clear:		db "clear", 0									; "clear" command string

; Input/Output Buffers
input_buf:		times 64 db 0									; Raw input buffer (64 bytes)
cmd_buf:		times 32 db 0									; Parsed command buffer (32 bytes)
arg_buf:		times 64 db 0									; Parsed argument buffer (64 bytes)

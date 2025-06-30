[BITS 16]
[ORG 0x6000]        ; This is where stage2 is loaded by stage1 (0x0600:0000)

start:
    ; Print startup message
    mov si, msg_welcome
    call print_str

.read_loop:
    ; Prompt user
    mov si, prompt_msg
    call print_str

    ; Clear buffers
    mov di, cmd_buf
    mov cx, 64
    xor al, al
    rep stosb

    mov di, arg_buf
    mov cx, 64
    xor al, al
    rep stosb

    ; Read user input into cmd_buf
    mov di, cmd_buf
    call read_line

    ; Parse command and arguments from cmd_buf → arg_buf
    mov si, cmd_buf
    call parse_args

    ; Compare with supported commands
    mov si, cmd_buf
    mov di, cmd_name
    call strcmp
    jnc .cmd_name

    mov si, cmd_buf
    mov di, cmd_help
    call strcmp
    jnc .cmd_help

    mov si, cmd_buf
    mov di, cmd_clear
    call strcmp
    jnc .cmd_clear

    ; Unknown command
    mov si, msg_unknown
    call print_str
    jmp .read_loop

.cmd_name:
    mov si, msg_hello
    call print_str
    mov si, arg_buf
    call print_str
    call newline
    jmp .read_loop

.cmd_help:
    mov si, msg_help
    call print_str
    call newline
    jmp .read_loop

.cmd_clear:
    ; BIOS scroll screen
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10

    ; Set cursor to 0,0
    mov ax, 0x0200
    mov bx, 0
    mov dx, 0
    int 0x10
    jmp .read_loop

; -----------------------------------
; Helper: Read a line into DI buffer
; -----------------------------------
read_line:
    xor cx, cx              ; character count
.read_char:
    xor ax, ax
    int 0x16                ; BIOS: wait for keypress → AL
    cmp al, 13              ; Enter?
    je .done
    cmp al, 8               ; Backspace?
    je .handle_backspace

    ; Normal char
    mov [di], al
    inc di
    inc cx

    mov ah, 0x0E
    int 0x10
    jmp .read_char

.handle_backspace:
    cmp cx, 0
    je .read_char
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_char

.done:
    mov byte [di], 0
    call newline
    ret

; -----------------------------------
; Helper: Parse first word into cmd_buf, rest into arg_buf
; -----------------------------------
parse_args:
    ; Skip leading spaces
.skip_spaces:
    lodsb
    cmp al, 0
    je .done_parse
    cmp al, ' '
    je .skip_spaces

    ; Copy command (word before space)
    mov di, cmd_buf
.copy_cmd:
    cmp al, 0
    je .done_parse
    cmp al, ' '
    je .copy_arg_start
    stosb
    lodsb
    jmp .copy_cmd

.copy_arg_start:
    ; Skip any extra spaces before arg
.skip_arg_spaces:
    cmp al, 0
    je .done_parse
    cmp al, ' '
    je .skip_arg_spaces

    ; Copy rest to arg_buf
    mov di, arg_buf
.copy_arg:
    cmp al, 0
    je .done_parse
    stosb
    lodsb
    jmp .copy_arg

.done_parse:
    ret

; -----------------------------------
; strcmp: sets CF=0 if equal
; -----------------------------------
strcmp:
.next:
    lodsb
    scasb
    jne .fail
    test al, al
    jnz .next
    clc
    ret
.fail:
    stc
    ret

; -----------------------------------
; Print string pointed by SI
; -----------------------------------
print_str:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp print_str
.done:
    ret

; Print newline (CRLF)
newline:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

; -----------------------------------
; Data Section
; -----------------------------------
cmd_buf:    times 64 db 0
arg_buf:    times 64 db 0

cmd_name:   db "name", 0
cmd_help:   db "help", 0
cmd_clear:  db "clear", 0

msg_welcome: db "Welcome to Stage 2", 13, 10, 0
prompt_msg: db 13, 10, "Enter command: ", 0
msg_hello:  db "Hello ", 0
msg_help:   db "Available: name <you>, help, clear", 0
msg_unknown:db "Unknown Command!", 13, 10, 0

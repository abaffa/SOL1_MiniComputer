;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SHELL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.include kernel.exp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MEMORY MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0000		ROM BEGIN
; ....
; 7FFF		ROM END
;
; 8000		RAM begin
; ....
; F7FF		Stack root
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; I/O MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FF80		UART 0		(16550)
; FF90		UART 1		(16550)
; FFA0		RTC			(M48T02)
; FFB0		PIO 0		(8255)
; FFC0		PIO 1		(8255)
; FFD0		IDE			(Compact Flash / PATA)
; FFE0		Timer		(8253)
; FFF0		BIOS CONFIGURATION NV-RAM STORE AREA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SYSTEM CONSTANTS / EQUATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TOKTYP_IDENTIFIER			.equ 0
TOKTYP_KEYWORD			.equ 1
TOKTYP_DELIMITER			.equ 2
TOKTYP_STRING				.equ 3
TOKTYP_CHAR				.equ 4
TOKTYP_NUMERIC			.equ 5

TOK_NULL					.equ 0
TOK_SLASH				.equ 1
TOK_TIMES 				.equ 2
TOK_PLUS 				.equ 3
TOK_MINUS 				.equ 4
TOK_DASH					.equ 4
TOK_OTHER				.equ 5
TOK_DOT					.equ 6
TOK_DDOT					.equ 7

TOK_END					.equ 15


_STACK_BEGIN				.equ $F7FF				; beginning of stack

_NULL					.equ 0

	
SHELL_RESET_VECTOR:	
	mov bp, _STACK_BEGIN
	mov sp, _STACK_BEGIN

	mov d, s_welcome
	call puts
	
	call shell			; this is the main shell procedure. the shell will loop here
	
	
shell:
shell_L1:
	sti
	mov byte [token_str], 0			; clear token_str (so that enter doesnt repeat last shell command)
	mov al, 13
	syscall sys_fileio
	
	mov d, shell_input_buff
	mov a, d
	mov [shell_buff_ptr], a
	call gets
	call get_token					; get command into token_str
	mov di, keywords
shell_L2:	
	push di
	add di, 2
	mov a, token_str
	mov si, a
	call strcmp
	pop di
	je cmd_equal	
	add di, 10
	push d
	lea d, [di + 0]
	mov al, [d]
	cmp al, 0
	pop d
	je cmd_not_found
	jmp shell_L2
cmd_equal:
	push d
	
	mov a, di
	call [a+0]
	pop d
	jmp shell_L1
cmd_not_found:
	call printnl
	call cmd_exec
	jmp shell_L1


cmd_test:
	mov c, 100
cmd_test_L0:
	sti
	dec c
	cmp c, 0
	jne cmd_test_L0
	ret


cmd_primer:
	call printnl
	syscall sys_primer
	call printnl
	ret

cmd_ps:
	call printnl
	syscall sys_list
	ret

cmd_en:

	syscall sys_en
	ret

cmd_fork:
	call printnl
	syscall sys_fork
	ret

cmd_fwb:
	syscall sys_fwb
	ret
	
cmd_fwk:
	syscall sys_fwk
	ret
	
	
loader:
	call get_token
	mov d, token_str
	call strtoint
	
	mov g, a
	mov d, s_dataentry
	call puts
	mov di, a					; save destiny
	call _load_hex
	call printnl
	ret
	
loadcall:
	call get_token
	mov d, token_str
	call strtoint
	
	mov [addr1], a			; save address
	mov d, s_dataentry
	call puts
	mov di, a					; save destiny
	call _load_hex
	call printnl

	mov a, [addr1]			; retrieve address
	
	call a
	ret
	
addr1: .dw 0
		
;******************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; strstr
; find sub-string
; str1 in SI
; str2 in DI
; SI points to end of source string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strstr:
	push al
	push d
	push di
strstr_loop:	
	cmpsb					; compare a byte of the strings
	jne strstr_ret
	lea d, [di + 0]
	mov al, [d]
	cmp al, 0				; check if at end of string (null)
	jne strstr_loop				; equal chars but not at end
strstr_ret:
	pop di
	pop d
	pop al				
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STRCMP
; compare two strings
; str1 in SI
; str2 in DI
; CREATE A STRING COMPAIRON INSTRUCION ?????
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strcmp:
	push al
	push d
	push di
	push si
strcmp_loop:	
	cmpsb					; compare a byte of the strings
	jne strcmp_ret
	lea d, [si +- 1]
	mov al, [d]
	cmp al, 0				; check if at end of string (null)
	jne strcmp_loop				; equal chars but not at end
strcmp_ret:
	pop si
	pop di
	pop d
	pop al				
	ret

call_address:
	call get_token
	mov d, token_str
	call strtoint
	
	call a
	ret

; STRCPY
; copy null terminated string from SI to DI
; source in SI
; destination in DI
strcpy:
	push si
	push di
	push al
strcpy_L1:
	lodsb
	stosb
	cmp al, 0
	jne strcpy_L1	
strcpy_end:
	pop al
	pop di
	pop si
	ret
	
; STRCAT
; concatenate a NULL terminated string into string at DI, from string at SI
; source in SI
; destination in DI
strcat:
	push si
	push di
	push al
	push d
	mov a, di
	mov d, a
strcat_goto_end_L1:
	mov al, [d]
	cmp al, 0
	je strcat_start
	inc d
	jmp strcat_goto_end_L1
strcat_start:
	mov di, d
strcat_L1:
	lodsb
	stosb
	cmp al, 0
	jne strcat_L1	
strcat_end:
	pop d
	pop al
	pop di
	pop si
	ret
	
; ************************************************************
; GET HEX FILE
; di = destination address
; return length in bytes in C
; ************************************************************
_load_hex:
	push bp
	mov bp, sp
	push a
	push b
	push d
	push si
	push di
	sub sp, $6000				; string data block
	mov c, 0
	
	mov a, sp
	inc a
	mov d, a				; start of string data block
	call gets				; get program string
	mov si, a
__load_hex_loop:
	lodsb					; load from [SI] to AL
	cmp al, 0				; check if ASCII 0
	jz __load_hex_ret
	mov bh, al
	lodsb
	mov bl, al
	call atoi				; convert ASCII byte in B to int (to AL)
	stosb					; store AL to [DI]
	inc c
	jmp __load_hex_loop
__load_hex_ret:
	add sp, $6000
	pop di
	pop si
	pop d
	pop b
	pop a
	mov sp, bp
	pop bp
	ret




mem_dump:
	call get_token
	mov d, token_str
	call strtoint
mem_dump_short:
	call printnl
	mov d, a				; dump pointer in d
	mov c, 0
dump_loop:
	mov al, cl
	and al, $0F
	jz print_base
back:
	mov al, [d]				; read byte
	mov bl, al
	call print_u8x
	mov a, $2000
	syscall sys_io			; space
	mov al, cl
	and al, $0F
	cmp al, $0F
	je print_ascii
back1:
	inc d
	inc c
	cmp c, 512
	jne dump_loop
	call printnl
	ret
print_ascii:
	mov a, $2000
	syscall sys_io
	sub d, 16
	mov b, 16
print_ascii_L:
	inc d
	mov al, [d]				; read byte
	cmp al, $20
	jlu dot
	cmp al, $7E
	jleu ascii
dot:
	mov a, $2E00
	syscall sys_io
	jmp ascii_continue
ascii:
	mov ah, al
	mov al, 0
	syscall sys_io
ascii_continue:
	loopb print_ascii_L
	jmp back1
print_base:
	call printnl
	mov b, d
	call print_u16x				; display row
	mov a, $3A00
	syscall sys_io
	mov a, $2000
	syscall sys_io
	jmp back


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GETCHAR
; char in ah
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getchar:
	push a
	mov al, 1
	syscall sys_io			; receive in AH
	pop a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PUTCHAR
; char in ah
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
putchar:
	push a
	mov al, 0
	syscall sys_io			; char in AH
	pop a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT A STRING 
;; terminates with null
;; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gets:
	push a
	push d
gets_loop:
	sti
	mov al, 1
	syscall sys_io			; receive in AH
	cmp ah, $FF				; check if nothing received (code for that is FF)
	je gets_loop
	
	cmp ah, 0Ah				; LF
	je gets_end
	cmp ah, 0Dh				; CR
	je gets_end
	cmp ah, $5C				; '\\'
	je gets_escape
	mov al, ah
	mov [d], al
	inc d
	jmp gets_loop
gets_escape:
	mov al, 1
	syscall sys_io			; receive in AH
	cmp ah, 'n'
	je gets_LF
	cmp ah, 'r'
	je gets_CR
	mov al, ah				; if not a known escape, it is just a normal letter
	mov [d], al
	inc d
	jmp gets_loop
gets_LF:
	mov al, $0A
	mov [d], al
	inc d
	jmp gets_loop
gets_CR:
	mov al, $0D
	mov [d], al
	inc d
	jmp gets_loop
gets_end:
	mov al, 0
	mov [d], al				; terminate string
	pop d
	pop a
	sti
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NEW LINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printnl:
	push a
	mov a, $0A00
	syscall sys_io
	mov a, $0D00
	syscall sys_io
	pop a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT 2 NEW LINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_NL2:
	push a
	mov a, $0A00
	syscall sys_io
	mov a, $0A00
	syscall sys_io
	mov a, $0D00
	syscall sys_io
	pop a
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CONVERT ASCII 'O'..'F' TO INTEGER 0..15
; ASCII in BL
; result in AL
; ascii for F = 0100 0110
; ascii for 9 = 0011 1001
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hex_ascii_encode:
	mov al, bl
	test al, 40h				; test if letter or number
	jnz hex_letter
	and al, 0Fh				; get number
	ret
hex_letter:
	and al, 0Fh				; get letter
	add al, 9
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATOI
; 2 letter hex string in B
; 8bit integer returned in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
atoi:
	push b
	
	call hex_ascii_encode			; convert BL to 4bit code in AL
	mov bl, bh
	push al					; save a
	call hex_ascii_encode
	pop bl	
	shl al, 4
	or al, bl
	
	pop b
	ret	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ITOA
; 8bit value in BL
; 2 byte ASCII result in A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
itoa:
	push d
	push	bh
	push bl

	mov bh, 0
	
	and 	bl, $0F
	mov 	d, s_hex_digits
	add 	d, b
	mov 	al, [d]				; get ASCII
	pop 	bl
	sub sp, 1				; push bl back
	push al
	
	and 	bl, $F0
	shr 	bl, 4
	mov 	d, s_hex_digits
	add 	d, b
	mov 	al, [d]				; get ASCII

	mov ah, al
	pop 	al	
	
	pop 	bl
	pop bh
	pop 	d
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; strtoint
; 4 digit string number in d
; integer returned in A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strtoint:
	push b
	mov bl, [d]
	mov bh, bl
	mov bl, [d + 1]
	call atoi				; convert to int in AL
	mov ah, al				; move to AH	
	mov bl, [d + 2]
	mov bh, bl
	mov bl, [d + 3]
	call atoi				; convert to int in AL
	pop b
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NULL TERMINATED STRING
; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
puts:
	push a
	push d
puts_L1:
	mov al, [d]
	cmp al, 0
	jz puts_END
	mov ah, al
	mov al, 0
	syscall sys_io
	inc d	
	jmp puts_L1
puts_END:
	pop d
	pop a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; print 16bit decimal number	
; input number in A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_u16d:
	push a
	push b
	
	mov b, 10000
	div a, b			; get 10000 coeff.
	call print_zero_or_space
	mov a, b
	
	mov b, 1000
	div a, b			; get 10000 coeff.
	call print_zero_or_space
	mov a, b

	mov b, 100
	div a, b			
	call print_zero_or_space
	mov a, b
		
	mov b, 10
	div a, b		
	call print_zero_or_space
	mov a, b
	
	mov al, bl
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
	pop b
	pop a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; if A == 0, print space
; else print A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_zero_or_space:
	; cmp a, 0
	; jne print_number
	; mov ah, $20
	; call putchar
	; ret
print_number:
	add al, $30
	mov ah, al
	call putchar
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT 16BIT HEX INTEGER
; integer value in reg B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_u16x:
	push a
	push b
	push bl
	mov bl, bh
	call itoa				; convert bh to char in A
	mov bl, al				; save al	
	mov al, 0
	syscall sys_io				; display AH
	mov ah, bl				; retrieve al
	mov al, 0
	syscall sys_io				; display AL

	pop bl
	call itoa				; convert bh to char in A
	mov bl, al				; save al
	mov al, 0
	syscall sys_io				; display AH
	mov ah, bl				; retrieve al
	mov al, 0
	syscall sys_io				; display AL

	pop b
	pop a
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT 16BIT HEX INTEGER
; read 16bit integer into A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scan_u16x:
	enter 16
	push b
	push d

	lea d, [bp + -15]
	call gets				; get number

	mov bl, [d]
	mov bh, bl
	mov bl, [d + 1]
	call atoi				; convert to int in AL
	mov ah, al				; move to AH
	
	mov bl, [d + 2]
	mov bh, bl
	mov bl, [d + 3]
	call atoi				; convert to int in AL
	
	pop d	
	pop b
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT 8BIT HEX INTEGER
; read 8bit integer into AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scan_u8x:
	enter 4
	push b
	push d

	lea d, [bp + -3]
	call gets				; get number

	mov bl, [d]
	mov bh, bl
	mov bl, [d + 1]
	call atoi				; convert to int in AL
	
	pop d	
	pop b
	leave
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT 8bit HEX INTEGER
; integer value in reg bl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_u8x:
	push a
	push bl

	call itoa				; convert bl to char in A
	mov bl, al				; save al
	mov al, 0
	syscall sys_io				; display AH
	mov ah, bl				; retrieve al
	mov al, 0
	syscall sys_io				; display AL

	pop bl
	pop a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; print 8bit decimal unsigned number	
; input number in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_u8d:
	push a
	push b
		
	mov ah, 0
	mov b, 100
	div a, b			
	push b			; save remainder
	cmp al, 0
	je skip100
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
skip100:
	pop a
	mov ah, 0
	mov b, 10
	div a, b			
	push b			; save remainder
	cmp al, 0
	je skip10
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
skip10:
	pop a
	mov al, bl
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
	pop b
	pop a
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HEX STRING TO BINARY
; di = destination address
; si = source
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hex_to_int:
hex_to_int_L1:
	lodsb					; load from [SI] to AL
	cmp al, 0				; check if ASCII 0
	jz hex_to_int_ret
	mov bh, al
	lodsb
	mov bl, al
	call atoi				; convert ASCII byte in B to int (to AL)
	stosb					; store AL to [DI]
	jmp hex_to_int_L1
hex_to_int_ret:
	ret		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; length of null terminated string
; result in C
; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strlen:
	push d
	push al
	mov c, 0
strlen_L1:
	cmp byte [d], 0
	je strlen_ret
	inc d
	inc c
	jmp strlen_L1	
strlen_ret:
	pop al
	pop d
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; input decimal number	
; result in A
; 655'\0'
; low--------high
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scan_u16d:
	enter 8
	push si
	push b
	push c
	push d
	lea d, [bp +- 7]
	call gets
	call strlen			; get string length in C
	dec c	
	mov si, d
	mov a, c
	shl a
	mov d, table_power
	add d, a
	mov c, 0
mul_loop:
	lodsb			; load ASCII to al
	cmp al, 0
	je mul_exit
	sub al, $30		; make into integer
	mov ah, 0
	mov b, [d]
	mul a, b			; result in B since it fits in 16bits
	mov a, b
	mov b, c
	add a, b
	mov c, a
	sub d, 2
	jmp mul_loop
mul_exit:
	mov a, c
	pop d
	pop c
	pop b
	pop si
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SHELL DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_token:
	mov al, TOK_NULL
	mov [token], al				; nullify token
	mov a, [shell_buff_ptr]
	mov si, a
	mov di, token_str
skip_spaces:
	lodsb
	cmp al, $20
	je skip_spaces
	cmp al, $0D
	je skip_spaces
	cmp al, $0A
	je skip_spaces
get_tok_type:
	call isalpha				;check if is alpha
	jz is_alphanumeric
	call isnumeric			;check if is numeric
	jz is_alphanumeric
; other token types
get_token_slash:
	cmp al, '/'				; check if '/'
	jne get_token_dash
	stosb					; store '/' into token string
	mov al, 0
	stosb					; terminate token string
	mov al, TOK_SLASH
	mov [token], al			; save token as SLASH
	mov a, si
	mov [shell_buff_ptr], a		; update pointer
	ret
get_token_dash:
	cmp al, '-'				; check if '-'
	jne get_token_dot
	stosb					; store '-' into token string
	mov al, 0
	stosb					; terminate token string
	mov al, TOK_DASH
	mov [token], al			; save token as SLASH
	mov a, si
	mov [shell_buff_ptr], a		; update pointer
	ret
get_token_dot:
	cmp al, '.'				; check if '.'
	jne get_token_skip
	stosb					; store '.' into token string
	lodsb
	cmp al, $2E
	je get_token_ddot
	sub si, 1
	mov al, 0
	stosb					; terminate token string
	mov al, TOK_DOT
	mov [token], al			; save token as DOT
	mov a, si
	mov [shell_buff_ptr], a		; update pointer
	ret
get_token_ddot:
	stosb
	mov al, 0
	stosb
	mov al, TOK_DDOT
	mov [token], al			; save token as DDOT
	mov a, si
	mov [shell_buff_ptr], a		; update pointer
	ret
get_token_skip:
	sub si, 1
	mov a, si
	mov [shell_buff_ptr], a		; update pointer
	ret
is_alphanumeric:
	stosb
	lodsb
	call isalpha				;check if is alpha
	jz is_alphanumeric
	call isnumeric			;check if is numeric
	jz is_alphanumeric
	cmp al, $2E				; check if is '.'
	je is_alphanumeric
	mov al, 0
	stosb
	mov al, TOKTYP_IDENTIFIER
	mov [token_type], al
	sub si, 1
	mov a, si
	mov [shell_buff_ptr], a		; update pointer
	ret
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PUT BACK TOKEN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
putback:
	push si
	mov si, token_str	
putback_loop:
	lodsb
	cmp al, 0
	je putback_end
	mov a, [shell_buff_ptr]
	dec a
	mov [shell_buff_ptr], a			; update pointer
	jmp putback_loop
putback_end:
	pop si
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IS NUMERIC
;; sets ZF according with result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isnumeric:
	push al
	cmp al, '0'
	jlu isnumeric_false
	cmp al, '9'
	jgu isnumeric_false
	lodflgs
	or al, %00000001
	stoflgs
	pop al
	ret
isnumeric_false:
	lodflgs
	and al, %11111110
	stoflgs
	pop al
	ret	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IS ALPHA
;; sets ZF according with result
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isalpha:
	push al
	cmp al, '_'
	je isalpha_true
	
	call to_lower
	cmp al, 'a'
	jlu isalpha_false
	cmp al, 'z'
	jgu isalpha_false
isalpha_true:
	lodflgs
	or al, %00000001
	stoflgs
	pop al
	ret
isalpha_false:
	lodflgs
	and al, %11111110
	stoflgs
	pop al
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TO LOWER
; input in AL
; output in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_lower:
	cmp al, 'Z'
	jgu to_lower_ret
	add al, $20				; convert to lower case
to_lower_ret:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TO UPPER
; input in AL
; output in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_upper:
	cmp al, 'a'
	jlu to_upper_ret
	sub al, $20			; convert to upper case
to_upper_ret:
	ret
	
; ********************************************************************
; DATETIME
; ********************************************************************
cmd_printdate:
	mov al, 3
	syscall sys_rtc				; get week
	mov al, ah
	mov ah, 0
	shl a, 2					; times 16
	mov d, s_week
	add d, a
	call puts
	mov a, $2000
	syscall sys_io					; display ' '
	
	mov al, 4
	syscall sys_rtc					; get day
	mov bl, ah
	call print_u8x
	mov a, $2000
	syscall sys_io					; display ' '
	
	mov al, 05
	syscall sys_rtc				; get month
	mov al, ah
	mov ah, 0
	shl a, 2					; times 16
	mov d, s_months
	add d, a
	call puts
	
	mov a, $2000
	syscall sys_io			; display ' '
	
	mov bl, $20
	call print_u8x			; print 20 for year prefix
	mov al, 06
	syscall sys_rtc					; get year
	mov bl, ah
	call print_u8x
	
	mov a, $2000	
	syscall sys_io			; display ' '

	mov al, 2
	syscall sys_rtc					; get hours
	mov bl, ah
	call print_u8x
	mov a, $3A00		
	syscall sys_io				; display ':'

	mov al, 01
	syscall sys_rtc					; get minutes
	mov bl, ah
	call print_u8x
	mov a, $3A00	
	syscall sys_io			; display ':'

	mov al, 0
	syscall sys_rtc					; get seconds
	mov bl, ah
	call print_u8x
	
	call printnl
	ret
	
cmd_setdate:
	call printnl
	mov d, s_set_year
	call puts
	call scan_u8x				; read integer into A
	shl a, 8				; only AL used, move to AH
	mov al, 0Dh				; set RTC year
	syscall sys_rtc					; set RTC
	
	call printnl
	mov d, s_set_month
	call puts
	call scan_u8x					; read integer into A
	shl a, 8				; only AL used, move to AH
	mov al, 0Ch				; set RTC month
	syscall sys_rtc					; set RTC

	call printnl
	mov d, s_set_day
	call puts
	call scan_u8x					; read integer into A
	shl a, 8				; only AL used, move to AH
	mov al, 0Bh				; set RTC month
	syscall sys_rtc					; set RTC

	call printnl
	mov d, s_set_week
	call puts
	call scan_u8x					; read integer into A
	shl a, 8				; only AL used, move to AH
	mov al, 0Ah				; set RTC month
	syscall sys_rtc					; set RTC

	call printnl
	mov d, s_set_hours
	call puts
	call scan_u8x					; read integer into A
	shl a, 8				; only AL used, move to AH
	mov al, 09h				; set RTC month
	syscall sys_rtc					; set RTC

	call printnl
	mov d, s_set_minutes
	call puts
	call scan_u8x					; read integer into A
	shl a, 8				; only AL used, move to AH
	mov al, 08h				; set RTC month
	syscall sys_rtc					; set RTC

	call printnl
	mov d, s_set_seconds
	call puts
	call scan_u8x					; read integer into A
	shl a, 8					; only AL used, move to AH
	mov al, 07h				; set RTC month
	syscall sys_rtc					; set RTC
	
	call printnl
	ret	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FILE SYSTEM DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; infor for : IDE SERVICES INTERRUPT
; al = option
; IDE read/write sector
; 512 bytes
; user buffer pointer in D
; AH = number of sectors
; CB = LBA bytes 3..0	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FILE SYSTEM DATA STRUCTURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for a directory we have the header first, followed by metadata
; header 1 sector (512 bytes)
; metadata 1 sector (512 bytes)
; HEADER ENTRIES:
; filename (64)
; parent dir LBA (2) -  to be used for faster backwards navigation...
;
; metadata entries:
; filename (24)
; attributes (1)
; LBA (2)
; size (2)
; day (1)
; month (1)
; year (1)
; packet size = 32 bytes
;
; first directory on disk is the root directory '/'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; FILE SYSTEM DISK FORMATTING
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; writes FST_TOTAL_SECTORS + FS_NBR_FILES disk sectors  with 0's
; this is the file system table formating
cmd_mkfs:
	call printnl	
	mov al, 0
	syscall sys_fileio
	ret
	

cmd_fs_space:
	mov al, 1
	syscall sys_fileio
	call printnl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CREATE NEW DIRECTORY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search list for NULL name entry.
; add new directory to list
cmd_mkdir:
	call get_token
	mov d, token_str
	mov al, 2
	syscall sys_fileio
	call printnl
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search for given directory inside current dir
; if found, read its LBA, and switch directories
cmd_cd:
	call printnl
	call get_token			; get dir name
	mov al, [token]			; get token
	cmp al, TOK_DDOT			; check if ".."
	jne cmd_cd_child			; is a child directory
	
; else we want the parent directory
	mov al, 12
	syscall sys_fileio
	ret
cmd_cd_child:
	mov d, token_str
	mov al, 3
	syscall sys_fileio
	ret

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_ls:	
	call printnl
	mov al, 4
	syscall sys_fileio
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pad string to 32 chars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; count in C
padding:
	push a
	mov a, 32
	mov b, c
	sub a, b
	mov c, a
padding_L1:
	mov ah, $20
	call putchar
	loopc padding_L1
	pop a
	ret
; file structure:
; 512 bytes header
; header used to tell whether the block is free

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CREATE NEW TEXTFILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search for first null block
cmd_mktxt:
	call printnl
	call get_token
	mov d, token_str
	mov al, 5
	syscall sys_fileio
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CREATE NEW BINARY FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search for first null block
cmd_mkbin:
	call printnl
	call get_token
	mov d, token_str
	mov al, 6
	syscall sys_fileio
	ret

			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PWD - PRINT WORKING DIRECTORY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
cmd_pwd:
	call printnl
	mov al, 7
	syscall sys_fileio
	ret

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CAT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:
cmd_cat:
	call printnl
	call get_token
	mov d, token_str
	
	mov al, 8
	syscall sys_fileio
	
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RMDIR - remove DIR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; deletes directory  entry in the current directory's file list 
; also deletes the actual directory entry in the FST
cmd_rmdir:
	call get_token
	mov d, token_str
	mov al, 9
	syscall sys_fileio	
	call printnl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RM - remove file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; frees up the data sectors for the file further down the disk
; deletes file entry in the current directory's file list 
cmd_rm:
	call get_token
	mov d, token_str
	mov al, 10
	syscall sys_fileio
	call printnl
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CHMOD - change file permissions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_chmod:
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mv - move / change file name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_mv:
	
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EXEC/OPEN PROGRAM/FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_exec:
; we read "./" sequence here
	mov al, [token]
	cmp al, TOK_DOT
	jne cmd_exec_end
	call get_token
	mov al, [token]
	cmp al, TOK_SLASH	
	jne cmd_exec_end
	call get_token		; get filename
	mov d, token_str
	mov al, 11
	syscall sys_fileio
cmd_exec_end:
	ret

index:				.dw 0
buffer_addr:			.dw 0

; shell variables
token_type: 			.db 0
token:				.db 0
token_str:			.fill 256, 0
shell_input_buff:		.fill 256, 0
shell_buff_ptr:		.dw 0

; file system variables

current_dir_LBA:		.dw 0				; keep ID of current directory
username:			.fill 64, 0
filename:			.fill 256, 0		; holds filename for search

keywords:
	.dw cmd_mkfs
	.db "mkfs", 0, 0, 0, 0
	
	.dw cmd_ps
	.db "ps", 0, 0, 0, 0, 0, 0
	
	.dw cmd_ls
	.db "ls", 0, 0, 0, 0, 0, 0
	.dw cmd_cd
	.db "cd", 0, 0, 0, 0, 0, 0
	
	.dw cmd_primer
	.db "primer", 0, 0
	
	.dw cmd_en
	.db "eni", 0, 0, 0, 0, 0

	.dw cmd_fwb
	.db "fwb", 0, 0, 0, 0, 0
	.dw cmd_fwk
	.db "fwk", 0, 0, 0, 0, 0
	
	.dw cmd_fork
	.db "fork", 0, 0, 0, 0
	
	.dw cmd_test
	.db "test", 0, 0, 0, 0
	.dw cmd_fs_space
	.db "fss", 0, 0, 0, 0, 0	
		
	.dw cmd_fork
	.db "fork", 0, 0, 0, 0
		
	.dw mem_dump
	.db "dmp", 0, 0, 0, 0, 0
	.dw loader
	.db "ld", 0, 0, 0, 0, 0, 0
	.dw call_address
	.db "call", 0, 0, 0, 0
	
	.dw loadcall
	.db "lc", 0, 0, 0, 0, 0, 0
	
	.dw cmd_cat
	.db "cat", 0, 0, 0, 0, 0
	
	.dw cmd_rm
	.db "rm", 0, 0, 0, 0, 0, 0
	
	.dw cmd_mkbin
	.db "mkbin", 0, 0, 0
	.dw cmd_mktxt
	.db "mktxt", 0, 0, 0
	
	.dw cmd_mkdir
	.db "mkdir", 0, 0, 0
	.dw cmd_rmdir
	.db "rmdir", 0, 0, 0
	
	.dw cmd_chmod
	.db "chmod", 0, 0, 0
	.dw cmd_mv
	.db "mv", 0, 0, 0, 0, 0, 0
	.dw cmd_mv
	.db "rn", 0, 0, 0, 0, 0, 0
		
	.dw cmd_pwd
	.db "pwd", 0, 0, 0, 0, 0
	
	.dw cmd_printdate
	.db "dat", 0, 0, 0, 0, 0
	.dw cmd_setdate
	.db "sdat", 0, 0, 0, 0
	
	.dw 0
	.db 0, 0

table_power:			.dw 1
					.dw 10
					.dw 100
					.dw 1000
					.dw 10000
					.dw 10000

file_attrib_d:		.db "-d"
file_attrib_r:		.db "-r"
file_attrib_w:		.db "-w"
file_attrib_x:		.db "-x"	

s_total_blocks:		.db " total blocks", 0
s_free_blocks:		.db " free blocks", 0
s_used_blocks:		.db " used blocks", 0	
s_block_size:			.db "block size: ", 0
s_bytes:				.db " bytes", 0		
				
s_hex_digits:			.db "0123456789ABCDEF"	

s_nl_2:				.db "\n"
s_nl_1:				.db "\n\r", 0

s_dataentry:			.db "% ", 0
s_origin_addr:		.db "origin: ", 0
				
s_pw:				.db "\n\rpassword: ", 0



progress_count: 		.dw 0
				


s_set_year:			.db "Year: ", 0
s_set_month:			.db "Month: ", 0
s_set_day:			.db "Day: ", 0
s_set_week:			.db "Weekday: ", 0
s_set_hours:			.db "Hours: ", 0
s_set_minutes:		.db "Minutes: ", 0
s_set_seconds:		.db "Seconds: ", 0

s_months:			.db "   ", 0
					.db "Jan", 0
					.db "Feb", 0
					.db "Mar", 0
					.db "Apr", 0
					.db "May", 0
					.db "Jun", 0
					.db "Jul", 0
					.db "Aug", 0
					.db "Sep", 0
					.db "Oct", 0
					.db "Nov", 0
					.db "Dec", 0
				
s_week:				.db "Sun", 0 
					.db "Mon", 0 
					.db "Tue", 0 
					.db "Wed", 0 
					.db "Thu", 0 
					.db "Fri", 0 
					.db "Sat", 0

s_procname:			.db "process name: ", 0

s_angle:				.db ">", 0
s_star: 				.db "*", 0				
s_slash: 			.db "/", 0
s_hex:				.db "0x", 0

s_OK:				.db "OK", 0

s_welcome:			.db "\n\r"
					.db "Welcome to Sol-OS ver. 0.1\n\r", 0
	
shell_disk_buffer:			.db 0			; this is actually a long buffer for disk data reads/writes

.end
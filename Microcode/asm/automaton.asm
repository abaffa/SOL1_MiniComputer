.include kernel.exp
.org origin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MATHEMATICS MENU
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
_math_menu:
	enter 512	
__get_math_choice:
	mov d, s_math_menu
	call puts
	lea d, [bp +- 511]
	call gets						; get choice
	mov al, [d]
	sub al, 30h
	cmp al, 2
	je _math_quit
	jgu __get_math_choice				; check bounds
	shl al, 1
	mov ah, 0
	call [a + __math_menu_jump_table]

	call put_nl
	jmp __get_math_choice
_math_quit:
	leave
	ret

; ***********************************************************************************
; MATHS JUMP TABLE
; ***********************************************************************************
__math_menu_jump_table:
	.dw automaton
	.dw chg_rules
	
automaton:
	
	enter 2
	mov d, s_steps
	call puts
	call scan_u16d
	mov [bp +- 1], a
	call put_nl
; reset initial state
	mov si, init_state
	mov di, prev_state
	mov c, 111
	rep movsb	
auto_L1:
	mov c, 1	
	mov a, [bp + -1]
	cmp a, 0
	je automaton_ret
	dec a
	mov [bp + -1], a
auto_L2:	
	mov a, c
	mov d, a
	cla
	inc d
	mov bl, [d + prev_state]
	add al, bl
	dec d
	mov bl, [d + prev_state]
	
	shl bl, 1
	add al, bl
	dec d
	mov bl, [d + prev_state]
	shl bl, 2
	add al, bl					; now al has the number for the table
	
	mov a, [a + automaton_table]
	inc d
	mov [d + state], al
	inc c
	cmp c, 110
	jlu auto_L2
	
; here we finished updating the current state, now we copy the current state to
; the previous state
	mov si, state
	mov di, prev_state
	mov c, 111
	rep movsb
	
; now print the current state on the screen
	mov si, state
	mov di, state_chars
	mov c, 111
state_convert_loop:
	lodsb
	mov ah, 0
	mov a, [a + table_translate]
	stosb
	loopc state_convert_loop
	
	mov d, state_chars
	call puts
	
	call put_nl
	jmp auto_L1	
automaton_ret:
	leave
	
	ret
	
chg_rules:
	mov d, s_rule
	call puts
	mov d, 0
	mov c, 4
chg_rule_L1:
	call scan_u16x
	mov [d + automaton_table], a
	add d, 2
	loopc chg_rule_L1
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
	mov al, 1
	syscall sys_uart
	inc d	
	jmp puts_L1
puts_END:
	pop d
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
	mov al, 3
	syscall sys_uart			; receive in AH
	cmp ah, 0Ah				; cr
	je gets_end
	cmp ah, 0Dh				; cr
	je gets_end
	mov al, ah
	mov [d], al
	inc d
	jmp gets_loop
gets_end:
	mov al, 0
	mov [d], al				; terminate string
	pop d
	pop a
	
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NEW LINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_nl:
	
	push a
	mov a, $0A01
	syscall sys_uart
	mov a, $0D01
	syscall sys_uart
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
	
table_power:
	.dw 1
	.dw 10
	.dw 100
	.dw 1000
	.dw 10000
	
	
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
	
s_rule:		.db "Rule: ", 0
s_steps:		.db "Steps: ", 0

table_translate:
	.db ' '
	.db '*'
	
init_state: 	.fill 55, 0
			.db 1 
			.fill 55, 0

prev_state: 	.fill 55, 0
			.db 1 
			.fill 55, 0
		
state: 		.fill 111, 0

state_chars:	.fill 111, ' '
			.db 0

automaton_table:
	.db 1		; 000
	.db 0		; 001
	.db 1		; 010
	.db 0		; 011
	.db 0		; 100
	.db 1		; 101
	.db 0		; 110
	.db 1		; 111
					

s_math_menu:		.db "\n\r"
				.db "0. Run automaton\n\r"
				.db "1. Change rule\n\r"
				.db "2. Quit\n\r", 0
				
.end
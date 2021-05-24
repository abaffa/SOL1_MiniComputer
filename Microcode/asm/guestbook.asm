.include kernel.exp
.org origin


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GUESTBOOK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_open_guest:
	enter 512	
	mov d, s_guest_welcome
	call puts
__guest_menu_loop:
	mov d, s_guest_menu
	call puts
__get_guest_choice:
	mov a, sp
	inc a
	mov d, a
	call gets						; get choice
	mov al, [d]
	sub al, 30h
	cmp al, 3
	je _guest_quit
	cmp al, 2
	jgu __get_guest_choice				; check bounds
	mov cl, 1
	shl al, cl
	mov ah, 0
	call [a + __guest_menu_jump_table]

	call put_NL2
	jmp __guest_menu_loop
_guest_quit:
	call put_NL2
	leave
	ret

; ***********************************************************************
; GUESTBOOK JUMP TABLE
; index of latest message stored in RTC RAM area address FFA0h-FFA1h
; ***********************************************************************************
__guest_menu_jump_table:
	.dw _guest_sign
	.dw _guest_list
	.dw _guestbook_set
	.dw _guest_quit

_guest_list:
	enter 512					; message block
	mov d, s_guest_list
	call puts
	cla	
__guest_list_loop:
	push al
	mov al, 2
	syscall misc					; read message count
	pop al
	cmp a, b					
	jgeu __guest_list_end	
	mov b, a						; load LBA[1:0] = index
	mov c, 1						; LBA[3:2] = 1

	push a						; save index
	call print_u16d				; display message index
	mov a, $2901
	syscall sys_uart
	mov a, $2001
	syscall sys_uart				; brackets

	lea d, [bp +- 511]			; pointer to message block start		

	mov a, $0102					; 1 sector, read
	syscall sys_ide				; read message onto block
	call puts					; display message
	call put_nl
	pop a						; retrieve index
	inc a						; inc index
	jmp __guest_list_loop
__guest_list_end:
	leave
	ret

_guest_sign:
	call put_nl
	enter 512					; space for message
	mov d, s_guest_new
	call puts
	lea d, [sp + 1]
	call gets					; input message string
	mov al, 2
	syscall misc
	push b						; save count / set LBA
	mov c, 1						; set LBA
	mov a, $0103					; 1 sector, write
	syscall sys_ide
	pop b						; retrieve count
	inc b
	mov al, 3
	syscall misc					; update count
	
	mov d, s_guest_thanks
	call puts					; thanks message
	leave
	ret

_guestbook_set:
	mov d, s_pw
	call puts
	call scan_u16d		; value in A
	cmp a, 1986
	jne _guestbook_set_end
	mov d, s_guestbook_count
	call puts
	call scan_u16d		; value in A
	mov b, a
	mov al, 3
	syscall misc
	mov d, s_OK
	call puts
_guestbook_set_end:
	ret

s_pw: .db "Password: ", 0

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NULL TERMINATED STRING
; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
puts:
	pushf
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
	popf
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT A STRING
;; terminates with null
;; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gets:
	pushf
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
	popf
	ret
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT 2 NEW LINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_NL2:
	pushf
	push a
	mov a, $0A01
	syscall sys_uart
	mov a, $0A01
	syscall sys_uart
	mov a, $0D01
	syscall sys_uart
	pop a
	popf
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NEW LINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_nl:
	pushf
	push a
	mov a, $0A01
	syscall sys_uart
	mov a, $0D01
	syscall sys_uart
	pop a
	popf
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
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 1
	syscall sys_uart	; print coeff
	pop a
	
	mov b, 1000
	div a, b			; get 10000 coeff.
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 1
	syscall sys_uart	; print coeff
	pop a
	
	mov b, 100
	div a, b			
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 1
	syscall sys_uart	; print coeff
	pop a
	
	mov b, 10
	div a, b			
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 1
	syscall sys_uart	; print coeff
	pop a
	
	mov al, bl
	add al, $30
	mov ah, al
	mov al, 1
	syscall sys_uart	; print coeff
	pop b
	pop a
	ret


s_guestbook_count:	.db "Number of entries? ", 0
s_OK: 				.db "\n\rOK.\n\r", 0


s_guest_welcome:	.db "\n\rWelcome to the visitors guestbook! "
				.db "These messages are saved in "
				.db "an old school 2.5-inch IDE "
				.db "hard drive.\n\r"
				.db "Here are the options...\n\r", 0

s_guest_menu:		.db "0. Sign guestbook\n\r"
				.db "1. List guestbook entries\n\r"
				.db "2. Set total\n\r"
				.db "3. [Close guestbook]\n\r", 0
				
s_guest_new:		.db "Enter your message: ", 0
s_guest_list:		.db "Here are all the messages"
				.db " left so far...\n\n\r", 0
s_guest_thanks:	.db "\n\rYour message has been "
				.db "saved. Thank you for signing!\n\r", 0
				
				
.end
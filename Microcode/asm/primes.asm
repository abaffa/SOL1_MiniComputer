.include kernel.exp

.org 0


primes:
	mov al, $FF
	stomsks
	
	mov a, 2
primes_L1:
	sti
	mov c, 2	
primes_L2:
	sti
	push a
	mov b, c
	div a, b
	cmp b, 0
	jz divisible
	inc c
	pop a
	jmp primes_L2		
divisible:
	pop a
	cmp a, c
	jnz notprime			
isprime:
	syscall sys_primew		; write prime to kernel
	inc a
	mov b, [max]
	cmp a, b
	jgeu primes_ret
	jmp primes_L1
notprime:
	inc a
	jmp primes_L1		
primes_ret:
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
;; INPUT A STRING
;; terminates with null
;; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gets:
	pushf
	push a
	push d
gets_loop:
	mov al, 1
	syscall sys_io			; receive in AH
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
	popf
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NEW LINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
put_nl:
	pushf
	push a
	mov a, $0A00
	syscall sys_io
	mov a, $0D00
	syscall sys_io
	pop a
	popf
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
	mov al, 0
	syscall sys_io
	inc d	
	jmp puts_L1
puts_END:
	pop d
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
	mov al, 0
	syscall sys_io	; print coeff
	pop a
	
	mov b, 1000
	div a, b			; get 10000 coeff.
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
	pop a
	
	mov b, 100
	div a, b			
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
	pop a
	
	mov b, 10
	div a, b			
	push b			; save remainder
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
	pop a
	
	mov al, bl
	add al, $30
	mov ah, al
	mov al, 0
	syscall sys_io	; print coeff
	pop b
	pop a
	ret


max:	.dw $FFFF

s_max: .db "\n\rUpper bound: ", 0



table_power:	.dw 1
			.dw 10
			.dw 100
			.dw 1000
			.dw 10000
			
.end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 74 SERIES MINICOMPUTER BIOS VERSION 1.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
_UART0_DATA				.equ $FF80				; data
_UART0_DLAB_0				.equ $FF80				; divisor latch low byte
_UART0_DLAB_1				.equ $FF81				; divisor latch high byte
_UART0_IER				.equ $FF81				; Interrupt enable register
_UART0_FCR				.equ $FF82				; FIFO control register
_UART0_LCR				.equ $FF83				; line control register
_UART0_LSR				.equ $FF85				; line status register

_IDE_BASE				.equ $FFD0				; IDE BASE
_IDE_R0					.equ _IDE_BASE + 0		; DATA PORT
_IDE_R1					.equ _IDE_BASE + 1		; READ: ERROR CODE, WRITE: FEATURE
_IDE_R2					.equ _IDE_BASE + 2		; NUMBER OF SECTORS TO TRANSFER
_IDE_R3					.equ _IDE_BASE + 3		; SECTOR ADDRESS LBA 0 [0:7]
_IDE_R4					.equ _IDE_BASE + 4		; SECTOR ADDRESS LBA 1 [8:15]
_IDE_R5					.equ _IDE_BASE + 5		; SECTOR ADDRESS LBA 2 [16:23]
_IDE_R6					.equ _IDE_BASE + 6		; SECTOR ADDRESS LBA 3 [24:27 (LSB)]
_IDE_R7					.equ _IDE_BASE + 7		; READ: STATUS, WRITE: COMMAND

_7SEG_DISPLAY				.equ $FFB0				; BIOS POST CODE HEX DISPLAY (2 DIGITS)
_BIOS_POST_CTRL			.equ $FFB3				; BIOS POST DISPLAY CONTROL REGISTER, 80h = As Output
_PIO_A					.equ $FFB0		
_PIO_B					.equ $FFB1
_PIO_C					.equ $FFB2
_PIO_CONTROL				.equ $FFB3				; PIO CONTROL PORT

_TIMER_C_0				.equ $FFE0				; TIMER COUNTER 0
_TIMER_C_1				.equ $FFE1				; TIMER COUNTER 1
_TIMER_C_2				.equ $FFE2				; TIMER COUNTER 2
_TIMER_CTRL				.equ $FFE3				; TIMER CONTROL REGISTER

_STACK_BEGIN				.equ $F7FF				; beginning of stack
_GLOBAL_BASE				.equ $8000				; base of global variable block

_IDE_BUFFER				.equ $9000
index: 					.equ _GLOBAL_BASE
buffer_addr:				.equ _GLOBAL_BASE + 2

_NULL					.equ 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GLOBAL SYSTEM VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXTERNAL INTERRUPT TABLE
; highest priority at lowest address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.dw INT_0
.dw INT_1
.dw INT_2
.dw INT_3
.dw INT_4
.dw INT_5
.dw INT_6
.dw INT_7

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RESET VECTOR DECLARATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.dw RESET_VECTOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EXCEPTION VECTOR TABLE
;; total of 7 entries, starting at address $0012
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.dw TRAP_PRIVILEGE	
.dw TRAP_DIV_ZERO	
.dw UNDEFINED_OPCODE
.dw _NULL
.dw _NULL
.dw _NULL
.dw _NULL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SYSTEM CALL VECTOR TABLE
;; starts at address $0020
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.dw TRAP_BREAKPOINT
.dw RTC_SERVICES				
.dw UART_SERVICES				
.dw IDE_SERVICES	
.dw _NULL
.dw _NULL
.dw _NULL
.dw _NULL
.dw _NULL
.dw _NULL	

bios_bkpt	.equ 0
bios_rtc		.equ 1
bios_uart	.equ 2
bios_ide		.equ 3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXTERNAL INTERRUPTS' CODE BLOCK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INT_0:
	sysret
INT_1:
	sysret
INT_2:
	sysret
INT_3:
	sysret
INT_4:
	sysret
INT_5:
	sysret
INT_6:	
	sysret
INT_7:
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXCEPTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRIVILEGE EXCEPTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TRAP_PRIVILEGE:
	push d

	mov d, s_priv1
	call puts

	pop d
							; enable interrupts
	sysret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BREAKPOINT EXCEPTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TRAP_BREAKPOINT:
	push a
	push d
	pushf
	
	mov d, s_bkpt
	call puts
	
	popf
	pop d
	pop a
							; enable interrupts
	sysret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE BY ZERO EXCEPTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TRAP_DIV_ZERO:
	push a
	push d
	pushf
	
	mov d, s_divzero
	call puts
	
	popf
	pop d
	pop a
							; enable interrupts
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UNDEFINED OPCODE EXCEPTION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UNDEFINED_OPCODE:
	sysret
	

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RTC SERVICES INTERRUPT
; RTC I/O bank = FFA0 to FFAF
; FFA0 to FFA7 is scratch RAM
; control register at $FFA8 [ W | R | S | Cal4..Cal0 ]
; al = 0..6 -> get
; al = 7..D -> set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RTC_SERVICES:
	push al
	push d
	cmp al, 6
	jgu RTC_SET
RTC_GET:
	add al, $A9			; generate RTC address to get to address A9 of clock
	mov ah, $FF		
	mov d, a				; get to FFA9 + offset
	mov byte[$FFA8], $40		; set R bit to 1
	mov al, [d]			; get data
	mov byte[$FFA8], 0		; reset R bit
	mov ah, al
	pop d
	pop al
	sysret
RTC_SET:
	push bl
	mov bl, ah		; set data asIDE
	add al, $A2		; generate RTC address to get to address A9 of clock
	mov ah, $FF		
	mov d, a		; get to FFA9 + offset
	mov al, bl		; get data back
	mov byte[$FFA8], $80	; set W bit to 1
	mov [d], al		; set data
	mov byte[$FFA8], 0		; reset write bit
	pop bl
	pop d
	pop al
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INT 4
; UART SERVICES INTERRUPT
; al = option
; ah = data
; 0 = init, 1 = send, 2 = receive, 3 = receive with echo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
UART_SERVICES:
	cmp al, 0
	jz UART_INIT
	dec al
	jz UART_SEND
	dec al
	jz UART_RECEIVE
	dec al
	jz UART_RECEIVE_E
UART_STATUS:
	sysret
UART_INIT:
	mov byte[_UART0_LCR], 83h			; 8 data, 1 stop, no parity	, divisor latch = 1, UART address 3 = Line Control Register
	mov byte[_UART0_DLAB_0], 3			; baud = 38400, divisor latch low byte = 3
	mov byte[_UART0_DLAB_1], 0			; divisor latch high byte = 0			
	mov byte[_UART0_LCR], 3			; divisor latch = 0, UART address 3 = Line Control Register
	mov byte[_UART0_IER], 0			; disable all UART interrupts
	mov byte[_UART0_FCR], 0			; disable FIFO
	sysret
UART_SEND:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, 20h					; isolate Transmitter Empty
	jz UART_SEND		
	mov al, ah
	mov [_UART0_DATA], al			; write char to Transmitter Holding Register
	sysret
UART_RECEIVE:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, 1					; isolate Data Ready
	jz UART_RECEIVE
	mov al, [_UART0_DATA]			; get character
	mov ah, al
	sysret
UART_RECEIVE_E:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, 1					; isolate Data Ready
	jz UART_RECEIVE_E
	mov al, [_UART0_DATA]			; get character
	mov ah, al
UART_RECEIVE_E_LOOP:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, 20h					; isolate Transmitter Empty
	jz UART_RECEIVE_E_LOOP
	mov al, ah
	mov [_UART0_DATA], al			; write char to Transmitter Holding Register
	sysret
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDE SERVICES INTERRUPT
; al = option
; 0 = ide reset, 1 = ide sleep, 2 = read sector, 3 = write sector
; IDE read/write sector
; 512 bytes
; user buffer pointer in D
; kernel buffer pointer = _IDE_BUFFER
; AH = number of sectors
; CB = LBA bytes 3..0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_SERVICES:
	pushf
	cmp al, 0
	je IDE_RESET
	dec al
	jz IDE_SLEEP
	dec al
	jz IDE_READ_SECT
	dec al
	jz IDE_WRITE_SECT
IDE_RET:
	popf
	sysret
IDE_RESET:
	mov al, 04h				; RESET IDE
	mov [_IDE_R7], al
	call IDE_wait				; wait for IDE ready			 
	mov al, 0E0h				; LBA3= 0, MASTER, MODE= LBA
	mov [_IDE_R6], al
	mov al, 01h				; 8-BIT TRANSFERS
	mov [_IDE_R1], al
	mov al, 0EFh				; SET FEATURE COMMAND
	mov [_IDE_R7], al
	jmp IDE_RET
IDE_SLEEP:
	call IDE_wait				; wait for IDE ready			 
	mov al, %01000000			; lba[3:0](reserved), bit 6=1
	mov [_IDE_R6], al
	mov al, 0E6h				; sleep command
	mov [_IDE_R7], al
	call IDE_wait				; wait for IDE ready
	jmp IDE_RET
IDE_READ_SECT:
	mov al, ah
	mov [_IDE_R2], al			; number of sectors (0..255)
	mov al, bl
	mov [_IDE_R3], al
	mov al, bh
	mov [_IDE_R4], al
	mov a, c
	mov [_IDE_R5], al
	mov al, ah
	and al, %00001111
	or al, %11100000			; mode lba, master
	mov [_IDE_R6], al
	call IDE_wait
	mov al, 20h
	mov [_IDE_R7], al			; read sector cmd

	call IDE_read	
	jmp IDE_RET

IDE_WRITE_SECT:
	mov al, ah
	mov [_IDE_R2], al			; number of sectors (0..255)
	mov al, bl
	mov [_IDE_R3], al
	mov al, bh
	mov [_IDE_R4], al
	mov a, c
	mov [_IDE_R5], al
	mov al, ah
	and al, %00001111
	or al, %11100000			; mode lba, master
	mov [_IDE_R6], al
	call IDE_wait
	mov al, 30h
	mov [_IDE_R7], al			; write sector cmd
	
	call IDE_write			
	jmp IDE_RET
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; READ IDE DATA
; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_read:
	push al
	push d
IDE_read_loop:
	call IDE_wait
	mov al, [_IDE_R7]
	and al, %00001000			; DRQ FLAG
	jz IDE_read_end
	mov al, [_IDE_R0]
	mov [d], al
	inc d
	jmp IDE_read_loop
IDE_read_end:
	pop d
	pop al
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WRITE IDE DATA
; data pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_write:
	push al
	push d
IDE_write_loop:
	call IDE_wait
	mov al, [_IDE_R7]
	and al, %00001000			; DRQ FLAG
	jz IDE_write_end
	mov al, [d]
	mov [_IDE_R0], al
	inc d 
	jmp IDE_write_loop
IDE_write_end:
	pop d
	pop al
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait for IDE to be ready
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_wait:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_wait
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
	call getse				; get program string
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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; BIOS ENTRY POINT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RESET_VECTOR:
	mov al, %00100000				; interrupts = OFF, mode = SUP, paging = OFF, halt = OFF, display_load = ON
	stostat
	mov a, _STACK_BEGIN
	mov sp, a
	mov bp, a			; setup stack and frame

	mov al, 0
	syscall bios_uart
	
	mov d, s_bios3
	call puts
	
	mov al, 0						; reset ide
	syscall bios_ide	
	

cmd_fwrite:
;boot sector
	mov d, s_dataentry
	call puts
	mov di, _IDE_BUFFER	; pointer to file contents
	call _load_hex			; load binary hex
	mov b, 0
	mov c, 1	
	mov a, $0103				; disk write, 1 sector
	mov d, _IDE_BUFFER
	syscall bios_ide			; write sector
	
; kernel
	mov d, s_dataentry
	call puts
	mov di, _IDE_BUFFER	; pointer to file contents
	call _load_hex			; load binary hex
	mov a, 0
	mov [index], a
	mov d, _IDE_BUFFER
	mov a, d
	mov [buffer_addr], a
	mov b, 1
	mov c, 1
cmd_fwrite_L1:	
	mov a, $0103				; disk write, 1 sector
	syscall bios_ide			; write sector
	mov a, [index]
	inc a
	mov [index], a
	cmp a, 32		
	je cmd_fwrite_end
	inc b
	mov a, [buffer_addr]
	add a, 512
	mov [buffer_addr], a
	mov d, a
	jmp cmd_fwrite_L1
cmd_fwrite_end:
	call put_nl
	mov d, s_done
	call puts
	
sss: jmp sss	
	
s_dataentry: .db ">> ", 0	
s_done: .db "\nDone!\n", 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT 16BIT HEX INTEGER
; integer value in reg B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRINT_U16X:
	pushf
	push a
	push b
	push bl
	mov bl, bh
	call itoa				; convert bh to char in A
	mov bl, al				; save al	
	mov al, 1
	syscall bios_uart				; display AH
	mov ah, bl				; retrieve al
	mov al, 1
	syscall bios_uart				; display AL

	pop bl
	call itoa				; convert bh to char in A
	mov bl, al				; save al
	mov al, 1
	syscall bios_uart				; display AH
	mov ah, bl				; retrieve al
	mov al, 1
	syscall bios_uart				; display AL

	pop b
	pop a
	popf
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INPUT 16BIT HEX INTEGER
; read 16bit integer into A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCAN_U16X:
	enter 16
	pushf
	push b
	push d

	lea d, [bp + -15]
	call getse				; get number

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
	popf
	leave
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT 8BIT HEX INTEGER
; byte value in reg BL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XPUT_U8:
	push a
	push bl
	pushf

	call itoa					; convert bl to char in A
	mov bl, al					; save al	
	mov al, 1
	syscall bios_uart				; display AH
	mov ah, bl					; retrieve al
	mov al, 1
	syscall bios_uart				; display AL
	
	popf
	pop bl
	pop a
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT NULL TERMINATED STRING
; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
puts:
	push a
	push d
	pushf
puts_L1:
	mov al, [d]
	cmp al, 0
	jz puts_end
puts_L2:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, $20					; isolate Transmitter Empty
	jz puts_L2		
	mov al, [d]
	mov [_UART0_DATA], al			; write char to Transmitter Holding Register
	inc d	
	jmp puts_L1
puts_end:
	popf
	pop d
	pop a
	ret



	
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INPUT A STRING with echo
;; terminates with null
;; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getse:
	pushf
	push a
	push d
getse_loop:
	mov al, 3
	syscall bios_uart			; receive in AH
	cmp ah, 0Ah				; LF
	je getse_end
	cmp ah, 0Dh				; CR
	je getse_end
	cmp ah, $5C				; '\\'
	je getse_escape
	mov al, ah
	mov [d], al
	inc d
	jmp getse_loop
getse_escape:
	mov al, 3
	syscall bios_uart			; receive in AH
	cmp ah, 'n'
	je getse_LF
	cmp ah, 'r'
	je getse_CR
	mov al, ah				; if not a known escape, it is just a normal letter
	mov [d], al
	inc d
	jmp getse_loop
getse_LF:
	mov al, $0A
	mov [d], al
	inc d
	jmp getse_loop
getse_CR:
	mov al, $0D
	mov [d], al
	inc d
	jmp getse_loop
getse_end:
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
	mov a, $0A01
	syscall bios_uart
	mov a, $0D01
	syscall bios_uart
	pop a
	popf
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
	push ah
	mov ah, bl
	call to_upper
	mov al, ah	
	and al, 0Fh				; get letter
	add al, 9
	pop ah
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ATOI
; 2 letter hex string in B
; 8bit integer returned in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
atoi:
	pushf
	push b
		
	call hex_ascii_encode			; convert BL to 4bit code in AL
	mov bl, bh
	push al					; save a
	call hex_ascii_encode
	pop bl	
	shl al, 4
	or al, bl
	
	pop b
	popf
	ret	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ITOA
; 8bit value in BL
; 2 byte ASCII result in A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
itoa:
	pushf
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
	popf
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STRCMP
; compare two strings
; str1 in SI
; str2 in DI
; changes: AL SI DI
; CREATE A STRING COMPAIRON INSTRUCION ?????
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
strcmp:
strcmp_loop:
	cmpsb					; compare a byte of the strings
	jne strcmp_ret
	lea d, [si + -1]
	mov al, [d]
	cmp al, 0				; check if at end of string (null)
	jne strcmp_loop				; equal chars but not at end
strcmp_ret:				
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TO LOWER
; input in AL
; output in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_lower:
	pushf
	cmp al, 'Z'
	jgu to_lower_ret
	add al, 20h				; convert to lower case
to_lower_ret:
	popf
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; TO UPPER
; input in AL
; output in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_upper:
	pushf
	cmp al, 'a'
	jlu to_upper_ret
	sub al, 20h				; convert to upper case
to_upper_ret:
	popf
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PRINT DECIMAL INTEGER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_decimal:
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GET HEX FILE
; di = destination address
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
load_hex:
	enter $6000
	
	mov a, $9000					; destination
	mov di, a	
						; string data block
	lea d, [bp + -24575]			; start of string data block
	call getse					; get program string
	mov a, d
	mov si, a
load_hex_loop:
	lodsb					; load from [SI] to AL
	cmp al, 0				; check if ASCII 0
	jz load_hex_ret
	mov bh, al
	lodsb
	mov bl, al
	call atoi				; convert ASCII byte in B to int (to AL)
	stosb					; store AL to [DI]
	jmp load_hex_loop
load_hex_ret:
	leave
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
		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DATA BLOCK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s_welcome:		.db "\n\n\rSol-1 74HC HomebrewCPU MiniComputer\n"
				.db "BIOS Version 0.1\n\n\r"
				.db "terminal-1 initialized\n\r", 0
s_boot:			.db "\n\rbooting from disk ", 0
s_kernel_setup:	.db "mapping the kernel\'s page-table to physical RAM...", 0
s_masks	:		.db "\n\rinterrupt masks register set to 0xFF", 0
s_bios2: 		.db "\n\rstarting the kernel...\n\r", 0
s_bios3: 		.db "resetting IDE drive\n\r", 0
s_bios4: 		.db "configuring Timer-1\n\r", 0
s_bios5:	 		.db "PIO-A set to output mode\n\r", 0


s_nl_2:			.db "\n"
s_nl_1:			.db "\n\r", 0



s_hex_digits:		.db "0123456789ABCDEF"
s_bkpt: 			.db "this is the breakpoint.", 0


s_priv1:			.db "\n\n\rsoftware failure: privilege exception "
				.db "press any key to continue...\n\r", 0
s_divzero:		.db "\n\rexception: zero division\n\r", 0






.end

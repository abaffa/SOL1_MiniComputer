.include bios.exp

.org boot_origin
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setting up kernel process.
; map kernel memory to BIOS 64KB
; 32 pages of 2KB = 64KB
; bl = ptb
; bh = page number (5bits)
; a = physical address
; for kernel, a goes from 0 to 31, but for the last page, bit '11' must be 1 for DEVICE space
; bl = 0
; bh(ms 5 bits) = 0 to 31
; a = 0000_1000_000_00000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setup_kernel_mem:
	mov d, s_boot1
	call puts
	
	mov d, s_kernel_setup
	call puts
; map pages 0 to 30 to normal kernel ram memory.
	mov bl, 0					; set PTB = 0 for kernel
	mov bh, 0					; start at PAGE 0
	mov a, 0						; set MEM/IO bit to MEMORY, for physical address. this means physical address starting at 0, but in MEMORY space
map_kernel_mem_L1:
	pagemap						; write page table entry
	add b, $0800					; increase page number (msb 5 bits of BH only)
	inc al						; increase both 
	cmp al, 31					; check to see if we reached the end of memory for kernel
	jne map_kernel_mem_L1
	
; here we map the last page of kernel memory, to DEVICE space, or the last 2KB of BIOS memory
; so that the kernel has access to IO devices.
	or a, $0800					; set MEM/IO bit to DEVICE, for physical address
	pagemap						; write page table entry
	
	mov al, 0
	setptb						; set process number to 0 (strictly not needed since we are in Supervisor mode)
								; which forces the page number to 0
	mov d, s_boot
	call puts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
; we read the first kernel sector, in order to obtain the reset vector at location $10
	mov c, 0
	mov b, 1					; start at disk sector 1
	mov d, _IDE_BUFFER		; we read into the bios ide buffer
	mov a, $0102				; disk read, 1 sector
	syscall bios_ide			; read sector
	mov a, [_IDE_BUFFER + $10]	; here we now have the kernel RESET VECTOR
	mov g, a					; save vector in G	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; read operating system into kernel memory
	mov a, 0
	mov [index], a
	mov d, 0				; start at kernel memory address 0
	mov b, 1				; start at disk sector 1
bootstrap_L1:
	mov ah, '>'
	call putchar
	mov c, 0
	push d					; save kernel memory pointer
	mov d, _IDE_BUFFER		; we read into the bios ide buffer
	mov a, $0102				; disk read, 1 sector
	syscall bios_ide			; read sector
	mov c, 512				; 512 bytes to copy
	mov a, _IDE_BUFFER
	mov si, a
	pop d					; retrieve kernel memory pointer
	mov di, d
	supcopy					; now copy data from bios mem to kernel mem
	mov a, [index]
	inc a
	mov [index], a
	cmp a, 32		
	je bootstrap_end
	inc b
	add d, 512
	jmp bootstrap_L1
bootstrap_end:
; interrupt masks	
	mov al, $FF
	stomsks						; store masks
	mov d, s_masks
	call puts
	
	mov d, s_bios2
	call puts
; now we start the kernel by using a special instruction.
; this instruction turns paging on and jumps to the address given in register A
	mov a, g				; retrieve kernel reset vector
	supstart
	
	
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
; putchar
; char in ah
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
putchar:
	push a
	pushf
putchar_L1:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, 20h					; isolate Transmitter Empty
	jz putchar_L1		
	mov al, ah
	mov [_UART0_DATA], al			; write char to Transmitter Holding Register
	popf
	pop a
	ret

index:			.dw 0
buffer_addr:		.dw 0

s_boot1:			.db "executing boot-loader...\n\r", 0
s_kernel_setup:	.db "mapping kernel page-table to physical RAM\n\r", 0
s_masks:			.db "\n\rinterrupt masks register set to $FF\n\r", 0
s_boot:			.db "loading kernel from disk ", 0
s_bios2: 		.db "entering protected-mode\n\r"
				.db "starting the kernel...\n\r", 0

.end
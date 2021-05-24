;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; KERNEL
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

_NULL					.equ 0


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


FST_ENTRY_SIZE			.equ 32
FST_FILES_PER_SECT		.equ (512 / FST_ENTRY_SIZE)
FST_FILES_PER_DIR			.equ 16
FST_NBR_DIRECTORIES		.equ 64
						; 1 sector for header, the rest is for the list of files/dirs
FST_SECTORS_PER_DIR		.equ (1 + (FST_ENTRY_SIZE * FST_FILES_PER_DIR / 512))		
FST_TOTAL_SECTORS			.equ (FST_SECTORS_PER_DIR * FST_NBR_DIRECTORIES)
FST_LBA_START				.equ 32
FST_LBA_END				.equ (FST_LBA_START + FST_TOTAL_SECTORS - 1)

FS_NBR_FILES 				.equ (FST_NBR_DIRECTORIES * FST_FILES_PER_DIR)
FS_SECTORS_PER_FILE		.equ 32				; the first sector is always a header with a NULL parameter (first byte)
											; so that we know which blocks are free or taken
FS_FILE_SIZE				.equ (FS_SECTORS_PER_FILE * 512)									
FS_TOTAL_SECTORS			.equ (FS_NBR_FILES * FS_SECTORS_PER_FILE)
FS_LBA_START				.equ (FST_LBA_END + 1)
FS_LBA_END				.equ (FS_LBA_START + FS_NBR_FILES - 1)

CF_CARD_LBA_SIZE			.equ $800			; temporary small size

ROOT_LBA:				.equ FST_LBA_START


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
.dw KERNEL_RESET_VECTOR

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
.dw IDE_SERVICES_KERNEL
.dw IO_SERVICES
.dw FILE_SYSTEM
.dw cmd_fork
.dw cmd_fwb
.dw cmd_fwk
.dw IDE_SERVICES_USER
.dw enable_ints
.dw list_procs
.dw primew
.dw primer

sys_bkpt			.equ 0
sys_rtc			.equ 1
sys_ide_kernel	.equ 2
sys_io			.equ 3
sys_fileio		.equ 4
sys_fork			.equ 5
sys_fwb			.equ 6
sys_fwk			.equ 7
sys_ide			.equ 8
sys_en			.equ 9
sys_list			.equ 10
sys_primew		.equ 11
sys_primer		.equ 12

.export sys_ide
.export sys_ide_kernel
.export sys_io
.export sys_fileio
.export sys_fork
.export sys_list
.export sys_primew
.export sys_primer
.export sys_rtc

.export sys_fwb
.export sys_fwk
.export sys_en

.export disk_buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXTERNAL INTERRUPTS' CODE BLOCK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; uart
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
; save all registers into kernel stack
	pusha
	mov ah, 0
	mov al, [ACTIVE_PROC_INDEX]
	shl a							; x2
	mov a, [PROC_TABLE_convert + a]	; get process state start index
		
	mov di, a
	mov a, sp
	inc a
	mov si, a
	mov c, 20
	rep movsb					; save process state!
; restore kernel stack position to point before interrupt arrived
	add sp, 20
; now load next process in queue
	mov al, [ACTIVE_PROC_INDEX]
	mov bl, [NBR_ACTIVE_PROCS]
	cmp al, bl
	je INT6_cycle_back
	inc al						; next process is next in the series
	jmp INT6_continue
INT6_cycle_back:
	mov al, 1				; next process = process 1
INT6_continue:
	mov [ACTIVE_PROC_INDEX], al		; set next active proc

; calculate LUT entry for next process
	mov ah, 0
	shl a							; x2
	mov a, [PROC_TABLE_convert + a]		; get process state start index	
	
	mov si, a						; source is proc state block
	mov a, sp
	sub a, 19
	mov di, a						; destination is kernel stack
; restore SP
	dec a
	mov sp, a
	mov c, 20
	rep movsb
; set VM process
	mov al, [ACTIVE_PROC_INDEX]
	setptb
		
	mov byte[_TIMER_C_0], 0				; load counter 0 low byte
	mov byte[_TIMER_C_0], $10				; load counter 0 high byte
			
	popa
	sysret

INT_7:
	push a
	push d
	pushf
			
	mov a, [fifo_pi]
	mov d, a
				
	mov al, [_UART0_DATA]			; get character
	mov [d], al					; add to fifo
	
	mov a, [fifo_pi]
	inc a
	cmp a, fifo + 512				; check if pointer reached the end of the fifo
	jne INT_7_continue
	mov a, fifo	
INT_7_continue:	
	mov [fifo_pi], a			; update fifo pointer
	
	popf
	pop d
	pop a	
	sysret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; EXCEPTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

primew:
	mov [current_prime], a		; write
	sysret
primer:
	mov a, [current_prime]
	call print_u16d
	sysret

current_prime: .dw 0

list_procs:
	mov d, PROC_AVAILABILITY_TABLE + 1
	mov c, 1
list_procs_L0:	
	mov al, [d]
	cmp al, 1
	jne list_procs_next
	mov b, d
	sub b, PROC_AVAILABILITY_TABLE
	shl b, 5
	push d
	mov a, c
	call print_u8d
	mov d, s_colon
	call puts
	mov d, b
	add d, PROC_NAMES
	call puts
	call printnl
	pop d
list_procs_next:
	inc d
	inc c
	cmp c, 9
	jne list_procs_L0
list_procs_end:
	sysret

; list_procs:
	; mov d, PROC_NAMES + 32
; list_procs_L0:	
	; mov al, [d]
	; cmp al, 0
	; je list_procs_end
	; call puts
	; call printnl
	; add d, 32
	; jmp list_procs_L0
; list_procs_end:
	; sysret

enable_ints:
	mov al, $FF
	stomsks					; mask out timer interrupt for now (only allow UART to interrupt)
	sti	
	sysret

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
; IDE SERVICES INTERRUPT
; al = option
; 0 = ide reset, 1 = ide sleep, 2 = read sector, 3 = write sector
; IDE read/write sector
; 512 bytes
; user buffer pointer in D
; AH = number of sectors
; CB = LBA bytes 3..0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ide_serv_tbl:
	.dw IDE_RESET
	.dw IDE_SLEEP
	.dw IDE_READ_SECT
	.dw IDE_WRITE_SECT
IDE_SERVICES_KERNEL:
	jmp [ide_serv_tbl + al]			
IDE_RESET:			
	mov byte[_IDE_R7], 4		; RESET IDE
	call IDE_wait				; wait for IDE ready			 			
	mov byte[_IDE_R6], $E0		; LBA3= 0, MASTER, MODE= LBA				
	mov byte[_IDE_R1], 1		; 8-BIT TRANSFERS			
	mov byte[_IDE_R7], $EF		; SET FEATURE COMMAND
	sysret
IDE_SLEEP:
	call IDE_wait					; wait for IDE ready			 			
	mov byte [_IDE_R6], %01000000	; lba[3:0](reserved), bit 6=1
	mov byte [_IDE_R7], $E6		; sleep command
	call IDE_wait					; wait for IDE ready
	sysret
IDE_READ_SECT:
	mov al, ah
	mov ah, bl
	mov [_IDE_R2], a			; number of sectors (0..255)
	mov al, bh
	mov [_IDE_R4], al
	mov a, c
	mov [_IDE_R5], al
	mov al, ah
	and al, %00001111
	or al, %11100000			; mode lba, master
	mov [_IDE_R6], al
IDE_READ_SECT_wait:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_READ_SECT_wait
	mov al, $20
	mov [_IDE_R7], al			; read sector cmd
	call IDE_read	
	sysret
IDE_WRITE_SECT:
	mov al, ah
	mov ah, bl
	mov [_IDE_R2], a			; number of sectors (0..255)
	mov al, bh
	mov [_IDE_R4], al
	mov a, c
	mov [_IDE_R5], al
	mov al, ah
	and al, %00001111
	or al, %11100000			; mode lba, master
	mov [_IDE_R6], al
IDE_WRITE_SECT_wait:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_WRITE_SECT_wait
	mov al, $30
	mov [_IDE_R7], al			; write sector cmd
	call IDE_write			
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; IDE SERVICES INTERRUPT
; al = option
; 0 = read sector, 1 = write sector
; 512 bytes
; user buffer pointer in D
; CB = LBA bytes 3..0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ide_serv_tbl_user:
	.dw IDE_USER_READ
	.dw IDE_USER_WRITE
IDE_SERVICES_USER:
	jmp [ide_serv_tbl_user + al]			
IDE_USER_READ:
	mov al, 1
	mov ah, bl
	mov [_IDE_R2], a			; number of sectors (0..255)
	mov al, bh
	mov [_IDE_R4], al
	mov a, c
	mov [_IDE_R5], al
	mov al, ah
	and al, %00001111
	or al, %11100000			; mode lba, master
	mov [_IDE_R6], al
IDE_USER_READ_wait:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_USER_READ_wait
	mov al, $20
	mov [_IDE_R7], al			; read sector cmd
	
	push d					; save user space D
	mov d, disk_buffer		; set pointer to kernel buffer
	call IDE_read				
; the data has been read into kernel memory at D
; now we need to transfer it into user space
	pop d					; recover user D pointer
	push si
	push di
	push c
	mov si, disk_buffer
	mov a, d
	mov di, a				; user space D
	mov c, 512
	store					; transfer data to user space!	
	pop c
	pop di
	pop si
	
	sysret
IDE_USER_WRITE:
	mov al, 1
	mov ah, bl
	mov [_IDE_R2], a			; number of sectors (0..255)
	mov al, bh
	mov [_IDE_R4], al
	mov a, c
	mov [_IDE_R5], al
	mov al, ah
	and al, %00001111
	or al, %11100000			; mode lba, master
	mov [_IDE_R6], al
IDE_USER_WRITE_wait:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_USER_WRITE_wait
	mov al, $30
	mov [_IDE_R7], al			; write sector cmd
	
	push si
	push di
	push c
	push d					; save user space D
	mov a, d
	mov si, a				; data source from user space
	mov di, disk_buffer	; destination in kernel space
	mov c, 512
	load						; transfer data to kernel space!
	
	mov d, disk_buffer		; set pointer to kernel buffer
	call IDE_write			
	pop d					; recover user D pointer
	pop c
	pop di
	pop si
	
	sysret
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; READ IDE DATA
; pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_read:
	push d
IDE_read_loop:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_read_loop			; wait loop
	
	mov al, [_IDE_R7]
	and al, %00001000			; DRQ FLAG
	jz IDE_read_end
	mov al, [_IDE_R0]
	mov [d], al
	inc d
	jmp IDE_read_loop
IDE_read_end:
	pop d
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WRITE IDE DATA
; data pointer in D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_write:
	push d
IDE_write_loop:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_write_loop			; wait loop
	
	mov al, [_IDE_R7]
	and al, %00001000			; DRQ FLAG
	jz IDE_write_end
	mov al, [d]
	mov [_IDE_R0], al
	inc d 
	jmp IDE_write_loop
IDE_write_end:
	pop d
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; wait for IDE to be ready
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IDE_wait:
	mov al, [_IDE_R7]	
	and al, 80h				; BUSY FLAG
	jnz IDE_wait
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; i/o interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IO_SERVICES_JMP:
	.dw IO_PUTCHAR
	.dw IO_GETCHAR
	.dw IO_UART_INIT
IO_SERVICES:
	jmp [IO_SERVICES_JMP + al]
IO_UART_INIT:	
	mov byte[_UART0_LCR], $83			; 8 data, 1 stop, no parity	, divisor latch = 1, UART address 3 = Line Control Register
	mov byte[_UART0_DLAB_0], 3			; baud = 38400, divisor latch low byte = 3
	mov byte[_UART0_DLAB_1], 0			; divisor latch high byte = 0			
	mov byte[_UART0_LCR], 3			; UART address 3 = Line Control Register
	mov byte[_UART0_IER], 1			; enable interrupt: receive data available
	mov byte[_UART0_FCR], 0			; disable FIFO
	sysret
; char in ah
IO_PUTCHAR:
	push al
IO_PUTCHAR_L0:
	mov al, [_UART0_LSR]			; read Line Status Register
	test al, $20					; isolate Transmitter Empty
	jz IO_PUTCHAR_L0		
	mov al, ah
	mov [_UART0_DATA], al			; write char to Transmitter Holding Register
	pop al
	sysret
; char in ah
IO_GETCHAR:
	push b
	push d
IO_GETCHAR_L0:	
	sti
	mov a, [fifo_pr]
	mov b, [fifo_pi]
	cmp a, b
	je IO_GETCHAR_L0
	
	mov d, a
	mov al, [d]
	push al
	
	mov a, [fifo_pr]
	inc a
	cmp a, fifo + 512				; check if pointer reached the end of the fifo
	jne IO_GETCHAR_cont2
	mov a, fifo	
IO_GETCHAR_cont2:	
	mov [fifo_pr], a			; update fifo pointer
	
	pop ah
	mov al, 0
	syscall sys_io
	
	pop d
	pop b
	sysret


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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FILE_SYSTEM_jmptbl:
	.dw FILE_SYSTEM_MKFS
	.dw cmd_fs_space
	.dw cmd_mkdir
	.dw cmd_cd_child
	.dw cmd_ls
	.dw cmd_mktxt
	.dw cmd_mkbin
	.dw cmd_pwd
	.dw cmd_cat_1
	.dw cmd_rmdir
	.dw cmd_rm
	.dw cmd_exec
	.dw cmd_cd_parent
	.dw print_address
FILE_SYSTEM:
	jmp [FILE_SYSTEM_jmptbl + al]
FILE_SYSTEM_MKFS:	
	mov b, 32
	mov a, CF_CARD_LBA_SIZE
	div a, b							; progress bar increment in A
	mov g, a							; save in G
	mov a, 0
	mov [progress_count], a
	mov di, disk_buffer
	mov al, 0
	mov c, 512
	rep stosb
	mov b, FST_LBA_START
	mov c, 0				; reset LBA to 0
FILE_SYSTEM_MKFS_L1:	
	mov a, $0103			; disk write
	mov d, disk_buffer
	syscall sys_ide_kernel
	mov a, [progress_count]
	inc a
	mov [progress_count], a			; update count
	push b
	mov b, g
	cmp a, b
	pop b
	je FILE_SYSTEM_MKFS_print_star
FILE_SYSTEM_MKFS_back:
	inc b
	cmp b, CF_CARD_LBA_SIZE
	jne FILE_SYSTEM_MKFS_L1
	call printnl
	mov d, s_OK
	call puts
	call printnl
FILE_SYSTEM_MKFS_create_root:
	mov a, ROOT_LBA
	mov [current_dir_LBA], a		; set current directory LBA to ROOT
	mov si, ROOT_DIRECTORY_STR
	mov di, current_dir_str
	call strcpy
	sysret	
FILE_SYSTEM_MKFS_print_star:
	mov d, s_angle
	call puts
	mov a, 0
	mov [progress_count], a		; reset counter
	jmp FILE_SYSTEM_MKFS_back
	

cmd_fs_space:
	enter 4
	call printnl
	mov b, FS_LBA_START		; files start when directories end
	mov a, 0
	mov [bp + -1], a				; index
	mov [bp + -3], a				; nbr used files
cmd_fs_space_L1:	
	mov c, 0						; reset LBA to 0
	mov a, $0102					; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel				; read sector
	mov al, [d]
	cmp al, 0					; check for NULL
	je cmd_fs_space_null
	mov a, $2B00					; '+'
	syscall sys_io
	mov a, [bp + -3]
	inc a
	mov [bp + -3], a
	jmp cmd_fs_space_continue
cmd_fs_space_null:
	mov a, $2D00					; '-'
	syscall sys_io
cmd_fs_space_continue:
	mov a, [bp + -1]
	inc a
	mov [bp + -1], a	
	add b, FS_SECTORS_PER_FILE
	and al, %00111111
	jnz cmd_fs_space_noNL
	call printnl
cmd_fs_space_noNL:
	cmp a, FS_NBR_FILES
	jne cmd_fs_space_L1
cmd_fs_space_end:
	call printnl
	mov a, [bp + -3]
	call print_u16d				; print total used space
	mov d, s_used_blocks
	call puts
	call printnl
	
	mov b, [bp + -3]
	mov d, FS_NBR_FILES
	sub d, b
	mov a, d
	call print_u16d				; print total free space
	mov d, s_free_blocks
	call puts
	call printnl
	
	mov a, FS_NBR_FILES
	call print_u16d				; print total space
	mov d, s_total_blocks
	call puts
	call printnl
	
	mov d, s_block_size
	call puts
	mov a, FS_FILE_SIZE
	call print_u16d
	mov d, s_bytes
	call puts
	call printnl
	
	leave
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CREATE NEW DIRECTORY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search list for NULL name entry.
; add new directory to list
cmd_mkdir:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	mov b, FST_LBA_START + 2				; start at 2 because LBA  0 is ROOT (this would also cause issues when checking for NULL name, since root has a NULL name)
	mov c, 0				; reset LBA to 0
cmd_mkdir_L1:	
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read sector
	mov al, [d]
	cmp al, 0			; check for NULL
	je cmd_mkdir_found_null
	add b, FST_SECTORS_PER_DIR					; skip directory
	jmp cmd_mkdir_L1
cmd_mkdir_found_null:
;create header file by grabbing dir name from parameter
	push b				; save new directory's LBA
	mov c, 64
	mov si, userspace_data
	mov di, disk_buffer
	rep movsb					; copy dirname from userspace_data to disk_buffer
	mov a, [current_dir_LBA]
	mov [disk_buffer + 64], a		; store parent directory LBA
	mov c, 0						; reset LBA to 0
	mov d, disk_buffer
	mov a, $0103					; disk write, 1 sector
	syscall sys_ide_kernel				; write header
	mov al, 0
	mov di, disk_buffer
	mov c, 512
	rep stosb					; clean buffer
	mov c, 0				; reset LBA(c) to 0
	inc b				; skip header sector
; write data sector (blank)
	mov d, disk_buffer
	mov a, $0103			; disk write, 1 sector
	syscall sys_ide_kernel		; write sector
; now we need to add the new directory to the list, inside the current directory
	mov a, [current_dir_LBA]
	add a, 1
	mov b, a					; metadata sector
	mov c, 0
	mov g, b					; save LBA
	mov d, disk_buffer
	mov a, $0102			; disk read
	syscall sys_ide_kernel		; read metadata sector
cmd_mkdir_L2:
	mov al, [d]
	cmp al, 0
	je cmd_mkdir_found_null2
	add d, FST_ENTRY_SIZE
	jmp cmd_mkdir_L2					; we look for a NULL entry here but dont check for limits. CARE NEEDED WHEN ADDING TOO MANY FILES TO A DIRECTORY
cmd_mkdir_found_null2:
	mov si, userspace_data
	mov di, d
	call strcpy			; copy directory name
	add d, 24			; goto ATTRIBUTES
	mov al, %00000111		; no execute, write, read, directory
	mov [d], al			
	inc d
	pop b
	mov [d], b			; save LBA
; set file creation date	
	add d, 4
	mov al, 4
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set day
	
	inc d
	mov al, 5
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set month
	
	inc d
	mov al, 6
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set year
	
; write sector into disk for new directory entry
	mov b, g
	mov c, 0
	mov d, disk_buffer
	mov a, $0103			; disk write, 1 sector
	syscall sys_ide_kernel		; write sector
cmd_mkdir_end:
	sysret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search for given directory inside current dir
; if found, read its LBA, and switch directories
cmd_cd_child:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read directory
	mov a, 0
	mov [index], a
cmd_cd_L1:
	mov al, [d + 24]
	and al, %00000011			; isolate read and directory flags
	cmp al, %00000011
	jne cmd_cd_no_permission
	mov si, d
	mov di, userspace_data
	call strcmp
	je cmd_cd_name_equal	
cmd_cd_no_permission:
	add d, 32
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FST_FILES_PER_DIR
	je cmd_cd_end
	jmp cmd_cd_L1
cmd_cd_name_equal:
	mov a, [current_dir_LBA]
	cmp a, ROOT_LBA
	je cmd_cd_skip_slash
	call path_add_slash
cmd_cd_skip_slash:
	mov si, d
	mov di, current_dir_str
	call strcat			; add directory to path
	add d, 25
	mov a, [d]
	mov [current_dir_LBA], a	
cmd_cd_end:
	sysret

cmd_cd_parent:
	mov b, [current_dir_LBA]	; else we want the parent directory
	cmp b, ROOT_LBA
	je cmd_cd_parent_end				; if root, leave
	mov c, 0					; reset LBA to 0
	mov a, $0102				; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel			; read directory
	mov a, [d + 64]			; read parent directory LBA
	mov [current_dir_LBA], a	; finally set current LBA
	call path_goto_parent		; remove last folder from pat
cmd_cd_parent_end:
	sysret
	

path_goto_parent:
	push a
	push c
	push d
	mov d, current_dir_str
	call strlen
	mov a, c
	add d, a			; skip to the end of path
path_goto_parent_L1:
	mov al, [d]
	cmp al, $2F		; check if '/'
	je path_goto_parent_end
	dec d
	jmp path_goto_parent_L1
path_goto_parent_end:
	mov a, [current_dir_LBA]
	cmp a, ROOT_LBA
	jne path_goto_parent_notroot
	inc d
path_goto_parent_notroot:
	mov al, 0
	mov [d], al
	pop d
	pop c
	pop a
	ret
	
path_add_slash:
	push si
	push di
	mov si, s_slash
	mov di, current_dir_str
	call strcat			; add '/' to path
	pop di
	pop si
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_ls:	
	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read directory
	mov a, 0
	mov [index], a		; reset entry index
cmd_ls_L1:
	mov al, [d]
	cmp al, 0			; check for NULL
	je cmd_ls_next
cmd_ls_non_null:
	mov al, [d + 24]
	and al, %00000001
	mov ah, 0
	mov a, [a + file_attrib_d]		; directory?
	mov ah, al
	call putchar
	mov al, [d + 24]
	and al, %00000010
	shr al, 1
	mov ah, 0
	mov a, [a + file_attrib_r]		; read
	mov ah, al
	call putchar
	mov al, [d + 24]
	and al, %00000100
	shr al, 2
	mov ah, 0
	mov a, [a + file_attrib_w]		; write
	mov ah, al
	call putchar
	mov al, [d + 24]
	and al, %00001000
	shr al, 3
	mov ah, 0
	mov a, [a + file_attrib_x]		; execute
	mov ah, al
	call putchar
	mov ah, $20
	call putchar	
	mov a, [d + 27]
	call print_u16d
	mov ah, $20
	call putchar
; print date
	mov bl, [d + 29]			; day
	call print_u8x
	mov ah, $20
	call putchar	
	mov al, [d + 30]			; month
	shl al, 2
	push d
	mov d, s_months
	mov ah, 0
	add d, a
	call puts
	pop d
	mov ah, $20
	call putchar
	mov bl, $20
	call print_u8x
	mov bl, [d + 31]			; year
	call print_u8x	
	mov ah, $20
	call putchar	
	call puts				; print filename	
	call printnl
cmd_ls_next:
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FST_FILES_PER_DIR
	je cmd_ls_end
	add d, 32			
	jmp cmd_ls_L1	
cmd_ls_end:
	sysret

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
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	mov b, FS_LBA_START		; raw files starting block
	mov c, 0						; reset LBA to 0
cmd_mktxt_L1:	
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read sector
	mov al, [d]
	cmp al, 0			; check for NULL
	je cmd_new_found_null
	add b, FS_SECTORS_PER_FILE
	jmp cmd_mktxt_L1
cmd_new_found_null:
	push b				; save LBA
;create header file by grabbing file name from parameter	
	mov d, s_dataentry
	call puts
	mov d, disk_buffer + 512			; pointer to file contents
	call gets
	call strlen						; get length of file
	push c							; save length
	mov al, 1
	mov [disk_buffer], al					; mark sectors as USED (not NULL)
	mov a, 0
	mov [index], a
	mov d, disk_buffer
	mov a, d
	mov [buffer_addr], a
cmd_mktxt_L2:
	mov c, 0
	mov a, $0103			; disk write, 1 sector
	syscall sys_ide_kernel		; write sector
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FS_SECTORS_PER_FILE
	je cmd_mktxt_add_to_dir
	inc b
	mov a, [buffer_addr]
	add a, 512
	mov [buffer_addr], a
	mov d, a
	jmp cmd_mktxt_L2
; now we add the file to the current directory!
cmd_mktxt_add_to_dir:	
	mov a, [current_dir_LBA]
	inc a
	mov b, a					; metadata sector
	mov c, 0
	mov g, b					; save LBA
	mov d, disk_buffer
	mov a, $0102			; disk read
	syscall sys_ide_kernel		; read metadata sector
cmd_mktxt_add_to_dir_L2:
	mov al, [d]
	cmp al, 0
	je cmd_mktxt_add_to_dir_null
	add d, FST_ENTRY_SIZE
	jmp cmd_mktxt_add_to_dir_L2					; we look for a NULL entry here but dont check for limits. CARE NEEDED WHEN ADDING TOO MANY FILES TO A DIRECTORY
cmd_mktxt_add_to_dir_null:
	mov si, userspace_data
	mov di, d
	call strcpy			; copy file name
	add d, 24			; skip name
	mov al, %00000110		; no execute, write, read, not directory
	mov [d], al			
	add d, 3
	pop a
	mov [d], a
	sub d, 2
	pop b				; get file LBA
	mov [d], b			; save LBA	
	
	; set file creation date	
	add d, 4
	mov al, 4
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set day
	
	inc d
	mov al, 5
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set month
	
	inc d
	mov al, 6
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set year
	
; write sector into disk for new directory entry
	mov b, g
	mov c, 0
	mov d, disk_buffer
	mov a, $0103			; disk write, 1 sector
	syscall sys_ide_kernel		; write sector
	call printnl
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CREATE NEW BINARY FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; search for first null block
cmd_mkbin:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	mov b, FS_LBA_START		; files start when directories end
	mov c, 0						; reset LBA to 0
cmd_mkbin_L1:	
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read sector
	mov al, [d]
	cmp al, 0			; check for NULL
	je cmd_mkbin_found_null
	add b, FS_SECTORS_PER_FILE
	jmp cmd_mkbin_L1
cmd_mkbin_found_null:
	push b				; save LBA
;create header file by grabbing file name from parameter
	mov d, s_dataentry
	call puts
	mov di, disk_buffer + 512	; pointer to file contents
	call _load_hex			; load binary hex
	push c					; save size (nbr of bytes)
	mov al, 1
	mov [disk_buffer], al		; mark sectors as USED (not NULL)
	mov a, 0
	mov [index], a
	mov d, disk_buffer
	mov a, d
	mov [buffer_addr], a
cmd_mkbin_L2:
	mov c, 0
	mov a, $0103				; disk write, 1 sector
	syscall sys_ide_kernel			; write sector
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FS_SECTORS_PER_FILE		; remove 1 from this because we dont count the header sector
	je cmd_mkbin_add_to_dir
	inc b
	mov a, [buffer_addr]
	add a, 512
	mov [buffer_addr], a
	mov d, a
	jmp cmd_mkbin_L2
; now we add the file to the current directory!
cmd_mkbin_add_to_dir:	
	mov a, [current_dir_LBA]
	inc a
	mov b, a					; metadata sector
	mov c, 0
	mov g, b					; save LBA
	mov d, disk_buffer
	mov a, $0102			; disk read
	syscall sys_ide_kernel		; read metadata sector
cmd_mkbin_add_to_dir_L2:
	mov al, [d]
	cmp al, 0
	je cmd_mkbin_add_to_dir_null
	add d, FST_ENTRY_SIZE
	jmp cmd_mkbin_add_to_dir_L2					; we look for a NULL entry here but dont check for limits. CARE NEEDED WHEN ADDING TOO MANY FILES TO A DIRECTORY
cmd_mkbin_add_to_dir_null:
	mov si, userspace_data
	mov di, d
	call strcpy			; copy file name
	add d, 24			; skip name
	mov al, %00001110		; execute, write, read, not directory
	mov [d], al
	add d, 3
	pop a
	mov [d], a
	sub d, 2
	pop b				; get file LBA
	mov [d], b			; save LBA
	
	; set file creation date	
	add d, 4
	mov al, 4
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set day
	
	inc d
	mov al, 5
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set month
	
	inc d
	mov al, 6
	syscall sys_rtc
	mov al, ah
	mov [d], al			; set year
	
; write sector into disk for new directory entry
	mov b, g
	mov c, 0
	mov d, disk_buffer
	mov a, $0103			; disk write, 1 sector
	syscall sys_ide_kernel		; write sector
	call printnl
	sysret

			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PWD - PRINT WORKING DIRECTORY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
cmd_pwd:
	mov d, current_dir_str
	call puts
	call printnl
	mov a, [current_dir_LBA]
	call print_u16d
	call printnl
	sysret

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CAT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;:
cmd_cat_1:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	call cmd_cat
	
	sysret
	
cmd_cat:
	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read directory
	mov a, 0
	mov [index], a		; reset file counter
cmd_cat_L1:
	mov al, [d + 24]		; isolate directory and read flags
	and al, %00001011
	cmp al, %00000010
	jne cmd_cat_no_permission
	mov si, d
	mov di, userspace_data
	call strcmp
	je cmd_cat_found_entry
cmd_cat_no_permission:
	add d, 32
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FST_FILES_PER_DIR
	je cmd_cat_not_found
	jmp cmd_cat_L1
cmd_cat_found_entry:
	add d, 25			; get to LBA/ID of file in disk
	mov b, [d]			; get LBA
	inc b				; add 1 to B because the LBA for data comes after the header sector 
	mov d, disk_buffer	
	mov a, disk_buffer
	mov [buffer_addr], a
	mov a, 0
	mov [index], a
cmd_cat_found_L1:					; here we have to read the data sectors
	mov a, $0102					; disk read 1 sect
	syscall sys_ide_kernel				; read sector
	inc b	
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FS_SECTORS_PER_FILE-1		; -1 is here because we read all sectors except the data header				
	je cmd_cat_found_end				; at the end
	mov a, [buffer_addr]
	add a, 512
	mov [buffer_addr], a
	mov d, a
	jmp 	cmd_cat_found_L1
cmd_cat_found_end:				; open textfile
	mov d, disk_buffer
	call puts
	call printnl
cmd_cat_not_found:
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RMDIR - remove DIR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; deletes directory  entry in the current directory's file list 
; also deletes the actual directory entry in the FST
cmd_rmdir:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	mov a, [current_dir_LBA]
	
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read directory
	mov a, 0
	mov [index], a		; reset file counter
cmd_rmdir_L1:
	mov al, [d + 24]		; get to file type (needs to be a directory and writeable)
	and al, %00000101	
	cmp al, %00000101
	jne cmd_rmdir_no_permission
	mov si, d
	mov di, userspace_data
	call strcmp
	je cmd_rmdir_found_entry
cmd_rmdir_no_permission:
	add d, 32
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FST_FILES_PER_DIR
	je cmd_rmdir_not_found
	jmp cmd_rmdir_L1
cmd_rmdir_found_entry:
	mov b, [d + 25]			; get LBA
	mov g, b				; save LBA
	mov al, 0
	mov [d], al			; make file entry NULL
	
	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0103			; disk write
	mov d, disk_buffer
	syscall sys_ide_kernel		; write sector and erase file's entry in the current DIR
		
	mov d, disk_buffer	
	mov al, 0
	mov [d], al			; make file's data header NULL for re-use

	mov c, 0
	mov b, g				; get data header LBA
	mov a, $0103					; disk write 1 sect
	syscall sys_ide_kernel				; write sector
cmd_rmdir_not_found:	
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RM - remove file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; frees up the data sectors for the file further down the disk
; deletes file entry in the current directory's file list 
cmd_rm:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space
	
	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read directory
	mov a, 0
	mov [index], a		; reset file counter
cmd_rm_L1:
	mov al, [d + 24]		; get to file type
	and al, %00000101		; isolate write and directory flags
	cmp al, %00000100
	jne cmd_rm_no_permission
	mov si, d
	mov di, userspace_data
	call strcmp
	je cmd_rm_found_entry
cmd_rm_no_permission:
	add d, 32
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FST_FILES_PER_DIR
	je cmd_rm_not_found
	jmp cmd_rm_L1
cmd_rm_found_entry:
	mov b, [d + 25]			; get LBA
	mov g, b				; save LBA
	mov al, 0
	mov [d], al			; make file entry NULL
	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0103			; disk write
	mov d, disk_buffer
	syscall sys_ide_kernel		; write sector and erase file's entry in the current DIR
	mov d, disk_buffer	
	mov al, 0
	mov [d], al			; make file's data header NULL for re-use
	mov c, 0
	mov b, g				; get data header LBA
	mov a, $0103					; disk write 1 sect
	syscall sys_ide_kernel				; write sector
cmd_rm_not_found:	
	sysret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CHMOD - change file permissions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_chmod:
	; mov si, d
	; mov di, userspace_data
	; mov c, 256
	; load					; load data from user-space
	
	; mov d, s_pw
	; call puts
	; call scan_u16d
	; cmp a, 9999
	; jne cmd_chmod_not_found
	
	; mov a, [current_dir_LBA]
	; inc a				; metadata sector
	; mov b, a
	; mov c, 0				; reset LBA to 0
	; mov a, $0102			; disk read
	; mov d, disk_buffer
	; syscall sys_ide		; read directory
	; mov a, 0
	; mov [index], a		; reset file counter
; cmd_chmod_L1:
	; mov si, d
	; mov di, userspace_data
	; call strcmp
	; je cmd_chmod_found_entry
; cmd_chmod_no_permission:
	; add d, 32
	; mov a, [index]
	; inc a
	; mov [index], a
	; cmp a, FST_FILES_PER_DIR
	; je cmd_chmod_not_found
	; jmp cmd_chmod_L1
; cmd_chmod_found_entry:	
	; push bl
	; call get_token
	; mov g, d
	; mov d, userspace_data
	; call strtoint				; integer in A
	; mov d, g
	; and al, %00000111			; mask out garbage
	; shl al, 1				; shift left to make space for D flag
	; mov bl, al				; save number
	; mov al, [d + 24]			; get permissions
	; and al, %00000001			; remove all permissions, keep D flag
	; or al, bl				; set new permissions
	; mov [d + 24], al			; write permissions
	; mov c, 0
	; mov d, disk_buffer
	; mov a, $0103					; disk write 1 sect
	; pop bl
	; syscall sys_ide				; write sector
; cmd_chmod_not_found:
	; call printnl
	sysret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mv - move / change file name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_mv:
	; mov si, d
	; mov di, userspace_data
	; mov c, 256
	; load					; load data from user-space
	
	; mov a, [current_dir_LBA]
	; inc a				; metadata sector
	; mov b, a
	; mov c, 0				; reset LBA to 0
	; mov a, $0102			; disk read
	; mov d, disk_buffer
	; syscall sys_ide		; read directory
	; mov a, 0
	; mov [index], a		; reset file counter
; cmd_mv_L1:
	; mov si, d
	; mov di, userspace_data
	; call strcmp
	; je cmd_mv_found_entry
; cmd_mv_no_permission:
	; add d, 32
	; mov a, [index]
	; inc a
	; mov [index], a
	; cmp a, FST_FILES_PER_DIR
	; je cmd_mv_not_found
	; jmp cmd_mv_L1
; cmd_mv_found_entry:	
	; push bl
	; call get_token		; get new file name
	; mov si, userspace_data
	; mov di, d
	; call strcpy	
	; mov c, 0
	; mov d, disk_buffer
	; mov a, $0103					; disk write 1 sect
	; pop bl
	; syscall sys_ide				; write sector
; cmd_mv_not_found:
	sysret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; EXEC/OPEN PROGRAM/FILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmd_exec:
	mov si, d
	mov di, userspace_data
	mov c, 256
	load					; load data from user-space

	mov a, [current_dir_LBA]
	inc a				; metadata sector
	mov b, a
	mov c, 0				; reset LBA to 0
	mov a, $0102			; disk read
	mov d, disk_buffer
	syscall sys_ide_kernel		; read directory
	mov a, 0
	mov [index], a		; reset file counter
cmd_exec_L1:
	mov al, [d + 24]		; get to file attributes (needs to be executable and not a directory)
	and al, %00001001		; isolate executable and directory flags
	cmp al, %00001000
	jne cmd_exec_no_permission
	mov si, d
	mov di, userspace_data
	call strcmp
	je cmd_exec_found_entry
cmd_exec_no_permission:
	add d, 32
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FST_FILES_PER_DIR
	je cmd_exec_not_found
	jmp cmd_exec_L1
cmd_exec_found_entry:
	add d, 25			; get to LBA/ID of file in disk
	mov b, [d]			; get LBA
	inc b				; add 1 to B because the LBA for data comes after the header sector
	mov d, disk_buffer	
	mov a, d
	mov [buffer_addr], a
	mov a, 0
	mov [index], a
cmd_exec_found_L1:					; here we have to read the data sectors
	mov a, $0102					; disk read 1 sect
	syscall sys_ide_kernel				; read sector
	inc b	
	mov a, [index]
	inc a
	mov [index], a
	cmp a, FS_SECTORS_PER_FILE-1		; -1 is here because we read all sectors except the data header			
	je cmd_exec_found_end				; at the end
	mov a, [buffer_addr]
	add a, 512
	mov [buffer_addr], a
	mov d, a
	jmp 	cmd_exec_found_L1
cmd_exec_found_end:				
	call printnl	
	call disk_buffer
	call printnl
cmd_exec_not_found:
	sysret

print_address:
	mov d, s_prompt
	call puts
	mov d, current_dir_str
	call puts
	mov d, s_hash
	call puts
	sysret
	
KERNEL_RESET_VECTOR:	
	mov bp, _STACK_BEGIN
	mov sp, _STACK_BEGIN
	
	mov al, %10000000
	stomsks					; mask out timer interrupt for now (only allow UART to interrupt)
	sti	
	
	mov a, ROOT_LBA
	mov [current_dir_LBA], a		; set current directory LBA to ROOT
	mov si, ROOT_DIRECTORY_STR
	mov di, current_dir_str
	call strcpy
	
; reset fifo pointers
	mov a, fifo
	mov d, fifo_pi
	mov [d], a
	mov d, fifo_pr
	mov [d], a	
	mov al, 2
	syscall sys_io			; enable uart in interrupt mode
	
	mov d, s_started
	call puts
	
; here we need to launch the shell
	;; now we allocate a new process	
	call find_free_proc			; index in A
	setptb
	call proc_memory_map			; map process memory pages
	mov d, s_dataentry
	call puts
			
	mov si, s_shell_proc
	mov di, PROC_NAMES + 32
	call strcpy					; copy shell process name
		
	
	mov di, disk_buffer				
	call _load_hex
; now copy process binary data into process1 memory
	mov si, disk_buffer
	mov di, 0
	mov c, 10000					; mov c is not needed because _load_hex returns the size of the program in C
	store						; copy process data
		
	call find_free_proc			; index in A
	mov [ACTIVE_PROC_INDEX], al		; set new active process
	mov d, a
	mov al, 1
	mov [d + PROC_AVAILABILITY_TABLE], al					; make process busy
	
	mov al, [NBR_ACTIVE_PROCS]			; increase nbr of active processes
	inc al
	mov [NBR_ACTIVE_PROCS], al
	
	
; launch process
	push word $FFFF 
	push byte %00000100
	push word 0
	sysret
	
s_shell_proc: .db "shell", 0	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Process Index in A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
find_free_proc:
	mov si, PROC_AVAILABILITY_TABLE + 1			; skip process 0 (kernel)
find_free_proc_L0:
	lodsb						; get process state
	cmp al, 0
	je find_free_proc_free			; if free, jump
	jmp find_free_proc_L0			; else, not busy, goto next
find_free_proc_free:
	mov a, si
	sub a, 1+PROC_AVAILABILITY_TABLE				; get process index
	ret
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Process Index in AL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
proc_memory_map:
	mov ah, 0
	mov b, a			; page in BL, 0 in BH
	shl a, 5			; multiply by 32
	mov c, a			; save in C
	add c, 32
proc_memory_map_L0:
	pagemap
	add b, $0800					; increase page number (msb 5 bits of BH only)
	add a, 1						; increase both 
	cmp a, c						; check to see if we reached the end of memory
	jne proc_memory_map_L0
	ret
	
cmd_fork:
	mov al, %10000000				; deactivate timer interrupt
	stomsks
; we save the active process first	
	pusha
	mov ah, 0
	mov al, [ACTIVE_PROC_INDEX]
	shl a							; x2
	mov a, [PROC_TABLE_convert + a]		; get process state start index
		
	mov di, a
	mov a, sp
	inc a
	mov si, a
	mov c, 20
	rep movsb					; save process state!
; restore kernel stack position to point before interrupt arrived
	add sp, 20
	
;; now we allocate a new process	
	call find_free_proc			; index in A
	setptb
	call proc_memory_map			; map process memory pages
	mov d, s_dataentry
	call puts
			
	mov di, disk_buffer				
	call _load_hex
; now copy process binary data into process1 memory
	mov si, disk_buffer
	mov di, 0
	mov c, 10000					; mov c is not needed because _load_hex returns the size of the program in C
	store						; copy process data
		
	call find_free_proc			; index in A
	mov [ACTIVE_PROC_INDEX], al		; set new active process
	shl a, 5						; x32
	call printnl
	mov d, s_procname
	call puts
	mov d, a
	add d, PROC_NAMES
	call gets					; get proc name
	call printnl
	
	call find_free_proc			; index in A
	mov d, a
	mov al, 1
	mov [d + PROC_AVAILABILITY_TABLE], al					; make process busy
	
	mov al, [NBR_ACTIVE_PROCS]			; increase nbr of active processes
	inc al
	mov [NBR_ACTIVE_PROCS], al
	
	mov al, %10000000
	stomsks					; mask out timer interrupt for now (only allow UART to interrupt)
	
	
; launch process
	push word $FFFF 
	push byte %00000100
	push word 0
	sysret
	
PROC_TABLE_convert:
	.dw PROC_STATE_TABLE + 0
	.dw PROC_STATE_TABLE + 20
	.dw PROC_STATE_TABLE + 40
	.dw PROC_STATE_TABLE + 60
	.dw PROC_STATE_TABLE + 80
	.dw PROC_STATE_TABLE + 100
	.dw PROC_STATE_TABLE + 120
	.dw PROC_STATE_TABLE + 140
	





cmd_fwb:
;boot sector
	mov d, s_enter_boot
	call puts
	mov di, disk_buffer	; pointer to file contents
	call _load_hex			; load binary hex
	mov b, 0
	mov c, 0
	mov a, $0103				; disk write, 1 sector
	mov d, disk_buffer
	syscall sys_ide_kernel			; write sector
	call printnl
	sysret
	
cmd_fwk:
; kernel
	mov d, s_enter_kernel
	call puts
	mov di, disk_buffer	; pointer to file contents
	call _load_hex			; load binary hex
	mov a, 0
	mov [index], a
	mov d, disk_buffer
	mov a, d
	mov [buffer_addr], a
	mov b, 1
	mov c, 0
cmd_fwrite_L1:	
	mov a, $0103				; disk write, 1 sector
	syscall sys_ide_kernel			; write sector
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
	call printnl
	sysret

s_enter_boot: .db "bootloader: ", 0
s_enter_kernel: .db "kernel: ", 0


	
		
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
	sub sp, $3000				; string data block
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
	add sp, $3000
	pop di
	pop si
	pop d
	pop b
	pop a
	mov sp, bp
	pop bp
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
	ret

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
	



NBR_ACTIVE_PROCS			.db 0
ACTIVE_PROC_INDEX			.db 1
PROC_STATE_TABLE			.fill 16 * 20, 0		; for 15 processes max
PROC_AVAILABILITY_TABLE:	.fill 16, 0			; space for 15 processes. 0 = process empty, 1 = process busy	
PROC_NAMES				.fill 16 * 32, 0			; process names			

index:				.dw 0
buffer_addr:			.dw 0

fifo_pi:				.dw fifo
fifo_pr:				.dw fifo
fifo:				.fill 512

;  user space data

userspace_data:		.fill 256, 0

; file system variables

current_dir_LBA:		.dw 0				; keep ID of current directory
ROOT_DIRECTORY_STR:	.db "/", 0
username:			.fill 64, 0
current_dir_str:		.fill 512, 0			; keeps current directory string
filename:			.fill 256, 0		; holds filename for search


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
				
s_prompt: 			.db "Sol-1:", 0


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
					.db "Sat", 0
					.db "Fri", 0 


s_int_en:			.db "interrupts enabled\n\r", 0
s_started:			.db "kernel started\n\r", 0

s_procname:			.db "enter process name: ", 0

s_angle:				.db ">", 0
s_star: 				.db "*", 0				
s_hash: 				.db " #", 0
s_slash: 			.db "/", 0
s_hex:				.db "0x", 0
s_colon:				.db " : ", 0

s_OK:				.db "OK", 0

s_divzero:			.db "\nexception: zero division\n\r", 0
s_bkpt: 				.db "this is the breakpoint.", 0
s_priv1:				.db "\n\nsoftware failure: privilege exception\n\r", 0
	
disk_buffer:			.db 0			; this is actually a long buffer for disk data reads/writes

.end
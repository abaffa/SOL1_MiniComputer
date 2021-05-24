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

_TICK					.EQU _GLOBAL_BASE
_KER_ACTIVE_PROC			.equ _GLOBAL_BASE + 2
_KER_PROC_BASE			.equ _GLOBAL_BASE + 3
_KER_IDE_BUFFER			.equ _GLOBAL_BASE + 5		

_NULL					.equ 0



TOKTYP_IDENTIFIER			.EQU 0
TOKTYP_KEYWORD			.EQU 1
TOKTYP_DELIMITER			.EQU 2
TOKTYP_STRING				.EQU 3
TOKTYP_CHAR				.EQU 4
TOKTYP_NUMERIC			.EQU 5

TOK_NULL					.EQU 0
TOK_SLASH				.EQU 1
TOK_TIMES 				.EQU 2
TOK_PLUS 				.EQU 3
TOK_MINUS 				.EQU 4
TOK_OTHER				.EQU 5
TOK_DOT					.EQU 6
TOK_DDOT					.EQU 7
TOK_END					.EQU 15


FST_ENTRY_SIZE			.EQU 32
FST_FILES_PER_SECT		.EQU (512 / FST_ENTRY_SIZE)
FST_FILES_PER_DIR			.EQU 16
FST_NBR_DIRECTORIES		.EQU 64
FST_SECTORS_PER_DIR		.EQU (1 + (FST_ENTRY_SIZE * FST_FILES_PER_DIR / 512))		; 1 sector for header, the rest is for the list of files/dirs
FST_TOTAL_SECTORS			.EQU (FST_SECTORS_PER_DIR * FST_NBR_DIRECTORIES)
FST_LBA_START				.EQU 0
FST_LBA_END				.EQU (FST_TOTAL_SECTORS - 1)

FS_NBR_FILES 				.EQU (FST_NBR_DIRECTORIES * FST_FILES_PER_DIR)
FS_SECTORS_PER_FILE		.EQU 64				; the first sector is always a header with a NULL parameter (first byte)
											; so that we know which blocks are free or taken
FS_TOTAL_SECTORS			.EQU (FS_NBR_FILES * FS_SECTORS_PER_FILE)
FS_LBA_START				.EQU (FST_LBA_END + 1)
FS_LBA_END				.EQU (FS_LBA_START + FS_NBR_FILES - 1)

CF_CARD_LBA_SIZE			.equ $1000			; temporary small size




disk_buffer:				.equ $4000		; data buffer for IDE drive
										; this is declared as a byte here, but we use it as a long buffer					
origin:					.equ disk_buffer



bkpt			.equ 0
kernel_serv	.equ 1
rtc_serv		.equ 2
uart_serv	.equ 3
ide_serv		.equ 4
misc			.equ 5
putchar		.equ 6
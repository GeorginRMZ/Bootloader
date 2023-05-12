; Created by George at 22:43 11.05.2023 UTC+3 time
[org 0x7c00]			; Set programm start addres to 0x7c00
[cpu 8086]				; Set CPU config
[bits 16]				; Set program mode

mov [BOOT_DISK], dl     ; Move number of boot disk to BOOT_DISK           

; Setting up the stack
xor ax, ax              ; AX = 0           
mov es, ax				; ES = 0
mov ds, ax				; DS = 0
mov bp, 0x8000			; idk
mov sp, bp				; idk
mov bx, 0x7e00			; Add to BX addres of 'A' symbol
; Stack settings end

mov ax, 03	 			; Clear display
int 0x10				; Use interrupt

mov ah, 0x0e			; Set ah to 0x0e and print char
mov si, MSG				; Set si to MSG addres

PRINT:
    mov al, [si]		; Load to al character in si
    cmp al, 0			; if al == 0 then jump to WAIT_KEY
    je WAIT_KEY			; Jump to WAIT_KEY to wait key from user
    int 0x10			; Interrupt
    inc si				; SI = SI + 1
    jmp PRINT			; Jump to PRINT

WAIT_KEY:
   	in al, 0x60         ; Get input from keyboard
   	cmp al, 0x3F        ; Check if F5 was pressed
   	je BOOT_SYSTEM		; If so then jump to BOOT_SYSTEM
	cmp al, 0x01		; Check if ESC was pressed
	je REBOOT			; If so then jump to REBOOT
   	jmp WAIT_KEY    	; Otherwise go back to wait_key label

REBOOT:
	int 0x19			; Interrupt to reboot PC
BOOT_SYSTEM:
	mov ah, 2			; Set ah to 2 for read function
	mov al, 1			; Read 1 sector
	mov ch, 0			; Set reading cylinder
	mov dh, 0			; Set head number to read
	mov cl, 2			; Sector number to read
	mov dl, [BOOT_DISK]	; Set drive number
	int 0x13			; Use interrupt

	mov ah, 0x0e		; Set function to write character
	mov al, [0x7e00]	; Set al to 'A'
	int 0x10			; Use interrupt

MSG: 
	db 'Press F5 to run OS or press ESC to reboot PC: ', 0
BOOTMSG:
	db 'OS is starting...', 0
BOOT_DISK: db 0

TIMES 510-($-$$) db 0	; Fill butes to zeroes to 510 byte
dw 0xAA55				; Set 511 and 512 bytes
TIMES 512 db 'A'		; Fill sector of 'A'

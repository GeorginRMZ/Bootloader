; Created by George at 22:43 11.05.2023 UTC+3 time
[org 0x7c00]			; Set programm start addres to 0x7c00
[cpu 8086]				; Set CPU config
[bits 16]				; Set program mode

mov ax, 03	 			; Clear display
int 0x10				; Use interrupt

mov ah, 0x0e			; Set ah to 0x0e and print char
mov bx, MSG				; Set bx to MSG addres

PRINT:
    mov al, [bx]		; Load to al character in bx
    cmp al, 0			; if al == 0 then jump to WAIT_KEY
    je WAIT_KEY			; Jump to WAIT_KEY to wait key from user
    int 0x10			; Interrupt
    inc bx				; BX = BX + 1
    jmp PRINT			; Jump to PRINT

WAIT_KEY:
   	in al, 0x60         ; Get keyboard input
   	cmp al, 0xBF        ; Check if the user realises the F5 key
   	je LOOP             ; If so then jump to loop
	cmp al, 0x81		; Check if the user realises the ESC key		
	je LOOP				; If so then jump to loop
   	jmp WAIT_KEY		; Jump to WAIT_KEY
LOOP:
   	in al, 0x60         ; Get input from keyboard
   	cmp al, 0x3F        ; Check if F5 was pressed
   	je BOOT_SYSTEM		; If so then jump to BOOT_SYSTEM
	cmp al, 0x01		; Check if ESC was pressed
	je REBOOT			; If so then jump to REBOOT
   	jmp LOOP    		; Otherwise go back to loop label

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
	db 'Press F5 to run OS and press ESC to reboot PC', 0
BOOTMSG:
	db 'OS is starting...', 0
BOOT_DISK: db 0

TIMES 510-($-$$) db 0	; Fill butes to zeroes to 510 byte
dw 0xAA55				; Set 511 and 512 bytes
TIMES 512 db 'A'		; Fill sector of 'A'
; Created by George at 22:43 11.05.2023 UTC+3 time
[org 0x7c00]			; Set programm start addres to 0x7c00
[cpu 8086]			; Set CPU config
[bits 16]			; Set program mode

mov [BOOT_DISK], dl     	; Move number of boot disk to BOOT_DISK           

; Setting up the stack
xor ax, ax              	; AX = 0           
mov es, ax			; ES = 0
mov ds, ax			; DS = 0
mov bp, 0x8000			; idk
mov sp, bp			; idk
mov bx, 0x7e00			; Add to BX addres of 'A' symbol
; Stack settings end

call CLS			; Call CLS
call SLEEP			; Call SLEEP
mov si, MSG			; Set si to MSG addres
call PRINT			; Jump to PRINT
jmp WAIT_KEY			; Jump to WAIT_KEY

WAIT_KEY:
   	in al, 0x60		; Use interrupt
   	cmp al, 0x3F        	; Check if F5 was pressed
   	je BOOT_SYSTEM		; If so then jump to BOOT_SYSTEM
	cmp al, 0x01		; Check if ESC was pressed
	je OFF			; If so then jump to OFF
   	jmp WAIT_KEY    	; Otherwise go back to WAIT_KEY label

OFF:
	mov si, OFFMSG		; Set si to OFFMSG addres
	call PRINT		; Jump to PRINT
	call SLEEP		; Jump to SLEEP
	mov ax, 0x5307 		; Power management
    	mov bx, 0x0001 		; Power management of all devices
    	mov cx, 0x0003 		; Off
    	int 0x15		; Use interrupt
BOOT_SYSTEM:
	mov ah, 2		; Set ah to 2 for read function
	mov al, 1		; Read 1 sector
	mov ch, 0		; Set reading cylinder
	mov dh, 0		; Set head number to read
	mov cl, 2		; Sector number to read
	mov dl, [BOOT_DISK]	; Set drive number
	int 0x13		; Use interrupt

	mov ah, 0x0e		; Set function to write character
	mov al, [0x7e00]	; Set al to 'A'
	int 0x10		; Use interrupt


PRINT:
	mov ah, 0x0e		; Set AH to print text
    	mov al, [si]		; Load to AL character in SI
    	cmp al, 0		; if AL == 0 then jump to BREAK
    	je BREAK		; Jump to BREAK
    	int 0x10		; Interrupt
    	inc si			; SI = SI + 1
    	jmp PRINT		; Jump to PRINT
SLEEP:
	mov ah, 0x86		; Function to sleep
    	mov cx, 0x0F		; Microseconds time
    	mov dx, 0x4240		; Microseconds time
    	int 0x15		; Use interrupt
    	ret			; Return
CLS:
	mov ax, 03	 	; Clear display
	int 0x10		; Use interrupt

	mov ah, 0x06    	; Scroll up function
	xor al, al     		; Clear entire screen
	xor cx, cx     		; Upper left corner CH=row, CL=column
	mov dx, 0x184f 		; Lower right corner DH=row, DL=column 
	mov bh, 0x1f    	; WhiteOnBlue
	int 0x10		; Use interrupt
	ret			; Return
BREAK:
	ret			; Return


MSG: 
	db 'Press F5 to run OS or press ESC to off PC: ', 0xA, 0xD, 0
BOOTMSG:
	db 'OS is starting...', 0xA, 0xD, 0
OFFMSG:
	db 'Computer shutting down...', 0xA, 0xD, 0
BOOT_DISK: db 0

TIMES 510-($-$$) db 0		; Fill butes to zeroes to 510 byte
dw 0xAA55			; Set 511 and 512 bytes
TIMES 512 db 'A'		; Fill sector of 'A'

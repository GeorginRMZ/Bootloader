[org 0x7c00]
[bits 16]
[cpu 8086]

jmp START			; Jump to WAIT_KEY

START:
    	call CLS		; Call CLS 
    	mov si, HEY		; Move ti SI HEY message addres
    	call PRINT		; Call print
    	mov si, KEYS		; Move to SI KEYS message addres
    	call PRINT		; Call print
    	jmp WAIT_KEY		; Jump to WAIT_KEY

WAIT_KEY:
    	in al, 0x60		; Use interrupt
    	cmp al, 0x01
    	je OFF
   	cmp al, 0x02        	; Check if 1 was pressed
   	je WHITEBLUE		; If so then jump to BOOT_SYSTEM
	cmp al, 0x03		; Check if 2 was pressed
	je YELLOWBLUE		; If so then jump to OFF
    	cmp al, 0x04        	; Check if 3 was pressed
    	je WHITERED         	; Change bg to red
   	jmp WAIT_KEY    	; Otherwise go back to WAIT_KEY label

OFF:
	mov si, OFFMSG		; Set si to OFFMSG addres
	call PRINT		; Jump to PRINT
	call SLEEP		; Jump to SLEEP
	mov ax, 0x5307 		; Power management
    	mov bx, 0x0001 		; Power management of all devices
    	mov cx, 0x0003 		; Off
    	int 0x15		; Use interrupt
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
WHITEBLUE:
	mov ax, 03	 	; Clear display
	int 0x10		; Use interrupt
	mov ah, 0x06    	; Scroll up function
	xor al, al     		; Clear entire screen
	xor cx, cx     		; Upper left corner CH=row, CL=column
	mov dx, 0x184f 		; Lower right corner DH=row, DL=column 
	mov bh, 0x1f    	; WhiteOnBlue
	int 0x10		; Use interrupt
	jmp START		; Return
YELLOWBLUE:
	mov ax, 03	 	; Clear display
	int 0x10		; Use interrupt
	mov ah, 0x06    	; Scroll up function
	xor al, al     		; Clear entire screen
	xor cx, cx     		; Upper left corner CH=row, CL=column
	mov dx, 0x184f 		; Lower right corner DH=row, DL=column 
	mov bh, 0x1e    	; YellowOnBlue
	int 0x10		; Use interrupt
	jmp START		; Return
WHITERED:
	mov ax, 03	 	; Clear display
	int 0x10		; Use interrupt
	mov ah, 0x06    	; Scroll up function
	xor al, al     		; Clear entire screen
	xor cx, cx     		; Upper left corner CH=row, CL=column
	mov dx, 0x184f 		; Lower right corner DH=row, DL=column 
	mov bh, 0x4f    	; YellowOnBlue
	int 0x10		; Use interrupt
	jmp START		; Return
BREAK:
	ret			; Return

HEY:
    	db 'Welcome to SimpleOS', 0xA, 0xD, 0
KEYS:
    	db 'Press special keys to change colors', 0xA, 0xD, 0
OFFMSG:
    	db 'Computer shutting down...', 0xA, 0xD, 0
TIMES 512-($-$$) db 0

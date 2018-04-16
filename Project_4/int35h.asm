org 300h
int_34:
    push ds
    push es
    push ax
    push bx
    push cx
    push dx
    mov ax,cs
    mov ds,ax
	mov	bp,message_34 ; BP=当前串的偏移地址
	mov	ax, ds			    ; ES:BP = 串地址
	mov	es, ax			    ; 置ES=DS 
	mov	cx, [strlen]       	; CX = 串长（=10）	
	mov	 ax, 1301h	 
	; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	 bx, 0007h
	; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov  dh, 6		; 行号=10
	mov	 dl, 60		; 列号=10
	int	10h		; BIOS的10h功能：显示一行字符
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop ds
    iret
data_34:
    message_34 db "Testing interruption"
    strlen dw $-message_34

org 100h
int_34:
    push bp
    push ds
    push es
    push ax
    push bx
    push cx
    push dx
    sti
    mov ax,cs
    mov ds,ax
	mov	bp,message_34
	mov	ax, ds
	mov	es, ax			   
	mov	cx, [strlen]）	
	mov	 ax, 1301h	 
	mov	 bx, 0007h
	mov  dh, 6
	mov	 dl, 10
	int	10h
    pop dx
    pop cx
    pop bx
    pop ax
    pop es
    pop ds
    pop bp
    iret
data_34:
    message_34 db "I Love OS!"
    strlen dw $-message_34

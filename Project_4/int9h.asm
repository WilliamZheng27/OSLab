start:
    pusha
    pushf
    push es
    mov ax,0b800h
    mov es,ax
intpro:
    mov ax,[ouch_stat]
    cmp ax,0
    je ouch
    cln_ouch:
    mov al,' '
	mov ah,0
	mov bx,2*(80*10+10)
    mov cx,4
    cln_lp:
    mov word [ouch_stat],0
	mov al,' '
	add bx,2
	mov word [es:bx],ax
    loop cln_lp
    jmp end
    ouch:
    mov word [ouch_stat],1
    mov al,'o'
	mov ah,0
	mov bx,2*(80*10+10)
    mov al,'u'
	add bx,2
	mov word [es:bx],ax
    mov al,'c'
	add bx,2
	mov word [es:bx],ax
    mov al,'h'
	add bx,2
	mov word [es:bx],ax
    mov al,'!'
	add bx,2
	mov word [es:bx],ax

end:
    pop es
    popf
    popa
    iret
datadef:
    ouch_stat dw 0
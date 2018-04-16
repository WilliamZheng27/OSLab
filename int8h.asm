delay equ 8
org 100h
start:
    mov ax,cs
    mov ds,ax
    mov ss,ax
    mov ax,0b700h
    mov es,ax
timing:
	;设定延迟
	dec word [count]
	jnz timing
    ret
down:
    inc word [x]
    mov ax,word [x]
    cmp ax,25
    je D_R
    call display
    jmp down
    D_R:
    mov word [x],24
    inc word [y]
    call display
    jmp right
right:
    inc word [y]
    mov ax,word [y]
    cmp ax,80
    je R_U
    call display
    jmp right
    R_U:
    dec word [x]
    mov word [y],79
    call display
    jmp up
up:
    dec word [x]
    mov ax,word [x]
    cmp ax,-1
    je U_L
    call display
    jmp up
    U_L:
    dec word [y]
    mov word [x],0
    call display
    jmp left
left:
    dec word [y]
    mov ax,word [y]
    cmp ax,-1
    je L_D
    call display
    jmp left
    L_D:
    inc word [x]
    mov word [y],0
    call display
    cmp byte [char],'Z'
    je reset_char
    inc byte [char]
    jmp down
    reset_char:
    mov byte [char],'A'
    jmp down
display:
	mov ax,[x]
	mov bx,80
	mul bx
	add ax,[y]
	mov bx,2
	mul bx
	mov bx,ax
	;将字符装入显存
	mov byte ah,[color]
	mov byte al,[char]
	mov [es:bx],ax
	call timing
    mov al,20h
    out 20h,al
    out 0A0h,al
    iret

datadef:
    count dw delay
    color db 7
    char db 'A'
    x dw 0
    y dw 0
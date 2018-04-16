;程序源代码（showstr.asm）
extrn _main:near
extrn _strt:near
extrn _Message:near
extrn _startingMsg:near
extrn _strlen:near
extrn _keyboardInput:near
public _put
public _input
public _clean
public _changeline
public _proc_Pg_1

.8086
_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
       assume cs:_TEXT,ds:_DATA
org 100h
start:
	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp, 100h
	call mod_int_8
	call _clean
	main_shell:
	;call near ptr _putstr
	jmp near ptr _main
	jmp $
datadef:
	old_int9h dd 0
	delay equ 20		; 计时器延迟计数
	count db delay		; 计时器计数变量，初值=delay
	int8_x dw -1
	int8_y dw 0
    color db 7
    char db 'A' - 1
	position dw 0
	ouch_x dw 1
	ouch_y dw 10
	usr_pg dd ?
	x dw 1
	y dw 1
	down_edge equ 0efch
	up_edge equ 0a2h
_put proc near
	;int put(char,int)
	;要显示的值放在ax中
	push bp
	mov bp,sp
	;弹出char
	mov cx,[bp+4]
	;弹出int
	mov bx,[bp+6]
	mov ch,bl
	mov ah,0
	int 20h
	mov sp,bp
	pop bp
    ret
endp
_clean proc near
	mov ah,3
	int 20h
	mov word ptr x,1
	mov word ptr y,1
    ret
endp
_changeline proc near
	mov al,2
	mov ah,2
	int 20h
    ret
endp
_proc_Pg_1 proc near
	call mod_int_9
	mov bx,offset usr_pg
	mov word ptr [bx],100h
	mov word ptr [bx+2],900h
	call  dword ptr [bx]
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ah,0
	mov al,3
	int 10h
	ret
endp


_input proc near
	mov di,offset _keyboardInput
	ip:
	mov ah,0
	int 16h
	cmp ax,1c0dh
	je ed
	mov bx,7
	push bx
	push ax
	call _put
	pop ax
	pop bx
	;写入缓冲区
	mov byte ptr es:[di],al
	inc di
	jmp ip
	ed:
	call _changeline
	ret
endp

modded_int8:
	push ax
	push bx
	push ds
	push es
	mov ax,cs
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	mov ax,position
	cmp ax,0
	je down
	cmp ax,1
	je right
	cmp ax,2
	je up
	cmp ax,3
	je left
down:
    inc int8_x
    mov ax,int8_x
    cmp ax,25
    je D_R
    jmp int8_display
    D_R:
    mov int8_x,24
    inc int8_y
	mov position,1
    jmp int8_display
right:
    inc int8_y
    mov ax,int8_y
    cmp ax,80
    je R_U
    jmp int8_display
    R_U:
    dec int8_x
    mov int8_y,79
	mov position,2
    jmp int8_display
up:
    dec int8_x
    mov ax,int8_x
    cmp ax,-1
    je U_L
    jmp int8_display
    U_L:
    dec int8_y
    mov int8_x,0
	mov position,3
    jmp int8_display
left:
    dec int8_y
    mov ax,int8_y
    cmp ax,-1
    je L_D
    jmp int8_display
    L_D:
    inc int8_x
    mov int8_y,0
	mov position,0
    jmp int8_display
int8_display:
    cmp char,'Z'
    jne reset_char
    mov char,'A' - 1
	reset_char:
	inc char
	mov ax,int8_x
	mov bx,80
	mul bx
	add ax,int8_y
	mov bx,2
	mul bx
	mov bx,ax
	;将字符装入显存
	mov ah,color
	mov al,char
	mov es:[bx],ax
	inc color
	pop es
	pop ds
	pop bx
	pop ax
    mov al,20h
    out 20h,al
    out 0A0h,al
    iret
timing:
	;设定延迟
	dec count
	jnz timing
	mov count,delay
    ret

modded_int9:
	in al,60h
	pushf
	call dword ptr cs:[old_int9h]
	push ds
    push ax
	push bx
	push cx
    push es
	mov ax,cs
	mov ds,ax
    mov ax,0b800h
    mov es,ax
intpro:
	mov ax,ouch_x
	mov cx,80
	mul cx
	add ax,ouch_y
	mov cx,2
	mul cx
	mov bx,ax
    mov al,'o'
	mov ah,7
	mov word ptr es:[bx],ax
    mov al,'u'
	add bx,2
	mov word ptr es:[bx],ax
    mov al,'c'
	add bx,2
	mov word ptr es:[bx],ax
    mov al,'h'
	add bx,2
	mov word ptr es:[bx],ax
    mov al,'!'
	add bx,2
	mov word ptr es:[bx],ax
	inc ouch_x
	ed_ouch:
	pop es
	pop cx
	pop bx
	pop ax
	pop ds
	iret

sys_call:
	cmp ah,0
	je sys_0
	cmp ah,1
	je sys_1
	cmp ah,2
	je sys_2
	cmp ah,3
	jz bar_3
	bar_3:
	jmp sys_3
sys_0:
	;0号系统调用：在光标位置显示一个字符
	;字符及属性放在cx中
	;保护现场
	push bx
	push es
	push ax
	sti ;开中断
	;设定显存段地址
	mov ax,0b800h
	mov es,ax
	;计算偏移量
	mov ah,1
	int 20h
	mov bx,ax
	;放置字符
	mov word ptr es:[bx],cx
	;放置光标
	mov ah,2
	mov al,0
	int 20h
	pop ax
	pop es
	pop bx
	iret
sys_1:
	;1号系统调用：计算显存偏移量，结果放在ax中
	push ds
	push bx
	sti
	mov ax,cs
	mov ds,ax
	mov ax,x
	mov bx,80
	mul bx
	add ax,y
	mov bx,2
	mul bx
	pop bx
	pop ds
	iret
sys_2:
	;2号系统调用：设置光标位置：x：bx y：cx
	;al=0:放置到当前位置的下一个位置
	;al=1:放置到指定位置
	;al=2:光标换行
	push ds
	push es
	push ax
	push bx
	push dx
	push ax
	sti
	mov ax,cs
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	pop ax
	;确定功能
	cmp al,1
	je equal
	cmp al,2
	je ch_line
	inc y
	cmp y,79
	je ch_line
	jmp put_flag
	ch_line:
	;消除当前位置的光标
	mov ah,1
	int 20h
	mov bx,ax
	mov al,' '
	mov ah,0
	mov word ptr es:[bx],ax
	inc x
	mov y,1
	jmp put_flag
	equal:
	;消除当前位置的光标
	mov ah,1
	int 20h
	mov dx,bx
	mov bx,ax
	mov al,' '
	mov ah,0
	mov word ptr es:[bx],ax
	mov bx,dx
	mov word ptr x,bx
	mov word ptr y,cx
	put_flag:
	mov ah,1
	int 20h
	mov bx,ax
	mov ah,7
	mov al,'_'
	mov word ptr es:[bx],ax
	pop dx
	pop bx
	pop ax
	pop es
	pop ds
	iret
sys_3:
	;3号系统调用：清空屏幕
	push es
	push ds
	push ax
	push bx
	push cx
	mov ax,cs
	mov ds,ax
	mov ax,0b800h
	mov es,ax
	xor bx,bx
	xor ax,ax
	mov cx,07fffh
	cln:
	mov byte ptr es:[bx],al
	inc bx
	loop cln
	sti
	pop cx
	pop bx
	pop ax
	pop ds
	pop es
	iret

mod_int_8 proc near
	cli
	;设置int 8h
	xor ax,ax			; AX = 0
	mov es,ax			; ES = 0
	mov word ptr [es:20h],offset modded_int8; 设置新中断向量的偏移地址
	mov ax,cs
	mov word ptr [es:22h],ax; 设置新中断向量的段地址=CS
	mov es,ax

	;设置int 20h
	xor ax,ax			; AX = 0
	mov es,ax			; ES = 0
	mov word ptr es:[80h],offset sys_call; 设置新中断向量的偏移地址
	mov ax,cs
	mov word ptr es:[82h],ax; 设置新中断向量的段地址=CS
	mov es,ax
	sti
	ret
mod_int_9 proc near
	;设置int 9h
	xor ax,ax			; AX = 0
	mov es,ax			; ES = 0 
	push es:[4*9]
	pop es:[200h]
	push es:[4*9+2]
	pop es:[202h]
	mov bx,word ptr es:[24h];保存原int 9h中断向量
	mov word ptr [old_int9h],bx
	mov bx,word ptr es:[26h]
	mov word ptr [old_int9h + 2],bx
	mov word ptr [es:24h],offset modded_int9; 设置新中断向量的偏移地址
	mov ax,cs
	mov word ptr [es:26h],ax; 设置新中断向量的段地址=CS
	mov es,ax
	ret
endp
endp






_TEXT ends
;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start

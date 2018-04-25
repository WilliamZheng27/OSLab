;程序源代码（showstr.asm）
extrn _main:near
extrn _strt:near
extrn _Message:near
extrn _startingMsg:near
extrn _strlen:near
extrn _keyboardInput:near
extrn _ProcessNum:near
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
	ds_save dw ?
	ret_save dw ?
	si_save dw ?
	kernelsp dw ?
	lds_low dw ?
	lds_high dw ?

_put proc near
	;int put(char,int)
	;在光标位置显示一个字符
	;要显示的值放在ax中
	push bp
	mov bp,sp
	;弹出char
	mov cx,[bp+4]
	;弹出int
	mov bx,[bp+6]
	;将字符和属性放在cx中
	mov ch,bl
	;调用0号系统中断
	mov ah,0
	int 20h
	mov sp,bp
	pop bp
    ret
endp
_clean proc near
	;int clean()
	;清空屏幕并重置光标
	;调用3号系统中断
	mov ah,3
	int 20h
	;重置光标到左上角
	mov word ptr x,1
	mov word ptr y,1
    ret
endp
_changeline proc near
	;调用2号系统中断
	;光标换行
	mov al,2
	mov ah,2
	int 20h
    ret
endp
_proc_Pg_1 proc near
	;修改int 9h
	;call mod_int_9
	cli
	mov bx,offset usr_pg
	mov word ptr [bx],100h
	mov word ptr [bx+2],900h
	;调用用户程序
	call  dword ptr [bx]
	mov ax,cs
	mov ds,ax
	mov es,ax
	;恢复int 9h
	;call reset_int_9
	ret
endp

_proc_Pg_2 proc near
	;修改int 9h
	;call mod_int_9
	cli
	mov bx,offset usr_pg
	mov word ptr [bx],300h
	mov word ptr [bx+2],900h
	;调用用户程序
	call  dword ptr [bx]
	mov ax,cs
	mov ds,ax
	mov es,ax
	;恢复int 9h
	;call reset_int_9
	ret
endp

_proc_Pg_3 proc near
	;修改int 9h
	;call mod_int_9
	cli
	mov bx,offset usr_pg
	mov word ptr [bx],500h
	mov word ptr [bx+2],900h
	;调用用户程序
	call  dword ptr [bx]
	mov ax,cs
	mov ds,ax
	mov es,ax
	;恢复int 9h
	;call reset_int_9
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
;save
	;此时是被中断程序的栈
	push ds
	push cs
	pop ds;ds=cs
	pop word ptr [ds_save];ds_save=ds
	pop word ptr [ret_save];ret_save=ip
	mov word ptr[si_save],si;si_save=si
	mov si,word ptr [_CurrentProc] ;si=*pcb currentProc
	add si,22;跳到IP的位置
	pop word ptr [si];
	add si,2
	pop word ptr [si]
	add si,2
	pop word ptr [si]
	mov word ptr [si-6],sp
	mov word ptr [si-8], ss
	mov si,ds;si=ds=cs
	mov ss,si;
	mov ss,si
	mov sp,word ptr [_CurrentProc]
	add sp,18;跳到ds处
	push word ptr[ds_save];保存ds
	push es;保存es
	push bp;保存bp
	push di;保存di
	push word ptr[si_save]
	push dx
	push cx
	push bx
	push ax
	mov sp,word ptr[kernelsp]
	mov ax,word ptr [ret_save]
	jmp ax

;schedule
	call _schedule
;Restart
	mov word ptr[kernelsp],sp
	mov sp,word ptr[_CurrentProc]
	pop ax
	pop bx
	pop cx
	pop dx
	pop si
	pop di
	pop bp
	pop es
	mov word ptr[lds_low],bx
	pop word ptr[lds_high]
	mov bx,sp
	mov bx,word ptr[bx]
	mov ss,bx
	mov bx,sp
	add bx,2
	mov sp,word ptr[bx]
	push word ptr[bx+6]
	push word ptr[bx+4]
	push word ptr[bx+2]
	lds bx,dword ptr[lds_low]
	push ax
	mov al,20h			; AL = EOI
	out 20h,al			; 发送EOI到主8529A
	out 0A0h,al			; 发送EOI到从8529A
	pop ax
	iret				; 从中断返回


modded_int9:
	;调用原int 9h
	in al,60h
	pushf
	call dword ptr cs:[old_int9h]
	;保护现场
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
	;计算显示位置的偏移量
	mov ax,ouch_x
	mov cx,80
	mul cx
	add ax,ouch_y
	mov cx,2
	mul cx
	mov bx,ax
	;显示“ouch”
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
	;恢复现场
	pop es
	pop cx
	pop bx
	pop ax
	pop ds
	iret

sys_call:
	;判断中断功能
	cmp ah,0
	je sys_0
	cmp ah,1
	je sys_1
	cmp ah,2
	je sys_2
	cmp ah,3
	jz bar_3;解决je跳转范围不够
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
endp

mod_int_9 proc near
	;设置int 9h
	xor ax,ax			; AX = 0
	mov es,ax			; ES = 0 
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

reset_int_9 proc near
	xor ax,ax
	mov es,ax
	mov bx,word ptr [old_int9h]
	mov word ptr es:[24h],bx
	mov bx,word ptr [old_int9h + 2]
	mov word ptr es:[26h],bx
	mov bx,cs
	mov es,bx
	ret
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

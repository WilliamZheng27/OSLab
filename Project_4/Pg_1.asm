;如有移动过快或过慢问题，请修改delay与delay_t的值
;其它子程序与此程序结构类似，仅有四个边界值、字母射出的初始位置与org指令不同
D_R equ 0
D_L equ 1
U_R equ 2
U_L equ 3
left_border equ -1
right_border equ 80
up_border equ -1
down_border equ 25
delay_t equ 200
delay equ 800

org 100h
start:
	;设定数据段偏移量
	mov ax,cs
	mov ds,ax
	;设定显存偏移量
	mov ax,0b800h
	mov es,ax
	;初始化变量
	mov byte [direction],D_R
	mov word [x],0
	mov word [y],0
	mov byte [color],1
	call near clean
	int 34h
	int 35h
	int 36h
	int 37h
timing:
	;设定延迟
	dec word [count]
	jnz timing
	;设定延迟倍数
	mov word[count],delay
	dec word [delay_t]
	jnz timing
	mov word [count],delay
	mov word [count_t],delay_t
	;初始化计数器
	mov si,message_pg1
	xor di,di
	inc di
	inc di
	mov cx,messagelen
personal:
	;显示个人信息
	mov al,[si]
	mov ah,[color]
	mov byte [es:di],al
	inc si
	inc di
	mov byte [es:di],ah
	inc di
	loop personal
	

;判断下一次移动方向
judging:
	mov al,D_R
	cmp al,[direction]
	jz Dn_Rt
	mov al,U_R
	cmp al,[direction]
	jz Up_Rt
	mov al,U_L
	cmp al,[direction]
	jz Up_Lt
	mov al,D_L
	cmp al,[direction]
	jz Dn_Lt
;Moving
Dn_Rt:
	inc word [x]
	inc word [y]
	jmp Border_detection
Up_Rt:
	dec word [x]
	inc word [y]
	jmp Border_detection
Up_Lt:
	dec word [x]
	dec word [y]
	jmp Border_detection
Dn_Lt:
	inc word [x]
	dec word [y]
	jmp Border_detection
;判断是否撞到边界
Border_detection:
	;判断是否撞到顶部
	mov ax,up_border
	sub ax,[x]
	jnz cU_D
	call U_D
cU_D:
	;判断是否撞到底部
	mov ax,down_border
	sub ax,[x]
	jnz cD_U
	call D_U
cD_U:
	;判断是否撞到左侧
	mov ax,left_border
	sub ax,[y]
	jnz cL_R
	call L_R
cL_R:
	;判断是否撞到右侧
	mov ax,right_border
	sub ax,[y]
	jnz cR_L
	call R_L
cR_L:
	jmp display
;改变运动方向
R_L:
	mov word [y],right_border
	sub word [y],2
	mov al,[direction]
	or al,01h
	mov byte [direction],al
	ret
L_R:
	mov word [y],left_border
	add word [y],2
	mov al,[direction]
	and al,02h
	mov byte [direction],al
	ret
D_U:
	mov word [x],down_border
	sub word [x],2
	mov al,[direction]
	or al,02h
	mov byte [direction],al
	ret
U_D:
	mov word [x],up_border
	add word [x],2
	mov al,[direction]
	and al,01h
	mov byte [direction],al
	ret
;显示模块
display:
	;退出/清屏判断
    mov ah,02h
    int 16h
	;按alt清屏
	cmp al,08h
	jnz n_alt
	call clean
n_alt:
	;按Ctrl+shift退回到程序选择界面
    cmp al,06h
    jz ret_to_os
	;计算显存地址
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
	;改变颜色
	inc byte [color]
	jmp timing
;清屏
clean:
	mov cx,07FFFh
	xor bx,bx
cln:
	mov byte [es:bx],0
	inc bx
	loop cln
	ret
ret_to_os:
	call clean
    retf
datadef:
	count_t dw delay_t
	count dw delay
	direction db D_R
	x dw 0
	y dw 0
	char db 'W'
	color db 1
	message_pg1 db '16337328ZhengYuXiao'
	messagelen equ $ - message_pg1
	
	

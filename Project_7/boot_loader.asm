org  7c00h		; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetOfKernelPrg equ 8100h
OffSetOfUserPrg equ 9100h
OffSetOfintPrg1 equ 5100h;int 34h
OffSetOfintPrg2 equ 5300h;int 35h
OffSetOfintPrg3 equ 5500h;int 36h
OffSetOfintPrg4 equ 5700h;int 37h

delay equ 1000
delay_t equ 450

Start:
	mov	ax, cs	       ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
	mov	es, ax		 ; 置ES=DS
LoadnEx:
     ;读取内核
      mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
      mov bx, OffSetOfKernelPrg  ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ; 功能号
      mov al,5                 ;扇区数
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      mov cl,2                 ;起始扇区号 ; 起始编号为1
      int 13H                  ;调用读磁盘BIOS的13h功能
      ;读取用户程序
      mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
      mov bx, OffSetOfUserPrg  ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ; 功能号
      mov al,3                 ;扇区数
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      mov cl,7                 ;起始扇区号 ; 起始编号为1
      int 13H ;                调用读磁盘BIOS的13h功能
      mov ax,800h
      push ax
      mov ax,100h
      push ax
      retf
      times 510-($-$$) db 0
      db 0x55,0xaa
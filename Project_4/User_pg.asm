start:
    ;测试系统中断
    mov ah,0
    int 21h
    mov ah,1
    int 21h
    mov ah,2
    int 21h
    ;测试软中断
    int 34h
    int 35h
    int 36h
    int 37h
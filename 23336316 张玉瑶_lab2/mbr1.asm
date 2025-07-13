org 0x7c00
[bits 16]
xor ax, ax ; eax = 0
; 初始化段寄存器, 段地址全部设为0
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax

; 初始化栈指针
mov sp, 0x7c00
mov ax, 0xb800
mov gs, ax

mov ah, 0x3c


mov di, (16*80+10)*2;
mov al, '2'
mov [gs:di], ax
add di, 2

mov al, '3'
mov [gs:di], ax
add di, 2

mov al, '3'
mov [gs:di], ax
add di, 2

mov al, '3'
mov [gs:di], ax
add di, 2

mov al, '6'
mov [gs:di], ax
add di, 2

mov al, '3'
mov [gs:di], ax
add di, 2

mov al, '1'
mov [gs:di], ax
add di, 2

mov al, '6'
mov [gs:di], ax

jmp $ ; 死循环

times 510 - ($ - $$) db 0
db 0x55, 0xaa

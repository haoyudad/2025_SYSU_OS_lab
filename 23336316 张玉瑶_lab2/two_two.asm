org 0x7c00
[bits 16]
xor ax, ax ; eax = 0
; 初始化段寄存器, 段地址全部设为0
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax


mov ah,0x02
mov bh,0x00
mov dh,16
mov dl,10
int 0x10

mov ah,0x09
mov al,'2'
mov bh,0x00
mov bl,0x3c
mov cx,1
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'3'
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'3'
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'3'
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'6'
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'3'
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'1'
int 0x10
inc dl
mov ah,0x02
int 0x10

mov ah,0x09
mov al,'6'
int 0x10

jmp $

times 510 - ($ - $$) db 0
db 0x55, 0xaa    ;has warning ,but i donnot know how to correct it

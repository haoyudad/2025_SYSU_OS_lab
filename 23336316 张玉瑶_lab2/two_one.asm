org 0x7c00
[bits 16]
xor ax, ax ; eax = 0
; 初始化段寄存器, 段地址全部设为0
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax

mov ah,0x03 ;get site
mov bh,0x00        
int 0x10 

mov ah,0x02 ;move site
mov bh,0x00
mov dh,10
mov dl,20
int 0x10

jmp $

times 510 - ($ - $$) db 0
db 0x55, 0xaa

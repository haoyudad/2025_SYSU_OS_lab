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


loop:
  mov ah,0x00
  int 0x16
  
  mov ah,0x09
  mov bh,0x00
  mov bl,0x0e
  mov cx,1
  int 0x10
  
  inc dl
  mov ah,0x02
  int 0x10
  
  jmp loop


times 510 - ($ - $$) db 0
db 0x55, 0xaa

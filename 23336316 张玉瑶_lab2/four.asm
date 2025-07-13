org 0x7C00
bits 16

mov ax,0x0002 
int 0x10
mov ax,0xB800
mov es,ax

mov byte [x],0 
mov byte [y],0 
mov byte [d],0 ;direction
mov word [c],0 ;color
mov word [s],0 ;char

loop:
cmp byte [d],0
je go_right
cmp byte [d],1
je go_down
cmp byte [d],2
je go_left
cmp byte [d],3
je go_up

go_right:
inc byte [x]
cmp byte [x],79
jb show
mov byte [d],1
dec byte [x]
jmp show

go_down:
inc byte [y]
cmp byte [y],24
jb show
mov byte [d],2
dec byte [y]
jmp show

go_left:
dec byte [x]
cmp byte [x],0
jge show
mov byte [d],3
inc byte [x]
jmp show

go_up:
dec byte [y]
cmp byte [y],0
jge show
mov byte [d],0
inc byte [y]

show:
mov ax,0
mov al,[y]
mov bx,80
mul bx
add al,[x]
adc ah,0
shl ax,1
mov di,ax


mov si, chars
add si,[s]
mov al,[si]
inc word [s]
cmp word [s],10 
jb get_color
mov word [s],0

get_color:
mov si,cols
add si,[c]
mov ah,[si]
inc word [c]
cmp word [c],11
jb print
mov word [c],0

print:
mov [es:di],ax ;

; delay
mov cx, 0x0001
mov dx, 0x86A0
mov ah, 0x86
int 0x15

jmp loop


x db 0
y db 0
d db 0
c dw 0
s dw 0

chars db "0123456789" ;
cols db 0x1E,0x2A,0x3C,0x36,0x02,0x6E,0x4E,0x5A,0x6C,0x7E,0x86 ;

times 510-($-$$) db 0
dw 0xAA55

%include "boot.inc"

[bits 16]
org 0x7e00

start:
    ; 初始化段寄存器
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; 设置GDT
    mov dword [GDT_START_ADDRESS+0x00], 0x00000000  ; 空描述符
    mov dword [GDT_START_ADDRESS+0x04], 0x00000000

    ; 平坦模式数据段
    mov dword [GDT_START_ADDRESS+0x08], 0x0000ffff
    mov dword [GDT_START_ADDRESS+0x0c], 0x00cf9200

    ; 平坦模式代码段
    mov dword [GDT_START_ADDRESS+0x10], 0x0000ffff
    mov dword [GDT_START_ADDRESS+0x14], 0x00cf9800

    ; 显存段 (0xB8000)
    mov dword [GDT_START_ADDRESS+0x18], 0x8000ffff
    mov dword [GDT_START_ADDRESS+0x1c], 0x0040920b

    ; 加载GDTR
    mov word [gdt_ptr], 31
    mov dword [gdt_ptr+2], GDT_START_ADDRESS
    lgdt [gdt_ptr]

    ; 开启A20
    in al, 0x92
    or al, 2
    out 0x92, al

    ; 切换到保护模式
    cli
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp dword CODE_SELECTOR:protected_mode

[bits 32]
protected_mode:
    ; 初始化段寄存器（32位）
    mov ax, DATA_SELECTOR
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov ax, VIDEO_SELECTOR
    mov gs, ax
    mov ss, ax
    mov esp, 0x7c00

    ; 初始化变量
    mov byte [x], 0
    mov byte [y], 0
    mov byte [d], 0
    mov dword [c], 0
    mov dword [s], 0

main_loop:
    ; 方向判断
    cmp byte [d], 0
    je go_right
    cmp byte [d], 1
    je go_down
    cmp byte [d], 2
    je go_left
    cmp byte [d], 3
    je go_up

go_right:
    inc byte [x]
    cmp byte [x], 79
    jb show
    mov byte [d], 1
    dec byte [x]
    jmp show

go_down:
    inc byte [y]
    cmp byte [y], 24
    jb show
    mov byte [d], 2
    dec byte [y]
    jmp show

go_left:
    dec byte [x]
    cmp byte [x], 0
    jge show
    mov byte [d], 3
    inc byte [x]
    jmp show

go_up:
    dec byte [y]
    cmp byte [y], 0
    jge show
    mov byte [d], 0
    inc byte [y]

show:
    call print_char_32
    call delay_32
    jmp main_loop

print_char_32:
    ; 计算显存偏移 (y*80 + x)*2
    movzx eax, byte [y]
    mov ebx, 80
    mul ebx
    movzx ebx, byte [x]
    add eax, ebx
    shl eax, 1
    mov edi, eax

    ; 获取字符
    mov esi, chars
    add esi, [s]
    mov al, [esi]
    inc dword [s]
    cmp dword [s], 10
    jb .get_color
    mov dword [s], 0

.get_color:
    ; 获取颜色
    mov esi, cols
    add esi, [c]
    mov ah, [esi]
    inc dword [c]
    cmp dword [c], 11
    jb .print
    mov dword [c], 0

.print:
    ; 写入显存
    mov [gs:edi], ax
    ret

delay_32:
    mov ecx, 0x000FFFFF
.delay_loop:
    nop
    loop .delay_loop
    ret

; 数据段
x db 0
y db 0
d db 0
c dd 0
s dd 0
chars db "233363160123456789"
cols db 0x1E,0x2A,0x3C,0x36,0x02,0x6E,0x4E,0x5A,0x6C,0x7E,0x86

gdt_ptr:
    dw 0
    dd 0

times 1024-($-$$) db 0

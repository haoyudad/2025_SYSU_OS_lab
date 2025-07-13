org 0x7c00
[bits 16]
xor ax, ax ; eax = 0
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
mov sp, 0x7c00

; 初始化参数
mov bx, 0x7e00       ; 加载地址
mov cx, 5            ; 读取5个扇区
mov si, 1            ; 起始LBA扇区号(0-based)

load_bootloader:
    ; 将LBA转换为CHS (公式: C=(LBA/SPT)/HPC, H=(LBA/SPT)%HPC, S=(LBA%SPT)+1)
    mov ax, si
    xor dx, dx
    mov di, 63        ; SPT=63
    div di            ; AX=LBA/63, DX=LBA%63
    mov cl, dl        ; 临时保存S=(LBA%63)
    
    xor dx, dx
    mov di, 18        ; HPC=18
    div di            ; AX=(LBA/63)/18 (柱面), DX=(LBA/63)%18 (磁头)
    
    ; 组装CHS参数
    inc cl           ; S=(LBA%63)+1 (扇区号1-based)
    mov ch, al       ; 柱面号低8位
    mov dh, dl       ; 磁头号
    mov dl, 0x80     ; 驱动器号
    
    ; 调用BIOS读取扇区
    mov ah, 0x02     ; 功能号
    mov al, 1        ; 读1个扇区
    int 0x13
    jc $             ; 出错则死循环
    
    add bx, 512      ; 下一个内存位置
    inc si           ; 下一个LBA扇区
    loop load_bootloader

jmp 0x0000:0x7e00    ; 跳转到bootloader

times 510 - ($ - $$) db 0
db 0x55, 0xaa

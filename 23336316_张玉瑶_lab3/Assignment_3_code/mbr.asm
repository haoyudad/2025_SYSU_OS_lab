%include "boot.inc"

[bits 16]
org 0x7c00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; 加载bootloader
    mov ax, 1
    mov cx, 2
    mov bx, LOADER_START_ADDRESS

load_loop:
    push ax
    push bx
    call read_disk
    add sp, 4
    inc ax
    add bx, 512
    loop load_loop

    jmp 0:LOADER_START_ADDRESS

read_disk:
    push bp
    mov bp, sp
    pusha

    mov ax, [bp+6]
    mov dx, 0x1f3
    out dx, al
    inc dx
    mov al, ah
    out dx, al
    xor ax, ax
    inc dx
    out dx, al
    inc dx
    or al, 0xe0
    out dx, al

    mov dx, 0x1f2
    mov al, 1
    out dx, al
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.wait:
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .wait

    mov bx, [bp+4]
    mov cx, 256
    mov dx, 0x1f0
.read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .read

    popa
    pop bp
    ret

times 510-($-$$) db 0
dw 0xaa55

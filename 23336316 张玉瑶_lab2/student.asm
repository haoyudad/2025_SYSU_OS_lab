; If you meet compile error, try 'sudo apt install gcc-multilib g++-multilib' first

%include "head.include"
; you code here

your_if:
mov eax,[a1]
cmp eax,40
jge if_case

cmp eax,18
jge else_if

shl eax,5
mov [if_flag],eax
jmp end_program

if_case:
add eax,3
mov ecx,5
idiv ecx
mov [if_flag],eax
jmp end_program

else_if:
mov ebx,eax
shl ebx,1
mov eax,80
sub eax,ebx
mov [if_flag],eax
jmp end_program

end_program:
mov eax,0
xor ebx,ebx


; put your implementation here

your_while:
mov eax,[a2]

while_loop:
cmp ebx,25
jge end_loop
call my_random
shl ebx,1
mov ecx,[while_flag]
add ebx,ecx
mov [ebx],eax
mov ecx,[a2]
add ecx,1
mov [a2],ecx
mov ebx,[a2] 
jmp while_loop
end_loop:
%include"end.include"


your_function:
mov ecx,0
mov esi,[your_string]

for_loop:

mov al,[esi+ecx]
test al,al
je end_function

add al,9
push ecx
push eax
call print_a_char
add esp,4
pop ecx
inc ecx
jmp for_loop

end_function:
ret

; put your implementation here

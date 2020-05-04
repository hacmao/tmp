from winpwn import * 

p = process("test.exe") 
p.sendline("aaa\x0ebbbcc") 
p.interactive()


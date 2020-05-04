f = open("drop_file.sc", "rb")
data = f.read() 

from binascii import hexlify 
shellcode = hexlify(data) 
print(shellcode)
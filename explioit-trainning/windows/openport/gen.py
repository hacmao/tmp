f = open("openport.sc", "rb")
data = f.read() 

from binascii import hexlify 
shellcode = hexlify(data) 
print(shellcode)
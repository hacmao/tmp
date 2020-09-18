import re
import threading
import time
import string
import random
import base64
import socketserver as SocketServer
from Dsa import DSA_server


host, port = 'localhost', 31340

banner = b"""********************Welcome to server********************
1.Signed data
2.Verify
3.Public key
4.Exit
"""

invalid_mess=b"""
:::::::::::::::::::::
::                 ::
:: Invalid message ::
::                 ::
:::::::::::::::::::::
"""

valid_mess=b"""
:::::::::::::::::::::
::                 ::
::  Valid message  ::
::                 ::
:::::::::::::::::::::
"""
rx_signature = re.compile(b'\((.*),(.*)\)')
class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
	allow_reuse_address = True

class ThreadedTCPRequestHandler(SocketServer.BaseRequestHandler):
	def handle(self):
		server = DSA_server(2048)
		server.generate()
		while True:
			try:
				self.request.sendall(banner)
				choice = int(self.request.recv(1<<16).strip())
				if choice==1:
					self.request.sendall(b"Message: ")
					mess = self.request.recv(1<<16).strip()
					if b'Give me the flag!!' in mess:
						self.request.sendall(b"Wait,that illegal!\n")
						self.request.close()
						break
					signature = server.sign(mess)
					self.request.sendall(f"Signature: {signature}\n".encode())
				elif choice==2:
					self.request.sendall(b"Message: ")	
					mess = self.request.recv(1<<16).strip()
					self.request.sendall(b"Signature: ")
					signature = (int(i) for i in rx_signature.findall(self.request.recv(1<<16).strip())[0])
					if server.verify(mess,signature):
						self.request.sendall(valid_mess)
						if b'Give me the flag!!' in mess:
							self.request.sendall(f'Here you are {open("flag.txt").read()}\n'.encode())	
						else:	
							self.request.sendall(f'Your mess: {mess.decode()}\n'.encode())	
					else : self.request.sendall(invalid_mess)	
				elif choice==3:
					# self.request.sendall(b"Public key:\n")	
					self.request.sendall(f"{server}\n".encode())	
				else : 
					self.request.sendall(b"Bye bye\n")
					self.request.close()
					break
				
			except:
				try:
					self.request.sendall(b"Illegal input :(\n")
					self.request.close()
					break
				except:
					break
				
	
	
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
			
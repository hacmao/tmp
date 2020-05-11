from Crypto.Util.number import bytes_to_long  
import sys 

"""
convert a string into 64 bit ints 
"""
def convert(string) : 
    chunk = [] 
    for i in range(0, len(string), 8) : 
        chunk.append(hex(bytes_to_long(string[i:i+8][::-1]))) 
    return chunk 

if __name__ == "__main__" : 
    print(convert(sys.argv[1]))
 
    

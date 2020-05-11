del openport.obj
del openport.exe
del openport.sc 
nasm -f win64 openport.asm -o openport.obj
D:\program\Golink\Golink.exe /ENTRY:main  /console openport.obj
nasm -f bin .\openport.asm -o .\openport.sc 
py3 gen.py
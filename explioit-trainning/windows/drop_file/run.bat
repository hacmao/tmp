del drop_file.obj
del drop_file.exe
del drop_file.sc 
nasm -f win64 drop_file.asm -o drop_file.obj
D:\program\Golink\Golink.exe /ENTRY:main  /console drop_file.obj
nasm -f bin .\drop_file.asm -o .\drop_file.sc 
py3 gen.py
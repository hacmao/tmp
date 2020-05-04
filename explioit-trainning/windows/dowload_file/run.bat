del download_file.obj
del download_file.exe
del download_file.sc 
nasm -f win64 download_file.asm -o download_file.obj
D:\program\Golink\Golink.exe /ENTRY:main  /console download_file.obj
nasm -f bin .\download_file.asm -o .\download_file.sc
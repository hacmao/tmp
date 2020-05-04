del pop_calc.obj
del pop_calc.exe
nasm -f win64 pop_calc.asm -o pop_calc.obj
D:\program\Golink\Golink.exe /ENTRY:main  /console pop_calc.obj

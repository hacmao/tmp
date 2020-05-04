#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <windows.h> 

int main()
{
	VOID *a1, *a2, *a3, *a4, *a5 ; 
	int i;
//	HANDLE h = HeapCreate(0, 0x1000, 0x0); 
	HANDLE h = GetProcessHeap();
	a1 = HeapAlloc(h, 0, 0x40);
	a2 = HeapAlloc(h, 0, 0x40);
	a3 = HeapAlloc(h, 0, 0x40); 
//	a3 = HeapAlloc(h, 0, 0x40);
//	a4 = HeapAlloc(h, 0, 0x40);
//	a5 = HeapAlloc(h, 0, 0x40);
	
	memset(a2, 0, 0x40);
	memset(a1, 0, 0x40);
	memset(a3, 0, 0x40);
	
	printf("A1 = 0x%x\n", a1); 
	printf("A2 = 0x%x\n", a2); 
	HeapFree(h, 0, a2);
	a2 = HeapAlloc(h, 0, 0x40);
	printf("A2 = 0x%x\n", a2);
//	HeapFree(h, 0, a1);
//	HeapFree(h, 0, a3); 

//	printf("Link = [0x%x - 0x%x]\n", ((long int *)a1)[0], ((long int *)a1)[1]);
//	printf("Link = [0x%x - 0x%x]\n", ((long int *)a2)[0], ((long int *)a2)[1]);
//	printf("New = 0x%x\n", HeapAlloc(h, 0, 0x60)); 
//	HeapFree(h, 0, a2);
//	printf("0x%x\n", HeapAlloc(h, 0, 0x40));
//	printf("0x%x\n", HeapAlloc(h, 0, 0x40));
//	printf("Link = [0x%x - 0x%x]\n", ((long int *)a1)[0], ((long int *)a1)[1]);
//	printf("Link = [0x%x - 0x%x]\n", ((long int *)a2)[0], ((long int *)a2)[1]);
	printf("Double free is not detected!!!");
}



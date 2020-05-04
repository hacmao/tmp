#include <stdio.h> 
#include <stdlib.h> 
int main() 
{ 
	FILE * fp; 
	fp = fopen ("baitapc.txt", "w+"); 
	fprintf(fp, "abc"); 
	fclose(fp); 
	return(0); 
}



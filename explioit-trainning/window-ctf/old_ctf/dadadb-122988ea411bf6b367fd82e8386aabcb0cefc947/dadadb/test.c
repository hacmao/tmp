#include <stdio.h>
#include <stdlib.h> 

int main()
{
	FILE * fp = NULL; 
	char * buf = (char * ) malloc(0x40);
	char msg[0x40];
	memset(msg, 0x0, 0x40); 
	fopen_s(&fp, "flag.txt", "w");
	
	((struct file_stream*)fp)->_flags = 0x2080;
	((struct file_stream*)fp)->_cnt = 0; 
	((struct file_stream*)fp)->_base = msg;
	((struct file_stream*)fp)->_bufsize = 0x30; 
	((struct file_stream*)fp)->_file = 0x0;
	fread(buf, 1, 6, fp); 
	printf("msg:%s\n", msg);
	return 0;
}

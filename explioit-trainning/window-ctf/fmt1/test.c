#include <stdio.h>

int main()
{
	char buf[1000];
	while(1)
	{
		printf("INput : ");
		scanf("%399s", buf);
		printf(buf);
	}
	return 0;
}

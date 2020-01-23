#include <stdio.h>           /* printf */

main ()
{
    int i;


    for (i = 0; i < 5; i++) {
        printf("i = %d\t", i);
    }
    sleep(2);
    putchar('\n');
    return 0;	
}

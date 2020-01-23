#include <stdio.h>           /* getc, printf */

main ()
{
    int c;

    
    do {
        c = getchar();
        printf("<%c (%d)>\n", c, c);
    } while (c != EOF);
    printf("\n---< Normal shutdown >---\n");
    return 0;
}


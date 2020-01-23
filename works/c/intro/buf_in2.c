#include <stdio.h>

main ()
{
    int c;


    fprintf(stderr, "Enter string: "); fflush(stderr);
    do {
        c = getchar();
        printf("<%c (%d)>\n", c, c);
    } while (c != '\n' && c != EOF);
    fprintf(stderr, "\n---< Normal shutdown >---\n");
    return 0;
}

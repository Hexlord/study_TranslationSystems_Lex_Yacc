/*
 *  List of integers 1,2,3 etc. 
 *  Task: parse list, calculate number of items and average value
 */

#include <stdio.h>
#include "scanner.h"

int chk_1[] = { NUM, 0 };
int chk_2[] = { ',', ';', 0 };

int main (void)
{
    int token, counter, total;
    

    if (!rd_token(chk_1)) {         /* get number or EOF */
        printf("Empty list\n");     /* EOF is OK here */
        return 0;
    }
    for (counter = total = 0;;) { 
        counter++;
        total += yylval;

        if (!rd_token(chk_2))       /* get comma (or EOF) */
            break;          /* EOF is OK, means end of list */

        if (!rd_token(chk_1))       /* number (or EOF) */
            bad_eof();      /* EOF not allowed here! */
    }

    printf("no. of items = %d, average = %d", counter, total/counter); 
    return 0;
}


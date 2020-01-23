#include <stdio.h>
#include <stdlib.h>
#include "nest.h"

t_list  lists[8];
int     level = 0;

void open_list (int dup)
{
    t_list *p = &lists[level++];
    p->dup    = dup;
    p->inx    = 0;
    p->area   = (int *)calloc(512, sizeof(int));
    if (p->area == NULL) 
        exit(1);
}

void append (int item)
{
    t_list *p = &lists[level-1];
    p->area[p->inx++] = item;
}

void close_list ()
{
    int i, j, x;
    t_list * p = &lists[--level];

    for (i = 0; i < p->dup; i++) {
        for (j = 0; j < p->inx; j++) {
            x = p->area[j];
            if (level) 
                append(x);
            else 
                printf("%d ", x);
        }
    }
    free(p->area);
}


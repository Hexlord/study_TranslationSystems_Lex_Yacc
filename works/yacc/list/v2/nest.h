#ifndef __NEST_H__
#define __NEST_H__

typedef struct
{
    int   dup, inx;
    int   * area;
} t_list;

void open_list (int dup); 
void append (int item);
void close_list ();

#endif


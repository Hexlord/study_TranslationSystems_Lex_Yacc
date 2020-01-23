%%
^[b-df-hj-np-tv-z]+[ \t]*$  { ECHO; printf( "\n" ); }
.|\n       ;
%%

#include "yy.c"

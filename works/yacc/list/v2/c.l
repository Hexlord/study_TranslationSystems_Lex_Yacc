%{
#include <stdlib.h>
#include "y.tab.h"

#define YYSTYPE int
extern YYSTYPE yylval;    /* value of numeric token */
%}
 
%%
dup     return DUP; 
[0-9]+  { yylval = atoi(yytext); return NUM; }
\n      return '\n'; 
[ \t]+  ;
.       return yytext[0];
%%

#ifndef yywrap
int yywrap () { return 1; }
#endif


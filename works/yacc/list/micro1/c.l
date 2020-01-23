%{
#include <stdlib.h>
#include "y.tab.h"

#define YYSTYPE int
extern YYSTYPE yylval;    /* value of numeric token */
%}
      
%%
[0-9]+  { yylval = atoi(yytext); return NUM; }
[ \t]      return '\n'; 
.|\n       {return yytext[0];}
%%

#ifndef yywrap
int yywrap () { return 1; }
#endif


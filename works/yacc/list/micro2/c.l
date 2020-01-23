%{
#include <string.h>
#include "y.tab.h"
%}

%%
[0-9]+		{ return NUMBER; }
[a-z]+		{ return LETTER; }
',' 		{ return ',';}
'\('		{ return '('; }
'\)'		{ return ')'; }
\n		return '\n';
[ ]		;
.		return yytext[0];
%%

#ifndef yywrap
int yywrap() { return 1; }
#endif
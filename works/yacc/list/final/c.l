%{
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
extern YYSTYPE yylval;
%}

%%
[0-9]		{ yylval.character = atoi(yytext);	return DIGIT; }
"int"		return INT;
"++"	return DOUBLE_PLUS;
"--"	return DOUBLE_MINUS;
"="		return yytext[0];
"+"		return yytext[0];
"-"		return yytext[0];
"/"		return yytext[0];
"*"		return yytext[0];
" "		return yytext[0];
"("		return yytext[0];
")"		return yytext[0];
"["		return yytext[0];
"]"		return yytext[0];
"&"		return yytext[0];
\n		return '\n';
[a-zA-Z]		{ yylval.digit = yytext[0]; return LETTER; }
%%

#ifndef yywrap
int yywrap() { return 1; }
#endif
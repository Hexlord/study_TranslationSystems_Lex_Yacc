#include <stdio.h>
#include "scanner.h"

int main (void)
{
    int token;

    do {
        token = yylex();
        fprintf(stderr, "token\t");
        prn_token(token);
        fprintf(stderr, "\tyytext %s\tyyleng %d\tyylval %d\n", 
            yytext, yyleng, yylval);
    } while (token);
    return 0;
}


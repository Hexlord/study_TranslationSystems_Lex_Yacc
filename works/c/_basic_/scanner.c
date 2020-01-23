#include <stdio.h>
#include <ctype.h>
#include "scanner.h"

/* ------- Global data ------- */

char    yytext[1024];
int     yyleng;
YYSTYPE yylval;

/* ------- Local macros and functions ------- */

#define unput(c) { ungetc(c, stdin); yytext[--yyleng] = 0; }

/*
 *  Read and save a char from stdio, used by __yylex()
 */
static int input ()
{
    int c;

    c = getchar();
    if (c == EOF) c = 0;
    yytext[yyleng++] = c;
    return c;
}

/*
 *  Get next token from stdio, used by yylex()
 */
static int __yylex ()
{
    int c, state;


    for (state = 0; ; ) {
        c = input();
        switch(state) {
          case 0:               /* skip whitespaces */
            if (isspace(c)) {   
                yyleng = 0;
                break;
            }               

            if (isalpha(c)) {
                state = 1;      /* treat next chars as Identifier */
                break;
            }
            if (isdigit(c)) {   
                state = 2;      /* treat next chars as Number */
                break;
            }

            return c;           /* return one-char Literal */

          case 1:               /* build Identifier */
            if (!isalnum(c)) {
                unput(c);
                return ID;
            }               
            break;

          case 2:               /* build Number */
            if (!isdigit(c)) {
                unput(c);
                yylval = atoi(yytext);  /* calculate the value */
                return NUM;
            }
            break;

          default:
            fprintf(stderr, "\nFatal error: yylex is in unknown state\n");
            exit(1);        
        }
    }
}

/* ------- Global functions: scanning and printing ------- */

/*
 *  Interface function to get next token from stdio
 */
int yylex()
{
    int token;

    yyleng = 0;
    token = __yylex();
    yytext[yyleng] = 0;     /* zero-end the string */
    return token;
}   

/* 
 *  Print the token, as char or, if invisible, as decimal ASCII 
 */
int prn_token (int token)
{
    fprintf(stderr, isprint(token) ? "'%c' " : "\\%d ", token);
    return token;
}   

/* ------- Global functions: helpers for parsing ------- */

/*  
 *  Check token against a set of tokens (zero ended) 
 */
int in (int token, int *p)
{
    for (; (*p) && (*p != token); p++);
    return (*p == token);
}

/*
 *  Check token against a set of tokens, with error report and abortion
 */
int chk_token (int token, int *p)
{
    if (!in(token, p)) {
        fprintf(stderr, "Token ");
        prn_token(token);
        fprintf(stderr, "\nExpected ");
        for (; *p; p++)
            prn_token(*p);
        fprintf(stderr, "\n");
        exit(1);
    }
    return token;
}

/*  
 *  Get next token, check-abort (see chk_token)
 */
int rd_token (int *p)
{
    return chk_token(yylex(), p);
}

/* 
 *  Print error message in case of misplaced EOF, abortion
 */
void bad_eof (void)
{
    fprintf(stderr, "Error: Unexpected EOF\n");
    exit(1);
}
   

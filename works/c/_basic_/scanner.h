#ifndef __SCANNER_H__
#define __SCANNER_H__

#include <limits.h>

/* ------- Token definitions ------- */

enum { NUM = UCHAR_MAX + 1, ID };   /* starts from 256 */

/* ------- Type of yylval -------- */

typedef int YYSTYPE; 

/* ------- Global data ------- */

extern char     yytext[];
extern int      yyleng;
extern YYSTYPE  yylval;

/* ------- Global functions ------- */

int yylex (void);

int in (int, int *);
int prn_token (int);
int chk_token (int, int *);
int rd_token (int *);
void bad_eof (void);

#endif


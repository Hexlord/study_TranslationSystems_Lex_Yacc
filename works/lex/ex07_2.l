%{
void skip_comments();
%}

D   [0-9]
H   [0-9A-Fa-f]
L   [_A-Za-z]

%%
{L}({L}|{D})*   printf( "ident: %s\n", yytext );
0{H}+(H|h)?     |
{D}{H}*(H|h)    printf( "hex: %s\n", yytext );
{D}+            printf( "decimal: %s\n", yytext );
"/*"            skip_comments();
.               ;
%%

void skip_comments()
{
    int c = input();	/* not char! */

	while(c != EOF && c != 0)
	{
		while(c != '*' && c != EOF && c != 0)
		{
			c = input();	/* skip until star */
		}

		while(c == '*' && c != EOF && c != 0)
		{
			c = input();	/* skip multiple stars */
		}

		if(c == '/')
		{
			return;
		}
	}

    
    fprintf(stderr, "?-EOF in comment\n");
    exit(1);
    
}

#include "yy.c"


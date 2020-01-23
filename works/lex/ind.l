%{

/*
^{C}{OP}{C}$  { printf( "распознано: " ); ECHO; printf( "\n" ); convert_to_c(); }

^.+$   { printf( "не распознано: " ); ECHO; printf( "\n" ); }
*/

void number_sanitized_print(char* str, int is_float);
void convert_to_c();

int step=0;

int is_left_float;
int is_right_float;
char* left=0;
char* op=0;
char* origin_op=0;
char* right=0;

/*
#define YY_USER_ACTION { fprintf(stderr, "<%d>", YYSTATE); }
*/
%}

%START c1 c2

CF   (\+|\-)?(\.([0-9]+)|([0-9]+)\.|([0-9]+)\.([0-9]+))
CI   (\+|\-)?([0-9]+)
C   ({CF}|{CI})
OPB (GT|LT|LE|GE|NE|EQ)
OP  (\.{OPB}\.)
DS  (.*(\+\+|\-\-|\+\-|\-\+).*)
DD  (.*\..*\..*)

%%
^{DS}{OP}{C}|{C}{OP}{DS}$  { printf( "два знака подряд: " ); ECHO; printf( "\n" ); }
^{C}\.{OP}{C}|{C}{OP}\.{C}|{C}\.{OP}\.{C}$  { printf( "лишняя точка в предложении: " ); ECHO; printf( "\n" ); }
^{DD}{OP}{C}|{C}{OP}{DD}|{DD}{OP}{DD}$  { printf( "две точки в одном числе: " ); ECHO; printf( "\n" ); }

^{CF}  { left = strdup(yytext); is_left_float = 1; BEGIN c1; }
^{CI}  { left = strdup(yytext); is_left_float = 0; BEGIN c1; }
<c1>\.GT\.  {origin_op=".GT."; op = " > "; BEGIN c2;}
<c1>\.LT\.  {origin_op=".LT."; op = " < "; BEGIN c2;}
<c1>\.LE\.  {origin_op=".LE."; op = " >= "; BEGIN c2;}
<c1>\.GE\.  {origin_op=".GE."; op = " >= "; BEGIN c2;}
<c1>\.NE\.  {origin_op=".NE."; op = " != "; BEGIN c2;}
<c1>\.EQ\.  {origin_op=".EQ."; op = " == "; BEGIN c2;}
<c2>{CF}$ { right = strdup(yytext); is_right_float = 1; convert_to_c(); BEGIN 0;}
<c2>{CI}$ { right = strdup(yytext); is_right_float = 0; convert_to_c(); BEGIN 0;}
<c2>.+$	  { printf("%s", left); printf("%s", origin_op); ECHO; BEGIN 0; }
%%

void number_sanitized_print(char* str, int is_float)
{
	int len = strlen(str);
	int is_signed = (str[0] == '+' || str[0] == '-') ? 1 : 0;
	if(is_float == 0 && str[len-1] == '.')
		str[len-1] = 0;

	if(is_signed) printf("%c", str[0]);
	if(is_float == 1 && str[0 + is_signed] == '.')
		printf("0");
	printf("%s", str + is_signed);
	if(str[len-1] == '.')
		printf("0");
}

void convert_to_c()
{
	number_sanitized_print(left, is_left_float);
	printf("%s", op);
	number_sanitized_print(right, is_right_float);

	free(left);
	free(right);

	printf("\n");

}

#include "yy.c"
#include <string.h>


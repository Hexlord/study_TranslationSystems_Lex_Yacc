%{
#include <string.h>
int numberOfIds = 0;
int numberOfNumbers = 0;
int numberOfSublists = 0;
int lineNumber = 1;
%}

%token LETTER
%token NUMBER
%token ID
%start lines

%%
lines:	line
	| lines line
	;

line:	id			{ numberOfIds++; }
	| wrongId		{}
	| NUMBER		{ numberOfNumbers++; }
	| sublist		{ numberOfSublists++; numberOfIds++; numberOfNumbers++; }
	| line ',' id		{ numberOfIds++; }
	| line ',' wrongId	{}
	| line ',' NUMBER	{ numberOfNumbers++; }
	| line ',' sublist	{ numberOfSublists++; numberOfIds++; numberOfNumbers++; }
	| line '\n'		{ printResult(); resetParams(); }
	;

sublist:
	'(' id ',' NUMBER ')'	{}
	| '(' NUMBER ',' id ')'	{}
	| '(' id ',' id ')'	{}
	;

id:
	LETTER
	| id LETTER
	| id NUMBER
	;

wrongId:
	NUMBER id
	;

%%

void resetParams() {
	numberOfIds = 0;
	numberOfNumbers = 0;
	numberOfSublists = 0;
}

void printResult() {
	//определяем подходящее слово
	char* ids;
	switch ( numberOfIds%10 ){
	case 1: ids = "идентификатор"; break;
	case 2: ids = "идентификатора"; break;
	case 3: ids = "идентификатора"; break;
	case 4: ids = "идентификатора"; break;
	case 5: ids = "идентификаторов"; break;
	case 6: ids = "идентификаторов"; break;
	case 7: ids = "идентификаторов"; break;
	case 8: ids = "идентификаторов"; break;
	case 9: ids = "идентификаторов"; break;
	default: ids = "идентификаторов"; break; }

	char* numbers;
	switch ( numberOfNumbers%10 ){
	case 1: numbers = "число"; break;
	case 2: numbers = "числа"; break;
	case 3: numbers = "числа"; break;
	case 4: numbers = "числа"; break;
	case 5: numbers = "чисел"; break;
	case 6: numbers = "чисел"; break;
	case 7: numbers = "чисел"; break;
	case 8: numbers = "чисел"; break;
	case 9: numbers = "чисел"; break;
	default: numbers = "чисел"; break; }

	char* sublists;
	switch ( numberOfSublists%10 ){
	case 1: sublists = "подсписок"; break;
	case 2: sublists = "подсписка"; break;
	case 3: sublists = "подсписка"; break;
	case 4: sublists = "подсписка"; break;
	case 5: sublists = "подсписков"; break;
	case 6: sublists = "подсписков"; break;
	case 7: sublists = "подсписков"; break;
	case 8: sublists = "подсписков"; break;
	case 9: sublists = "подсписков"; break;
	default: sublists = "подсписков"; break; }

	printf("В строке %d содержатся %d %s, %d %s, %d %s.\n", lineNumber++, numberOfIds, ids, numberOfNumbers, numbers, numberOfSublists, sublists);
} 
%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

char* char_to_str(char c);
void printStatement();
void printResult();
void push_result(char* str, int type); // type = 1->point to (&); type = 2->deref (*)
void push_op(char op);
void push_lb();
void push_rb();
int is_debug = 0;
void debug();
int is_op(char* str);
int priority_of(char c);
void printOp(char* opa, char* opb, char op, char* out);
char* construct_var(int number);

int statement_type = 0; // 0 = assignment; 1 = array assignment; 2 = int; 3 = int*; 4 = deref assignment;
int statement_assignment_array_offset = 0;
char* statement_variable = 0;

char id_buffer[256] = {0};
int id_length = 0;

int current_number = 0;

int stack_length = 0;
char stack[256] = {0};

int result_length = 0;
char* results[256] = {0};
int result_types[256] = {0};

char output[4096] = {0};

int line_number = 1;

int indention = 0;
int brace_number = 0;
int error_brace_number = 0;
int error_double_plus = 0;
int error_double_minus = 0;

int var = 0;

int exec_length = 0;
char* execs[256] = {0};

%}

%union
{
	char character;
	int digit;
}

%token <text>DIGIT
%token <text>LETTER
%token <text>INT
%token <text>DOUBLE_PLUS
%token <text>DOUBLE_MINUS
%start line

%%
line:	statement
	| line statement
	| line '\n'	{ printStatement(); }
	;

statement:
	left '=' right 
	;


right:
	right_elem
	| right right_elem
	;

right_elem:
	DOUBLE_PLUS {error_double_plus = 1;}
	| DOUBLE_MINUS {error_double_minus = 1;}
	| op
	| number {char buf[256]; sprintf(buf,"%d",current_number);  push_result(strdup(buf), 0);}
	| '&' id {push_result(strdup(id_buffer), 1);}
	| '*' id {push_result(strdup(id_buffer), 2);}
	| id {push_result(strdup(id_buffer), 0);}
	| '(' {push_lb();}
	| ')' {push_rb();}
	;

op:
	'+' {push_op('+');}
	| '-' {push_op('-');}
	| '*' {push_op('*');}
	| '/' {push_op('/');}
	;

left:
	INT '*' ' ' id {statement_type = 3; statement_variable = strdup(id_buffer);}
	| '*' id {statement_type = 4; statement_variable = strdup(id_buffer);}
	| INT ' ' id {statement_type = 2; statement_variable = strdup(id_buffer);}
	| id '[' number ']' {statement_type = 1; statement_assignment_array_offset = current_number; statement_variable = strdup(id_buffer);}
	| id {statement_type = 0; statement_variable = strdup(id_buffer);}
	;

id:
	LETTER {id_length = 0; id_buffer[id_length++] = $<character>1; id_buffer[id_length] = 0;}
	| id LETTER {id_buffer[id_length++] = $<character>2; id_buffer[id_length] = 0;}
	| id DIGIT {id_buffer[id_length++] = $<digit>2 + '0'; id_buffer[id_length] = 0;}
	;

signed:
	'-' number {current_number = -current_number;}
	| number
	;

number:
	DIGIT {current_number = $<digit>1;}
	| number DIGIT {current_number = current_number * 10 + $<digit>2;}
	;

%%
char* char_to_str(char c)
{
	char buf[2];
	buf[0] = c;
	buf[1] = 0;
	return strdup(buf);
}

void push_result(char* str, int type)
{
	debug();
	if(is_debug) printf("pushing to result: %s of type %d\n", str, type);

	if(strcmp(str, "(") == 0 
	|| strcmp(str, ")") == 0)
	{
		return; // ignore braces in output
	}

	results[result_length] = str;
	result_types[result_length] = type;
	++result_length;
}

void push_op(char op)
{
	debug();
	if(is_debug) printf("pushing op to stack: %s\n", char_to_str(op));

	int prior = priority_of(op);

	if(stack_length != 0)
	{
		for(int i = stack_length - 1; i >= 0; --i)
		{
			char op_i = stack[i];

			if(is_debug) printf("[%d/%d] comparing priorities: %s->%d ? %s->%d\n", i, stack_length-1, char_to_str(op_i), priority_of(op_i), char_to_str(op), prior);

			if(priority_of(op_i) >= prior)
			{
				push_result(char_to_str(op_i), 0);

				--stack_length;
				stack[stack_length] = 0;
			} else break;
		}
	}
	stack[stack_length++] = op;
}

void push_lb()
{
	debug();
	if(is_debug) printf("pushing left brace\n");
	++brace_number;
	++indention;

	stack[stack_length++] = '(';
}

void push_rb()
{
	debug();
	if(is_debug) printf("pushing right brace\n");
	++brace_number;
	--indention;
	if(error_brace_number == 0 && indention < 0)
	{
		error_brace_number = brace_number;
	}

	for(int i = stack_length - 1; i>=0; --i)
	{
		char op_i = stack[i];
		--stack_length;
		stack[stack_length] = 0;
		if(op_i == '(') break;
		push_result(char_to_str(op_i), 0);
	}
}

int priority_of(char c)
{

	switch(c)
	{
	case '(': return 0;
	case ')': return 1;
	case '+':
	case '-': return 2;
	case '*':
	case '/': return 3;
	}

	return -1;
}

int is_op(char* str)
{
	return strlen(str) == 1 && priority_of(str[0]) > 1;
}

void printOp(char* opa, char* opb, char op, char* out)
{
	if(op == '+')
	{
		sprintf(output + strlen(output), "mov eax, %s\n", opa);
		sprintf(output + strlen(output), "add eax, %s\n", opb);
		sprintf(output + strlen(output), "mov %s, eax\n", out);
	} else if(op == '-')
	{
		sprintf(output + strlen(output), "mov eax, %s\n", opa);
		sprintf(output + strlen(output), "sub eax, %s\n", opb);
		sprintf(output + strlen(output), "mov %s, eax\n", out);
	} else if(op == '/')
	{
		sprintf(output + strlen(output), "mov eax, %s\n", opa);
		sprintf(output + strlen(output), "mov ebx, %s\n", opb);
		sprintf(output + strlen(output), "idiv %s, ebx\n", out);
	} else if(op == '*')
	{
		sprintf(output + strlen(output), "mov eax, %s\n", opa);
		sprintf(output + strlen(output), "mov ebx, %s\n", opb);
		sprintf(output + strlen(output), "imul %s, ebx\n", out);
	}
}

void debug()
{
	if(!is_debug) return;
	printf("--stack(%d): %s; results(%d): ", stack_length, stack, result_length);
	for(int i = 0; i < result_length; ++i)
	{
		printf("%s", results[i]);
	}
	printf("\n");
}

char* construct_var(int number)
{
	char buf[128];
	buf[0] = 0;
	strcpy(buf, "[array+");
	char buf2[256];
	sprintf(buf2,"%d",number * 4);
	strcat(buf, buf2);
	strcat(buf, "]");
	return strdup(buf);
}

void printResult()
{
	output[0] = 0;
	sprintf(output, "array times 256 resb 1\n");

 	if(statement_type >= 2 && statement_type <= 3)
 	{
 		sprintf(output + strlen(output), "%s DD 0\n", statement_variable);
 	}
	var = -1;

	// unwind remaining stack
	for(int i = stack_length - 1; i>=0; --i)
	{
		char op_i = stack[i];
		push_result(char_to_str(op_i), 0);
		--stack_length;
		stack[stack_length] = 0;
	}

	int op_i = result_length - 1;

	for(int i = 0; i < result_length; ++i)
	{
		char* str = results[i];
		int type = result_types[i];
		int isop = is_op(str);

		if(is_debug) printf("[%d/%d] var:%d current:%s==\n", i, result_length-1, var, str);

		if(isop)
		{
			if(exec_length >= 2)
			{
				++var;
				char* var_str = construct_var(var);
				printOp(execs[exec_length-2],execs[exec_length-1],str[0],var_str);
				--exec_length;
				execs[exec_length-1] = var_str;
			} else
			{
				printf("Бинарная операция не следует за двумя операндами на строке %d", line_number);
					return;
			}

			

		} else
		{
			char buffer[256]={0};
			if(type == 1) strcat(buffer, "OFFSET ");
			else if(type == 2) strcat(buffer, "[");
			strcat(buffer, str);
			if(type == 2) strcat(buffer, "]");
			execs[exec_length++] = strdup(buffer);
		}
	}

	if(exec_length > 1)
	{
		printf("Лишние операнды на строке %d", line_number);
					return;
	}

	if(statement_type == 1)
 	{
 		sprintf(output + strlen(output), "mov [%s+%d], %s\n", statement_variable, statement_assignment_array_offset, execs[0]);
 	} 
 	else if(statement_type == 4)
 	{
 		sprintf(output + strlen(output), "mov [%s], %s\n", statement_variable, execs[0]);
 	} 
 	else
 	{
 		sprintf(output + strlen(output), "mov %s, %s\n", statement_variable, execs[0]);
 	}

	printf("%s", output);
}

void printStatement() {
	if(error_brace_number == 0 && indention > 0)
	{
		error_brace_number = brace_number;
	}

	if(error_brace_number != 0)
	{
		char* error = indention > 0 
		? "Незакрытая скобка"
		: "Лишняя закрывающая скобка";
		printf("%s под номером %d на строке %d\n", error, error_brace_number, line_number);
	} else if(error_double_plus)
	{
		printf("Два плюса подряд на строке %d\n", line_number);
	} else if(error_double_minus)
	{
		printf("Два минуса подряд на строке %d\n", line_number);
	} else
	{
		printResult();
	}

	// reset
	statement_type = 0; // 0 = assignment; 1 = array assignment; 2 = int; 3 = int*; 4 = deref assignment;
	statement_assignment_array_offset = 0;
	current_number = 0;
	stack_length = 0;
	result_length = 0;
	indention = 0;
	brace_number = 0;
	error_brace_number = 0;
	error_double_plus = 0;
	error_double_minus = 0;
	var = 0;
	exec_length = 0;

	++line_number;
}

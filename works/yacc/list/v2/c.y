%{
#include "nest.h"
#define YYSTYPE int
YYSTYPE num;
%}

%token NUM DUP
%start _list

%%
_list:  { open_list(1); } list { close_list(); }

list:   '\n'
    |   n_list '\n'
    ;

atom:   NUM  { append($1); }
    |   '?'  { append(0); }
    ;

item:   atom
    |   NUM 
        { open_list ($1); }
        DUP 
        dup_list    
        { close_list (); }
    ;

dup_list: atom
        | '(' n_list ')'    
        ;

n_list: item
      | item ',' n_list
      ; 
%%

#if 0
main() 
{ 
  int err_code;

  open_list(1); err_code = yyparse(); close_list();
  return err_code;
}
#endif

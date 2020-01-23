%token NUM
%start __list

%%
__list: _list    ;
    | _list '\n' __list ;

_list: { $$ = 0; }
      | list {printf("No. of items: %d\n", $$);}

list:	{ $$ = 0; } 
	| NUM       { $$ = 1; }           
    | NUM ',' list { $$ = $3 + 1;}
%%


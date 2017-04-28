%{

%}

%token <int> NUM
%token NEWLINE
%token PCNF
%token EQ
%token NEQ

%start file
%type <Ast.instance_t> file

%%

literal:
	a=NUM EQ b=NUM { Ast.L_Eq (a,b) }
|	a=NUM NEQ b=NUM { Ast.L_NEq (a,b) }
;

clause:
	c=literal+ { c }
;

instance:
	i=separated_nonempty_list(NEWLINE+,clause) { i }
;

file:
	NEWLINE* PCNF v=NUM c=NUM NEWLINE+ i=instance {
		Ast.({n_var = v; n_clause = c; clauses = i})
	}
;


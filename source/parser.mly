%{

%}

%token <int> NUM
%token NEWLINE
%token PCNF
%token EQ
%token NEQ
%token MINUS
%token EOF

%start file
%type <Ast.instance_t> file

%start sat_file
%type <Sat.instance_t> sat_file

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
	NEWLINE* PCNF v=NUM c=NUM NEWLINE+ i=instance EOF {
		Ast.({n_var = v; n_clause = c; clauses = i})
	}
;

sat_literal:
	a=NUM { Sat.Var a }
|	MINUS a=NUM { Sat.Neg a }
;

sat_clause:
	c=sat_literal+ { c }
;

sat_instance:
	i=separated_nonempty_list(NEWLINE+,sat_clause) { i }
;

sat_file:
	NEWLINE* PCNF v=NUM c=NUM NEWLINE+ i=sat_instance EOF {
		Sat.({n_var = v; n_clause = c; clauses = i})
	}
;


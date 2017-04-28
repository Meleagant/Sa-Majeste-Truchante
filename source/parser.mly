%{
	let perr s e = begin
		Format.printf "Parser error, line %i characters %i-%i@."
			Lexing.(s.pos_lnum)
			Lexing.(s.pos_cnum - s.pos_bol)
			Lexing.(e.pos_cnum - s.pos_bol);
		exit 0
	end
%}

%token <int> NUM
%token NEWLINE
%token END
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
	a=NUM EQ b=NUM { Ast.L_Eq (a-1,b-1) }
|	a=NUM NEQ b=NUM { Ast.L_NEq (a-1,b-1) }
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
| error { perr $startpos $endpos }
;

sat_literal:
	a=NUM { Sat.Var (a-1) }
|	MINUS a=NUM { Sat.Neg (a-1) }
;

sat_clause:
	c=sat_literal+ END { c }
;

sat_instance:
	c=sat_clause { [c] }
|	s=sat_instance NEWLINE c=sat_clause { c :: s }
;

sat_file:
	NEWLINE* PCNF v=NUM c=NUM NEWLINE+ i=sat_instance NEWLINE* EOF {
		Sat.({n_var = v; n_clause = c; clauses = i})
	}
| error { perr $startpos $endpos }
;


%{
	let perr s e = begin
		Format.printf "Parser error, line %i characters %i-%i@."
			Lexing.(s.pos_lnum)
			Lexing.(s.pos_cnum - s.pos_bol)
			Lexing.(e.pos_cnum - s.pos_bol);
		exit 0
	end
%}

%token PCNF
%token <int> NUM
%token ZERO
%token MINUS
%token EOF

%start file
%type <Sat.instance_t> file

%%

literal:
	a=NUM { Sat.Var (a-1) }
|	MINUS a=NUM { Sat.Neg (a-1) }
;

clause:
	c=literal+ ZERO { c }
;

instance:
	c=clause { [c] }
|	s=instance c=clause { c :: s }
;

file:
	PCNF v=NUM c=NUM i=instance EOF {
		Sat.({n_var = v; n_clause = c; clauses = i})
	}
| error { perr $startpos $endpos }
;


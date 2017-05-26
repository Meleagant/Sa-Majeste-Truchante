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
%token PCNF
%token EQ
%token NEQ
%token EOF

%start file
%type <Theory_equality.t list list> file

%%

literal:
	a=NUM EQ b=NUM { Theory_equality.A_Eq (a-1,b-1) }
|	a=NUM NEQ b=NUM { Theory_equality.A_NEq (a-1,b-1) }
;

clause:
	c=literal+ NEWLINE+ { c }
;

file:
	NEWLINE+ PCNF NUM NUM NEWLINE+ i=clause+ EOF { i }
| error { perr $startpos $endpos }
;


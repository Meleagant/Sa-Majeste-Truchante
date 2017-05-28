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
%token LT
%token LE
%token EQ
%token GE
%token GT
%token NEQ
%token EOF

%start file
%type <Theory_inequality.t list list> file

%%

literal:
	a=NUM LT b=NUM { Theory_inequality.([A_Lt (a-1,b-1)]) }
|	a=NUM LE b=NUM { Theory_inequality.([A_Lt (a-1,b-1); A_Eq (a-1,b-1)]) }
|	a=NUM EQ b=NUM { Theory_inequality.([A_Eq (a-1,b-1)]) }
|	a=NUM GE b=NUM { Theory_inequality.([A_Lt (b-1,a-1); A_Eq (a-1,b-1)]) }
|	a=NUM GT b=NUM { Theory_inequality.([A_Lt (b-1,a-1)]) }
|	a=NUM NEQ b=NUM { Theory_inequality.([A_NEq (a-1,b-1)]) }
;

clause:
	c=literal+ NEWLINE+ { List.flatten c }
;

file:
	NEWLINE+ PCNF NUM NUM NEWLINE+ i=clause+ EOF { i }
| error { perr $startpos $endpos }
;


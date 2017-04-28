{
	open Lexing
	open Parser
}

rule token = parse

| [' ' '\t'] { token lexbuf }
| "c" [^ '\n']* { token lexbuf }
| "\n" { new_line lexbuf ; NEWLINE }
| "p" (' ')+ "cnf" { PCNF }
| ['1' - '9'] (['0' - '9'])* as n { NUM (int_of_string n) }
| "0" { END }
| "=" { EQ }
| "<>" { NEQ }
| "-" { MINUS }
| eof { EOF }
| _ { token lexbuf }


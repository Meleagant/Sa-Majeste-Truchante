{
	open Lexing
	open Sat_parser
}

rule token = parse

| [' ' '\t'] { token lexbuf }
| "c" [^ '\n']* { token lexbuf }
| '\n' { new_line lexbuf ; token lexbuf }
| "p" (' ')+ "cnf" { PCNF }
| ['1' - '9'] (['0' - '9'])* as n { NUM (int_of_string n) }
| "0" { ZERO }
| "-" { MINUS }
| eof { EOF }
| _ { token lexbuf }


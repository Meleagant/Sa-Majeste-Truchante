{
	open Lexing
	open Theory_inequality_parser
}

rule token = parse

| [' ' '\t'] { token lexbuf }
| "c" [^ '\n']* { token lexbuf }
| "\n" { new_line lexbuf ; NEWLINE }
| "p" (' ')+ "cnf" { PCNF }
| (['0' - '9'])* as n { NUM (int_of_string n) }
| "<" { LT }
| "<=" { LE }
| "=" { EQ }
| ">=" { GE }
| ">" { GT }
| "<>" { NEQ }
| eof { EOF }
| _ { token lexbuf }


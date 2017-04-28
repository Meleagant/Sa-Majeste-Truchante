
let load filename =

	let file = open_in filename in
	let lexbuf = Lexing.from_channel file in
	let instance = Parser.file Lexer.token lexbuf in
	let () = close_in file in

	instance


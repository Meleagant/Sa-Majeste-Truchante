
	(*******)
	(* SAT *)
	(*******)

module S : Sat.Type = Sat_naive

let load_sat filename =

	let file = open_in filename in
	let lexbuf = Lexing.from_channel file in
	let instance = Parser.sat_file Lexer.token lexbuf in
	let () = close_in file in

	instance

let run_sat instance =

	match S.resolve instance with
	| Sat.SAT _ -> Format.printf "SAT@."
	| Sat.UNSAT -> Format.printf "UNSAT@."

	(*******)
	(* SMT *)
	(*******)

let load_smt filename =

	let file = open_in filename in
	let lexbuf = Lexing.from_channel file in
	let instance = Parser.file Lexer.token lexbuf in
	let () = close_in file in

	instance

	(********)
	(* main *)
	(********)

let () = begin

	match Array.to_list Sys.argv with
	| _ :: "--sat" :: filename :: _ ->
		let i = load_sat filename in
		run_sat i
	| _ -> Format.printf "Wrong usage@."

end


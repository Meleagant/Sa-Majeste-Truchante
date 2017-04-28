
	(*******)
	(* SAT *)
	(*******)

module S = Sat_naive

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

let load filename =

	let file = open_in filename in
	let lexbuf = Lexing.from_channel file in
	let instance = Parser.file Lexer.token lexbuf in
	let () = close_in file in

	instance

	(********)
	(* main *)
	(********)

let () = begin

	let smt_mode = ref true in
	let filename = ref "" in

	for i = 1 to (Array.length Sys.argv) - 1 do
		if Sys.argv.(i) = "--sat" then
			smt_mode := false
		else
			filename := Sys.argv.(i)
	done;

	if !filename <> "" then begin
		if !smt_mode then
			assert false
		else
			run_sat (load_sat !filename)
	end;

	()
end


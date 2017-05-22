
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
	(* TEST *)
	(********)

module Smt_S = Test_smt.Make (Sat_naive)

let run_tests () = begin
	let launch f =
		try f () with
		| Assert_failure (file, line, col) -> begin
			Format.printf "  - (%s,%i,%i)@." file line col;
			Format.printf "  - failed@."
			end
	in

	launch Test_equality.run;
	launch (Smt_S.run);
end

	(********)
	(* main *)
	(********)

let () = begin

	match Array.to_list Sys.argv with
	| _ :: "--sat" :: filename :: _ ->
		let i = load_sat filename in
		run_sat i
	| _ :: "--test" :: _ ->
		run_tests ()
	| _ -> Format.printf "Wrong usage@."

end


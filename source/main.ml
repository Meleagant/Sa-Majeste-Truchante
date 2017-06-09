
module Main (S : Sat.Type) = struct

		(*******)
		(* SAT *)
		(*******)

	let load_sat filename =

		let file = open_in filename in
		let lexbuf = Lexing.from_channel file in
		let instance = Sat_parser.file Sat_lexer.token lexbuf in
		let () = close_in file in

		instance

	let run_sat instance =

		match S.resolve instance with
		| Sat.SAT _ -> Format.printf "SAT@."
		| Sat.UNSAT -> Format.printf "UNSAT@."

		(*******)
		(* SMT *)
		(*******)
	
	module EQUALITY = Smt.Make (S) (Theory_equality)

	let load_equality file =
		
		let file = open_in file in
		let lexbuf = Lexing.from_channel file in
		let instance = Theory_equality_parser.file
			Theory_equality_lexer.token lexbuf in
		let () = close_in file in

		instance
	
	module INEQUALITY = Smt.Make (S) (Theory_inequality)

	let load_inequality file =

		let file = open_in file in
		let lexbuf = Lexing.from_channel file in
		let instance = Theory_inequality_parser.file
			Theory_inequality_lexer.token lexbuf in
		let () = close_in file in

		instance

end

	(********)
	(* TEST *)
	(********)

module Smt_Sn = Test_smt.Make (Sat_naive)
module Smt_Se = Test_smt.Make (Sat_epate)

let run_tests () = begin
	let launch f =
		try f () with
		| Assert_failure (file, line, col) -> begin
			Format.printf "  - (%s,%i,%i)@." file line col;
			Format.printf "  - failed@."
			end
	in

	launch Test_equality.run;
	launch (Smt_Sn.run);
	launch (Smt_Se.run);
end

	(********)
	(* main *)
	(********)

module MAIN = Main(Sat_epate)

let () =
let t0 = Unix.gettimeofday () 
in begin
	(match Array.to_list Sys.argv with
	| _ :: "--sat" :: filename :: _ ->
		let i = MAIN.load_sat filename in
		MAIN.run_sat i
	| _ :: "--sat-rand":: _ ->
		Test_sat.main ()
	| _ :: "--test" :: _ ->
		run_tests ()
	| _ :: "--ineq" :: filename :: _ ->
		let i = MAIN.load_inequality filename in
		if MAIN.INEQUALITY.resolve i then Format.printf "SAT@." else Format.printf "UNSAT@."
	| _ :: "--eq" :: filename :: _
	| _ :: filename :: _ ->
		let i = MAIN.load_equality filename in
		if MAIN.EQUALITY.resolve i then Format.printf "SAT@." else Format.printf "UNSAT@."
	| _ -> Format.printf "Wrong usage@.");
if List.mem "--time" (Array.to_list Sys.argv) then
Format.printf "Calcul effectué en %f s \n" (Unix.gettimeofday() -. t0);

end


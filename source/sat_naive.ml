
let name = "Sat naif ..."

let verify_literal ba l =
	match l with
	| Sat.Var i -> ba.(i)
	| Sat.Neg i -> not ba.(i)

let verify_clause ba c =
	let c = List.map (verify_literal ba) c in
	List.fold_left ( || ) false c

let verify_instance ba i =
	let c = List.map (verify_clause ba) Sat.(i.clauses) in
	List.fold_left ( && ) true c

exception Found

let resolve i =
	let ba = Array.make Sat.(i.n_var) false in
	let rec aux n =
		if n < Sat.(i.n_var) then begin
			aux (n+1);
			ba.(n) <- true;
			aux (n+1);
			ba.(n) <- false;
		end else
			if verify_instance ba i then (raise Found)
	in
	try aux 0 ; Sat.UNSAT with
	| Found -> Sat.SAT ba


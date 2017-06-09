open Sat
open Sat_epate
module N = Sat_naive
module S = String
module A = Array
module R = Random
module L = List
module U  = Unix

(* Pourt la compilation : 
ocamlbuild -libs unix test.native 
*)

let fpf = Printf.printf 

(*------------------------------------------------------------*)
(*           Pretty Printer de formules SAT                   *)
(*------------------------------------------------------------*)


let ou = (S.make 1 '\x5c') ^"/" 
let et = "/"^(S.make 1 '\x5c')


let print_litt t =
match t with
| Var i -> Printf.sprintf "%d" i
| Neg i -> Printf.sprintf "not %d" i

let rec print_clause c = 
match c with
[] -> ""
| [x] -> print_litt x
| t::q -> 
	Printf.sprintf "%s %s %s" (print_litt t) ou (print_clause q)

let rec print_clauses cs =
match cs with
| [] -> ""
| [x] -> Printf.sprintf "%s \n" (print_clause x)
| t::q ->
	Printf.sprintf "%s %s \n %s" (print_clause t) et (print_clauses q)

let print_instance instance = 
	Printf.printf "%s" (print_clauses instance.clauses) 

let print_res res = 
match res with 
| UNSAT -> Printf.printf "LA Formule est insatisfiable ! \n"
| SAT tab ->
begin
	Printf.printf "La formule est satisfiable ! \n";
	A.iteri (fun i b -> Printf.printf "%d -> %b \n" i b) tab;
end

let trivial = 
	{n_var = 5;
	 n_clause = 5;
	 clauses = [[Var 0];[Var 1];[Var 2];[Var 3];[Var 4]]}

let genere_litt nb_var = 
	match R.int 2 with
	| 0 -> Var (R.int nb_var)
	| 1 | _ -> Neg (R.int nb_var)
	(* 
	Le cas _ ne se présente jamais (selon la doc de Random)
	mais je l'inclus pour éviter que le compilateur chiale
	*)

let genere_cl nb_var = 
	let l =  (R.int (nb_var-1))/2 +1  in
	L.map (fun () -> genere_litt nb_var) (A.to_list (A.make l ()))

let genere nb_var nb_cl = 
begin
	R.self_init ();
	{n_var = nb_var;
	 n_clause = nb_cl;
	 clauses = 
	 	L.map (fun () -> genere_cl nb_var) (A.to_list (A.make nb_cl ()))
	};
end

let printdebug s = 
begin
	print_string s;
	flush_all ();
end

let mesure n instance = 
	if n = 0 then
	begin
		let t0 = U.gettimeofday () in
			let res = resolve instance in
			res,(U.gettimeofday () -. t0);
	end
	else
	begin
		let t0 = U.gettimeofday () in
			let res = N.resolve instance in
			res,(U.gettimeofday () -. t0);
	end

let get_arg i = 
	int_of_string (Sys.argv.(i))

let main () = 
	let nb_try =
		try get_arg 2
		with _ ->
		begin	
			fpf "Le premier argument est le nombre d'essai \n";
			exit 0;
		end
		
	and nb_cl = 
		try get_arg 3 
		with _ ->
		begin	
			fpf "Le deuxième argument est le nombre de clauses \n";
			exit 0;
		end
	and nb_var = 
		try get_arg 4
		with _ ->
		begin	
			fpf "Le troisième argument est le nombre de variables \n";
			exit 0;
		end
	and comp = L.mem "--compare" (A.to_list Sys.argv)
	and verb = L.mem "--verbose" (A.to_list Sys.argv)
	and t0 = ref 0.
	and t1 = ref 0. 
	in begin
	for i = 1 to nb_try do
		let instance = genere nb_var nb_cl in
		let r0,dt0 = mesure 0 instance
		and r1,dt1 = mesure (if comp then 1 else 0) instance
		(* 
		Si on test sur de tros grosses instance l'algo naif chiale.
		Il suffit de remplacer le 1 par un 0 au dessus.
		On lance alors les tests sur le me algo 
		*)
		in begin 
			t0 := !t0 +. dt0;
			t1 := !t1 +. dt1;
			if comp then
				match r0,r1 with
				|UNSAT,UNSAT | SAT _ , SAT _ -> 
				if verb then
				Printf.printf "==========> OK ! <==========\n "
				| _ ->
				Printf.printf "==========> Pas Cool ! <==========\n ";
		end
	done;
	t0 := !t0 /. (float_of_int nb_try);
	t1 := !t1 /. (float_of_int nb_try);
	Printf.printf "L'algo DCLL a fait ses calculs en %f s \n" !t0;
	if comp then
		Printf.printf "L'algo naif a fait ses calculs en %f s \n" !t1;
	end
	
				

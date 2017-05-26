open Sat
module L = List
module A = Array
module R = Random

exception NoBackTrackingLeft
exception FalseClause


let name = "Sat épate !"

(*-------------------------------------------------------*)
(*               Type trilléen & opérateurs              *)
(*-------------------------------------------------------*)

type trillen = 
	| True
	| False
	| Undef

type assign = 
	| Unify of (int)
	| Decision of (int)
	
let t_to_b = function
| True -> true
| False -> false
| Undef -> true

let b_to_t b = 
if b then
	True
else
	False


let or_t t1 t2 = 
match t1,t2 with
| True,_ | _,True -> True
| False,False -> False
| _ -> Undef

let and_t t1 t2 = 
match t1,t2 with 
| True,True -> True
| False,_ | _,False -> False
| _ -> Undef

let neg t = 
match t with
| True -> False
| False -> True
| Undef -> Undef

let (or) = or_t

and (&) = and_t

(*-------------------------------------------------------*)
(*                  Fonctions d'évaluation               *)
(*-------------------------------------------------------*)

let eval_litt l value = 
match l with
| Var i -> value.(i)
| Neg i -> neg value.(i)


let eval_clause clause value = 
	L.fold_right (fun l t -> t or (eval_litt l value))  clause False

let eval_instance clauses value = 
	L.fold_right (fun c t -> t & (eval_clause c value)) clauses True

(*-------------------------------------------------------*)
(*                        Règle Unit                     *)
(*-------------------------------------------------------*)

type res_unit = 
	| Already (* Si la clause est déjà vraie *)
	| ToUnify of literal_t (* un litteral qui doit être vrai *)
	| Chepa (* Si on sait pas la valuation de la clause *)

let rec rule_unit clause value = 
(* renvoie un élément de type res_unify *)
(* Lève une exception si la clause est fausse *)
(* /!\ : Il ne faut pas appeler ce solveur sur une instance contenant une
clause vide *)
match clause with
| [] -> raise FalseClause
| t::q ->
	match eval_litt t value with 
	| True -> Already
	| False -> rule_unit q value
	| Undef -> 
		match eval_clause q value with
		| False -> ToUnify t
		| True -> Already
		| Undef -> Chepa


let rec unifys clauses value =
match clauses with
| [] -> Already
| t::q -> 
	let res = rule_unit t value in
	match res with
	| Already -> unifys q value
	| Chepa -> 
	begin
		let res = unifys q value in
		match res with
		| Already -> Chepa
		| _ -> res
	end
	| _  -> res

(*-------------------------------------------------------*)
(*                     Règle Backtrack                   *)
(*-------------------------------------------------------*)

	

let rec backtrack value decision =
match decision with
| [] -> raise NoBackTrackingLeft
| t::q -> match t with
	| Unify (i) -> 
	begin
		value.(i) <- Undef;
		backtrack value q;
	end
	| Decision (i) ->
	begin
		value.(i) <- neg value.(i);
		(Unify i)::q;
	end

(*-------------------------------------------------------*)
(*                     Le reste                          *)
(*-------------------------------------------------------*)

let plus_fqt instance = 
	let aux i j = 
		if i = j then 
			0
		else if i > j then
			1
		else
			-1
	in
	let n = instance.n_var in
	let res = A.make n (0,0) in
	let count_litt t =
		let i = 
			match t with
			| Var i -> i
			| Neg i -> i
		in
			res.(i) <- (i,snd (res.(i)) + 1)
	in
	let iter_clause = L.iter count_litt in
	let iter_clauses = L.iter iter_clause
	in begin
	A.iteri (fun i x -> res.(i) <- (i,0)) res;
	iter_clauses instance.clauses;
	L.map fst (L.sort aux (A.to_list res));
	end

let rec find_undef value fqce = 
	match fqce with 
	| [] -> assert false
	| t::q -> 
		if value.(t) = Undef then
			t
		else
			find_undef value q
let solve clauses value decision fqce = 
	let cont = ref true 
	in begin
	while !cont do
		try
			let ass = unifys clauses value in
			match ass with
			| Already -> 
				cont := false
			| ToUnify t ->
			begin
				match t with
				| Var i -> 
				begin
					value.(i) <- True;
					decision := (Unify i)::(!decision);
				end
				| Neg i ->
				begin
					value.(i) <- False;
					decision := (Unify i)::(!decision);
				end
			end
			| Chepa -> 
				let i = find_undef value fqce 
				in begin
					decision := (Decision i)::(!decision);
					value.(i) <- if R.int 2 = 0 then
									True
								 else
								 	False;
				end
		with
		| FalseClause ->
			try
				decision := backtrack value !decision
			with
			| NoBackTrackingLeft -> 
			begin
				cont := false;
				decision := [];
			end
	done;
	if !decision = [] then
		UNSAT
	else
		SAT (A.map  t_to_b value);
	end
				

let rec resolve instance = 
	solve instance.clauses (A.make instance.n_var Undef) (ref [])
	(plus_fqt instance)

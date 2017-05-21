open Sat
module L = List
module A = Array

exception NoBackTrackingLeft
exception FalseClause


let name = "Sat épate !"



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

let eval_litt l value = 
match l with
| Var i -> value.(i)
| Neg i -> neg value.(i)


let eval_clause clause value = 
	L.fold_right (fun l t -> t or (eval_litt l value))  clause False

let eval_instance clauses value = 
	L.fold_right (fun c t -> t & (eval_clause c value)) clauses True

type res_unify = 
	| Already (* Si la clause est déjà vraie *)
	| ToUnify of literal_t (* un litteral qui doit être vrai *)
	| Chepa (* Si on sait pas la valuation de la clause *)

let rec unify clause value = 
(* renvoie un élément de type res_unify *)
(* Lève une exception si la clause est fausse *)
(* /!\ : Il ne faut pas appeler ce solveur sur une instance contenant une
clause vide *)
match clause with
| [] -> raise FalseClause
| t::q ->
	match eval_litt t value with 
	| True -> Already
	| False -> unify q value
	| Undef -> 
		match eval_clause q value with
		| False -> ToUnify t
		| True -> Already
		| Undef -> Chepa


let rec unifys clauses value =
match clauses with
| [] -> Already
| t::q -> 
	let res = unify t value in
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

let find_undef value = 
	let res = ref (-1)
	and i = ref 0
	and l = A.length value 
	in begin
		while !res = -1 && !i < l do
			if value.(!i) = Undef then
				res := !i
			else
				incr i
		done;
		!res;
	end

let solve clauses value decision = 
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
				let i = find_undef value 
				in begin
					decision := (Decision i)::(!decision);
					value.(i) <- True;
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

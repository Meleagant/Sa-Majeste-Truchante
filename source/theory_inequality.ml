
type atom_t =
| A_Eq of int * int
| A_Lt of int * int
| A_NEq of int * int

type t = atom_t

let compare = compare

let neg = function
| A_Eq (a,b) -> A_NEq (a,b)
| A_Lt (a,b) -> A_Lt (b,a)
| A_NEq (a,b) -> A_Eq (a,b)

module ISet = Set.Make (struct type t = int let compare = compare end)
module IMap = Map.Make (struct type t = int let compare = compare end)

let check (p : atom_t list) : bool =
	let p' = p in
	let (uf, p) = List.fold_left (
		fun (uf, p) t -> match t with
		| A_Eq (a,b) -> (Uf.union a b uf, p)
		| _ -> (uf, t :: p)
	) (Uf.empty, []) p in
	let rec aux p m =
		match p with
		| [] -> Some m
		| A_NEq (a,b) :: ps ->
			if ((Uf.find a uf) = (Uf.find b uf)) then None else
			aux ps m
		| A_Lt (a,b) :: ps ->
			let _, a = Uf.find a uf in
			let _, b = Uf.find b uf in
			let l = try IMap.find a m with Not_found -> [] in
			let m = IMap.add a (b :: l) m in
			aux ps m
		| _ -> assert false
	in
	match (aux p IMap.empty) with
	| None -> false
	| Some m ->
		let d = ref ISet.empty in
		let rec aux v i =
			if ISet.mem i v then false else
			if ISet.mem i !d then true else
			let () = d := ISet.add i !d in
			let v = ISet.add i v in
			let l = try IMap.find i m with Not_found -> [] in
			List.fold_left (fun acc j ->
				acc && (aux v j)) true l
		in
		List.fold_left (fun acc -> function
			| A_Eq (a,b) | A_NEq (a,b) | A_Lt (a,b) ->
				let _, a = Uf.find a uf in
				let _, b = Uf.find b uf in
				acc && (aux ISet.empty a) && (aux ISet.empty b)
			) true p'
			



type atom_t =
| A_Eq of int * int
| A_Lt of int * int
| A_Ge of int * int
| A_NEq of int * int

type t = atom_t

let compare = compare

let neg = function
| A_Eq (a,b) -> A_NEq (a,b)
| A_Lt (a,b) -> A_Ge (a,b)
| A_Ge (a,b) -> A_Lt (a,b)
| A_NEq (a,b) -> A_Eq (a,b)

module ISet = Set.Make (struct type t = int let compare = compare end)
module IMap = Map.Make (struct type t = int let compare = compare end)

let check (p : atom_t list) : bool =
	let p = List.fold_left (
		fun p t -> match t with
		| A_Lt (b,a) -> (A_Ge (a,b)) :: (A_NEq (a,b)) :: p
		| _ -> t :: p) [] p
	in
	let uf = List.fold_left (
		fun uf t -> match t with
		| A_Eq (a,b) -> Uf.union a b uf
		| A_Ge (_,_) | A_NEq (_,_) | A_Lt (_,_) -> uf
	) Uf.empty p in
	let rec aux_map p m =
		match p with
		| [] -> m
		| A_Ge (a,b) :: p ->
			if a = b then aux_map p m else
			let v = try IMap.find a m with Not_found -> ISet.empty in
			let v = ISet.add b v in
			let m = IMap.add a v m in
			aux_map p m
		| _ :: p -> aux_map p m
	in
	let map = aux_map p IMap.empty in
	let rec aux_dfs i v uf =
		if ISet.mem i v then (uf, ISet.singleton i) else
		let v = ISet.add i v in
		ISet.fold (
			fun j (uf, bs) ->
				let (uf, bs') = aux_dfs j v uf in
				let bs = ISet.union bs bs' in
				let uf = if (ISet.cardinal bs) = 0 then uf else
					Uf.union i j uf in
				let bs = ISet.remove i bs in
				(uf, bs)
		) (try IMap.find i map with Not_found -> ISet.empty) (uf, ISet.empty)
	in
	let uf = IMap.fold (
		fun j _ uf ->
			let (uf, _) = aux_dfs j ISet.empty uf in
			uf
		) map uf
	in
	let rec aux p =
		match p with
		| [] -> true
		| A_NEq (a,b) :: ps ->
			if ((Uf.find a uf) = (Uf.find b uf)) then false else
			aux ps
		| _ :: ps -> aux ps
	in
	aux p
	




type atom_t =
| A_Eq of int * int
| A_NEq of int * int

type t = atom_t

let compare = compare

let neg = function
| A_Eq (a,b) -> A_NEq (a,b)
| A_NEq (a,b) -> A_Eq (a,b)

let check (p : atom_t list) : bool =
	let (uf, p) = List.fold_left (
		fun (uf, p) t -> match t with
		| A_Eq (a,b) -> (Uf.union a b uf, p)
		| A_NEq (a,b) -> (uf, (a,b) :: p)
	) (Uf.empty,[]) p in
	let rec aux p =
		match p with
		| [] -> true
		| (a,b) :: ps ->
			if ((Uf.find a uf) = (Uf.find b uf)) then false else
			aux ps
	in
	aux p


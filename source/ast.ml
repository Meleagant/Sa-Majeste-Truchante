
type literal_t =
| L_Eq of int * int
| L_NEq of int * int

type clause_t = literal_t list

type instance_t = {
	n_var : int;
	n_clause : int;
	clauses : clause_t list;
}


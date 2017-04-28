
type literal_t = 
| Var of int
| Neg of int

type clause_t = literal_t list

type instance_t = {
	n_var : int;
	n_clause : int;
	clauses : clause_t list;
}

type result_t =
| SAT of bool array
| UNSAT


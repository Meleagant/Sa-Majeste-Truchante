
open Theory_equality

let a_eq i j = A_Eq (i,j)
let a_neq i j = A_NEq (i,j)

let run () = begin

	Format.printf "[theory_equality]@.";

	assert (check (
		[a_eq 0 1; a_eq 2 3; a_eq 4 5]
	));

	assert (check (
		[a_eq 0 1; a_eq 2 3; a_neq 1 4; a_eq 4 5]
	));

	assert (not (check (
		[a_eq 0 1; a_neq 1 2; a_eq 0 2]
	)));

end


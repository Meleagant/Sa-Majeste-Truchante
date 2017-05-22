
module Make (S : Sat.Type) = struct

	module T = Theory_equality
	module SMT = Smt.Make (S) (T)

	let a_eq i j = T.A_Eq (i,j)
	let a_neq i j = T.A_NEq (i,j)

	let run () = begin
		
		Format.printf "[smt equality : %s]@." S.name;

		assert (SMT.resolve [
			[a_eq 0 1];
			[a_eq 2 3]
		]);

		assert (SMT.resolve [
			[a_eq 0 1];
			[a_eq 2 3; a_eq 0 2];
			[a_neq 1 2]
		]);

		assert (SMT.resolve [
			[a_eq 0 1];
			[a_neq 1 2];
			[a_eq 2 3];
			[a_neq 3 4];
			[a_eq 4 5];
			[a_neq 5 6];
			[a_eq 0 2; a_neq 1 4];
			[a_eq 1 6; a_neq 4 6]
		]);

	end

end



module IMap = Map.Make (struct type t = int let compare = compare end)

module Make (S : Sat.Type) (T : Theory.Type) = struct

	module AMap = Map.Make (struct type t = T.t let compare = T.compare end)

	type atom_t = T.t

	let resolve (i : atom_t list list) : bool =
		let rec aux i =
			let (amap,var_count) = List.fold_left (
				fun (map,c) a ->
					if AMap.mem        a  map then (map,c) else
					if AMap.mem (T.neg a) map then (map,c) else
					(AMap.add a c map, c+1)
				) (AMap.empty, 0) (List.flatten i)
			in
			let sati = List.map (fun l -> List.map (
				fun a ->
					if AMap.mem        a  amap then Sat.Var (AMap.find        a  amap) else
					if AMap.mem (T.neg a) amap then Sat.Neg (AMap.find (T.neg a) amap) else
					assert false
				) l ) i
			in
			let result = Sat.(S.resolve {
				n_var = var_count;
				n_clause = List.length sati;
				clauses = sati;
			}) in
			match result with | Sat.UNSAT -> false
			| Sat.SAT ba ->
			
			let revmap = AMap.fold (fun k v m -> IMap.add v k m) amap IMap.empty in
			let thi_array = Array.init var_count (fun i ->
				let a = IMap.find i revmap in
				if ba.(i) then a else T.neg a
				) in
			let thi = Array.to_list thi_array in
			if T.check thi then true else

			let ncl = List.map (T.neg) thi in
			aux (ncl :: i)
		in
		aux i

end


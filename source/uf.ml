
module IMap = Map.Make (struct type t = int let compare = compare end)

type t = {
	t_parent : int IMap.t;
	t_count : int IMap.t;
}

let empty = {
	t_parent = IMap.empty;
	t_count = IMap.empty;
}

let rec find i uf =
	let p = try IMap.find i uf.t_parent with Not_found -> i in
	if i = p then (uf, p) else
	let (uf, p) = find p uf in
	let uf = {
		t_parent = IMap.add i p uf.t_parent;
		t_count = uf.t_count;
	} in
	(uf, p)
	
let union a b uf =
	let ca = try IMap.find a uf.t_count with Not_found -> 1 in
	let cb = try IMap.find b uf.t_count with Not_found -> 1 in
	let (a,b,ca,cb) = if ca >= cb then (a,b,ca,cb) else (b,a,cb,ca) in
	let (uf, pa) = find a uf in
	let (uf, pb) = find b uf in
	{
		t_parent = IMap.add b a uf.t_parent;
		t_count = IMap.add a (ca+cb) (IMap.remove b uf.t_count);
	}



module type Type = sig
	type t
	val compare : t -> t -> int
	val neg : t -> t
	val check : t list -> bool
end


type t

val empty: t
val make: string -> t
val show: t -> string
val pp: t -> Pretext.t
val compare: t -> t -> int

module Set:
sig
  include Set.S with type elt = t
  val show: t -> string
  val pp: t -> Pretext.t
end

module Map: Map.S with type key = t

(** Pools from which one can pick random values. *)

type 'a t

val create_from_list: 'a list -> 'a t

(** Pick a value, remove it from the pool, and return it.

    Return [None] if the pool is empty. *)
val pick: 'a t -> 'a option

(** Get the list of values that are still in a pool. *)
val to_list: 'a t -> 'a list

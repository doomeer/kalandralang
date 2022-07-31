type t

val make: string -> Ezjsonm.value -> t

val parse: origin: string -> string -> t

val parse_file: string -> t

val encode: t -> string

val write_file: string -> Ezjsonm.value -> unit

val show_origin: t -> string

val fail: t -> string -> 'a

val as_bool: t -> bool

val as_int: t -> int

val as_float: t -> float

val as_float_opt: t -> float option

val as_string: t -> string

val as_id: t -> Id.t

val as_option: t -> t option

val as_object: t -> (string * t) list

val as_object_opt: t -> (string * t) list option

val as_array: t -> t list

val get: string -> t -> t

val (|->): t -> string -> t

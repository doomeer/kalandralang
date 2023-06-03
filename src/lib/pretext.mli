type t

val empty: t
val concat: t -> t -> t
val seq: t list -> t
val atom: ?size: int -> string -> t
val int: int -> t
val space: t
val newline: t
val empty_line: t
val box: t list -> t (* TODO: boxl? same for seq / seql? *)
val if_flat: t -> t -> t
val break0: t
val break: t
val indent: t
val dedent: t
val flow: t list -> t
val separate: t -> t list -> t
val separate_map: t -> ('a -> t) -> 'a list -> t

val show:
  ?starting_level: int ->
  ?starting_width: int ->
  ?spaces_per_indent: int ->
  ?max_width: int ->
  t -> string

val to_channel:
  ?starting_level: int ->
  ?starting_width: int ->
  ?spaces_per_indent: int ->
  ?max_width: int ->
  out_channel -> t -> unit

val to_formatter:
  ?starting_level: int ->
  ?starting_width: int ->
  ?spaces_per_indent: int ->
  ?max_width: int ->
  Format.formatter -> t -> unit

module OCaml:
sig
  val bool: bool -> t
  val int: int -> t
  val string: string -> t
  val list: ('a -> t) -> 'a list -> t
  val variant: string -> t list -> t
  val record: (string * t) list -> t
  val tuple: t list -> t
end

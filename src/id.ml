module M =
struct
  type t = { int: int; string: string }
  let compare a b = Int.compare a.int b.int
end

include M

let string_table: (string, t) Hashtbl.t = Hashtbl.create 512
let next = ref 0

let make string =
  match Hashtbl.find_opt string_table string with
    | None ->
        let int = !next in
        incr next;
        let id = { int; string } in
        Hashtbl.replace string_table string id;
        id
    | Some id ->
        id

let empty = make ""

let show id = id.string

let pp id =
  Pretext.OCaml.string (show id)

module Set =
struct
  include Set.Make (M)
  let pp set = Pretext.OCaml.list pp (elements set)
end

module Map = Map.Make (M)

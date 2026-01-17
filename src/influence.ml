open Misc

(* Shaper / Elder / Conqueror *)
type sec =
  | Shaper
  | Elder
  | Crusader
  | Hunter
  | Redeemer
  | Warlord

let show_sec = function
  | Shaper -> "Shaper"
  | Elder -> "Elder"
  | Crusader -> "Crusader"
  | Hunter -> "Hunter"
  | Redeemer -> "Redeemer"
  | Warlord -> "Warlord"

let pp_sec sec =
  Pretext.atom (show_sec sec)

type eld =
  | Exarch
  | Eater
  | Exarch_and_eater

let show_eld = function
  | Exarch -> "Exarch"
  | Eater -> "Eater"
  | Exarch_and_eater -> "Exarch_and_eater"

let pp_eld eld =
  Pretext.atom (show_eld eld)

let add_eldritch a b =
  match a, b with
    | Exarch, Exarch -> Exarch
    | Eater, Eater -> Eater
    | Exarch_and_eater, _ | _, Exarch_and_eater -> Exarch_and_eater
    | Exarch, Eater | Eater, Exarch -> Exarch_and_eater

let compare_sec = (Stdlib.compare: sec -> sec -> int)

type t =
  | Not_influenced
  | Fractured of eld option
  | Synthesized
  | SEC of sec
  | SEC_pair of sec * sec
  | Eldritch of eld

let pp = function
  | Not_influenced -> Pretext.atom "Not_influenced"
  | Fractured x -> (
      match x with
        | None -> Pretext.atom "Fractured"
        | Some eld -> Pretext.OCaml.variant "Fractured" [ pp_eld eld ]
    )
  | Synthesized -> Pretext.atom "Synthesized"
  | SEC sec -> Pretext.OCaml.variant "SEC" [ pp_sec sec ]
  | SEC_pair (sec1, sec2) -> Pretext.OCaml.variant "SEC_pair" [ pp_sec sec1; pp_sec sec2 ]
  | Eldritch eld -> Pretext.OCaml.variant "Eldritch" [ pp_eld eld ]

let add a b =
  match a, b with
    | Not_influenced, x | x, Not_influenced ->
        x
    | Fractured x, Fractured y ->
        (match x, y with
          | None, None -> Fractured None
          | Some eld, None
          | None, Some eld ->
              Fractured (Some eld)
          | Some eld1, Some eld2 -> Fractured (Some (add_eldritch eld1 eld2))
        )
    | Eldritch eld, Fractured None -> Fractured (Some eld)
    | Fractured None, Eldritch eld -> Fractured (Some eld)
    | Fractured (Some eld1), Eldritch eld2 -> Fractured (Some (add_eldritch eld1 eld2))
    | Fractured _, _ | _, Fractured _ ->
        fail "cannot both be fractured and influenced"
    | Synthesized, Synthesized ->
        Synthesized
    | Synthesized, _ | _, Synthesized ->
        fail "cannot both be synthesized and influenced"
    | SEC x, SEC y when x = y ->
        a
    | SEC x, SEC y ->
        SEC_pair (x, y)
    | (SEC x, (SEC_pair (y, z) as sec2) | (SEC_pair (y, z) as sec2), SEC x)
      when x = y || x = z ->
        sec2
    | SEC _, SEC_pair _ | SEC_pair _, SEC _ | SEC_pair _, SEC_pair _ ->
        fail "cannot have more than two influences"
    | Eldritch eld1, Eldritch eld2 -> Eldritch (add_eldritch eld1 eld2)
    | Eldritch _, (SEC _ | SEC_pair _)
    | (SEC _ | SEC_pair _), Eldritch _ ->
        fail "cannot have both Eldritch and Shaper / Elder / Conqueror influences"

(* [a] includes [b] *)
let rec includes a b =
  match a, b with
    | Not_influenced, Not_influenced -> true
    | Not_influenced, _ -> false
    | Fractured _, Fractured None -> true
    | Fractured (Some eld1), Fractured (Some eld2) -> includes (Eldritch eld1) (Eldritch eld2)
    | Fractured (Some eld1), Eldritch eld2 -> includes (Eldritch eld1) (Eldritch eld2)
    | Fractured _, _ -> false
    | Synthesized, Synthesized -> true
    | Synthesized, _ -> false
    | SEC a, SEC b -> a = b
    | SEC _, _ -> false
    | SEC_pair (a, b), SEC c -> a = c || b = c
    | SEC_pair (a, b), SEC_pair (c, d) -> (a = c && b = d) || (a = d && b = c)
    | SEC_pair _, _ -> false
    | Eldritch Exarch, Eldritch Exarch -> true
    | Eldritch Exarch, _ -> false
    | Eldritch Eater, Eldritch Eater -> true
    | Eldritch Eater, _ -> false
    | Eldritch Exarch_and_eater, Eldritch (Exarch | Eater | Exarch_and_eater) -> true
    | Eldritch Exarch_and_eater, _ -> false

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

type t =
  | Not_influenced
  | Fractured
  | Synthesized
  | SEC of sec
  | SEC_pair of sec * sec
  | Exarch
  | Eater
  | Exarch_and_eater

let pp = function
  | Not_influenced -> Pretext.atom "Not_influenced"
  | Fractured -> Pretext.atom "Fractured"
  | Synthesized -> Pretext.atom "Synthesized"
  | SEC sec -> Pretext.OCaml.variant "SEC" [ pp_sec sec ]
  | SEC_pair (sec1, sec2) -> Pretext.OCaml.variant "SEC_pair" [ pp_sec sec1; pp_sec sec2 ]
  | Exarch -> Pretext.atom "Exarch"
  | Eater -> Pretext.atom "Eater"
  | Exarch_and_eater -> Pretext.atom "Exarch_and_eater"

let add a b =
  match a, b with
    | Not_influenced, x | x, Not_influenced ->
        x
    | Fractured, Fractured ->
        Fractured
    | Fractured, _ | _, Fractured ->
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
    | Exarch, Exarch ->
        Exarch
    | Eater, Eater ->
        Eater
    | Exarch_and_eater, (Exarch | Eater | Exarch_and_eater)
    | (Exarch | Eater), Exarch_and_eater
    | Exarch, Eater | Eater, Exarch ->
        Exarch_and_eater
    | (Exarch | Eater | Exarch_and_eater), (SEC _ | SEC_pair _)
    | (SEC _ | SEC_pair _), (Exarch | Eater | Exarch_and_eater) ->
        fail "cannot have both Eldritch and Shaper / Elder / Conqueror influences"

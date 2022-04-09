open Misc

(* Don't forget to call [register] after adding a fossil to this type. *)
(* TODO: Hollow (has an abyssal socket) *)
(* TODO: Sanctified (higher tiers more likely) *)
type t =
  | Aberrant
  | Aetheric
  | Bound
  | Corroded
  | Dense
  | Faceted
  | Frigid
  | Jagged
  | Lucent
  | Metallic
  | Prismatic
  | Pristine
  | Scorched
  | Serrated
  | Shuddering
  | Fundamental
  | Deft

let show = function
  | Aberrant -> "aberrant"
  | Aetheric -> "aetheric"
  | Bound -> "bound"
  | Corroded -> "corroded"
  | Dense -> "dense"
  | Faceted -> "faceted"
  | Frigid -> "frigid"
  | Jagged -> "jagged"
  | Lucent -> "lucent"
  | Metallic -> "metallic"
  | Prismatic -> "prismatic"
  | Pristine -> "pristine"
  | Scorched -> "scorched"
  | Serrated -> "serrated"
  | Shuddering -> "shuddering"
  | Fundamental -> "fundamental"
  | Deft -> "deft"

type weights =
  {
    more: Id.t list;
    less: Id.t list;
    no: Id.t list;
  }

module M =
struct
  type nonrec t = t
  let compare = (Stdlib.compare: t -> t -> int)
end

module Map = Map.Make (M)

let weight_map: weights Map.t ref = ref Map.empty

let register ?(more = []) ?(less = []) ?(no = []) fossil =
  let more = List.map Mod.tag_id more in
  let less = List.map Mod.tag_id less in
  let no = List.map Mod.tag_id no in
  weight_map := Map.add fossil { more; less; no } !weight_map

let () =
  register Aberrant ~more: [ `chaos ] ~no: [ `lightning ];
  register Aetheric ~more: [ `caster ] ~less: [ `attack ];
  register Bound ~more: [ `minion; `aura; `curse ];
  register Corroded ~more: [ `bleed; `poison ] ~no: [ `elemental ];
  register Dense ~more: [ `defences ] ~no: [ `life ];
  register Faceted ~more: [ `gem ];
  register Frigid ~more: [ `cold ] ~no: [ `fire ];
  register Jagged ~more: [ `physical ] ~no: [ `chaos ];
  register Lucent ~more: [ `mana ] ~no: [ `speed ];
  register Metallic ~more: [ `lightning ] ~no: [ `physical ];
  register Prismatic ~more: [ `elemental ] ~no: [ `bleed; `poison ];
  register Pristine ~more: [ `life ] ~no: [ `defences ];
  register Scorched ~more: [ `fire ] ~no: [ `cold ];
  register Serrated ~more: [ `attack ] ~less: [ `caster ];
  register Shuddering ~more: [ `speed ] ~no: [ `mana ];
  register Fundamental ~more: [ `attribute ] ~no: [ `critical ];
  register Deft ~more: [ `critical ] ~no: [ `attribute ];
  ()

let get_weights fossil =
  match Map.find_opt fossil !weight_map with
    | None ->
        fail "fossil was not registered in weight map: %s" (show fossil)
    | Some w ->
        w

type counts =
  {
    mutable more: int;
    mutable less: int;
    mutable no: int;
  }

let apply_combination fossils mod_tags mod_weight =
  let counts =
    {
      more = 0;
      less = 0;
      no = 0;
    }
  in
  let has tag = Id.Set.mem tag mod_tags in
  let apply_fossil fossil =
    let weights = get_weights fossil in
    if List.exists has weights.more then counts.more <- counts.more + 1;
    if List.exists has weights.less then counts.less <- counts.less + 1;
    if List.exists has weights.no then counts.no <- counts.no + 1;
  in
  List.iter apply_fossil fossils;
  if counts.no > 0 then 0 else
    let mod_weight = if counts.more > 0 then 10 * counts.more * mod_weight else mod_weight in
    if counts.less > 0 then mod_weight * 15 / 100 else mod_weight

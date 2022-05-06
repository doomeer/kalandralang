open Misc

module Item_type =
struct
  type t = Base_tag.item_type
  let compare = (Stdlib.compare: t -> t -> int)
end

module Item_type_map = Map.Make (Item_type)

type level =
  | Whispering (* 1 *)
  | Muttering (* 2 *)
  | Weeping (* 3 *)
  | Wailing (* 4 *)
  | Screaming (* 5 *)
  | Shrieking (* 6 *)
  | Deafening (* 7 *)
  | Corrupted (* 8 - Horror, Insanity, etc. *)

let tier = function
  | Whispering -> 7
  | Muttering -> 6
  | Weeping -> 5
  | Wailing -> 4
  | Screaming -> 3
  | Shrieking -> 2
  | Deafening
  | Corrupted -> 1

type t =
  {
    id: Id.t;
    name: Id.t;
    item_level_restriction: int option;
    level: level;
    on_amulet: Id.t;
    on_belt: Id.t;
    on_body_armour: Id.t;
    on_boots: Id.t;
    on_bow: Id.t;
    on_claw: Id.t;
    on_dagger: Id.t;
    on_gloves: Id.t;
    on_helmet: Id.t;
    on_one_hand_axe: Id.t;
    on_one_hand_mace: Id.t;
    on_one_hand_sword: Id.t;
    on_quiver: Id.t;
    on_ring: Id.t;
    on_sceptre: Id.t;
    on_shield: Id.t;
    on_staff: Id.t;
    on_thrusting_one_hand_sword: Id.t;
    on_two_hand_axe: Id.t;
    on_two_hand_mace: Id.t;
    on_two_hand_sword: Id.t;
    on_wand: Id.t;
  }

(* Map from essence id to essence. *)
let id_map = ref Id.Map.empty

(* Reverse map from modifier identifier to essence. *)
let mod_id_map = ref Id.Map.empty

let add_to_mod_id_map
    (
      {
        id = _;
        name = _;
        item_level_restriction = _;
        level = _;
        on_amulet;
        on_belt;
        on_body_armour;
        on_boots;
        on_bow;
        on_claw;
        on_dagger;
        on_gloves;
        on_helmet;
        on_one_hand_axe;
        on_one_hand_mace;
        on_one_hand_sword;
        on_quiver;
        on_ring;
        on_sceptre;
        on_shield;
        on_staff;
        on_thrusting_one_hand_sword;
        on_two_hand_axe;
        on_two_hand_mace;
        on_two_hand_sword;
        on_wand;
      }
      as essence
    ) =
  let add id = mod_id_map := Id.Map.add id essence !mod_id_map in
  add on_amulet;
  add on_belt;
  add on_body_armour;
  add on_boots;
  add on_bow;
  add on_claw;
  add on_dagger;
  add on_gloves;
  add on_helmet;
  add on_one_hand_axe;
  add on_one_hand_mace;
  add on_one_hand_sword;
  add on_quiver;
  add on_ring;
  add on_sceptre;
  add on_shield;
  add on_staff;
  add on_thrusting_one_hand_sword;
  add on_two_hand_axe;
  add on_two_hand_mace;
  add on_two_hand_sword;
  add on_wand;
  ()

type data = t Id.Map.t

let export (): data = !id_map

let import (x: data) =
  id_map := x;
  Id.Map.iter (fun _ -> add_to_mod_id_map) x

let load filename =
  let add_entry (id, json) =
    let id = Id.make id in
    let name = JSON.(json |-> "name" |> as_id) in
    let mods = JSON.(json |-> "mods") in
    let as_level_opt = function
      | 0 -> None (* Remnant of Corruption *)
      | 1 -> Some Whispering
      | 2 -> Some Muttering
      | 3 -> Some Weeping
      | 4 -> Some Wailing
      | 5 -> Some Screaming
      | 6 -> Some Shrieking
      | 7 -> Some Deafening
      | 8 -> Some Corrupted
      | x -> fail "unknown essence level: %d" x
    in
    let level = JSON.(json |-> "level" |> as_int) |> as_level_opt in
    match level with
      | None ->
          ()
      | Some level ->
          let essence =
            {
              id;
              name;
              item_level_restriction =
                JSON.(json |-> "item_level_restriction" |> as_option |> Option.map as_int);
              level;
              on_amulet = JSON.(mods |-> "Amulet" |> as_id);
              on_belt = JSON.(mods |-> "Belt" |> as_id);
              on_body_armour = JSON.(mods |-> "Body Armour" |> as_id);
              on_boots = JSON.(mods |-> "Boots" |> as_id);
              on_bow = JSON.(mods |-> "Bow" |> as_id);
              on_claw = JSON.(mods |-> "Claw" |> as_id);
              on_dagger = JSON.(mods |-> "Dagger" |> as_id);
              on_gloves = JSON.(mods |-> "Gloves" |> as_id);
              on_helmet = JSON.(mods |-> "Helmet" |> as_id);
              on_one_hand_axe = JSON.(mods |-> "One Hand Axe" |> as_id);
              on_one_hand_mace = JSON.(mods |-> "One Hand Mace" |> as_id);
              on_one_hand_sword = JSON.(mods |-> "One Hand Sword" |> as_id);
              on_quiver = JSON.(mods |-> "Quiver" |> as_id);
              on_ring = JSON.(mods |-> "Ring" |> as_id);
              on_sceptre = JSON.(mods |-> "Sceptre" |> as_id);
              on_shield = JSON.(mods |-> "Shield" |> as_id);
              on_staff = JSON.(mods |-> "Staff" |> as_id);
              on_thrusting_one_hand_sword =
                JSON.(mods |-> "Thrusting One Hand Sword" |> as_id);
              on_two_hand_axe = JSON.(mods |-> "Two Hand Axe" |> as_id);
              on_two_hand_mace = JSON.(mods |-> "Two Hand Mace" |> as_id);
              on_two_hand_sword = JSON.(mods |-> "Two Hand Sword" |> as_id);
              on_wand = JSON.(mods |-> "Wand" |> as_id);
            }
          in
          id_map := Id.Map.add id essence !id_map;
          add_to_mod_id_map essence
  in
  List.iter add_entry JSON.(parse_file filename |> as_object)

let get_mod essence (item_type: Base_tag.item_type) =
  match item_type with
    | Amulet ->
        Some essence.on_amulet
    | Belt ->
        Some essence.on_belt
    | Body_armour ->
        Some essence.on_body_armour
    | Boots ->
        Some essence.on_boots
    | Bow ->
        Some essence.on_bow
    | Claw ->
        Some essence.on_claw
    | Dagger | Rune_dagger ->
        Some essence.on_dagger
    | Gloves ->
        Some essence.on_gloves
    | Helmet ->
        Some essence.on_helmet
    | One_hand_axe ->
        Some essence.on_one_hand_axe
    | One_hand_mace ->
        Some essence.on_one_hand_mace
    | One_hand_sword ->
        Some essence.on_one_hand_sword
    | Quiver ->
        Some essence.on_quiver
    | Ring ->
        Some essence.on_ring
    | Sceptre ->
        Some essence.on_sceptre
    | Shield ->
        Some essence.on_shield
    | Staff | Warstaff ->
        Some essence.on_staff
    | Thrusting_one_hand_sword ->
        Some essence.on_thrusting_one_hand_sword
    | Two_hand_axe ->
        Some essence.on_two_hand_axe
    | Two_hand_mace ->
        Some essence.on_two_hand_mace
    | Two_hand_sword ->
        Some essence.on_two_hand_sword
    | Wand ->
        Some essence.on_wand
    | Other ->
        None

let by_id id =
  match Id.Map.find_opt id !id_map with
    | None ->
        fail "no essence with id %S" (Id.show id)
    | Some x ->
        x

let by_mod_id_opt id = Id.Map.find_opt id !mod_id_map

let deafening_of_anger_id = Id.make "Metadata/Items/Currency/CurrencyEssenceAnger6"
let deafening_of_anguish_id = Id.make "Metadata/Items/Currency/CurrencyEssenceAnguish4"
let deafening_of_contempt_id = Id.make "Metadata/Items/Currency/CurrencyEssenceContempt7"
let deafening_of_doubt_id = Id.make "Metadata/Items/Currency/CurrencyEssenceDoubt5"
let deafening_of_dread_id = Id.make "Metadata/Items/Currency/CurrencyEssenceDread3"
let deafening_of_envy_id = Id.make "Metadata/Items/Currency/CurrencyEssenceEnvy3"
let deafening_of_fear_id = Id.make "Metadata/Items/Currency/CurrencyEssenceFear6"
let deafening_of_greed_id = Id.make "Metadata/Items/Currency/CurrencyEssenceGreed7"
let deafening_of_hatred_id = Id.make "Metadata/Items/Currency/CurrencyEssenceHatred7"
let deafening_of_loathing_id = Id.make "Metadata/Items/Currency/CurrencyEssenceLoathing4"
let deafening_of_misery_id = Id.make "Metadata/Items/Currency/CurrencyEssenceMisery3"
let deafening_of_rage_id = Id.make "Metadata/Items/Currency/CurrencyEssenceRage5"
let deafening_of_scorn_id = Id.make "Metadata/Items/Currency/CurrencyEssenceScorn3"
let deafening_of_sorrow_id = Id.make "Metadata/Items/Currency/CurrencyEssenceSorrow6"
let deafening_of_spite_id = Id.make "Metadata/Items/Currency/CurrencyEssenceSpite4"
let deafening_of_suffering_id = Id.make "Metadata/Items/Currency/CurrencyEssenceSuffering5"
let deafening_of_torment_id = Id.make "Metadata/Items/Currency/CurrencyEssenceTorment6"
let deafening_of_woe_id = Id.make "Metadata/Items/Currency/CurrencyEssenceWoe7"
let deafening_of_wrath_id = Id.make "Metadata/Items/Currency/CurrencyEssenceWrath5"
let deafening_of_zeal_id = Id.make "Metadata/Items/Currency/CurrencyEssenceZeal4"
let of_delirium_id = Id.make "Metadata/Items/Currency/CurrencyEssenceDelirium1"
let of_horror_id = Id.make "Metadata/Items/Currency/CurrencyEssenceHorror1"
let of_hysteria_id = Id.make "Metadata/Items/Currency/CurrencyEssenceHysteria1"
let of_insanity_id = Id.make "Metadata/Items/Currency/CurrencyEssenceInsanity1"

type name =
  | Anger
  | Anguish
  | Contempt
  | Doubt
  | Dread
  | Envy
  | Fear
  | Greed
  | Hatred
  | Loathing
  | Misery
  | Rage
  | Scorn
  | Sorrow
  | Spite
  | Suffering
  | Torment
  | Woe
  | Wrath
  | Zeal
  | Delirium
  | Horror
  | Hysteria
  | Insanity

let id_of_name = function
  | Anger -> deafening_of_anger_id
  | Anguish -> deafening_of_anguish_id
  | Contempt -> deafening_of_contempt_id
  | Doubt -> deafening_of_doubt_id
  | Dread -> deafening_of_dread_id
  | Envy -> deafening_of_envy_id
  | Fear -> deafening_of_fear_id
  | Greed -> deafening_of_greed_id
  | Hatred -> deafening_of_hatred_id
  | Loathing -> deafening_of_loathing_id
  | Misery -> deafening_of_misery_id
  | Rage -> deafening_of_rage_id
  | Scorn -> deafening_of_scorn_id
  | Sorrow -> deafening_of_sorrow_id
  | Spite -> deafening_of_spite_id
  | Suffering -> deafening_of_suffering_id
  | Torment -> deafening_of_torment_id
  | Woe -> deafening_of_woe_id
  | Wrath -> deafening_of_wrath_id
  | Zeal -> deafening_of_zeal_id
  | Delirium -> of_delirium_id
  | Horror -> of_horror_id
  | Hysteria -> of_hysteria_id
  | Insanity -> of_insanity_id

let show_name = function
  | Anger -> "anger"
  | Anguish -> "anguish"
  | Contempt -> "contempt"
  | Doubt -> "doubt"
  | Dread -> "dread"
  | Envy -> "envy"
  | Fear -> "fear"
  | Greed -> "greed"
  | Hatred -> "hatred"
  | Loathing -> "loathing"
  | Misery -> "misery"
  | Rage -> "rage"
  | Scorn -> "scorn"
  | Sorrow -> "sorrow"
  | Spite -> "spite"
  | Suffering -> "suffering"
  | Torment -> "torment"
  | Woe -> "woe"
  | Wrath -> "wrath"
  | Zeal -> "zeal"
  | Delirium -> "delirium"
  | Horror -> "horror"
  | Hysteria -> "hysteria"
  | Insanity -> "insanity"

let by_name name = by_id (id_of_name name)

open Misc

type eldritch_tier =
  | Lesser
  | Greater
  | Grand
  | Exceptional
  | Exquisite
  | Perfect

let show_eldritch_tier = function
  | Lesser -> "Lesser"
  | Greater -> "Greater"
  | Grand -> "Grand"
  | Exceptional -> "Exceptional"
  | Exquisite -> "Exquisite"
  | Perfect -> "Perfect"

let int_of_eldritch_tier = function
  | Lesser -> 1
  | Greater -> 2
  | Grand -> 3
  | Exceptional -> 4
  | Exquisite -> 5
  | Perfect -> 6

let compare_eldritch_tiers a b =
  Int.compare (int_of_eldritch_tier a) (int_of_eldritch_tier b)

(* There are other generation types ("corrupted", "exarch_implicit", ...)
   but we only support the following ones. *)
type generation_type =
  | Prefix
  | Suffix
  | Exarch_implicit of eldritch_tier
  | Eater_implicit of eldritch_tier

let show_generation_type = function
  | Prefix -> "Prefix"
  | Suffix -> "Suffix"
  | Exarch_implicit tier -> "Exarch " ^ show_eldritch_tier tier
  | Eater_implicit tier -> "Eater " ^ show_eldritch_tier tier

let pp_generation_type generation_type =
  Pretext.OCaml.variant (show_generation_type generation_type) []

type stat =
  {
    id: Id.t;
    min: int;
    max: int;
  }

type t =
  {
    id: Id.t;
    mod_type: Id.t; (* "type" in data file *)
    domain: Base_item.domain;
    generation_type: generation_type;
    (* Only one mod per [group] can spawn on an item. *)
    groups: Id.Set.t;
    required_level: int;
    (* [spawn_weights] define on which items the modifier can spawn,
       and with which weight (first matching tag in the list wins).
       Those weights can further be modified by [generation_weights].
       Influenced items have different tags than regular items. *)
    spawn_weights: (Id.t * int) list;
    (* [generation_weights] are percentage multipliers to apply
       if some tags are present. *)
    generation_weights: (Id.t * int) list;
    (* [tags] define the tags for fossil and harvest crafting. *)
    tags: Id.Set.t;
    (* [adds_tags] causes the item to now have those tags.
       This can thus change future spawn weights. *)
    adds_tags: Id.Set.t;
    stats: stat list;
    is_essence_only: bool;
  }

let is_prefix modifier =
  match modifier.generation_type with
    | Prefix ->
        true
    | _ ->
        false

let is_suffix modifier =
  match modifier.generation_type with
    | Suffix ->
        true
    | _ ->
        false

let is_prefix_or_suffix modifier =
  match modifier.generation_type with
    | Prefix | Suffix ->
        true
    | _ ->
        false

let is_implicit modifier =
  match modifier.generation_type with
    | Exarch_implicit _ | Eater_implicit _ ->
        true
    | Prefix | Suffix ->
        false

let is_exarch_implicit modifier =
  match modifier.generation_type with
    | Exarch_implicit _ ->
        true
    | _ ->
        false

let is_eater_implicit modifier =
  match modifier.generation_type with
    | Eater_implicit _ ->
        true
    | _ ->
        false

let is_crafted modifier =
  match modifier.domain with
    | Crafted ->
        true
    | _ ->
        false

let caster_tag = Id.make "caster"
let attack_tag = Id.make "attack"

let is_caster modifier =
  Id.Set.mem caster_tag modifier.tags

let is_attack modifier =
  Id.Set.mem attack_tag modifier.tags

let pp_spawn_weight (tag, weight) =
  Pretext.OCaml.tuple [ Id.pp tag; Pretext.OCaml.int weight ]

let pp_stat { id; min; max } =
  Pretext.OCaml.record [
    "id", Id.pp id;
    "min", Pretext.OCaml.int min;
    "max", Pretext.OCaml.int max;
  ]

let pp {
    id; mod_type; domain; generation_type; groups; required_level;
    spawn_weights; generation_weights;
    tags; adds_tags; stats; is_essence_only;
  } =
  Pretext.OCaml.record [
    "id", Id.pp id;
    "type", Id.pp mod_type;
    "domain", Base_item.pp_domain domain;
    "generation_type", pp_generation_type generation_type;
    "groups", Id.Set.pp groups;
    "required_level", Pretext.OCaml.int required_level;
    "spawn_weights", Pretext.OCaml.list pp_spawn_weight spawn_weights;
    "generation_weights", Pretext.OCaml.list pp_spawn_weight generation_weights;
    "tags", Id.Set.pp tags;
    "adds_tags", Id.Set.pp adds_tags;
    "stats", Pretext.OCaml.list pp_stat stats;
    "is_essence_only", Pretext.OCaml.bool is_essence_only;
  ]

let pool = ref []
let id_map = ref Id.Map.empty
let mod_groups = ref Id.Set.empty
let mod_types = ref Id.Set.empty

type data = t list

let export (): data = !pool

let import (x: data) =
  pool := x;
  let add modifier =
    id_map := Id.Map.add modifier.id modifier !id_map;
    mod_groups := Id.Set.union modifier.groups !mod_groups;
    mod_types := Id.Set.add modifier.mod_type !mod_types
  in
  List.iter add x

let royale_rex = rex "Royale"

let no_tier_6_eldritch_implicit_tag = Id.make "no_tier_6_eldritch_implicit"
let no_tier_5_eldritch_implicit_tag = Id.make "no_tier_5_eldritch_implicit"
let no_tier_4_eldritch_implicit_tag = Id.make "no_tier_4_eldritch_implicit"
let no_tier_3_eldritch_implicit_tag = Id.make "no_tier_3_eldritch_implicit"
let no_tier_2_eldritch_implicit_tag = Id.make "no_tier_2_eldritch_implicit"
let no_tier_1_eldritch_implicit_tag = Id.make "no_tier_1_eldritch_implicit"

let chosen_name = Id.make "Chosen"
let of_the_order_name = Id.make "of the Order"

let load filename =
  let as_spawn_weight json =
    let tag = ref None in
    let weight = ref 0 in
    let handle_value (field, value) =
      match field with
        | "tag" ->
            tag := Some (JSON.as_id value)
        | "weight" ->
            weight := JSON.as_int value
        | _ ->
            ()
    in
    List.iter handle_value (JSON.as_object json);
    let tag =
      match !tag with
        | None ->
            fail "%s: no tag" (JSON.show_origin json)
        | Some tag ->
            tag
    in
    tag, !weight
  in
  let add_entry (id, json) =
    if id =~! royale_rex then
      let id = Id.make id in
      let mod_type = ref Id.empty in
      let domain = ref None in
      let generation_type = ref None in
      let groups = ref Id.Set.empty in
      let required_level = ref 0 in
      let spawn_weights = ref [] in
      let generation_weights = ref [] in
      let tags = ref Id.Set.empty in
      let adds_tags = ref Id.Set.empty in
      let stats = ref [] in
      let name = ref Id.empty in
      let is_essence_only = ref false in
      let handle_value (field, value) =
        match field with
          | "domain" ->
              domain := Base_item.as_domain value
          | "generation_type" ->
              (
                match JSON.as_string value with
                  | "prefix" ->
                      generation_type := Some `Prefix
                  | "suffix" ->
                      generation_type := Some `Suffix
                  | "eater_implicit" ->
                      generation_type := Some `Eater_implicit
                  | "archnemesis" ->
                      generation_type := Some `Eater_implicit
                  | "exarch_implicit" ->
                      generation_type := Some `Exarch_implicit
                  | "searing_exarch_implicit" ->
                      generation_type := Some `Exarch_implicit
                  | _ ->
                      ()
              )
          | "group" ->
              groups := Id.Set.add (JSON.as_id value) !groups
          | "groups" ->
              groups :=
                Id.Set.union
                  (JSON.as_array value |> List.map JSON.as_id |> Id.Set.of_list)
                  !groups
          | "name" ->
              name := JSON.as_id value
          | "type" ->
              mod_type := JSON.as_id value
          | "required_level" ->
              required_level := JSON.as_int value
          | "spawn_weights" ->
              spawn_weights := JSON.as_array value |> List.map as_spawn_weight
          | "generation_weights" ->
              generation_weights := JSON.as_array value |> List.map as_spawn_weight
          | "implicit_tags" ->
              tags := JSON.as_array value |> List.map JSON.as_id |> Id.Set.of_list
          | "adds_tags" ->
              adds_tags := JSON.as_array value |> List.map JSON.as_id |> Id.Set.of_list
          | "stats" ->
              let as_stat json =
                let id = ref Id.empty in
                let min = ref 0 in
                let max = ref 0 in
                let handle_value (field, value) =
                  match field with
                    | "id" -> id := JSON.as_id value
                    | "min" -> min := JSON.as_int value
                    | "max" -> max := JSON.as_int value
                    | _ -> ()
                in
                List.iter handle_value (JSON.as_object json);
                {
                  id = !id;
                  min = !min;
                  max = !max;
                }
              in
              stats := JSON.as_array value |> List.map as_stat
          | "is_essence_only" ->
              is_essence_only := JSON.as_bool value
          | _ ->
              ()
      in
      List.iter handle_value (JSON.as_object json);
      match !generation_type, !domain with
        | None, _ | _, None ->
            ()
        | Some generation_type,
          Some domain ->
            let ignored_unveiled_mod =
              match domain with
                | Unveiled ->
                    Id.compare !name chosen_name <> 0 &&
                    Id.compare !name of_the_order_name <> 0
                | _ ->
                    false
            in
            if not ignored_unveiled_mod then
              let spawn_weights = !spawn_weights in
              let generation_type =
                match generation_type with
                  | `Prefix -> Some Prefix
                  | `Suffix -> Some Suffix
                  | `Eater_implicit | `Exarch_implicit as generation_type ->
                      let no_tier tag =
                        List.exists
                          (fun (t, w) -> w = 0 && Id.compare t tag = 0)
                          spawn_weights
                      in
                      let tier =
                        if no_tier no_tier_6_eldritch_implicit_tag then Some Lesser else
                        if no_tier no_tier_5_eldritch_implicit_tag then Some Greater else
                        if no_tier no_tier_4_eldritch_implicit_tag then Some Grand else
                        if no_tier no_tier_3_eldritch_implicit_tag then Some Exceptional else
                        if no_tier no_tier_2_eldritch_implicit_tag then Some Exquisite else
                        if no_tier no_tier_1_eldritch_implicit_tag then Some Perfect else
                          None
                      in
                      match tier with
                        | None ->
                            None
                        | Some tier ->
                            match generation_type with
                              | `Eater_implicit -> Some (Eater_implicit tier)
                              | `Exarch_implicit -> Some (Exarch_implicit tier)
              in
              match generation_type with
                | None ->
                    ()
                | Some generation_type ->
                    let modifier =
                      {
                        id;
                        mod_type = !mod_type;
                        domain;
                        generation_type;
                        groups = !groups;
                        required_level = !required_level;
                        spawn_weights;
                        generation_weights = !generation_weights;
                        tags = !tags;
                        adds_tags = !adds_tags;
                        stats = !stats;
                        is_essence_only = !is_essence_only;
                      }
                    in
                    match Id.Map.find_opt id !id_map with
                      | Some _ ->
                          fail "%s: two mods with id %s" filename (Id.show id)
                      | None ->
                          pool := modifier :: !pool;
                          id_map := Id.Map.add id modifier !id_map;
                          mod_groups := Id.Set.union modifier.groups !mod_groups;
                          mod_types := Id.Set.add modifier.mod_type !mod_types
  in
  List.iter add_entry JSON.(parse_file filename |> as_object)

let by_id_opt id =
  Id.Map.find_opt id !id_map

let by_id id =
  match by_id_opt id with
    | None ->
        fail "no mod with id %S" (Id.show id)
    | Some x ->
        x

let group_exists id =
  Id.Set.mem id !mod_groups

let mod_type_exists id =
  Id.Set.mem id !mod_types

type show_mode =
  | With_placeholders
  | With_ranges
  | With_random_values

let show_identifiers = ref false
let show_group_identifiers = ref false

let show ?tier ?(indentation = 0) ?(fractured = false) mode modifier =
  let generation_type =
    match modifier.generation_type with
      | Prefix -> "(prefix) "
      | Suffix -> "(suffix) "
      | Exarch_implicit tier -> "(" ^ show_eldritch_tier tier ^ " Exarch) "
      | Eater_implicit tier -> "(" ^ show_eldritch_tier tier ^ " Eater) "
  in
  let fractured = if fractured then "{fractured} " else "" in
  let domain =
    match modifier.domain with
      | Item | Misc | Abyss_jewel | Unveiled | Flask -> ""
      | Crafted -> "{crafted} "
      | Veiled -> "{veiled} "
  in
  let tier =
    match tier with
      | None ->
          ""
      | Some tier ->
          "[T" ^ string_of_int tier ^ "] "
  in
  let influence =
    match Base_tag.get_influence_from_spawn_weights modifier.spawn_weights with
      | Some influence -> "*" ^ String.sub (Influence.show_sec influence) 0 1 ^ "* "
      | None -> ""
  in
  let margin =
    String.make
      (
        indentation +
        String.length generation_type +
        String.length domain +
        String.length tier +
        String.length influence
      )
      ' '
  in
  let translated_mod =
    match modifier.domain with
      | Veiled ->
          "????????"
      | _ ->
          let translate_mode: Stat_translation.translate_mode =
            let ranges =
              let add_range acc (stat: stat) = Id.Map.add stat.id (stat.min, stat.max) acc in
              List.fold_left add_range Id.Map.empty modifier.stats
            in
            match mode with
              | With_placeholders ->
                  With_placeholders ranges
              | With_ranges ->
                  With_ranges ranges
              | With_random_values ->
                  let choose_randomly (min, max) =
                    if max >= min then
                      min + Random.int (max - min + 1)
                    else
                      max + Random.int (min - max + 1)
                  in
                  With_values (Id.Map.map choose_randomly ranges)
          in
          let strings =
            let ids = List.map (fun (stat: stat) -> stat.id) modifier.stats in
            List.map (Stat_translation.translate_id translate_mode) ids
          in
          let strings = deduplicate String.compare strings in
          String.concat ("\n" ^ margin) strings
  in
  generation_type ^ fractured ^ domain ^ tier ^ influence ^
  translated_mod ^
  (if !show_identifiers then " (" ^ Id.show modifier.id ^ ")" else "") ^
  (
    if !show_group_identifiers then
      " (" ^ String.concat ", " (Id.Set.elements modifier.groups |> List.map Id.show) ^ ")"
    else
      ""
  )

let multimod_id = Id.make "StrIntMasterItemGenerationCanHaveMultipleCraftedMods"
let prefixes_cannot_be_changed_id = Id.make "StrMasterItemGenerationCannotChangePrefixes"
let suffixes_cannot_be_changed_id = Id.make "DexMasterItemGenerationCannotChangeSuffixes"
let cannot_roll_attack_mods_id = Id.make "IntMasterItemGenerationCannotRollAttackAffixes"
let cannot_roll_caster_mods_id = Id.make "StrDexMasterItemGenerationCannotRollCasterAffixes"

let beastcrafted_avian_aspect_id = Id.make "GrantsBirdAspectCrafted" (* Saqawal *)
let beastcrafted_cat_aspect_id = Id.make "GrantsCatAspectCrafted" (* Farrul *)
let beastcrafted_crab_aspect_id = Id.make "GrantsCrabAspectCrafted" (* Craiceann *)
let beastcrafted_spider_aspect_id = Id.make "GrantsSpiderAspectCrafted" (* Fenumus *)

let veiled_prefix_id = Id.make "VeiledPrefix"
let veiled_suffix_id = Id.make "VeiledSuffix"
let veiled_prefix_group = Id.make "VeiledPrefix"
let veiled_suffix_group = Id.make "VeiledSuffix"
let veiled_prefix_groups = Id.Set.singleton veiled_prefix_group
let veiled_suffix_groups = Id.Set.singleton veiled_suffix_group

type harvest_tag = [
  | `attack
  | `caster
  | `chaos
  | `cold
  | `critical
  | `defences
  | `fire
  | `life
  | `lightning
  | `physical
  | `speed
]

type tag = [
  | harvest_tag
  | `minion
  | `aura
  | `curse
  | `bleed
  | `poison
  | `elemental
  | `gem
  | `mana
  | `attribute
]

let attack_tag_id = Id.make "attack"
let caster_tag_id = Id.make "caster"
let chaos_tag_id = Id.make "chaos"
let cold_tag_id = Id.make "cold"
let critical_tag_id = Id.make "critical"
let defences_tag_id = Id.make "defences"
let fire_tag_id = Id.make "fire"
let life_tag_id = Id.make "life"
let lightning_tag_id = Id.make "lightning"
let physical_tag_id = Id.make "physical"
let speed_tag_id = Id.make "speed"
let minion_id = Id.make "minion"
let aura_id = Id.make "aura"
let curse_id = Id.make "curse"
let bleed_id = Id.make "bleed"
let poison_id = Id.make "poison"
let elemental_id = Id.make "elemental"
let gem_id = Id.make "gem"
let mana_id = Id.make "mana"
let attribute_id = Id.make "attribute"

let tag_id: [< tag ] -> Id.t = function
  | `attack -> attack_tag_id
  | `caster -> caster_tag_id
  | `chaos -> chaos_tag_id
  | `cold -> cold_tag_id
  | `critical -> critical_tag_id
  | `defences -> defences_tag_id
  | `fire -> fire_tag_id
  | `life -> life_tag_id
  | `lightning -> lightning_tag_id
  | `physical -> physical_tag_id
  | `speed -> speed_tag_id
  | `minion -> minion_id
  | `aura -> aura_id
  | `curse -> curse_id
  | `bleed -> bleed_id
  | `poison -> poison_id
  | `elemental -> elemental_id
  | `gem -> gem_id
  | `mana -> mana_id
  | `attribute -> attribute_id

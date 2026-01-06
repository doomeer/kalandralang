open Misc

type rarity =
  | Normal
  | Magic
  | Rare

let show_rarity = function
  | Normal -> "Normal"
  | Magic -> "Magic"
  | Rare -> "Rare"

let pp_rarity rarity =
  Pretext.OCaml.string (show_rarity rarity)

type modifier =
  {
    modifier: Mod.t;
    rolls: int Id.Map.t;
    fractured: bool;
  }

let pp_modifier { modifier; fractured; _ } =
  Pretext.OCaml.record [
    "modifier", Mod.pp modifier;
    "fractured", Pretext.OCaml.bool fractured;
  ]

type t =
  {
    base: Base_item.t;
    level: int;
    (* [tags] can expand or restrict the mod pool further (e.g. influences). *)
    tags: Id.Set.t;
    rarity: rarity;
    mods: modifier list;
    split: bool;
    influence: Influence.t;
  }

let pp { base; level; tags; rarity; mods; split; influence } =
  Pretext.OCaml.record [
    "base", Base_item.pp base;
    "level", Pretext.OCaml.int level;
    "tags", Id.Set.pp tags;
    "rarity", pp_rarity rarity;
    "mods", Pretext.OCaml.list pp_modifier mods;
    "split", Pretext.OCaml.bool split;
    "influence", Influence.pp influence;
  ]

let set_rarity rarity item =
  { item with rarity }

let get_max_rarity item =
  if item.base.domain = Flask then
    Magic
  else
    Rare

let set_max_rarity item =
  let rar = get_max_rarity item in
  set_rarity rar item

let is_fractured item =
  List.exists (fun { fractured; _ } -> fractured) item.mods

let is_prefix { modifier; _ } =
  Mod.is_prefix modifier

let is_suffix { modifier; _ } =
  Mod.is_suffix modifier

let is_prefix_or_suffix { modifier; _ } =
  Mod.is_prefix_or_suffix modifier

let prefix_and_suffix_count item =
  List.length (List.filter is_prefix_or_suffix item.mods)

(* TODO: jewels
   (domain "abyss_jewel" or ... misc for regular jewels
   or item_class "AbyssJewel" or "Jewel"
   or tag "abyss_jewel" or "jewel") *)
let max_prefix_count item =
  match item.rarity with
    | Normal -> 0
    | Magic -> 1
    | Rare ->
        if Base_item.is_jewel item.base then
          2
        else
          3

let max_suffix_count = max_prefix_count

let max_affix_count item = max_prefix_count item + max_suffix_count item

let prefix_count item =
  List.length (List.filter (fun { modifier; _ } -> Mod.is_prefix modifier) item.mods)

let suffix_count item =
  List.length (List.filter (fun { modifier; _ } -> Mod.is_suffix modifier) item.mods)

let affix_count item =
  prefix_count item + suffix_count item

let has_a_prefix item =
  List.exists (fun { modifier; _ } -> Mod.is_prefix modifier) item.mods

let has_a_suffix item =
  List.exists (fun { modifier; _ } -> Mod.is_suffix modifier) item.mods

let has_mod_id ?(must_be_fractured = false) modifier_id item =
  List.exists
    (fun { modifier; fractured; _ } ->
       (fractured || not must_be_fractured) &&
       Id.compare modifier.Mod.id modifier_id = 0)
    item.mods

let has_mod_group_id ?(must_be_fractured = false) group_id item =
  List.exists
    (fun { modifier; fractured; _ } ->
       (fractured || not must_be_fractured) &&
       Id.Set.mem group_id modifier.Mod.groups)
    item.mods

let has_mod modifier item =
  has_mod_id modifier.Mod.id item

(* My experiment on one mod (unveiling move speed + onslaught on boots)
   seems to show that implicits and prefixes/suffixes are independent,
   but this needs to be experimented on more. *)
(* Since we can only have one of each eldritch implicits,
   and [mod_pool] is used to *replace* mods when used with eldritch implicits,
   we allow all eldritch implicits to be in the mod pool. *)
let has_mod_group_prefix_or_suffix groups item =
  let is_group { modifier; _ } =
    match modifier.generation_type with
      | Prefix | Suffix ->
          not (Id.Set.disjoint groups modifier.Mod.groups)
      | Exarch_implicit _ | Eater_implicit _ ->
          false
  in
  List.exists is_group item.mods

let has_veiled_mod item =
  has_mod_group_prefix_or_suffix Mod.veiled_prefix_groups item ||
  has_mod_group_prefix_or_suffix Mod.veiled_suffix_groups item

let is_veiled { modifier; _ } =
  Id.Set.mem Mod.veiled_prefix_group modifier.Mod.groups ||
  Id.Set.mem Mod.veiled_suffix_group modifier.Mod.groups

let has_unveiled_mod item =
  List.exists
    (function { modifier = { domain = Unveiled; _ }; _ } -> true | _ -> false)
    item.mods

let crafted_mod_count item =
  List.length (List.filter (fun { modifier; _ } -> Mod.is_crafted modifier) item.mods)

let max_crafted_mod_count item =
  if has_mod Mod.(by_id multimod_id) item then
    3
  else
    1

(* Base tags include influence tags but not tags added by mods such as
   [has_flat_intelligence_mod]. *)
let base_tags item =
  Id.Set.union item.base.tags item.tags

let tags item =
  let add_mod_added_tags acc { modifier; _ } = Id.Set.union acc modifier.Mod.adds_tags in
  List.fold_left add_mod_added_tags (base_tags item) item.mods

let has_tag tag item =
  Id.Set.mem tag (tags item)

let get_type item =
  Base_tag.get_item_type_from_tags item.base.tags

type only =
  | Prefixes_and_suffixes
  | Prefixes
  | Suffixes
  | Eater_implicits of Mod.eldritch_tier
  | Exarch_implicits of Mod.eldritch_tier

(* Mod pool for a given domain and a given set of item tags (i.e. including SEC influences).
   Includes Eldritch implicits (all tiers).
   Not restricted by:
   - ilvl;
   - whether prefixes / suffixes are full;
   - existing mods;
   - fossils;
   - meta-mods;
   - etc. *)
(* TODO: can improve performances further by not returning Eldritch implicits
   and treating them separately. *)
let full_mod_pool = memoize @@ fun (domain, item_tags, keep_weight_0_tag) ->
  let can_spawn_mod modifier =
    if modifier.Mod.domain <> domain then
      None
    else
      let matching_tag (tag, _) = Id.Set.mem tag item_tags in
      match List.find_opt matching_tag modifier.spawn_weights with
        | None ->
            None
        | Some (tag, weight) when weight <= 0 && domain <> Crafted ->
            (
              match keep_weight_0_tag with
                | None ->
                    None
                | Some keep_tag ->
                    if Id.compare tag keep_tag = 0 then
                      Some (weight, modifier)
                    else
                      None
            )
        | Some (_, weight) ->
            match List.find_opt matching_tag modifier.generation_weights with
              | None ->
                  Some (weight, modifier)
              | Some (_, percent_multiplier) ->
                  let weight = weight * percent_multiplier / 100 in
                  if weight <= 0 && domain <> Crafted then
                    None
                  else
                    Some (weight, modifier)
  in
  List.filter_map can_spawn_mod !Mod.pool

let sort_tier_group = memoize @@ fun (domain, item_tags, mod_type, keep_weight_0_tag) ->
  let pool =
    let has_mod_type (_, modifier) =
      match modifier.Mod.generation_type with
        | Prefix | Suffix ->
            if Id.compare mod_type modifier.Mod.mod_type = 0 then
              Some modifier
            else
              None
        | Exarch_implicit _ | Eater_implicit _ ->
            (* We don't want those in the mod pool while computing tiers. *)
            None
    in
    full_mod_pool (domain, item_tags, keep_weight_0_tag)
    |> List.filter_map has_mod_type
  in
  (* [mod2] and [mod1] are reversed because we want to sort in reverse order. *)
  let by_ilvl_or_stat (mod2: Mod.t) (mod1: Mod.t) =
    let c = Int.compare mod1.required_level mod2.required_level in
    if c <> 0 then c else
      (* Both mods require the same ilvl.
         So we try to sort by stats instead. *)
      let sum_stats (modifier: Mod.t) =
        let add_stats acc ({ id = _; min; max }: Mod.stat) = acc + min + max in
        List.fold_left add_stats 0 modifier.stats
      in
      (* echo "same: %s and %s" (Mod.show With_ranges mod2) (Mod.show With_ranges mod1); *)
      Int.compare (sum_stats mod1) (sum_stats mod2)
  in
  List.sort by_ilvl_or_stat pool |> list_group by_ilvl_or_stat

let mod_tier =
  let mod_tier_memoized = memoize @@ fun (domain, item_tags, mod_type, mod_id) ->
    let sorted_group = sort_tier_group (domain, item_tags, mod_type, None) in
    let rec find_mod tier = function
      | [] ->
          (* echo "cannot find mod %s" (Id.show mod_id); *)
          (* let echo_mod modifier = *)
          (*   echo "- %s" (Mod.show With_ranges modifier) *)
          (* in *)
          (* echo "tags = %s" (Id.Set.show item_tags); *)
          (* List.iter echo_mod sorted_group; *)
          None
      | head :: tail ->
          if
            List.exists
              (fun candidate -> Id.compare candidate.Mod.id mod_id = 0)
              head
          then
            Some tier
          else
            find_mod (tier + 1) tail
    in
    find_mod 1 sorted_group
  in
  let essence_mod_tier mod_id =
    match Essence.by_mod_id_opt mod_id with
      | None ->
          None
      | Some essence ->
          Some (Essence.tier essence.level)
  in
  fun item (modifier: Mod.t) ->
    (* We use [base_tags] and not the [tags] function
       because we don't want the mod pool to be modified by added tags such as
       [has_flat_intelligence_mod] when computing tiers. *)
    if modifier.is_essence_only then
      essence_mod_tier modifier.id
    else
      mod_tier_memoized (modifier.domain, base_tags item, modifier.mod_type, modifier.id)

let show_modifier item { modifier; fractured; rolls } =
  let tier = mod_tier item modifier in
  Mod.show ?tier ~fractured ~rolls With_rolled_values modifier

let show item =
  let compare_mods
      { modifier = a; fractured = _; rolls = _ }
      { modifier = b; fractured = _; rolls = _ } =
    match a.Mod.domain, b.Mod.domain with
      | Item, Crafted -> -1
      | Crafted, Item -> 1
      | _ ->
          let int_of_generation_type = function
            | Mod.Exarch_implicit _ -> 0
            | Mod.Eater_implicit _ -> 1
            | Mod.Prefix -> 2
            | Mod.Suffix -> 3
          in
          let c =
            Int.compare
              (int_of_generation_type a.Mod.generation_type)
              (int_of_generation_type b.Mod.generation_type)
          in
          if c <> 0 then c else Id.compare a.id b.id
  in
  let mods = List.sort compare_mods item.mods in
  let rarity = show_rarity item.rarity in
  let influence =
    match item.influence with
      | Not_influenced ->
          ""
      | Fractured ->
          " (Fractured)"
      | Synthesized ->
          " (Synthesized)"
      | SEC sec ->
          " (" ^ Influence.show_sec sec ^ ")"
      | SEC_pair (sec1, sec2) ->
          " (" ^ Influence.show_sec sec1 ^ " / " ^ Influence.show_sec sec2 ^ ")"
      | Exarch ->
          " (Exarch)"
      | Eater ->
          " (Eater)"
      | Exarch_and_eater ->
          " (Exarch / Eater)"
  in
  let split = if item.split then [ "Split" ] else [] in
  "--------\n" ^ Id.show item.base.name ^ " (" ^ rarity ^ ")" ^ influence ^ "\n--------\n" ^
  String.concat "\n" (List.map (show_modifier item) mods @ split) ^ "\n--------"

(* If [tag] is specified, restrict the mod pool to mods with this tag. *)
let mod_pool ?(fossils = []) ?tag ?tag_more_common
    ?(crafted = false) ?(unveiled = false) ?(only = Prefixes_and_suffixes)
    ?(mod_groups = Id.Set.empty) ?mod_group_multiplier item =
  let item_tags = tags item in
  let prefix_count = prefix_count item in
  let suffix_count = suffix_count item in
  let max_prefix = max_prefix_count item in
  let max_suffix = max_suffix_count item in
  let allow_prefix, allow_suffix =
    match only with
      | Prefixes_and_suffixes -> true, true
      | Prefixes -> true, false
      | Suffixes -> false, true
      | Eater_implicits _ | Exarch_implicits _ -> false, false
  in
  let not_tags =
    Id.Set.of_list @@ List.flatten [
      if has_mod Mod.(by_id cannot_roll_attack_mods_id) item then
        [ Mod.attack_tag_id ]
      else
        [];
      if has_mod Mod.(by_id cannot_roll_caster_mods_id) item then
        [ Mod.caster_tag_id ]
      else
        [];
    ]
  in
  let can_spawn_mod (_, modifier) =
    let can_spawn_this_generation_type =
      (* Note: max prefix/suffix count is handled below, not here *)
      match only, modifier.Mod.generation_type with
        | Prefixes_and_suffixes, (Prefix | Suffix)
        | Prefixes, Prefix
        | Suffixes, Suffix ->
            true
        | Exarch_implicits only_tier, Exarch_implicit mod_tier
        | Eater_implicits only_tier, Eater_implicit mod_tier ->
            only_tier = mod_tier
        | _ ->
            false
    in
    let already_has_mod_group = has_mod_group_prefix_or_suffix modifier.Mod.groups item in
    if
      match tag with
        | None -> false
        | Some tag -> not (Id.Set.mem (Mod.tag_id tag) modifier.tags)
    then
      None
    else if modifier.Mod.required_level > item.level then
      None
    else if Mod.is_prefix modifier && (not allow_prefix || prefix_count >= max_prefix) then
      None
    else if Mod.is_suffix modifier && (not allow_suffix || suffix_count >= max_suffix) then
      None
    else if not can_spawn_this_generation_type then
      None
    else if already_has_mod_group then
      None
    else if not (Id.Set.is_empty (Id.Set.inter not_tags modifier.tags)) then
      None
    else
      let matching_tag (tag, weight) =
        if Id.Set.mem tag item_tags then
          Some weight
        else
          None
      in
      let spawn_weights =
        match fossils with
          | [] ->
              modifier.spawn_weights
          | _ :: _ ->
              let apply_combination (id, weight) =
                id, Fossil.apply_combination fossils modifier.tags weight
              in
              List.map apply_combination modifier.spawn_weights
      in
      match List.find_map matching_tag spawn_weights with
        | None ->
            None
        | Some weight when weight <= 0 && not crafted ->
            None
        | Some weight ->
            match List.find_map matching_tag modifier.generation_weights with
              | None ->
                  Some (weight, modifier)
              | Some percent_multiplier ->
                  let weight = weight * percent_multiplier / 100 in
                  if weight <= 0 && not crafted then
                    None
                  else
                    Some (weight, modifier)
  in
  let domain =
    if crafted then Base_item.Crafted else
    if unveiled then Unveiled else
      item.base.domain
  in
  let mod_pool = List.filter_map can_spawn_mod (full_mod_pool (domain, item_tags, None)) in
  let mod_pool =
    match mod_group_multiplier with
      | None ->
          mod_pool
      | Some multiplier ->
          let adjust_weight (weight, modifier) =
            if not (Id.Set.disjoint modifier.Mod.groups mod_groups) then
              int_of_float (float weight *. multiplier), modifier
            else
              weight, modifier
          in
          List.map adjust_weight mod_pool
  in
  match tag_more_common with
    | None ->
        mod_pool
    | Some (multiplied_tag, multiplier) ->
        let multiplied_tag = Mod.tag_id multiplied_tag in
        let adjust_weight (weight, modifier) =
          if Id.Set.mem multiplied_tag modifier.Mod.tags then
            int_of_float (float weight *. multiplier), modifier
          else
            weight, modifier
        in
        List.map adjust_weight mod_pool

let add_mod_force ?(fractured = false) modifier item =
  { item with mods = {
        modifier;
        fractured;
        rolls = Mod.roll_stats modifier
      } :: item.mods
  }

let add_mod ?(fractured = false) modifier item =
  if Mod.is_prefix modifier && prefix_count item >= max_prefix_count item then
    fail "cannot add another prefix";
  if Mod.is_suffix modifier && suffix_count item >= max_suffix_count item then
    fail "cannot add another suffix";
  if Mod.is_crafted modifier then (
    if crafted_mod_count item >= max_crafted_mod_count item then
      fail "item cannot have another crafted mod";
  )
  else (
    if has_mod_group_prefix_or_suffix modifier.groups item then
      fail "item already has a mod for this group";
  );
  add_mod_force ~fractured modifier item

let spawn_random_mod ?(fail_if_impossible = true) ?fossils ?tag ?tag_more_common ?only
    ?mod_groups ?mod_group_multiplier item =
  match
    random_from_pool
      (mod_pool ?fossils ?tag ?tag_more_common ?only ?mod_groups ?mod_group_multiplier item)
  with
    | None ->
        if fail_if_impossible then
          match tag with
            | None ->
                fail "item cannot spawn any mod"
            | Some tag ->
                fail "item cannot spawn any mod with tag %s" (Id.show (Mod.tag_id tag))
        else
          item
    | Some modifier ->
        add_mod_force modifier item

type meta =
  {
    prefixes_cannot_be_changed: bool;
    suffixes_cannot_be_changed: bool;
    cannot_roll_attack_mods: bool;
    cannot_roll_caster_mods: bool;
  }

let meta
    ?(force_prefixes_cannot_be_changed = false)
    ?(force_suffixes_cannot_be_changed = false)
    ~respect_cannot_be_changed
    ~respect_cannot_roll
    item =
  let prefixes_cannot_be_changed =
    force_prefixes_cannot_be_changed || (
      respect_cannot_be_changed &&
      has_mod Mod.(by_id prefixes_cannot_be_changed_id) item
    )
  in
  let suffixes_cannot_be_changed =
    force_suffixes_cannot_be_changed || (
      respect_cannot_be_changed &&
      has_mod Mod.(by_id suffixes_cannot_be_changed_id) item
    )
  in
  let cannot_roll_attack_mods =
    respect_cannot_roll &&
    has_mod Mod.(by_id cannot_roll_attack_mods_id) item
  in
  let cannot_roll_caster_mods =
    respect_cannot_roll &&
    has_mod Mod.(by_id cannot_roll_caster_mods_id) item
  in
  {
    prefixes_cannot_be_changed;
    suffixes_cannot_be_changed;
    cannot_roll_attack_mods;
    cannot_roll_caster_mods;
  }

let can_be_removed meta { modifier; fractured; _ } =
  Mod.is_prefix_or_suffix modifier &&
  not fractured &&
  not (meta.prefixes_cannot_be_changed && Mod.is_prefix modifier) &&
  not (meta.suffixes_cannot_be_changed && Mod.is_suffix modifier) &&
  not (meta.cannot_roll_attack_mods && Mod.is_attack modifier) &&
  not (meta.cannot_roll_caster_mods && Mod.is_caster modifier)

let remove_random_mod
    ?without_tag
    ?force_prefixes_cannot_be_changed
    ?force_suffixes_cannot_be_changed
    ~respect_cannot_be_changed
    ~respect_cannot_roll
    item =
  let meta =
    meta
      ?force_prefixes_cannot_be_changed
      ?force_suffixes_cannot_be_changed
      ~respect_cannot_be_changed
      ~respect_cannot_roll
      item
  in
  let removable_mods = List.filter (can_be_removed meta) item.mods in
  let removable_mods =
    match without_tag with
      | None ->
          removable_mods
      | Some tag ->
          let tag_id = Mod.tag_id tag in
          let can_be_removed { modifier; _ } = not (Id.Set.mem tag_id modifier.tags) in
          List.filter can_be_removed item.mods
  in
  let removable_mod_count = List.length removable_mods in
  if removable_mod_count <= 0 then
    fail "item has no removable mod";
  let mod_to_remove = (Array.of_list removable_mods).(Random.int removable_mod_count) in
  let mods =
    List.filter
      (fun { modifier; _ } -> Id.compare modifier.Mod.id mod_to_remove.modifier.id <> 0)
      item.mods
  in
  { item with mods }

let remove_crafted_mods item =
  let mods = List.filter (fun { modifier; _ } -> not (Mod.is_crafted modifier)) item.mods in
  { item with mods }

let remove_all_mods ~respect_cannot_be_changed ~respect_cannot_roll item =
  let meta = meta ~respect_cannot_be_changed ~respect_cannot_roll item in
  let mods = List.filter (fun modifier -> not (can_be_removed meta modifier)) item.mods in
  { item with mods }

let remove_all_prefixes item =
  let mods =
    List.filter
      (fun { modifier; fractured; _ } -> fractured || not (Mod.is_prefix modifier))
      item.mods
  in
  { item with mods }

let remove_all_suffixes item =
  let mods =
    List.filter
      (fun { modifier; fractured; _ } -> fractured || not (Mod.is_suffix modifier))
      item.mods
  in
  { item with mods }

let harvest_augment_and_remove ~tag item =
  (* Choose mod to add before removing a random mod, because this random mod is
     actually removed *after* adding. *)
  match
    random_from_pool (mod_pool ~tag item)
  with
    | None ->
        fail "item cannot spawn any mod with tag %s" (Id.show (Mod.tag_id tag))
    | Some modifier ->
        let item =
          remove_random_mod item
            ~respect_cannot_be_changed: true
            ~respect_cannot_roll: false
        in
        add_mod_force modifier item

let set_to_lowest_possible_rarity item =
  let p = prefix_count item in
  let s = suffix_count item in
  let rarity =
    if p > 1 || s > 1 then Rare else
    if p > 0 || s > 0 then Magic else
      Normal
  in
  { item with rarity }

let spawn_additional_random_mods ?fossils ?tag_more_common ?only
    ?mod_groups ?mod_group_multiplier item =
  let spawn_random_mod =
    spawn_random_mod ~fail_if_impossible: false ?fossils ?tag_more_common ?only
      ?mod_groups ?mod_group_multiplier
  in
  let final_mod_count =
    match item.rarity with
      | Normal ->
          0
      | Magic ->
          let w1 = 50 in
          let w2 = 50 in
          let i = Random.int (w1 + w2) in
          if i < w1 then 1 else 2
      | Rare ->
          if item.base.domain = Flask then
            let w1 = 50 in
            let w2 = 50 in
            let i = Random.int (w1 + w2) in
            if i < w1 then 1 else 2
          else if Base_item.is_jewel item.base then
            let w3 = 65 in
            let w4 = 35 in
            let i = Random.int (w3 + w4) in
            if i < w3 then 3 else 4
          else
            let w4 = 8 in
            let w5 = 3 in
            let w6 = 1 in
            let i = Random.int (w4 + w5 + w6) in
            if i < w4 then 4 else if i < w4 + w5 then 5 else 6
  in
  let rec spawn_n_mods count item =
    if count <= 0
    then item
    else item |> spawn_random_mod |> (spawn_n_mods (count-1))
  in
  spawn_n_mods (final_mod_count - prefix_and_suffix_count item) item

let reforge_magic item =
  let item =
    remove_all_mods item
      ~respect_cannot_be_changed: true
      ~respect_cannot_roll: false
  in
  spawn_additional_random_mods item

(* If [modifier] is specified, [tag] cannot be specified; [modifier] is added first. *)
(* The first added mod always has [tag]. *)
(* [tag_more_common = (multiplied_tag, multiplier)] multiplies the weight of
   mods that have tag [multiplied_tag] by [multiplier]. *)
(* [mod_group_multiplier] multiplies the weight of all [mod_groups]. *)
let reforge_rare ?(respect_cannot_be_changed = true) ?fossils ?tag ?tag_more_common
    ?mod_groups ?mod_group_multiplier ?modifier item =
  let item =
    remove_all_mods item
      ~respect_cannot_be_changed
      ~respect_cannot_roll: false
  in
  let item =
    match tag, modifier with
      | _, None ->
          spawn_random_mod ?fossils ?tag ?tag_more_common
            ?mod_groups ?mod_group_multiplier item
      | None, Some modifier ->
          add_mod modifier item
      | Some _, Some _ ->
          invalid_arg "Item.reforge_rare cannot take both ?tag and ?modifier"
  in
  spawn_additional_random_mods ?fossils ?tag_more_common
    ?mod_groups ?mod_group_multiplier item

let reforge_rare_suffixes ?(can_add_prefixes = true) item =
  let item = remove_all_suffixes item in
  let only = if can_add_prefixes then None else Some Suffixes in
  let item = spawn_random_mod ~fail_if_impossible: false ?only item in
  spawn_additional_random_mods ?only item

let reforge_rare_prefixes ?(can_add_suffixes = true) item =
  let item = remove_all_prefixes item in
  let only = if can_add_suffixes then None else Some Prefixes in
  let item = spawn_random_mod ~fail_if_impossible: false ?only item in
  spawn_additional_random_mods ?only item

let add_sec_influence_tag influence item =
  match Base_tag.get_influence_tag_for_tags item.base.tags influence with
    | None ->
        fail "cannot add an influence to this item type"
    | Some influence_tag ->
        { item with tags = Id.Set.add influence_tag item.tags }

let add_influence influence item =
  let item = { item with influence = Influence.add item.influence influence } in
  match influence with
    | SEC sec ->
        item |> add_sec_influence_tag sec
    | SEC_pair (sec1, sec2) ->
        item |> add_sec_influence_tag sec1 |> add_sec_influence_tag sec2
    | Not_influenced | Fractured | Synthesized | Exarch | Eater | Exarch_and_eater ->
        item

let make ?rarity base level influence =
  let item =
    {
      base;
      level;
      rarity = rarity |> default Rare;
      tags = Id.Set.empty;
      mods = [];
      split = false;
      influence = Not_influenced;
    }
  in
  let item = match rarity with None -> set_max_rarity item | Some _ -> item in
  add_influence influence item

let is_influence_mod influence_tag modifier =
  let tag_with_weight (mod_tag, weight) =
    weight > 0 &&
    Id.compare mod_tag influence_tag = 0
  in
  List.exists tag_with_weight modifier.Mod.spawn_weights

let spawn_random_sec_influence_mod influence item =
  match Base_tag.get_influence_tag_for_tags item.base.tags influence with
    | None ->
        fail "cannot add influence to this item type"
    | Some influence_tag ->
        let item = add_influence (SEC influence) item in
        let pool = mod_pool item in
        let pool =
          let is_influence_mod (_, modifier) = is_influence_mod influence_tag modifier in
          List.filter is_influence_mod pool
        in
        match random_from_pool pool with
          | None ->
              fail "item cannot spawn any mod for this influence"
          | Some modifier ->
              add_mod_force modifier item

let add_random_veiled_mod item =
  match prefix_count item < 3, suffix_count item < 3 with
    | false, false ->
        fail "item has no space for another mod"
    | true, false ->
        add_mod Mod.(by_id veiled_prefix_id) item
    | false, true ->
        add_mod Mod.(by_id veiled_suffix_id) item
    | true, true ->
        (* TODO: do the weights apply? *)
        if Random.bool () then
          add_mod Mod.(by_id veiled_prefix_id) item
        else
          add_mod Mod.(by_id veiled_suffix_id) item

let remove_random_mod_add_veiled_mod item =
  if has_veiled_mod item then fail "item already has a veiled modifier";
  if has_unveiled_mod item then fail "item already has an unveiled modifier";
  let item =
    remove_random_mod item
      ~respect_cannot_be_changed: true
      ~respect_cannot_roll: false
  in
  add_random_veiled_mod item

(* [tag] is only applied to the first added mod. *)
let reforge_rare_with_veiled_mod item =
  let item =
    remove_all_mods item
      ~respect_cannot_be_changed: true
      ~respect_cannot_roll: false
  in
  let item = add_random_veiled_mod item in
  spawn_additional_random_mods item

let is_prefix_or_suffix { modifier; _ } = Mod.is_prefix_or_suffix modifier

let split item =
  if item.split then fail "item is already split";
  let mods_to_split, non_splittable_mods = List.partition is_prefix_or_suffix item.mods in
  let pool = Pool.create_from_list mods_to_split in
  (* Both resulting items will have at least one mod. *)
  let mandatory_mod1, mandatory_mod2 =
    let mod1 = Pool.pick pool in
    let mod2 = Pool.pick pool in
    match mod1, mod2 with
      | Some mod1, Some mod2 -> mod1, mod2
      | None, _ | _, None -> fail "cannot split an item with less than two modifiers"
  in
  let other_mods1, other_mods2 =
    List.partition (fun _ -> Random.bool ()) (Pool.to_list pool)
  in
  let mods1 = mandatory_mod1 :: other_mods1 @ non_splittable_mods in
  let mods2 = mandatory_mod2 :: other_mods2 @ non_splittable_mods in
  set_to_lowest_possible_rarity { item with mods = mods1; split = true },
  set_to_lowest_possible_rarity { item with mods = mods2; split = true }

let is_exarch_implicit_or_not_an_implicit { modifier; _ } =
  Mod.is_exarch_implicit modifier ||
  not (Mod.is_implicit modifier)

let is_eater_implicit_or_not_an_implicit { modifier; _ } =
  Mod.is_eater_implicit modifier ||
  not (Mod.is_implicit modifier)

let remove_all_implicits_except_exarch item =
  let mods = List.filter is_exarch_implicit_or_not_an_implicit item.mods in
  { item with mods }

let remove_all_implicits_except_eater item =
  let mods = List.filter is_eater_implicit_or_not_an_implicit item.mods in
  { item with mods }

let spawn_random_exarch_implicit tier item =
  spawn_random_mod ~only: (Exarch_implicits tier) item

let spawn_random_eater_implicit tier item =
  spawn_random_mod ~only: (Eater_implicits tier) item

let apply_eldritch_ichor tier item =
  item
  |> add_influence Eater
  |> remove_all_implicits_except_exarch
  |> spawn_random_eater_implicit tier

let apply_eldritch_ember tier item =
  item
  |> add_influence Exarch
  |> remove_all_implicits_except_eater
  |> spawn_random_exarch_implicit tier

type dominant_eldritch =
  | Exarch
  | Eater

let get_dominant_eldritch item =
  let exarch_tier = ref None in
  let eater_tier = ref None in
  let update_tiers { modifier; _ } =
    match modifier.generation_type with
      | Exarch_implicit tier -> exarch_tier := Some tier
      | Eater_implicit tier -> eater_tier := Some tier
      | _ -> ()
  in
  List.iter update_tiers item.mods;
  match !exarch_tier, !eater_tier with
    | None, None -> None
    | None, Some _ -> Some Eater
    | Some _, None -> Some Exarch
    | Some exarch_tier, Some eater_tier ->
        let c = Mod.compare_eldritch_tiers exarch_tier eater_tier in
        if c > 0 then Some Exarch else
        if c < 0 then Some Eater else
          None

let with_dominance item f =
  match get_dominant_eldritch item with
    | None ->
        fail "neither the Searing Exarch nor the Eater of Worlds is dominant"
    | Some dominance ->
        f dominance

let apply_eldritch_annul item =
  with_dominance item @@ function
  | Exarch ->
      remove_random_mod
        ~force_suffixes_cannot_be_changed: true
        ~respect_cannot_be_changed: true
        ~respect_cannot_roll: true
        item
  | Eater ->
      remove_random_mod
        ~force_prefixes_cannot_be_changed: true
        ~respect_cannot_be_changed: true
        ~respect_cannot_roll: true
        item

let apply_eldritch_exalt item =
  with_dominance item @@ function
  | Exarch -> spawn_random_mod ~only: Prefixes item
  | Eater -> spawn_random_mod ~only: Suffixes item

let apply_eldritch_chaos item =
  with_dominance item @@ function
  | Exarch -> reforge_rare_prefixes ~can_add_suffixes: false item
  | Eater -> reforge_rare_suffixes ~can_add_prefixes: false item

let reforge_with_mod_group_multiplier mod_group_multiplier item =
  let mod_groups =
    let get_group acc { modifier; _ } =
      if Mod.is_prefix_or_suffix modifier then
        Id.Set.union acc modifier.groups
      else
        acc
    in
    List.fold_left get_group Id.Set.empty item.mods
  in
  reforge_rare ~mod_groups ~mod_group_multiplier item

let prepare_unveil item =
  let veiled_mods, not_veiled_mods = List.partition is_veiled item.mods in
  let veiled_mod =
    match veiled_mods with
      | [] ->
          fail "item has no veiled mod"
      | _ :: _ :: _ ->
          fail "item has several veiled mods"
      | [ x ] ->
          x
  in
  let item = { item with mods = not_veiled_mods } in
  let unveiled_mod_pool =
    let only =
      match veiled_mod.modifier.generation_type with
        | Prefix -> Prefixes
        | Suffix -> Suffixes
        | _ -> fail "veiled mod is neither a prefix nor a suffix"
    in
    mod_pool ~unveiled: true ~only item
  in
  item, unveiled_mod_pool

let remove_mod_group (modifier: Mod.t option) pool =
  match modifier with
    | None ->
        pool
    | Some { groups; _ } ->
        List.filter (fun (_, modifier) -> Id.Set.disjoint modifier.Mod.groups groups) pool

let unveil item =
  let item, pool = prepare_unveil item in
  let mod1 = random_from_pool pool in
  let pool = remove_mod_group mod1 pool in
  let mod2 = random_from_pool pool in
  let pool = remove_mod_group mod2 pool in
  let mod3 = random_from_pool pool in
  item, List.filter_map Fun.id [ mod1; mod2; mod3 ]

let apply_orb_of_dominance item =
  let influences =
    match item.influence with
      | SEC x -> [ x ]
      | SEC_pair (x, y) -> [ x; y ]
      | Not_influenced
      | Fractured
      | Synthesized
      | Exarch
      | Eater
      | Exarch_and_eater ->
          fail "item does not have a Shaper / Elder / Conqueror influence"
  in
  let candidates =
    let elevate_if_possible { modifier; fractured; _ } =
      let elevate_with_influence_if_possible (influence: Influence.sec) =
        match Base_tag.get_influence_tag_for_tags item.base.tags influence with
          | None ->
              None
          | Some influence_tag ->
              let has_weight (tag, _) = Id.compare tag influence_tag = 0 in
              if List.exists has_weight modifier.spawn_weights then
                let mod_group =
                  sort_tier_group (
                    modifier.domain,
                    base_tags item,
                    modifier.mod_type,
                    Some influence_tag
                  )
                in
                let rec elevate upgraded_version = function
                  | [] ->
                      upgraded_version
                  | [ head ] :: tail ->
                      if Id.compare head.Mod.id modifier.id = 0 then
                        upgraded_version
                      else
                        elevate (Some head) tail
                  | (_ :: _ :: _ | []) :: _ ->
                      (* Cannot elevate when there are multiple or no mods to elevate to. *)
                      None
                in
                Some (modifier, elevate None mod_group)
              else
                None
      in
      if fractured then
        None
      else
        List.find_map elevate_with_influence_if_possible influences
    in
    List.filter_map elevate_if_possible item.mods
  in
  (* Choose a mod to elevate. *)
  let elevatable_candidates =
    List.filter_map
      (fun (m, e) -> match e with None -> None | Some e -> Some (m, e))
      candidates
  in
  let candidate_count = List.length elevatable_candidates in
  if candidate_count <= 0 then fail "item has no mod that can be elevated";
  let to_elevate, elevated =
    List.nth elevatable_candidates (Random.int candidate_count)
  in
  (* Remove chosen mod from list of candidates. *)
  let candidates =
    List.filter
      (fun (m, _) -> Id.compare m.Mod.id to_elevate.id <> 0)
      candidates
  in
  (* Choose a mod to remove. *)
  let candidate_count = List.length candidates in
  if candidate_count <= 0 then fail "item must have at least two influenced modifiers";
  let to_remove, _ = List.nth candidates (Random.int candidate_count) in
  (* Replace the mods on the item. *)
  let mods =
    List.filter_map
      (fun ({ modifier; _ } as x) ->
         if Id.compare modifier.id to_remove.id = 0 then
           None
         else if Id.compare modifier.id to_elevate.id = 0 then
           Some { modifier = elevated; fractured = false; rolls = Mod.roll_stats elevated }
         else
           Some x)
      item.mods
  in
  { item with mods }

let get_influence_tags item =
  match item.influence with
    | Not_influenced
    | Fractured
    | Synthesized
    | Exarch
    | Eater
    | Exarch_and_eater ->
        Id.Set.empty
    | SEC sec ->
        (
          match Base_tag.get_influence_tag (get_type item) sec with
            | None -> Id.Set.empty
            | Some tag -> Id.Set.singleton tag
        )
    | SEC_pair (sec1, sec2) ->
        let item_type = get_type item in
        let tags1 =
          match Base_tag.get_influence_tag item_type sec1 with
            | None -> Id.Set.empty
            | Some tag -> Id.Set.singleton tag
        in
        let tags2 =
          match Base_tag.get_influence_tag item_type sec2 with
            | None -> Id.Set.empty
            | Some tag -> Id.Set.singleton tag
        in
        Id.Set.union tags1 tags2

(* /r/pathofexile/comments/v0nm0c/the_complete_guide_to_recombinators/ *)
let recombine item1 item2 =
  let selected_base, forbidden_influence_tags =
    let selected_item, forbidden_influence_tags =
      let item1_influence_tags = get_influence_tags item1 in
      let item2_influence_tags = get_influence_tags item2 in
      if Random.bool () then
        (* The only influenced mods that can occur on the item we don't pick
           necessarily have the influence of this item.
           We can thus simply forbid the influences of the item we don't
           pick, unless the item we pick has those influences. *)
        item1, Id.Set.diff item2_influence_tags item1_influence_tags
      else
        item2, Id.Set.diff item1_influence_tags item2_influence_tags
    in
    {
      base = selected_item.base;
      level = (item1.level + item2.level) / 2; (* TODO: check *)
      tags = selected_item.tags;
      rarity = Rare; (* Will be updated at the end. *)
      mods = List.filter (fun m -> not (is_prefix_or_suffix m)) selected_item.mods;
      split = selected_item.split;
      influence = selected_item.influence;
    },
    forbidden_influence_tags
  in
  let prefix_mod_pool =
    List.filter is_prefix item1.mods @
    List.filter is_prefix item2.mods
  in
  let suffix_mod_pool =
    List.filter is_suffix item1.mods @
    List.filter is_suffix item2.mods
  in
  let pick pool =
    let count =
      match List.length pool with
        | 0 ->
            0
        | 1 ->
            (
              match Random.int 3 with
                | 0 | 1 -> 1
                | 2 | _ -> 0
            )
        | 2 ->
            (
              match Random.int 3 with
                | 0 -> 2
                | 1 | 2 | _ -> 1
            )
        | 3 ->
            let c = Random.int 100 in
            if c < 20 then 3 else
            if c < 70 then 2 else
              1
        | 4 ->
            let c = Random.int 100 in
            if c < 35 then 3 else
            if c < 90 then 2 else
              1
        | 5 ->
            let c = Random.int 100 in
            if c < 50 then 3 else 2
        | _ ->
            let c = Random.int 100 in
            if c < 70 then 3 else 2
    in
    (* Remove mods that require influence which is not present. *)
    (* TODO: It is unclear if the mods should be removed before or after
       computing [count]. *)
    let pool =
      let not_forbidden { modifier; _ } =
        let not_forbidden_weight (tag, _) =
          not (Id.Set.mem tag forbidden_influence_tags)
        in
        List.for_all not_forbidden_weight modifier.spawn_weights
      in
      List.filter not_forbidden pool
    in
    (* Pick mods, but do not select the same group twice. *)
    let rec pick pool acc n =
      if n <= 0 then
        acc
      else
        (* Pick a random mod. *)
        match pool with
          | [] ->
              acc
          | _ :: _ ->
              let selected_mod = List.nth pool (Random.int (List.length pool)) in
              (* Remove mods that can no longer be picked. *)
              let pool =
                let can_still_be_picked { modifier; _ } =
                  Id.Set.disjoint modifier.groups selected_mod.modifier.groups
                in
                List.filter can_still_be_picked pool
              in
              pick pool (selected_mod :: acc) (n - 1)
    in
    pick pool [] count
  in
  let prefixes = pick prefix_mod_pool in
  let suffixes = pick suffix_mod_pool in
  let result =
    set_to_lowest_possible_rarity
      { selected_base with mods = selected_base.mods @ prefixes @ suffixes }
  in
  (* Chance to upgrade or downgrade a tier. *)
  let result =
    if Random.int 8 = 0 then
      result (* TODO: upgrade a mod *)
    else if Random.int 8 = 0 then
      result (* TODO: downgrade a mod *)
    else
      result
  in
  (* Chance to add a random mod. *)
  (* TODO: chance to add a special mod instead *)
  let result =
    if Random.int 8 = 0 then
      spawn_random_mod ~fail_if_impossible: false result
    else
      result
  in
  result

let apply_fracturing_orb item =
  let map_fracturable_mods f =
    item.mods |> List.map @@ fun ({ modifier; fractured; _ } as m) ->
    if not fractured && Mod.is_prefix_or_suffix modifier then
      f m
    else
      m
  in
  let fracturable_mod_count =
    let count = ref 0 in
    let _: modifier list = map_fracturable_mods (fun m -> incr count; m) in
    !count
  in
  if fracturable_mod_count <= 0 then
    item
  else
    let index_to_fracture = Random.int fracturable_mod_count in
    let current_index = ref 0 in
    let mods =
      map_fracturable_mods @@ fun m ->
      let m =
        if !current_index = index_to_fracture then { m with fractured = true } else m
      in
      incr current_index;
      m
    in
    { item with mods; influence = Influence.add item.influence Fractured }

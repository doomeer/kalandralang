open Misc

module Currency =
struct
  type t = AST.currency
  let compare = Stdlib.compare
end

module Amount =
struct
  module Map = Map.Make (Currency)

  type t = int Map.t

  let zero = Map.empty

  let add a b =
    Map.merge
      (fun _ a b ->
         match a, b with
           | None, x | x, None -> x
           | Some a, Some b -> Some (a + b))
      a b

  let neg a =
    Map.map (~-) a

  let sub a b =
    add a (neg b)

  let of_list list =
    List.fold_left
      (fun acc (n, c) ->
         let old = Map.find_opt c acc |> default 0 in
         Map.add c (old + n) acc)
      zero
      list

  let make n c =
    Map.singleton c n

  let is_zero a =
    Map.for_all (fun _ i -> i = 0) a

  let show a =
    if is_zero a then
      "0"
    else
      Map.bindings a
      |> List.map (fun (c, n) -> string_of_int n ^ " " ^ AST.show_currency c)
      |> String.concat " + "

  let to_chaos a =
    let total = ref 0. in
    Map.iter (fun c n -> total := !total +. float n *. Cost.get_currency c) a;
    !total

  let to_exalt a =
    to_chaos a /. Cost.(get exalt)

  let iter a f = Map.iter f a
end

type state =
  {
    echo: string -> unit;
    debug: string -> unit;
    item: Item.t option;
    aside: Item.t option;
    imprint: Item.t option;
    paid: Amount.t;
    gained: Amount.t;
    program: Linear.program;
    point: int; (* program is done is point is out of program.instructions *)
  }

let start ~echo ~debug program =
  {
    echo;
    debug;
    item = None;
    aside = None;
    imprint = None;
    paid = Amount.zero;
    gained = Amount.zero;
    program;
    point = 0;
  }

let with_item state f =
  match state.item with
    | None ->
        fail "no current item"
    | Some item ->
        f item

let with_aside state f =
  match state.aside with
    | None ->
        fail "no item set aside"
    | Some item ->
        f item

let rec eval_condition state (condition: AST.condition) =
  match condition with
    | True ->
        true
    | False ->
        false
    | Not condition ->
        not (eval_condition state condition)
    | And (a, b) ->
        eval_condition state a && eval_condition state b
    | Or (a, b) ->
        eval_condition state a || eval_condition state b
    | Has id ->
        with_item state @@ fun item ->
        Item.has_mod_id id item
    | Prefix_count (min, max) ->
        with_item state @@ fun item ->
        let count = Item.prefix_count item in
        min <= count && count <= max
    | Open_prefix ->
        with_item state @@ fun item ->
        Item.prefix_count item < Item.max_prefix_count item
    | Full_prefixes ->
        with_item state @@ fun item ->
        Item.prefix_count item >= Item.max_prefix_count item
    | Suffix_count (min, max) ->
        with_item state @@ fun item ->
        let count = Item.suffix_count item in
        min <= count && count <= max
    | Open_suffix ->
        with_item state @@ fun item ->
        Item.suffix_count item < Item.max_suffix_count item
    | Full_suffixes ->
        with_item state @@ fun item ->
        Item.suffix_count item >= Item.max_suffix_count item
    | Affix_count (min, max) ->
        with_item state @@ fun item ->
        let count = Item.prefix_count item + Item.suffix_count item in
        min <= count && count <= max
    | Open_affix ->
        with_item state @@ fun item ->
        Item.prefix_count item + Item.suffix_count item < Item.max_prefix_count item + Item.max_suffix_count item
    | Full_affixes ->
        with_item state @@ fun item ->
        Item.prefix_count item + Item.suffix_count item >= Item.max_prefix_count item + Item.max_suffix_count item

let is_done state =
  state.point < 0 || state.point >= Array.length state.program.instructions

let goto state label =
  match Linear.Label_map.find_opt label state.program.labels with
    | None ->
        fail "unknown label: %s" (AST.Label.show label)
    | Some point ->
        { state with point }

let goto_next state =
  { state with point = state.point + 1 }

let item_must_be_normal (item: Item.t) =
  match item.rarity with
    | Normal -> ()
    | _ -> fail "item is not normal"

let item_must_be_magic (item: Item.t) =
  match item.rarity with
    | Magic -> ()
    | _ -> fail "item is not magic"

let item_must_be_rare (item: Item.t) =
  match item.rarity with
    | Rare -> ()
    | _ -> fail "item is not rare"

let item_must_be_normal_or_magic (item: Item.t) =
  match item.rarity with
    | Normal | Magic -> ()
    | Rare -> fail "item is rare"

let check_can_apply_conqueror_exalt (item: Item.t) =
  match item.influence with
    | Not_influenced -> ()
    | Fractured ->
        fail "cannot use a conqueror exalted orb on a fractured item"
    | Synthesized ->
        fail "cannot use a conqueror exalted orb on a synthesized item"
    | SEC _ | SEC_pair _
    | Exarch | Eater | Exarch_and_eater ->
        fail "cannot use a conqueror exalted orb on an influenced item"

let item_cannot_be_split (item: Item.t) =
  if item.split then
    fail "item is split"

let apply_currency state (currency: AST.currency) =
  state.debug (AST.show_currency currency);
  let return item =
    {
      state with
        item = Some item;
        paid = Amount.add state.paid (Amount.make 1 currency);
    }
  in
  let craft modifier =
    with_item state @@ fun item ->
    let modifier = Mod.by_id modifier in
    if not (Mod.is_crafted modifier) then
      fail "not a crafted modifier";
    return (Item.add_mod modifier item)
  in
  match currency with
    | Orb_of_transmutation ->
        with_item state @@ fun item ->
        item_must_be_normal item;
        return @@ Item.reforge_magic (Item.set_rarity Magic item)
    | Orb_of_augmentation ->
        with_item state @@ fun item ->
        item_must_be_magic item;
        return @@ Item.spawn_random_mod item
    | Orb_of_alteration ->
        with_item state @@ fun item ->
        item_must_be_magic item;
        return @@ Item.reforge_magic item
    | Regal_orb ->
        with_item state @@ fun item ->
        item_must_be_magic item;
        return @@ Item.spawn_random_mod (Item.set_rarity Rare item)
    | Orb_of_alchemy ->
        with_item state @@ fun item ->
        item_must_be_normal item;
        return @@ Item.reforge_rare (Item.set_rarity Rare item)
    | Orb_of_scouring ->
        with_item state @@ fun item ->
        let item =
          Item.remove_all_mods item
            ~respect_cannot_be_changed: true
            ~respect_cannot_roll: false
        in
        return @@ Item.set_to_lowest_possible_rarity item
    | Blessed_orb ->
        fail "not implemented: bless"
    | Chaos_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.reforge_rare item
    | Orb_of_annulment ->
        with_item state @@ fun item ->
        return @@ Item.remove_random_mod item
          ~respect_cannot_be_changed: true
          ~respect_cannot_roll: true
    | Exalted_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.spawn_random_mod item
    | Crusader_exalted_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        check_can_apply_conqueror_exalt item;
        return @@ Item.spawn_random_sec_influence_mod Crusader item
    | Hunter_exalted_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        check_can_apply_conqueror_exalt item;
        return @@ Item.spawn_random_sec_influence_mod Hunter item
    | Redeemer_exalted_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        check_can_apply_conqueror_exalt item;
        return @@ Item.spawn_random_sec_influence_mod Redeemer item
    | Warlord_exalted_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        check_can_apply_conqueror_exalt item;
        return @@ Item.spawn_random_sec_influence_mod Warlord item
    | Veiled_chaos_orb ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.reforge_rare_with_veiled_mod item
    | Essence name ->
        with_item state @@ fun item ->
        let essence = Essence.by_name name in
        let modifier =
          match
            Essence.get_mod essence Base_tag.(get_item_type_from_tags item.base.tags)
          with
            | None ->
                fail "cannot use an essence on this item type"
            | Some modifier ->
                Mod.by_id modifier
        in
        return @@ Item.reforge_rare
          ~respect_cannot_be_changed: false
          ~modifier
          (Item.set_rarity Rare item)
    | Fossils fossils ->
        let count = List.length fossils in
        if count < 1 then fail "must use at least 1 fossil"; (* cannot happen *)
        if count > 4 then fail "cannot use more than 4 fossils at the same time";
        with_item state @@ fun item ->
        return @@ Item.reforge_rare ~fossils (Item.set_rarity Rare item)
    | Awakeners_orb ->
        with_item state @@ fun item ->
        with_aside state @@ fun aside ->
        let get_sec_influence name (item: Item.t) =
          match item.influence with
            | SEC x ->
                x
            | SEC_pair _ ->
                fail "%s has more than one influence" name
            | Not_influenced | Exarch | Eater | Exarch_and_eater | Synthesized | Fractured ->
                fail "%s does not have a Shaper / Elder / Conqueror influence" name
        in
        let item_influence = get_sec_influence "current item" item in
        let aside_influence = get_sec_influence "item set aside" aside in
        if item_influence = aside_influence then fail "Current and item set aside have the same influence";
        let random_influenced_mod_from (item: Item.t) influence =
          match Base_tag.get_influence_tag_for_tags item.base.tags influence with
            | None ->
                fail "item is not influenced"
            | Some influence_tag ->
                let candidates =
                  List.filter
                    (fun { Item.modifier; _ } -> Item.is_influence_mod influence_tag modifier)
                    item.mods
                  |> Array.of_list
                in
                let count = Array.length candidates in
                if count > 0 then
                  [ candidates.(Random.int count) ]
                else
                  []
        in
        let mod1 = random_influenced_mod_from item item_influence in
        let mod2 = random_influenced_mod_from aside aside_influence in
        let item =
          {
            item with
              rarity = Rare;
              mods = mod1 @ mod2;
          }
          |> Item.add_influence (SEC item_influence)
          |> Item.add_influence (SEC aside_influence)
          |> Item.spawn_additional_random_mods
        in
        { (return item) with aside = None }
    | Ember tier ->
        with_item state @@ fun item ->
        return @@ Item.apply_eldritch_ember (AST.eldritch_tier_of_currency tier) item
    | Ichor tier ->
        with_item state @@ fun item ->
        return @@ Item.apply_eldritch_ichor (AST.eldritch_tier_of_currency tier) item
    | Eldritch_annul ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.apply_eldritch_annul item
    | Eldritch_exalt ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.apply_eldritch_exalt item
    | Eldritch_chaos ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.apply_eldritch_chaos item
    | Harvest_augment tag ->
        with_item state @@ fun item ->
        (
          match item.influence with
            | Not_influenced | Synthesized | Fractured ->
                ()
            | SEC _ | SEC_pair _ | Exarch | Eater | Exarch_and_eater ->
                fail "cannot harvest augment an influenced item"
        );
        return @@ Item.spawn_random_mod ~tag item
    | Harvest_non_to tag ->
        with_item state @@ fun item ->
        (
          match item.influence with
            | Not_influenced | Synthesized | Fractured ->
                ()
            | SEC _ | SEC_pair _ | Exarch | Eater | Exarch_and_eater ->
                fail "cannot harvest non-X to X an influenced item"
        );
        let item =
          Item.remove_random_mod item
            ~without_tag: tag
            ~respect_cannot_be_changed: true
            ~respect_cannot_roll: false
        in
        return @@ Item.spawn_random_mod ~tag item
    | Harvest_reforge tag ->
        with_item state @@ fun item ->
        return @@ Item.reforge_rare ~tag (Item.set_rarity Rare item)
    | Harvest_reforge_more_common tag ->
        with_item state @@ fun item ->
        let item = Item.set_rarity Rare item in
        return @@ Item.reforge_rare ~tag ~tag_more_common: (tag, 10.) item
    | Harvest_reforge_keep_prefixes ->
        with_item state @@ fun item ->
        return @@ Item.reforge_rare_suffixes (Item.set_rarity Rare item)
    | Harvest_reforge_keep_suffixes ->
        with_item state @@ fun item ->
        return @@ Item.reforge_rare_prefixes (Item.set_rarity Rare item)
    | Harvest_reforge_more_likely ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.reforge_with_mod_group_multiplier 90. item
    | Harvest_reforge_less_likely ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.reforge_with_mod_group_multiplier 0.01 item
    | Beastcraft_aspect_of_the_avian ->
        with_item state @@ fun item ->
        return @@ Item.add_mod Mod.(by_id beastcrafted_avian_aspect_id) item
    | Beastcraft_aspect_of_the_cat ->
        with_item state @@ fun item ->
        return @@ Item.add_mod Mod.(by_id beastcrafted_cat_aspect_id) item
    | Beastcraft_aspect_of_the_crab ->
        with_item state @@ fun item ->
        return @@ Item.add_mod Mod.(by_id beastcrafted_crab_aspect_id) item
    | Beastcraft_aspect_of_the_spider ->
        with_item state @@ fun item ->
        return @@ Item.add_mod Mod.(by_id beastcrafted_spider_aspect_id) item
    | Beastcraft_split ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        item_cannot_be_split item;
        (
          match item.influence with
            | Not_influenced ->
                ()
            | Fractured ->
                fail "cannot split a fractured item"
            | Synthesized ->
                fail "cannot split a synthesized item"
            | SEC _ | SEC_pair _ | Exarch | Eater | Exarch_and_eater ->
                fail "cannot split an influenced item"
        );
        let item1, item2 = Item.split item in
        let state = return item1 in
        { state with aside = Some item2 }
    | Beastcraft_imprint ->
        with_item state @@ fun item ->
        item_must_be_normal_or_magic item;
        (
          match item.influence with
            | Not_influenced | Synthesized
            | SEC _ | SEC_pair _ | Exarch | Eater | Exarch_and_eater ->
                ()
            | Fractured ->
                fail "cannot imprint a fractured item"
        );
        let state = return item in
        { state with imprint = Some item }
    | Aisling ->
        with_item state @@ fun item ->
        item_must_be_rare item;
        return @@ Item.remove_random_mod_add_veiled_mod item
    | Craft modifier ->
        craft modifier
    | Multimod ->
        craft Mod.multimod_id
    | Prefixes_cannot_be_changed ->
        craft Mod.prefixes_cannot_be_changed_id
    | Suffixes_cannot_be_changed ->
        craft Mod.suffixes_cannot_be_changed_id
    | Cannot_roll_attack_mods ->
        craft Mod.cannot_roll_attack_mods_id
    | Cannot_roll_caster_mods ->
        craft Mod.cannot_roll_caster_mods_id
    | Remove_crafted_mods ->
        with_item state @@ fun item ->
        if Item.crafted_mod_count item = 0 then
          state
        else
          return @@ Item.remove_crafted_mods item
    | Craft_any_prefix ->
        with_item state @@ fun item ->
        let item =
          match Item.mod_pool item ~crafted: true ~only: Prefixes with
            | [] ->
                fail "no prefix to craft"
            | (_, modifier) :: _ ->
                Item.add_mod modifier item
        in
        return item
    | Craft_any_suffix ->
        with_item state @@ fun item ->
        let item =
          match Item.mod_pool item ~crafted: true ~only: Suffixes with
            | [] ->
                fail "no suffix to craft"
            | (_, modifier) :: _ ->
                Item.add_mod modifier item
        in
        return item

let show_mod_pool pool =
  let total_weight = List.fold_left (fun acc (w, _) -> acc + w) 0 pool |> float in
  let prefixes, suffixes = List.partition (fun (_, m) -> Mod.is_prefix m) pool in
  let show_mod (w, (m: Mod.t)) =
    let weight = Printf.sprintf "%.3f%%" (float w *. 100. /. total_weight) in
    let padding = String.make (max 0 (6 - String.length weight)) ' ' in
    echo "%s%s %s" padding weight
      (Mod.show ~indentation: (String.length padding + String.length weight + 1)
         With_ranges m)
  in
  List.iter show_mod prefixes;
  List.iter show_mod suffixes

let run_simple_instruction state (instruction: AST.simple_instruction) =
  match instruction with
    | Goto label ->
        goto state label
    | Stop ->
        { state with point = Array.length state.program.instructions }
    | Buy { influence; base; ilvl; mods; cost } ->
        (* TODO: check that [mods] are compatible with influences.
           More generally, check that [mods] can actually exist on the item. *)
        state.debug ("buy " ^ Id.show base);
        let item = Item.make (Base_item.by_id base) ilvl Rare influence in
        let item =
          let add_mod item ({ modifier; fractured }: AST.buy_with) =
            let item = if fractured then Item.add_influence Fractured item else item in
            Item.add_mod ~fractured (Mod.by_id modifier) item
          in
          List.fold_left add_mod item mods
        in
        let item = Item.spawn_additional_random_mods item in
        let state =
          {
            state with
              item = Some item;
              paid = Amount.add state.paid (Amount.of_list cost);
          }
        in
        goto_next state
    | Apply currency ->
        let state = apply_currency state currency in
        goto_next state
    | Set_aside ->
        state.debug "set aside";
        with_item state @@ fun item ->
        goto_next { state with aside = Some item; item = None }
    | Swap ->
        state.debug "swap";
        goto_next { state with aside = state.item; item = state.aside }
    | Use_imprint ->
        state.debug "use_imprint";
        let imprint =
          match state.item, state.imprint with
            | None, _ ->
                fail "no current item"
            | _, None ->
                fail "no imprint"
            | Some item, Some imprint ->
                if item.split && not imprint.split then
                    fail "can't apply imprint (can't revert to pre-split)"
                else
                    imprint
        in
        goto_next { state with item = Some imprint; imprint = None }
    | Gain amount ->
        let amount = Amount.of_list amount in
        let state = { state with gained = Amount.add state.gained amount } in
        goto_next state
    | Echo message ->
        state.echo message;
        goto_next state
    | Show ->
        (
          match state.item with
            | None ->
                state.echo "(no current item)"
            | Some item ->
                state.echo (Item.show item);
                state.echo @@ sf "Paid up to now: %s"
                  (Cost.show_chaos_amount (Amount.to_chaos state.paid))
        );
        goto_next state
    | Show_mod_pool ->
        with_item state @@ fun item ->
        let pool = Item.mod_pool item in
        show_mod_pool pool;
        goto_next state
    | Show_unveil_mod_pool ->
        with_item state @@ fun item ->
        let _, pool = Item.prepare_unveil item in
        show_mod_pool pool;
        goto_next state
    | Unveil mods ->
        with_item state @@ fun item ->
        let item, unveiled_mods = Item.unveil item in
        let chosen_mod =
          let rec choose = function
            | [] ->
                (
                  match unveiled_mods with
                    | [] ->
                        fail "no unveiled mod"
                    | first :: _ ->
                        first
                )
            | best :: other ->
                let is_best modifier = Id.compare modifier.Mod.id best = 0 in
                match List.find_opt is_best unveiled_mods with
                  | None ->
                      choose other
                  | Some modifier ->
                      modifier
          in
          choose mods
        in
        let chosen_mod = { Item.modifier = chosen_mod; fractured = false } in
        let item = { item with mods = chosen_mod :: item.mods } in
        let state = { state with item = Some item } in
        goto_next state

let run_instruction state (instruction: Linear.instruction AST.node) =
  match instruction.node with
    | Simple instruction ->
        run_simple_instruction state instruction
    | If (condition, label) ->
        if eval_condition state condition then
          goto state label
        else
          { state with point = state.point + 1 }

let step state =
  if is_done state then
    None
  else
    Some (run_instruction state state.program.instructions.(state.point))

exception Failed of state * exn

let run state =
  let state = ref state in
  let exception Stop in
  let exception Abort in
  Sys.(set_signal sigint) (Signal_handle (fun _ -> raise Abort));
  try
    while true do
      match step !state with
        | None ->
            raise Stop
        | Some new_state ->
            state := new_state
    done;
    assert false
  with
    | Stop ->
        !state
    | Abort ->
        raise (Failed (!state, Failure "Aborted."))
    | exn ->
        raise (Failed (!state, exn))

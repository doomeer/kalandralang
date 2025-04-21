open Misc

type recipe_version_options =
  {
    (* Enable legacy crafting currencies and methods *)
    legacy: bool;
  }

let found_an_error = ref false

let warn loc x =
  Printf.ksprintf (fun s -> echo "%s:\nWarning: %s" (show_loc loc) s) x

let error loc x =
  Printf.ksprintf (fun s -> found_an_error := true; echo "%s:\nError: %s" (show_loc loc) s) x

module Label_set = Set.Make (AST.Label)

let check_base_item loc base_item_id =
  if not (Base_item.id_exists base_item_id) then
    error loc "unknown base item: %S" (Id.show base_item_id)

let check_mod ?(unveilable = false) loc mod_id =
  match Mod.by_id_opt mod_id with
    | None ->
        error loc "unknown modifier: %S" (Id.show mod_id)
    | Some modifier ->
        if unveilable then
          match modifier.domain with
            | Unveiled ->
                ()
            | _ ->
                error loc "modifier is not unveilable: %S" (Id.show mod_id)

let check_mod_group loc mod_group_id =
  if not (Mod.group_exists mod_group_id) then
    error loc "unknown modifier group: %S" (Id.show mod_group_id)

let check_mod_or_group loc id =
  if not (Mod.group_exists id) then
    match Mod.by_id_opt id with
      | None ->
          error loc "unknown modifier or modifier group: %S" (Id.show id)
      | Some _ ->
          ()

let rec check_arithmetic_expression ({ node; loc }: AST.arithmetic_expression) =
  match node with
    | Int _
    | Prefix_count
    | Suffix_count
    | Affix_count ->
        ()
    | Neg a ->
        check_arithmetic_expression a
    | Binary_arithmetic_operator (a, _, b) ->
        check_arithmetic_expression a;
        check_arithmetic_expression b
    | Tier mod_type ->
        (* Mod groups are replaced with mod types.  If the mod type does not
           exist, check if the identifier is not a mod group, in which case warn
           the user that mod groups are no longer supported and that they need
           to switch *)
       if not (Mod.mod_type_exists mod_type) then
         if (Mod.group_exists mod_type) then
           error loc "you are using modifier group: %S.  Modifier groups were replaced by modifier type." (Id.show mod_type)
         else
           error loc "unknown modifier type: %S" (Id.show mod_type)
    | Int_of_bool condition ->
        check_condition condition

and check_condition ({ node; loc }: AST.condition) =
  match node with
    | True
    | False
    | Open_prefix
    | Full_prefixes
    | Open_suffix
    | Full_suffixes
    | Open_affix
    | Full_affixes
    | Normal
    | Magic
    | Rare
    | Has_influence _ ->
        ()
    | C_prefix_count (0, 0) ->
        warn loc "no_prefix and prefix_count 0 are deprecated, use prefix_count = 0 instead"
    | C_prefix_count (a, b) when a = b ->
        warn loc "prefix_count %d is deprecated, use prefix_count = %d instead" a a
    | C_prefix_count (a, b) ->
        warn loc "prefix_count %d..%d is deprecated, use %d <= prefix_count <= %d instead"
          a b a b
    | C_suffix_count (0, 0) ->
        warn loc "no_suffix and suffix_count 0 are deprecated, use suffix_count = 0 instead"
    | C_suffix_count (a, b) when a = b ->
        warn loc "suffix_count %d is deprecated, use suffix_count = %d instead" a a
    | C_suffix_count (a, b) ->
        warn loc "suffix_count %d..%d is deprecated, use %d <= suffix_count <= %d instead"
          a b a b
    | C_affix_count (0, 0) ->
        warn loc "no_affix and affix_count 0 are deprecated, use affix_count = 0 instead"
    | C_affix_count (a, b) when a = b ->
        warn loc "affix_count %d is deprecated, use affix_count = %d instead" a a
    | C_affix_count (a, b) ->
        warn loc "affix_count %d..%d is deprecated, use %d <= affix_count <= %d instead"
          a b a b
    | Not a ->
        check_condition a
    | And (a, b)
    | Or (a, b) ->
        check_condition a;
        check_condition b
    | Comparison (a, _, b) ->
        check_arithmetic_expression a;
        check_arithmetic_expression b
    | Double_comparison (a, _, b, _, c) ->
        check_arithmetic_expression a;
        check_arithmetic_expression b;
        check_arithmetic_expression c
    | Has { fractured = _; id } ->
        check_mod_or_group loc id
    | Has_mod { fractured = _; id } ->
        check_mod loc id
    | Has_group { fractured = _; id } ->
        check_mod_group loc id
    | Is_base base ->
        check_base_item loc base

let check_recipe ast (options: recipe_version_options) =
  let rec gather_labels ((declared, used) as acc) (ast: AST.t) =
    match ast.node with
      | Simple (Goto label) ->
          declared, Label_set.add label used
      | Label label ->
          Label_set.add label declared, used
      | Simple _
      | Noop ->
          acc
      | If (_, a, None)
      | Until (_, a)
      | While (_, a)
      | Repeat (a, _)
      | Unveil_else (_, a) ->
          gather_labels acc a
      | Seq (a, b)
      | If (_, a, Some b) ->
          let acc = gather_labels acc a in
          gather_labels acc b
  in
  let declared_labels, used_labels = gather_labels (Label_set.empty, Label_set.empty) ast in
  let rec check ({ node; loc }: AST.t) =
    match node with
      | Noop ->
          ()
      | Seq (a, b) ->
          check a;
          check b
      | Label label ->
          if not (Label_set.mem label used_labels) then
            warn loc "unused label: %s" (AST.Label.show label)
      | Simple (Goto label) ->
          if not (Label_set.mem label declared_labels) then
            error loc "unknown label: %s" (AST.Label.show label)
      | Simple (Apply currency) ->
         (match currency with
           | Harvest_reforge_keep_prefixes
           | Harvest_reforge_keep_suffixes
           | Veiled_chaos_orb
           | Aisling ->
             if not options.legacy then
               error loc
                 "Legacy crafting method: %s.  Use `run --legacy' to enable it."
                 (AST.show_currency currency)
           | _ ->
              ())
      | Simple (
          Stop | Set_aside | Recombine |
          Swap | Use_imprint | Gain _ | Echo _ | Show |
          Show_mod_pool | Show_unveil_mod_pool
        ) ->
          ()
      | Simple (
          Buy { exact = _; rarity = _; influence = _; base; ilvl = _; mods; cost = _ }
        ) ->
          check_base_item loc base;
          List.iter (fun { AST.modifier; fractured = _ } -> check_mod loc modifier) mods
      | Simple (Unveil mods) ->
          List.iter (check_mod ~unveilable: true loc) mods
      | If (cond, a, None)
      | Until (cond, a)
      | While (cond, a)
      | Repeat (a, cond) ->
          check_condition cond;
          check a
      | If (cond, a, Some b) ->
          check_condition cond;
          check a;
          check b
      | Unveil_else (mods, a) ->
          List.iter (check_mod ~unveilable: true loc) mods;
          check a
  in
  check ast;
  if !found_an_error then exit 1

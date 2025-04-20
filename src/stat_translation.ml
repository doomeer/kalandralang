open Misc

type format =
  | Number
  | Plus_number
  | IH_30pct_of_value of format (* 30%_of_value *)
  | IH_60pct_of_value of format (* 60%_of_value *)
  | IH_deciseconds_to_seconds of format
  | IH_plus_two_hundred of format
  | IH_divide_by_three of format
  | IH_divide_by_five of format
  | IH_divide_by_one_hundred of format
  | IH_divide_by_one_hundred_and_negate of format
  | IH_divide_by_one_hundred_2dp of format
  | IH_divide_by_two_0dp of format
  | IH_divide_by_four of format
  | IH_divide_by_six of format
  | IH_divide_by_ten_0dp of format
  | IH_divide_by_ten_1dp of format
  | IH_divide_by_ten_1dp_if_required of format
  | IH_divide_by_twelve of format
  | IH_divide_by_fifteen_0dp of format
  | IH_divide_by_twenty of format
  | IH_divide_by_twenty_then_double_0dp of format
  | IH_divide_by_fifty of format
  | IH_divide_by_one_hundred_2dp_if_required of format
  | IH_divide_by_one_thousand of format
  | IH_milliseconds_to_seconds of format
  | IH_milliseconds_to_seconds_0dp of format
  | IH_milliseconds_to_seconds_1dp of format
  | IH_milliseconds_to_seconds_2dp of format
  | IH_milliseconds_to_seconds_2dp_if_required of format
  | IH_multiplicative_damage_modifier of format
  | IH_multiplicative_permyriad_damage_modifier of format
  | IH_multiply_by_four of format
  | IH_negate of format
  | IH_old_leech_percent of format
  | IH_old_leech_permyriad of format
  | IH_per_minute_to_per_second of format
  | IH_per_minute_to_per_second_0dp of format
  | IH_per_minute_to_per_second_1dp of format
  | IH_per_minute_to_per_second_2dp of format
  | IH_per_minute_to_per_second_2dp_if_required of format
  | IH_times_twenty of format
  | IH_canonical_line of format
  | IH_canonical_stat of format
  | IH_mod_value_to_item_class of format
  | IH_tempest_mod_text of format
  | IH_display_indexable_support of format
  | IH_tree_expansion_jewel_passive of format
  | IH_affliction_reward_type of format
  | IH_passive_hash of format
  | IH_reminderstring of format
  | IH_times_one_point_five of format
  | IH_double of format
  | IH_negate_and_double of format
  | IH_metamorphosis_reward_description of format
  | IH_weapon_tree_unique_base_type_name of format
  | IH_locations_to_metres of format
  | IH_display_indexable_skill of format

type condition =
  {
    min: int option;
    max: int option;
  }

type string_part =
  | Constant of string
  | Stat of int

type translation =
  {
    conditions: condition list;
    formats: format list;
    string: string_part list;
    stats: Id.t list;
  }

type t = translation list

let round f = if f >= 0. then int_of_float (f +. 0.5) else int_of_float (f -. 0.5)
let round_0dp f = float (round f)
let round_1dp f = float (round (f *. 10.)) /. 10.
let round_2dp f = float (round (f *. 100.)) /. 100.

let string_of_float f =
  let s = string_of_float f in
  let len = String.length s in
  if s <> "" && s.[len - 1] = '.' then
    String.sub s 0 (len - 1)
  else
    s

let rec apply_format ?(omit_plus = false) f value =
  let apply_format = apply_format ~omit_plus in
  match f with
    | Number ->
        string_of_float value
    | Plus_number when value >= 0. ->
        if omit_plus then
          string_of_float value
        else
          "+" ^ string_of_float value
    | Plus_number ->
        string_of_float value
    | IH_30pct_of_value f ->
        apply_format f (value *. 30. /. 100.)
    | IH_60pct_of_value f ->
        apply_format f (value *. 60. /. 100.)
    | IH_deciseconds_to_seconds f ->
        apply_format f (value /. 10.)
    | IH_plus_two_hundred f ->
        apply_format f (value +. 200.)
    | IH_divide_by_three f ->
        apply_format f (value /. 3.)
    | IH_divide_by_five f ->
        apply_format f (value /. 5.)
    | IH_divide_by_one_hundred f ->
        apply_format f (value /. 100.)
    | IH_divide_by_one_hundred_and_negate f ->
        apply_format f (-. value /. 100.)
    | IH_divide_by_one_hundred_2dp f ->
        apply_format f (round_2dp (value /. 100.))
    | IH_divide_by_two_0dp f ->
        apply_format f (round_0dp (value /. 2.))
    | IH_divide_by_four f ->
        apply_format f (value /. 4.)
    | IH_divide_by_six f ->
        apply_format f (value /. 6.)
    | IH_divide_by_ten_0dp f ->
        apply_format f (round_0dp (value /. 10.))
    | IH_divide_by_ten_1dp f ->
        apply_format f (round_1dp (value /. 10.))
    | IH_divide_by_ten_1dp_if_required f ->
        apply_format f (round_1dp (value /. 10.))
    | IH_divide_by_twelve f ->
        apply_format f (value /. 12.)
    | IH_divide_by_fifteen_0dp f ->
        apply_format f (round_0dp (value /. 15.))
    | IH_divide_by_twenty f ->
        apply_format f (value /. 20.)
    | IH_divide_by_twenty_then_double_0dp f ->
        apply_format f (round_0dp (value /. 20.) *. 2.)
    | IH_divide_by_fifty f ->
        apply_format f (value /. 50.)
    | IH_divide_by_one_hundred_2dp_if_required f ->
        apply_format f (round_2dp (value /. 100.))
    | IH_divide_by_one_thousand f ->
        apply_format f (value /. 1000.)
    | IH_milliseconds_to_seconds f ->
        apply_format f (value /. 1000.)
    | IH_milliseconds_to_seconds_0dp f ->
        apply_format f (round_0dp (value /. 1000.))
    | IH_milliseconds_to_seconds_1dp f ->
        apply_format f (round_1dp (value /. 1000.))
    | IH_milliseconds_to_seconds_2dp f ->
        apply_format f (round_2dp (value /. 1000.))
    | IH_milliseconds_to_seconds_2dp_if_required f ->
        apply_format f (round_2dp (value /. 1000.))
    | IH_multiplicative_damage_modifier f ->
        apply_format f (value +. 100.)
    | IH_multiplicative_permyriad_damage_modifier f ->
        apply_format f (value /. 100. +. 100.)
    | IH_multiply_by_four f ->
        apply_format f (value *. 4.)
    | IH_negate f ->
        apply_format f (-. value)
    | IH_old_leech_percent f ->
        apply_format f (value /. 5.)
    | IH_old_leech_permyriad f ->
        apply_format f (value /. 500.)
    | IH_per_minute_to_per_second f ->
        apply_format f (round_1dp (value /. 60.))
    | IH_per_minute_to_per_second_0dp f ->
        apply_format f (round_0dp (value /. 60.))
    | IH_per_minute_to_per_second_1dp f ->
        apply_format f (round_1dp (value /. 60.))
    | IH_per_minute_to_per_second_2dp f ->
        apply_format f (round_2dp (value /. 60.))
    | IH_per_minute_to_per_second_2dp_if_required f ->
        apply_format f (round_2dp (value /. 60.))
    | IH_times_twenty f ->
        apply_format f (value *. 20.)
    | IH_canonical_line f ->
        apply_format f value
    | IH_canonical_stat f ->
        apply_format f value
    | IH_mod_value_to_item_class f ->
        apply_format f value
    | IH_tempest_mod_text f ->
        apply_format f value
    | IH_display_indexable_support f ->
        apply_format f value
    | IH_tree_expansion_jewel_passive f ->
        apply_format f value
    | IH_affliction_reward_type f ->
        apply_format f value
    | IH_passive_hash f ->
        apply_format f value
    | IH_reminderstring f ->
        apply_format f value
    | IH_times_one_point_five f ->
        apply_format f (value *. 1.5)
    | IH_double f ->
        apply_format f (value *. 2.)
    | IH_negate_and_double f ->
        apply_format f (-. value *. 2.)
    | IH_metamorphosis_reward_description f ->
        apply_format f value
    | IH_weapon_tree_unique_base_type_name f ->
        apply_format f value
    | IH_locations_to_metres f ->
        apply_format f value
    | IH_display_indexable_skill f ->
        apply_format f value

type translate_mode =
  | With_placeholders of (int * int) Id.Map.t
  | With_ranges of (int * int) Id.Map.t
  | With_values of int Id.Map.t

let translate_part translation mode = function
  | Constant s ->
      s
  | Stat index ->
      match mode with
        | With_placeholders _ ->
            "#"
        | With_ranges ranges ->
            (
              match List.nth_opt translation.stats index with
                | None ->
                    "?"
                | Some stat_id ->
                    match Id.Map.find_opt stat_id ranges with
                      | None ->
                          "?"
                      | Some (min, max) ->
                          let format =
                            List.nth_opt translation.formats index |> default Number
                          in
                          if min = max then
                            apply_format format (float min)
                          else
                            let min = apply_format format (float min) in
                            let max = apply_format ~omit_plus: true format (float max) in
                            min ^ "-" ^ max
            )
        | With_values values ->
            (
              match List.nth_opt translation.stats index with
                | None ->
                    "?"
                | Some stat_id ->
                    match Id.Map.find_opt stat_id values with
                      | None ->
                          "?"
                      | Some value ->
                          let format =
                            List.nth_opt translation.formats index |> default Number
                          in
                          apply_format format (float value)
            )

let values_for_mode translation = function
  | With_placeholders ranges
  | With_ranges ranges ->
      let get_value stat_id =
        match Id.Map.find_opt stat_id ranges with
          | None ->
              0
          | Some (min, max) ->
              (min + max) / 2
      in
      List.map get_value translation.stats
  | With_values values ->
      let get_value stat_id =
        match Id.Map.find_opt stat_id values with
          | None ->
              0
          | Some value ->
              value
      in
      List.map get_value translation.stats

let translate_one mode translation =
  if
    let rec matches values conditions =
      match values, conditions with
        | [], [] | [], _ :: _ | _ :: _, [] ->
            true
        | value :: other_values, condition :: other_conditions ->
            (
              match condition.min with
                | None -> true
                | Some min -> value >= min
            ) &&
            (
              match condition.max with
                | None -> true
                | Some max -> value <= max
            ) &&
            matches other_values other_conditions
    in
    matches (values_for_mode translation mode) translation.conditions
  then
    Some (String.concat "" (List.map (translate_part translation mode) translation.string))
  else
    None

let translate mode id translations =
  List.find_map (translate_one mode) translations
  |> default (Id.show id)

let by_id = ref Id.Map.empty

type data = t Id.Map.t
let export (): data = !by_id
let import (x: data) = by_id := x

let translate_id mode id =
  match Id.Map.find_opt id !by_id with
    | None ->
        Id.show id
    | Some translations ->
        translate mode id translations

let parse_translation_string string =
  let state = ref `normal in
  let start = ref 0 in
  let parts = ref [] in
  let add_constant i =
    let pos = !start in
    let len = i - pos in
    if len > 0 then parts := Constant (String.sub string pos len) :: !parts;
    start := i
  in
  let add_stat i =
    let pos = !start + 1 in
    let len = i - pos in
    if len > 0 then
      parts := Stat (int_of_string (String.sub string pos len)) :: !parts
    else
      parts := Constant "{}" :: !parts;
    start := i + 1
  in
  for i = 0 to String.length string - 1 do
    match !state, string.[i] with
      | `normal, '{' ->
          add_constant i;
          state := `open_brace;
      | `normal, _ ->
          ()
      | `open_brace, '0'..'9' ->
          ()
      | `open_brace, '}' ->
          add_stat i;
          state := `normal
      | `open_brace, _ ->
          add_constant i;
          state := `normal
  done;
  add_constant (String.length string);
  List.rev !parts

let load filename =
  let add_entry entry =
    let english = ref [] in
    let ids = ref [] in
    let handle_value (name, value) =
      match name with
        | "English" -> english := JSON.as_array value
        | "ids" -> ids := JSON.as_array value |> List.map JSON.as_id
        | _ -> ()
    in
    List.iter handle_value (JSON.as_object entry);
    let as_translation id json =
      let conditions = ref [] in
      let formats = ref [] in
      let index_handlers = ref [] in
      let string = ref ("(no string in translation of " ^ Id.show id ^ ")") in
      let handle_value (name, value) =
        match name with
          | "condition" ->
              let as_condition json =
                let max = ref None in
                let min = ref None in
                let handle_value (name, value) =
                  match name with
                    | "max" -> max := (JSON.as_int_opt value)
                    | "min" -> min := (JSON.as_int_opt value)
                    | _ -> ()
                in
                List.iter handle_value (JSON.as_object json);
                { min = !min; max = !max }
              in
              conditions := (JSON.as_array value |> List.map as_condition)
          | "format" ->
              let as_format json =
                match JSON.as_string json with
                  | "#" | "ignore" -> Number
                  | "+#" -> Plus_number
                  | s -> fail "%s: unknown format: %s" (JSON.show_origin json) s
              in
              formats := (JSON.as_array value |> List.map as_format)
          | "index_handlers" ->
              index_handlers := JSON.as_array value
          | "string" ->
              string := JSON.as_string value
          | _ -> ()
      in
      List.iter handle_value (JSON.as_object json);
      let format_and_handlers =
        let rec zip acc formats handlers =
          match formats, handlers with
            | [], [] | [], _ :: _ | _ :: _, [] ->
                List.rev acc
            | format :: other_formats, handler :: other_handlers ->
                zip ((format, handler) :: acc) other_formats other_handlers
        in
        zip [] !formats !index_handlers
      in
      let formats =
        let apply_handlers (format, handlers) =
          let handlers = JSON.as_array handlers in
          let apply_handler format json =
            match JSON.as_string json with
              | "30%_of_value" ->
                  IH_30pct_of_value format
              | "60%_of_value" ->
                  IH_60pct_of_value format
              | "deciseconds_to_seconds" ->
                  IH_deciseconds_to_seconds format
              | "plus_two_hundred" ->
                  IH_plus_two_hundred format
              | "divide_by_three" ->
                  IH_divide_by_three format
              | "divide_by_five" ->
                  IH_divide_by_five format
              | "divide_by_one_hundred" ->
                  IH_divide_by_one_hundred format
              | "divide_by_one_hundred_and_negate" ->
                  IH_divide_by_one_hundred_and_negate format
              | "divide_by_one_hundred_2dp" ->
                  IH_divide_by_one_hundred_2dp format
              | "divide_by_two_0dp" ->
                  IH_divide_by_two_0dp format
              | "divide_by_four" ->
                  IH_divide_by_four format
              | "divide_by_six" ->
                  IH_divide_by_six format
              | "divide_by_ten_0dp" ->
                  IH_divide_by_ten_0dp format
              | "divide_by_ten_1dp" ->
                  IH_divide_by_ten_1dp format
              | "divide_by_ten_1dp_if_required" ->
                  IH_divide_by_ten_1dp_if_required format
              | "divide_by_twelve" ->
                  IH_divide_by_twelve format
              | "divide_by_fifteen_0dp" ->
                  IH_divide_by_fifteen_0dp format
              | "divide_by_twenty" ->
                  IH_divide_by_twenty format
              | "divide_by_twenty_then_double_0dp" ->
                  IH_divide_by_twenty_then_double_0dp format
              | "divide_by_fifty" ->
                  IH_divide_by_fifty format
              | "divide_by_one_hundred_2dp_if_required" ->
                  IH_divide_by_one_hundred_2dp_if_required format
              | "divide_by_one_thousand" ->
                  IH_divide_by_one_thousand format
              | "milliseconds_to_seconds" ->
                  IH_milliseconds_to_seconds format
              | "milliseconds_to_seconds_0dp" ->
                  IH_milliseconds_to_seconds_0dp format
              | "milliseconds_to_seconds_1dp" ->
                  IH_milliseconds_to_seconds_1dp format
              | "milliseconds_to_seconds_2dp" ->
                  IH_milliseconds_to_seconds_2dp format
              | "milliseconds_to_seconds_2dp_if_required" ->
                  IH_milliseconds_to_seconds_2dp_if_required format
              | "multiplicative_damage_modifier" ->
                  IH_multiplicative_damage_modifier format
              | "multiplicative_permyriad_damage_modifier" ->
                  IH_multiplicative_permyriad_damage_modifier format
              | "multiply_by_four" ->
                  IH_multiply_by_four format
              | "negate" ->
                  IH_negate format
              | "old_leech_percent" ->
                  IH_old_leech_percent format
              | "old_leech_permyriad" ->
                  IH_old_leech_permyriad format
              | "per_minute_to_per_second" ->
                  IH_per_minute_to_per_second format
              | "per_minute_to_per_second_0dp" ->
                  IH_per_minute_to_per_second_0dp format
              | "per_minute_to_per_second_1dp" ->
                  IH_per_minute_to_per_second_1dp format
              | "per_minute_to_per_second_2dp" ->
                  IH_per_minute_to_per_second_2dp format
              | "per_minute_to_per_second_2dp_if_required" ->
                  IH_per_minute_to_per_second_2dp_if_required format
              | "times_twenty" ->
                  IH_times_twenty format
              | "canonical_line" ->
                  IH_canonical_line format
              | "canonical_stat" ->
                  IH_canonical_stat format
              | "mod_value_to_item_class" ->
                  IH_mod_value_to_item_class format
              | "tempest_mod_text" ->
                  IH_tempest_mod_text format
              | "display_indexable_support" ->
                  IH_display_indexable_support format
              | "tree_expansion_jewel_passive" ->
                  IH_tree_expansion_jewel_passive format
              | "affliction_reward_type" ->
                  IH_affliction_reward_type format
              | "passive_hash" ->
                  IH_passive_hash format
              | "reminderstring" ->
                  IH_reminderstring format
              | "times_one_point_five" ->
                  IH_times_one_point_five format
              | "double" ->
                  IH_double format
              | "negate_and_double" ->
                  IH_negate_and_double format
              | "metamorphosis_reward_description" ->
                  IH_metamorphosis_reward_description format
              | "weapon_tree_unique_base_type_name" ->
                  IH_weapon_tree_unique_base_type_name format
              | "locations_to_metres" ->
                  IH_locations_to_metres format
              | "display_indexable_skill" ->
                  IH_display_indexable_skill format
              | s ->
                  Printf.printf "Warning: %s: unknown format: %s\n%!"
                    (JSON.show_origin json) s;
                  format
          in
          List.fold_left apply_handler format handlers
        in
        List.map apply_handlers format_and_handlers
      in
      let string = parse_translation_string !string in
      {
        conditions = !conditions;
        formats;
        string;
        stats = !ids;
      }
    in
    let add_translation id =
      let translations = List.map (as_translation id) !english in
      by_id := Id.Map.add id translations !by_id
    in
    List.iter add_translation !ids
  in
  List.iter add_entry JSON.(parse_file filename |> as_array)

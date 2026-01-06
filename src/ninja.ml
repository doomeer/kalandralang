(* USES uri *)

open Misc

let as_currencies = function
  | None ->
      String_map.empty
  | Some json ->
      try
        let as_item json =
          let id = JSON.(json |-> "id" |> as_string) in
          let name = JSON.(json |-> "name" |> as_string) in
          id, name
        in
        let item_map = JSON.(json |-> "items" |> as_array) |> List.map as_item |> String_map.of_list in
        let as_currency json =
          let id = JSON.(json |-> "id" |> as_string) in
          let cost = JSON.(json |-> "primaryValue" |> as_float) in
          let name = String_map.find id item_map in
          name, cost
        in
        JSON.(json |-> "lines" |> as_array) |> List.map as_currency |> String_map.of_list
      with exn ->
        echo "failed to parse poe.ninja's response (CurrencyOverview): %s"
          (Printexc.to_string exn);
        String_map.empty

let get_currencies_ninja league currency_type =
  Uri.(with_query' (of_string "https://poe.ninja/poe1/api/economy/exchange/current/overview")) [
    "league", league;
    "type", currency_type;
    "language", "en";
  ]
  |> Http_request.get_json "poe.ninja response"
  |> as_currencies

let get_currencies league =
  get_currencies_ninja league "Currency"

let get_essences league =
  get_currencies_ninja league "Essence"

let get_fossils league =
  get_currencies_ninja league "Fossil"

let get_resonators league =
  get_currencies_ninja league "Resonator"

let as_items = function
  | None ->
      String_map.empty
  | Some json ->
      try
        let as_item json =
          let name = JSON.(json |-> "name" |> as_string) in
          let cost = JSON.(json |-> "chaosValue" |> as_float) in
          name, cost
        in
        JSON.(json |-> "lines" |> as_array) |> List.map as_item |> String_map.of_list
      with exn ->
        echo "failed to parse poe.ninja's response (ItemOverview): %s"
          (Printexc.to_string exn);
        String_map.empty

let get_items league item_type =
  Uri.(with_query' (of_string "https://poe.ninja/poe1/api/economy/stash/current/item/overview")) [
    "league", league;
    "type", item_type;
    "language", "en";
  ]
  |> Http_request.get_json "poe.ninja response"
  |> as_items

let get_beasts league =
  get_items league "Beast"

let as_tft = function
  | None ->
      String_map.empty
  | Some json ->
      try
        let as_item json =
          let name = JSON.(json |-> "name" |> as_string) in
          let cost = JSON.(json |-> "chaos" |> as_float) in
          name, cost
        in
        JSON.(json |-> "data" |> as_array) |> List.map as_item |> String_map.of_list
      with exn ->
        echo "failed to parse TFT's JSON file: %s"
          (Printexc.to_string exn);
        String_map.empty

let get_tft league filename =
  Uri.of_string
    ("https://raw.githubusercontent.com/The-Forbidden-Trove/tft-data-prices/master/" ^
     league ^ "/" ^ filename)
  |> Http_request.get_json "TFT response"
  |> as_tft

let write_costs ~ninja_league ~tft_league ~filename =
  let currencies = get_currencies ninja_league in
  let essences = get_essences ninja_league in
  let fossils = get_fossils ninja_league in
  let resonators = get_resonators ninja_league in
  let beasts = get_beasts ninja_league in
  let harvest_crafts = get_tft tft_league "harvest.json" in
  let services = get_tft tft_league "service.json" in
  let wrap kind f name =
    let result = f name in
    (
      match result with
        | None ->
            echo "%s: %s: failed to fetch value, will use default" kind name
        | Some value ->
            echo "%s: %s: %gc" kind name value
    );
    result
  in
  let c = wrap "Currency (poe.ninja)" @@ fun name -> String_map.find_opt name currencies in
  let e = wrap "Essence (poe.ninja)" @@ fun name -> String_map.find_opt name essences in
  let f = wrap "Fossil (poe.ninja)" @@ fun name -> String_map.find_opt name fossils in
  let r = wrap "Resonator (poe.ninja)" @@ fun name -> String_map.find_opt name resonators in
  let b = wrap "Beast (poe.ninja)" @@ fun name -> String_map.find_opt name beasts in
  let h = wrap "Harvest Craft (TFT)" @@ fun name -> String_map.find_opt name harvest_crafts in
  let s = wrap "Service (TFT)" @@ fun name -> String_map.find_opt name services in
  let update_field (field: Cost.field) =
    let getter =
      match field.source with
        | Ninja_currency -> c
        | Ninja_essence -> e
        | Ninja_fossil -> f
        | Ninja_resonator -> r
        | Ninja_beast -> b
        | TFT_harvest -> h
        | TFT_service -> s
    in
    Option.iter (Cost.set field) (getter field.source_name)
  in
  List.iter update_field !Cost.field_list;
  Cost.write_current filename

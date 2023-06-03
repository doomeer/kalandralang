open Misc

type display_options =
  {
    verbose: bool;
    show_seed: bool;
    no_item: bool;
    no_cost: bool;
    no_total: bool;
    no_echo: bool;
    no_histogram: bool;
    show_time: bool;
    summary: bool;
  }

type batch_options =
  {
    count: int;
    timeout: int option;
    loop: bool;
  }

type item_results =
  {
    item: Item.t option;
    paid: Interpreter.Amount.t;
    gained: Interpreter.Amount.t;
    paid_div: float;
    gained_div: float;
  }

type json = Ezjsonm.value

let json_of_option json_of_value = function
  | None -> `Null
  | Some x -> json_of_value x

let json_of_id x =
  `String (Id.show x)

let json_of_generation_type (generation_type: Mod.generation_type): json =
  match generation_type with
    | Prefix -> `String "Prefix"
    | Suffix -> `String "Suffix"
    | Exarch_implicit _ -> `String "Exarch Implicit"
    | Eater_implicit _ -> `String "Eater Implicit"

(* TODO: crafted, veiled *)
let json_of_modifier item (modifier: Item.modifier): json =
  let tier = Item.mod_tier item modifier.modifier in
  `O [
    "id", json_of_id modifier.modifier.id;
    "groups", `A (List.map json_of_id (Id.Set.elements modifier.modifier.groups));
    "tier", json_of_option (fun tier -> `Float (float tier)) tier;
    "generation_type", json_of_generation_type modifier.modifier.generation_type;
    "fractured", `Bool modifier.fractured;
    "crafted", `Bool (Mod.is_crafted modifier.modifier);
    "veiled", `Bool (Mod.is_veiled modifier.modifier);
    "text", `String (
      Mod.show ~only_text: true ?tier ~fractured: modifier.fractured
        With_random_values modifier.modifier
    );
  ]

let json_of_influence (influence: Influence.t): json =
  let list =
    match influence with
      | Not_influenced -> []
      | Fractured -> [ "Fractured" ]
      | Synthesized -> [ "Synthesized" ]
      | SEC a -> [ Influence.show_sec a ]
      | SEC_pair (a, b) -> [ Influence.show_sec a; Influence.show_sec b ]
      | Exarch -> [ "Exarch" ]
      | Eater -> [ "Eater" ]
      | Exarch_and_eater -> [ "Exarch"; "Eater" ]
  in
  `A (List.map (fun x -> `String x) list)

let json_of_item (item: Item.t): json =
  `O [
    "base", json_of_id item.base.name;
    "level", `Float (float item.level);
    "rarity", `String (Item.show_rarity item.rarity);
    "mods", `A (List.map (json_of_modifier item) item.mods);
    "split", `Bool item.split;
    "influence", json_of_influence item.influence;
  ]

let json_of_amount_gen float amount: json =
  let list = ref [] in
  (
    Interpreter.Amount.iter amount @@ fun currency amount ->
    list := (AST.show_currency currency, `Float (float amount)) :: !list
  );
  `O !list

let json_of_amount = json_of_amount_gen float
let json_of_average_amount = json_of_amount_gen Fun.id

let json_of_item_results x: json =
  `O [
    "item", json_of_option json_of_item x.item;
    "paid", json_of_amount x.paid;
    "gained", json_of_amount x.gained;
    "paid_div", `Float x.paid_div;
    "gained_div", `Float x.gained_div;
  ]

type results =
  {
    count: int;
    items: item_results list;
    average_paid: Interpreter.Amount.average;
    average_gained: Interpreter.Amount.average;
    average_paid_div: float;
    average_gained_div: float;
  }

let json_of_results logs x: json =
  `O [
    "count", `Float (float x.count);
    "items", `A (List.map json_of_item_results x.items);
    "average_paid", json_of_average_amount x.average_paid;
    "average_gained", json_of_average_amount x.average_gained;
    "average_paid_div", `Float x.average_paid_div;
    "average_gained_div", `Float x.average_gained_div;
    "logs", logs;
  ]

let recipe echo recipe ~batch_options ~display_options ~return_items =
  let debug s = if display_options.verbose then echo s in
  let user_echo_function =
    if display_options.no_echo then
      fun _ -> ()
    else
      echo
  in
  let echo x = Printf.ksprintf echo x in
  let module A = Interpreter.Amount in
  let paid = ref A.zero in
  let gained = ref A.zero in
  let items = ref [] in
  let show_amount ?(divide_by = 1) amount =
    Cost.show_chaos_amount (A.to_chaos amount /. float divide_by)
  in
  let histogram = Histogram.create () in
  let run_index = ref 0 in
  let summary () =
    let count = !run_index in
    let profit = A.sub !gained !paid in
    if display_options.summary || count >= 2 then (
      let show_average = show_amount ~divide_by: count in
      echo "";
      echo "Average cost (out of %d):" count;
      (
        A.iter !paid @@ fun currency amount ->
        echo "%9.2f × %s" (float amount /. float count) (AST.show_currency currency)
      );
      if A.is_zero !gained then
        echo "Total: %s" (show_average !paid)
      else
        echo "Total: %s — Profit: %s"
          (show_average !paid)
          (show_average profit);
      if not display_options.no_histogram && count >= 2 then (
        echo "";
        Histogram.output histogram ~w: 80 ~h: 12 ~unit: "div"
      );
    );
    Ok {
      count;
      items = !items; (* reverse order but does not matter *)
      average_paid = A.average !paid count;
      average_gained = A.average !gained count;
      average_paid_div = A.to_divine !paid /. float count;
      average_gained_div = A.to_divine !gained /. float count;
    }
  in
  try
    let timeout =
      match batch_options.timeout with
        | None ->
            Float.max_float
        | Some timeout ->
            if timeout > 0 then
              Unix.gettimeofday() +. float timeout
            else
              fail "Timeout must be positive."
    in
    while !run_index < batch_options.count || batch_options.loop do
      if
        !run_index > 1 && (
          not display_options.no_item ||
          not display_options.no_cost
        )
      then
        echo "";
      let state =
        Interpreter.(run (start ~echo: user_echo_function ~debug recipe)) timeout
      in
      paid := A.add !paid state.paid;
      gained := A.add !gained state.gained;
      if not display_options.no_item then
        Option.iter (fun item -> echo "%s" (Item.show item)) state.item;
      if not display_options.no_cost then (
        echo "Cost:";
        A.iter state.paid @@ fun currency amount ->
        echo "%6d × %s" amount (AST.show_currency currency)
      );
      if not display_options.no_total then (
        if A.is_zero state.gained then
          echo "Total: %s" (show_amount state.paid)
        else
          echo "Total: %s — Profit: %s"
            (show_amount state.paid)
            (show_amount (A.sub state.gained state.paid));
      );
      if not display_options.no_histogram then
        Histogram.add histogram (A.to_divine state.paid);
      run_index := !run_index + 1;
      if return_items >= !run_index then (
        let item_summary =
          {
            item = state.item;
            paid = state.paid;
            gained = state.gained;
            paid_div = A.to_divine state.paid;
            gained_div = A.to_divine state.gained;
          }
        in
        items := item_summary :: !items;
      );
    done;
    summary ()
  with
    | Interpreter.Timeout ->
        echo "Timeout reached";
        summary ()
    | Interpreter.Abort ->
        echo "Aborted";
        summary ()
    | Interpreter.Failed (state, exn) ->
        Option.iter (fun item -> echo "%s" (Item.show item)) state.item;
        let error_message = Printexc.to_string exn in
        echo "Error: %s" error_message;
        Error error_message

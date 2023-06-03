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
    show_time:bool;
    summary: bool;
  }

type batch_options =
  {
    count: int;
    timeout: int option;
    loop: bool;
  }

let recipe echo recipe ~batch_options ~display_options =
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
  let worst_loss = ref 0. in
  let best_profit = ref 0. in
  let loss_count = ref 0 in
  let profit_count = ref 0 in
  let show_amount ?(divide_by = 1) amount =
    Cost.show_chaos_amount (A.to_chaos amount /. float divide_by)
  in
  let histogram = Histogram.create () in
  let run_index = ref 0 in
  let display_summary () =
    if display_options.summary || !run_index >= 2 then
      let show_average = show_amount ~divide_by: !run_index in
      echo "";
      echo "Average cost (out of %d):" !run_index;
      (
        A.iter !paid @@ fun currency amount ->
        echo "%9.2f × %s" (float amount /. float !run_index) (AST.show_currency currency)
      );
      if A.is_zero !gained then
        echo "Total: %s" (show_average !paid)
      else
        echo "Total: %s — Profit: %s"
          (show_average !paid)
          (show_average (A.sub !gained !paid));
      if not display_options.no_histogram && !run_index >= 2 then (
        echo "";
        Histogram.output histogram ~w: 80 ~h: 12 ~unit: "div"
      );
  in
  let () = (
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
        let profit = A.sub state.gained state.paid |> A.to_chaos in
        if profit >= 0. then
          (
            best_profit := max !best_profit profit;
            incr profit_count;
          )
        else
          (
            worst_loss := min !worst_loss profit;
            incr loss_count;
          );
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
      done;
      display_summary()
    with
      | Interpreter.Timeout ->
          echo "Timeout reached";
          display_summary()
      | Interpreter.Abort ->
          echo "Aborted";
          display_summary()
      | Interpreter.Failed (state, exn) ->
          Option.iter (fun item -> echo "%s" (Item.show item)) state.item;
          echo "Error: %s" (Printexc.to_string exn);
  ) in
  !run_index

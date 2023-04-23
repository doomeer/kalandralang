open Misc

module Label_map = Map.Make (AST.Label)

type instruction =
  | Simple of AST.simple_instruction
  | If of AST.condition * AST.Label.t

type program =
  {
    instructions: instruction AST.node array;
    labels: int Label_map.t; (* label -> index in [instructions] *)
  }

let empty =
  {
    instructions = [| |];
    labels = Label_map.empty;
  }

let label lbl =
  {
    instructions = [| |];
    labels = Label_map.singleton lbl 0;
  }

let single loc node =
  {
    instructions = [| { loc; node } |];
    labels = Label_map.empty;
  }

let if_ loc condition label =
  single loc (If (condition, label))

let goto loc label =
  single loc (Simple (Goto label))

let seq a b =
  let b_offset = Array.length a.instructions in
  let merge_labels label a b =
    match a, b with
      | None, None -> None
      | Some _, Some _ -> fail "label %s is defined twice" (AST.Label.show label)
      | Some _, None -> a
      | None, Some offset -> Some (b_offset + offset)
  in
  {
    instructions = Array.append a.instructions b.instructions;
    labels = Label_map.merge merge_labels a.labels b.labels;
  }

let seql l = List.fold_left seq empty l

let rec compile ({ node; loc }: AST.t): program =
  match node with
    | Noop ->
        empty
    | Seq (a, b) ->
        let a = compile a in
        let b = compile b in
        seq a b
    | Label lbl ->
        label lbl
    | Simple instruction ->
        single loc (Simple instruction)
    | If (condition, { node = Simple (Goto label); _ }, None) ->
        if_ loc condition label
    | If (condition, then_, None) ->
        let else_label = AST.Label.fresh "if" in
        (* unused but trick to get matching indexes *)
        let _endif_label = AST.Label.fresh "endif" in
        let then_ = compile then_ in
        seql [
          if_ loc { loc; node = Not condition } else_label;
          then_;
          label else_label;
        ]
    | If (condition, then_, Some else_) ->
        let then_label = AST.Label.fresh "if" in
        let endif_label = AST.Label.fresh "endif" in
        let then_ = compile then_ in
        let else_ = compile else_ in
        seql [
          if_ loc condition then_label;
          else_;
          goto loc endif_label;
          label then_label;
          then_;
          label endif_label;
        ]
    | Until (condition, body) ->
        let until_label = AST.Label.fresh "until" in
        let enduntil_label = AST.Label.fresh "enduntil" in
        let body = compile body in
        seql [
          label until_label;
          if_ loc condition enduntil_label;
          body;
          goto loc until_label;
          label enduntil_label;
        ]
    | While (condition, body) ->
        let while_label = AST.Label.fresh "while" in
        let endwhile_label = AST.Label.fresh "endwhile" in
        let body = compile body in
        seql [
          label while_label;
          if_ loc { loc; node = Not condition } endwhile_label;
          body;
          goto loc while_label;
          label endwhile_label;
        ]
    | Repeat (body, condition) ->
        let repeat_label = AST.Label.fresh "repeat" in
        let body = compile body in
        seql [
          label repeat_label;
          body;
          if_ loc { loc; node = Not condition } repeat_label;
        ]
    | Unveil_else ([], else_) ->
        let else_ = compile else_ in
        seql [
          single loc (Simple (Unveil []));
          else_;
        ]
    | Unveil_else (head :: tail as mods, else_) ->
        let endunveil_label = AST.Label.fresh "endunveil" in
        let else_ = compile else_ in
        let has_one_of_the_mods =
          List.fold_left
            (fun acc id ->
               {
                 AST.loc;
                 node = AST.Or (acc, { loc; node = Has { fractured = false; id } })
               })
            { AST.loc; node = Has { fractured = false; id = head } }
            tail
        in
        seql [
          single loc (Simple (Unveil mods));
          if_ loc has_one_of_the_mods endunveil_label;
          else_;
          label endunveil_label;
        ]

let decompile { instructions; labels } =
  let label_map =
    let add label offset acc =
      let others = Int_map.find_opt offset acc |> default [] in
      Int_map.add offset (label :: others) acc
    in
    Label_map.fold add labels Int_map.empty
  in
  let result = ref [] in
  let instruction_count = Array.length instructions in
  for i = 0 to instruction_count do
    let labels = Int_map.find_opt i label_map |> default [] in
    let make_label label =
      let loc =
        if i < instruction_count then
          instructions.(i).loc
        else
          Lexing.dummy_pos, Lexing.dummy_pos
      in
      AST.{ loc; node = Label label }
    in
    result := List.map make_label labels @ !result;
    if i < instruction_count then
      let instruction = instructions.(i) in
      match instruction.node with
        | Simple simple ->
            result := AST.{ loc = instruction.loc; node = Simple simple } :: !result
        | If (condition, label) ->
            let goto = AST.{ loc = instruction.loc; node = Simple (Goto label) } in
            result :=
              AST.{ loc = instruction.loc; node = If (condition, goto, None) } :: !result
  done;
  match !result with
    | [] ->
        None
    | head :: tail ->
        let seq b a = AST.{ loc = a.loc; node = Seq (a, b) } in
        Some (List.fold_left seq head tail)

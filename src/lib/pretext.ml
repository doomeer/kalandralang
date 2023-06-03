type t =
  | Empty
  | Concat of t * t
  | Atom of string * int
  | Space
  | Newline
  | Empty_line
  | Indent
  | Dedent
  | Open
  | Close
  | If_flat of t * t

let empty = Empty
let concat a b = Concat (a, b)

let seq = function
  | [] -> Empty
  | [ head ] -> head
  | head :: tail -> List.fold_left concat head tail

let atom ?size s =
  let size =
    match size with
      | None -> String.length s
      | Some x -> x
  in
  if size = 0 then Empty else Atom (s, size)

let int i = atom (string_of_int i)
let space = Space
let newline = Newline
let empty_line = Empty_line
let box l = Concat (Open, Concat (seq l, Close))
let if_flat then_ else_ = If_flat (then_, else_)
let break0 = If_flat (Empty, Newline)
let break = If_flat (Space, Newline)
let indent = Indent
let dedent = Dedent

let flow = function
  | [] ->
      Empty
  | [ head ] ->
      head
  | head :: tail ->
      (* TODO: this can be made more efficient without List.map and
         maybe we do want to have the first item also prepended by a break? *)
      let make item = box [ break; item ] in
      Concat (head, seq (List.map make tail))

let separate sep = function
  | [] ->
      Empty
  | [ head ] ->
      head
  | head :: tail ->
      List.fold_left (fun acc item -> Concat (acc, Concat (sep, item))) head tail

let separate_map sep f = function
  | [] ->
      Empty
  | [ head ] ->
      f head
  | head :: tail ->
      List.fold_left (fun acc item -> Concat (acc, Concat (sep, f item))) (f head) tail

(* The stack of open boxes is always of the form:
   - some flat boxes on top (possibly none);
   - some non-flat boxes below (possibly none).
   Indeed, once a box is made non-flat, all its parents are also made non-flat.

   We never backtrack to non-flat boxes, since they are already non-flat.
   So we don't need to store them at all, except maybe to make sure that
   [Open] and [Close] are well parenthesized, but we don't really care about that.

   If a box is made non-flat, all its parents are also made non-flat,
   so the only backtracking point we need is the oldest flat box.
   But we do need to count how many other flat boxes are open so that
   we know when to close the oldest flat box.

   We are in non-flat mode if oldest_flat_boxes is [None]. *)
type flat_boxes =
  | No_flat_boxes
  | Flat_boxes of {
      oldest: state;
      others: int;
    }

and state =
  {
    mutable beginning: bool;
    mutable pending_space: bool;
    mutable pending_newline: bool;
    mutable pending_empty_line: bool;
    mutable level: int;
    mutable width: int;
    mutable flat_boxes: flat_boxes;
    mutable queue: t list;
    mutable output: string list; (* reversed *)
  }

let copy state =
  { state with beginning = state.beginning }

let run
    ?(starting_level = 0)
    ?(starting_width = 0)
    ?(spaces_per_indent = 2)
    ?(max_width = 80)
    document =
  let state =
    {
      beginning = starting_width <= 0;
      pending_space = false;
      pending_newline = false;
      pending_empty_line = false;
      level = starting_level;
      width = starting_width;
      flat_boxes = No_flat_boxes;
      queue = [ document ];
      output = [];
    }
  in
  let restore
      {
        beginning;
        pending_space;
        pending_newline;
        pending_empty_line;
        level;
        width;
        flat_boxes;
        queue;
        output;
      }
    =
    state.beginning <- beginning;
    state.pending_space <- pending_space;
    state.pending_newline <- pending_newline;
    state.pending_empty_line <- pending_empty_line;
    state.level <- level;
    state.width <- width;
    state.flat_boxes <- flat_boxes;
    state.queue <- queue;
    state.output <- output;
  in
  (* We start from a flat box, so we want to be able to backtrack to the initial state
     (without this flat box in the stack). *)
  state.flat_boxes <-
    Flat_boxes {
      oldest = copy state;
      others = 0;
    };
  let output_atom_at_beginning_of_line atom width =
    state.pending_empty_line <- false;
    state.pending_newline <- false;
    state.pending_space <- false;
    if state.level > 0 then
      state.output <- String.make state.level ' ' :: state.output;
    state.width <- state.level + width;
    state.output <- atom :: state.output;
  in
  let check_not_flat_or_backtrack () =
    match state.flat_boxes with
      | No_flat_boxes ->
          true
      | Flat_boxes { oldest; others = _ } ->
          restore oldest;
          false
  in
  let output_atom_at_middle_of_line atom width =
    let new_width = state.width + width in
    if new_width <= max_width || check_not_flat_or_backtrack () then (
      state.output <- atom :: state.output;
      state.width <- new_width;
    )
  in
  let step = function
    | Empty ->
        ()
    | Concat (a, b) ->
        state.queue <- a :: b :: state.queue
    | Atom (atom, width) ->
        if state.beginning then (
          output_atom_at_beginning_of_line atom width;
          state.beginning <- false;
        )
        else (
          if state.pending_empty_line then (
            state.output <- "\n\n" :: state.output;
            output_atom_at_beginning_of_line atom width;
          )
          else if state.pending_newline then (
            state.output <- "\n" :: state.output;
            output_atom_at_beginning_of_line atom width;
          )
          else if state.pending_space then (
            state.output <- " " :: state.output;
            state.width <- state.width + 1;
            state.pending_space <- false;
            output_atom_at_middle_of_line atom width;
          )
          else
            output_atom_at_middle_of_line atom width
        )
    | Space ->
        state.pending_space <- true
    | Newline ->
        (* If flat, trigger the backtrack now, not when we will actually
           output the next atom, as this next atom could be in another box
           that could have stayed flat. *)
        if check_not_flat_or_backtrack () then
          state.pending_newline <- true
    | Empty_line ->
        if check_not_flat_or_backtrack () then
          state.pending_empty_line <- true
    | Indent ->
        state.level <- state.level + spaces_per_indent
    | Dedent ->
        state.level <- state.level - spaces_per_indent
    | Open ->
        (
          match state.flat_boxes with
            | No_flat_boxes ->
                state.flat_boxes <-
                  Flat_boxes {
                    oldest = copy state;
                    others = 0;
                  }
            | Flat_boxes { oldest; others } ->
                state.flat_boxes <-
                  Flat_boxes {
                    oldest;
                    others = others + 1;
                  }
        )
    | Close ->
        (
          match state.flat_boxes with
            | No_flat_boxes ->
                ()
            | Flat_boxes { oldest; others } ->
                if others > 0 then
                  state.flat_boxes <-
                    Flat_boxes {
                      oldest;
                      others = others - 1;
                    }
                else
                  state.flat_boxes <- No_flat_boxes
        )
    | If_flat (then_, else_) ->
        (
          match state.flat_boxes with
            | No_flat_boxes ->
                state.queue <- else_ :: state.queue
            | Flat_boxes _ ->
                state.queue <- then_ :: state.queue
        )
  in
  let rec loop () =
    match state.queue with
      | [] ->
          ()
      | head :: tail ->
          state.queue <- tail;
          step head;
          loop ()
  in
  loop ();
  state

let show ?starting_level ?starting_width ?spaces_per_indent ?max_width document =
  let state = run ?starting_level ?starting_width ?spaces_per_indent ?max_width document in
  String.concat "" (List.rev state.output)

let to_channel ?starting_level ?starting_width ?spaces_per_indent ?max_width
    channel document =
  let state = run ?starting_level ?starting_width ?spaces_per_indent ?max_width document in
  List.iter (output_string channel) (List.rev state.output)

let to_formatter ?starting_level ?starting_width ?spaces_per_indent ?max_width
    fmt document =
  let state = run ?starting_level ?starting_width ?spaces_per_indent ?max_width document in
  List.iter (Format.pp_print_string fmt) (List.rev state.output)

module OCaml =
struct
  let bool b = atom (string_of_bool b)

  let int = int

  let string s = atom ("\"" ^ String.escaped s ^ "\"")

  let list pp_item = function
    | [] ->
        atom "[]"
    | list ->
        box [
          atom "[";
          indent;
          break;
          separate (concat (atom ";") break) (List.map pp_item list);
          dedent;
          break;
          atom "]";
        ]

  let variant constructor arguments =
    match arguments with
      | [] ->
          atom constructor
      | [ head ] ->
          box [
            atom constructor;
            break;
            head;
          ]
      | _ ->
          box [
            atom constructor;
            space;
            atom "(";
            indent;
            break0;
            separate (concat (atom ",") break) arguments;
            break0;
            dedent;
            atom ")";
          ]

  let record = function
    | [] ->
        atom "{}"
    | fields ->
        box [
          atom "{";
          indent;
          break;
          separate
            (concat (atom ";") break)
            (List.map
               (fun (n, v) -> box [ atom n; space; atom "="; indent; break; v; dedent ])
               fields);
          break;
          dedent;
          atom "}";
        ]

  let tuple = function
    | [] ->
        atom "()"
    | values ->
        box [
          atom "(";
          indent;
          break0;
          separate (concat (atom ",") break) values;
          break0;
          dedent;
          atom ")";
        ]
end

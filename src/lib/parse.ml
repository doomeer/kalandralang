open Misc

exception Parse_error of {
    file: string;
    line: int;
    char1: int;
    char2: int;
    message: string
  }

let () =
  Printexc.register_printer @@ function
  | Failure message ->
      Some message
  | Parse_error { file; line; char1; char2; message } ->
      Some (sf "File %S, line %d, characters %d-%d: %s" file line char1 char2 message)
  | _ ->
      None

let from_lexbuf lexbuf =
  try
    try
      Parser.program Lexer.token lexbuf
    with
      | Parsing.Parse_error ->
          failwith "parse error"
  with Failure message ->
    let file = lexbuf.lex_start_p.pos_fname in
    let line = lexbuf.lex_start_p.pos_lnum in
    let char1 = lexbuf.lex_start_p.pos_cnum - lexbuf.lex_start_p.pos_bol in
    let char2 = lexbuf.lex_curr_p.pos_cnum - lexbuf.lex_start_p.pos_bol in
    raise (Parse_error { file; line; char1; char2; message })

let from_string string =
  from_lexbuf (Lexing.from_string string)

let from_stdin () =
  from_lexbuf (Lexing.from_channel stdin)

let from_file filename =
  let ch = open_in filename in
  Fun.protect ~finally: (fun () -> close_in ch) @@ fun () ->
  let lexbuf = Lexing.from_channel ch in
  lexbuf.lex_start_p <- { lexbuf.lex_start_p with pos_fname = filename };
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  from_lexbuf lexbuf

let from_file_or_stdin filename =
  match filename with
    | None -> from_stdin ()
    | Some filename -> from_file filename

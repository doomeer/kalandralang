(* USES ezjsonm *)

type origin_item =
  | File of string
  | Object_field of string
  | Array_item of int

let show_origin_item = function
  | File s -> s ^ ": "
  | Object_field s -> "." ^ s
  | Array_item i -> "." ^ string_of_int i

type t =
  {
    json: Ezjsonm.value;
    origin_rev: origin_item list;
  }

let parse ~origin string =
  {
    json = Ezjsonm.from_string string;
    origin_rev = [ File origin ];
  }

let parse_file filename =
  let ch = open_in filename in
  Fun.protect ~finally: (fun () -> close_in ch) @@ fun () ->
  {
    json = Ezjsonm.from_channel ch;
    origin_rev = [ File filename ];
  }

let encode json =
  Ezjsonm.value_to_string ~minify: false json.json

let write_file filename json =
  let ch = open_out filename in
  Fun.protect ~finally: (fun () -> close_out ch) @@ fun () ->
  Ezjsonm.value_to_channel ~minify: false ch json

let show_origin json =
  List.rev json.origin_rev |> List.map show_origin_item |> String.concat ""

let fail json message =
  failwith (show_origin json ^ ": " ^ message)

let as_int json =
  match json.json with
    | `Float x ->
        int_of_float x
    | _ ->
        fail json "not a number"

let as_float json =
  match json.json with
    | `Float x ->
        x
    | _ ->
        fail json "not a number"

let as_float_opt json =
  match json.json with
    | `Float x ->
        Some x
    | _ ->
        None

let as_string json =
  match json.json with
    | `String x ->
        x
    | _ ->
        fail json "not a string"

let as_id json =
  as_string json |> Id.make

let as_option json =
  match json.json with
    | `Null -> None
    | _ -> Some json

let as_object_opt json =
  match json.json with
    | `O x ->
        Some (
          List.map
            (fun (field, value) ->
               field, { json = value; origin_rev = Object_field field :: json.origin_rev })
            x
        )
    | _ ->
        None

let as_object json =
  match as_object_opt json with
    | Some x -> x
    | None -> fail json "not an object"

let as_array json =
  match json.json with
    | `A x ->
        List.mapi
          (fun i value -> { json = value; origin_rev = Array_item i :: json.origin_rev })
          x
    | _ ->
        fail json "not an array"

let get field json =
  match List.assoc_opt field (as_object json) with
    | None ->
        { json = `Null; origin_rev = Object_field field :: json.origin_rev }
    | Some x ->
        x

let (|->) json field = get field json

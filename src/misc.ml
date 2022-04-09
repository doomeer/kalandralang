module Int_map = Map.Make (Int)
module String_set = Set.Make (String)

module String_map =
struct
  include Map.Make (String)

  let of_list list =
    List.fold_left (fun acc (k, v) -> add k v acc) empty list
end

let fail x = Printf.ksprintf failwith x
let default x = function None -> x | Some x -> x
let echo x = Format.kasprintf print_endline x
let sf = Printf.sprintf

let random_from_pool pool =
  let total_weight = List.fold_left (fun acc (weight, _) -> acc + weight) 0 pool in
  if total_weight <= 0 then
    None
  else
    let rec find choice = function
      | [] ->
          None
      | (head_weight, head) :: tail ->
          if choice < head_weight then
            Some head
          else
            find (choice - head_weight) tail
    in
    find (Random.int total_weight) pool

let ppf pp_doc fmt x = Pretext.to_formatter fmt (pp_doc x)

let rec deduplicate ?(acc = []) compare list =
  match list with
    | [] ->
        List.rev acc
    | head :: tail ->
        if List.exists (fun item -> compare item head = 0) acc then
          deduplicate ~acc compare tail
        else
          deduplicate ~acc: (head :: acc) compare tail

let rex_glob pattern = Re.compile (Re.Glob.glob (String.lowercase_ascii pattern))
let rex pattern = Re.compile (Re.Perl.re pattern)
let (=~) string rex = Re.execp rex string
let (=~!) string rex = not (string =~ rex)

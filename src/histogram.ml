type t = float list ref

let create () = ref []

let add histogram value = histogram := value :: !histogram

let round_up_for_axis x =
  if x < 0. then
    0.
  else
    let rec lowest_greater candidate =
      if candidate >= x then
        candidate
      else
        lowest_greater (candidate *. 10.)
    in
    let ten = lowest_greater 0.0000001 in
    let five = ten /. 2. in
    if five >= x then
      let two = ten /. 5. in
      if two >= x then
        two
      else
        five
    else
      ten

let block_1_8 = "▁"
let block_2_8 = "▂"
let block_3_8 = "▃"
let block_4_8 = "▄"
let block_5_8 = "▅"
let block_6_8 = "▆"
let block_7_8 = "▇"
let block_8_8 = "█"

let output ?(unit = "") histogram ~w ~h =
  match !histogram with
    | [] ->
        ()
    | head :: tail as values ->
        (* Compute min and max values. *)
        let min_value = ref head in
        let max_value = ref head in
        let update_min_max value =
          if value < !min_value then min_value := value;
          if value > !max_value then max_value := value;
        in
        List.iter update_min_max tail;
        let min_value = !min_value in
        let max_value = !max_value in
        (* Include zero. *)
        let min_value = min 0. min_value in
        let max_value = max 0. max_value in
        (* Find nice round numbers. *)
        let max_value = round_up_for_axis max_value in
        (* Fill [w] buckets. *)
        let buckets = Array.make w 0 in
        let bucket_width = (max_value -. min_value) /. float w in
        let add_to_bucket value =
          let bucket = int_of_float ((value -. min_value) /. bucket_width) in
          let bucket = min (w - 1) (max 0 bucket) in
          buckets.(bucket) <- buckets.(bucket) + 1;
        in
        List.iter add_to_bucket values;
        (* Compute max count. *)
        let max_count = ref 0 in
        let update_max_count count =
          if count > !max_count then max_count := count
        in
        Array.iter update_max_count buckets;
        (* Display histogram. *)
        for y = 1 to h do
          for x = 0 to w - 1 do
            let ratio =
              float buckets.(x) *. float h /. float !max_count -. float (h - y)
            in
            if ratio >= 8. /. 8. -. 1. /. 16. then print_string block_8_8 else
            if ratio >= 7. /. 8. -. 1. /. 16. then print_string block_7_8 else
            if ratio >= 6. /. 8. -. 1. /. 16. then print_string block_6_8 else
            if ratio >= 5. /. 8. -. 1. /. 16. then print_string block_5_8 else
            if ratio >= 4. /. 8. -. 1. /. 16. then print_string block_4_8 else
            if ratio >= 3. /. 8. -. 1. /. 16. then print_string block_3_8 else
            if ratio >= 2. /. 8. -. 1. /. 16. then print_string block_2_8 else
            if ratio >= 1. /. 8. -. 1. /. 16. then print_string block_1_8 else
              print_char ' '
          done;
          print_newline ();
        done;
        (* Display X axis. *)
        for _ = 1 to w do
          print_string "‾";
        done;
        print_newline ();
        let string_of_float x =
          if x = 0. || x >= 1. then string_of_int (int_of_float x) else string_of_float x
        in
        let min_string = string_of_float min_value ^ unit in
        let max_string = string_of_float max_value ^ unit in
        let blank = w - String.length min_string - String.length max_string in
        print_string min_string;
        print_string (String.make blank ' ');
        print_endline max_string;
        ()

let test () =
  let h = create () in
  add h 10.;
  add h 15.;
  add h 50.;
  add h 50.;
  output h ~w: 80 ~h: 16

type 'a t =
  {
    values: 'a array;
    mutable remaining: int;
  }

let create_from_list list =
  let values = Array.of_list list in
  {
    values;
    remaining = Array.length values;
  }

let pick pool =
  if pool.remaining <= 0 then
    None
  else
    let index = Random.int pool.remaining in
    let value = pool.values.(index) in
    (* Remove the value by replacing it with the last value. *)
    pool.values.(index) <- pool.values.(pool.remaining - 1);
    pool.remaining <- pool.remaining - 1;
    Some value

let to_list pool =
  Array.sub pool.values 0 pool.remaining |> Array.to_list

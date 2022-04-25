let version = "KKASH002"

exception Wrong_version

type data =
  {
    base_items: Base_item.data;
    mods: Mod.data;
    stat_translations: Stat_translation.data;
    essences: Essence.data;
  }

let o_fixed_string = output_string
let i_fixed_string size o = really_input_string o size

let o_byte = output_byte
let i_byte = input_byte

let o_int = output_binary_int
let i_int = input_binary_int

let o_string o x =
  o_int o (String.length x);
  o_fixed_string o x

let i_string i =
  let length = i_int i in
  i_fixed_string length i

let o_option o_value o = function
  | None ->
      o_byte o 0
  | Some value ->
      o_byte o 1;
      o_value o value

let i_option i_value i =
  match i_byte i with
    | 0 ->
        None
    | 1 ->
        let value = i_value i in
        Some value
    | _ -> failwith "invalid option"

let o_list o_value o x =
  o_int o (List.length x);
  List.iter (o_value o) x

let i_list i_value i =
  let length = i_int i in
  let rec loop acc n =
    if n <= 0 then
      List.rev acc
    else
      let value = i_value i in
      loop (value :: acc) (n - 1)
  in
  loop [] length

let o_pair o_a o_b o (a, b) =
  o_a o a;
  o_b o b

let i_pair i_a i_b i =
  let a = i_a i in
  let b = i_b i in
  a, b

let o_id o id =
  o_string o (Id.show id)

let i_id i =
  Id.make (i_string i)

let o_id_map_without_keys o_value o x =
  o_int o (Id.Map.cardinal x);
  Id.Map.iter (fun _ value -> o_value o value) x

let i_id_map_without_keys i_value get_id i =
  let cardinal = i_int i in
  let rec loop acc n =
    if n <= 0 then
      acc
    else
      let value = i_value i in
      loop (Id.Map.add (get_id value) value acc) (n - 1)
  in
  loop Id.Map.empty cardinal

let o_id_map_with_keys o_value o x =
  o_int o (Id.Map.cardinal x);
  Id.Map.iter (fun id value -> o_id o id; o_value o value) x

let i_id_map_with_keys i_value i =
  let cardinal = i_int i in
  let rec loop acc n =
    if n <= 0 then
      acc
    else
      let id = i_id i in
      let value = i_value i in
      loop (Id.Map.add id value acc) (n - 1)
  in
  loop Id.Map.empty cardinal

let o_id_set o x =
  o_int o (Id.Set.cardinal x);
  Id.Set.iter (o_id o) x

let i_id_set i =
  let cardinal = i_int i in
  let rec loop acc n =
    if n <= 0 then
      acc
    else
      let id = i_id i in
      loop (Id.Set.add id acc) (n - 1)
  in
  loop Id.Set.empty cardinal

let o_base_item_domain o (x: Base_item.domain) =
  match x with
    | Item -> o_byte o 0
    | Crafted -> o_byte o 1
    | Veiled -> o_byte o 2
    | Misc -> o_byte o 3
    | Abyss_jewel -> o_byte o 4
    | Unveiled -> o_byte o 5

let i_base_item_domain i: Base_item.domain =
  match i_byte i with
    | 0 -> Item
    | 1 -> Crafted
    | 2 -> Veiled
    | 3 -> Misc
    | 4 -> Abyss_jewel
    | 5 -> Unveiled
    | _ -> failwith "invalid base item domain"

let o_base_item o ({ id; domain; item_class; name; tags }: Base_item.t) =
  o_id o id;
  o_base_item_domain o domain;
  o_id o item_class;
  o_id o name;
  o_id_set o tags

let i_base_item i: Base_item.t =
  let id = i_id i in
  let domain = i_base_item_domain i in
  let item_class = i_id i in
  let name = i_id i in
  let tags = i_id_set i in
  { id; domain; item_class; name; tags }

let o_mod_generation_type o (x: Mod.generation_type) =
  match x with
    | Prefix -> o_byte o 0
    | Suffix -> o_byte o 1
    | Exarch_implicit Lesser -> o_byte o 2
    | Exarch_implicit Greater -> o_byte o 3
    | Exarch_implicit Grand -> o_byte o 4
    | Exarch_implicit Exceptional -> o_byte o 5
    | Exarch_implicit Exquisite -> o_byte o 6
    | Exarch_implicit Perfect -> o_byte o 7
    | Eater_implicit Lesser -> o_byte o 8
    | Eater_implicit Greater -> o_byte o 9
    | Eater_implicit Grand -> o_byte o 10
    | Eater_implicit Exceptional -> o_byte o 11
    | Eater_implicit Exquisite -> o_byte o 12
    | Eater_implicit Perfect -> o_byte o 13

let i_mod_generation_type i: Mod.generation_type =
  match i_byte i with
    | 0 -> Prefix
    | 1 -> Suffix
    | 2 -> Exarch_implicit Lesser
    | 3 -> Exarch_implicit Greater
    | 4 -> Exarch_implicit Grand
    | 5 -> Exarch_implicit Exceptional
    | 6 -> Exarch_implicit Exquisite
    | 7 -> Exarch_implicit Perfect
    | 8 -> Eater_implicit Lesser
    | 9 -> Eater_implicit Greater
    | 10 -> Eater_implicit Grand
    | 11 -> Eater_implicit Exceptional
    | 12 -> Eater_implicit Exquisite
    | 13 -> Eater_implicit Perfect
    | _ -> failwith "invalid mod generation type"

let o_mod_stat o ({ id; min; max }: Mod.stat) =
  o_id o id;
  o_int o min;
  o_int o max

let i_mod_stat i: Mod.stat =
  let id = i_id i in
  let min = i_int i in
  let max = i_int i in
  { id; min; max }

let o_mod o (
    { id; domain; generation_type; group; required_level; spawn_weights;
      generation_weights; tags; adds_tags; stats }: Mod.t
  ) =
  o_id o id;
  o_base_item_domain o domain;
  o_mod_generation_type o generation_type;
  o_id o group;
  o_int o required_level;
  o_list (o_pair o_id o_int) o spawn_weights;
  o_list (o_pair o_id o_int) o generation_weights;
  o_id_set o tags;
  o_id_set o adds_tags;
  o_list o_mod_stat o stats

let i_mod i: Mod.t =
  let id = i_id i in
  let domain = i_base_item_domain i in
  let generation_type = i_mod_generation_type i in
  let group = i_id i in
  let required_level = i_int i in
  let spawn_weights = i_list (i_pair i_id i_int) i in
  let generation_weights = i_list (i_pair i_id i_int) i in
  let tags = i_id_set i in
  let adds_tags = i_id_set i in
  let stats = i_list i_mod_stat i in
  { id; domain; generation_type; group; required_level; spawn_weights;
    generation_weights; tags; adds_tags; stats }

let o_stat_translation_condition o ({ min; max }: Stat_translation.condition) =
  o_option o_int o min;
  o_option o_int o max

let i_stat_translation_condition i: Stat_translation.condition =
  let min = i_option i_int i in
  let max = i_option i_int i in
  { min; max }

let rec o_stat_translation_format o (x: Stat_translation.format) =
  match x with
    | Number ->
        o_byte o 0
    | Plus_number ->
        o_byte o 1
    | IH_30pct_of_value y ->
        o_byte o 2;
        o_stat_translation_format o y
    | IH_60pct_of_value y ->
        o_byte o 3;
        o_stat_translation_format o y
    | IH_deciseconds_to_seconds y ->
        o_byte o 4;
        o_stat_translation_format o y
    | IH_divide_by_three y ->
        o_byte o 5;
        o_stat_translation_format o y
    | IH_divide_by_five y ->
        o_byte o 6;
        o_stat_translation_format o y
    | IH_divide_by_one_hundred y ->
        o_byte o 7;
        o_stat_translation_format o y
    | IH_divide_by_one_hundred_and_negate y ->
        o_byte o 8;
        o_stat_translation_format o y
    | IH_divide_by_one_hundred_2dp y ->
        o_byte o 9;
        o_stat_translation_format o y
    | IH_divide_by_two_0dp y ->
        o_byte o 10;
        o_stat_translation_format o y
    | IH_divide_by_four y ->
        o_byte o 11;
        o_stat_translation_format o y
    | IH_divide_by_six y ->
        o_byte o 12;
        o_stat_translation_format o y
    | IH_divide_by_ten_0dp y ->
        o_byte o 13;
        o_stat_translation_format o y
    | IH_divide_by_ten_1dp y ->
        o_byte o 14;
        o_stat_translation_format o y
    | IH_divide_by_ten_1dp_if_required y ->
        o_byte o 15;
        o_stat_translation_format o y
    | IH_divide_by_twelve y ->
        o_byte o 16;
        o_stat_translation_format o y
    | IH_divide_by_fifteen_0dp y ->
        o_byte o 17;
        o_stat_translation_format o y
    | IH_divide_by_twenty_then_double_0dp y ->
        o_byte o 18;
        o_stat_translation_format o y
    | IH_divide_by_fifty y ->
        o_byte o 19;
        o_stat_translation_format o y
    | IH_divide_by_one_hundred_2dp_if_required y ->
        o_byte o 20;
        o_stat_translation_format o y
    | IH_milliseconds_to_seconds y ->
        o_byte o 21;
        o_stat_translation_format o y
    | IH_milliseconds_to_seconds_0dp y ->
        o_byte o 22;
        o_stat_translation_format o y
    | IH_milliseconds_to_seconds_1dp y ->
        o_byte o 23;
        o_stat_translation_format o y
    | IH_milliseconds_to_seconds_2dp y ->
        o_byte o 24;
        o_stat_translation_format o y
    | IH_milliseconds_to_seconds_2dp_if_required y ->
        o_byte o 25;
        o_stat_translation_format o y
    | IH_multiplicative_damage_modifier y ->
        o_byte o 26;
        o_stat_translation_format o y
    | IH_multiplicative_permyriad_damage_modifier y ->
        o_byte o 27;
        o_stat_translation_format o y
    | IH_multiply_by_four y ->
        o_byte o 28;
        o_stat_translation_format o y
    | IH_negate y ->
        o_byte o 29;
        o_stat_translation_format o y
    | IH_old_leech_percent y ->
        o_byte o 30;
        o_stat_translation_format o y
    | IH_old_leech_permyriad y ->
        o_byte o 31;
        o_stat_translation_format o y
    | IH_per_minute_to_per_second y ->
        o_byte o 32;
        o_stat_translation_format o y
    | IH_per_minute_to_per_second_0dp y ->
        o_byte o 33;
        o_stat_translation_format o y
    | IH_per_minute_to_per_second_1dp y ->
        o_byte o 34;
        o_stat_translation_format o y
    | IH_per_minute_to_per_second_2dp y ->
        o_byte o 35;
        o_stat_translation_format o y
    | IH_per_minute_to_per_second_2dp_if_required y ->
        o_byte o 36;
        o_stat_translation_format o y
    | IH_times_twenty y ->
        o_byte o 37;
        o_stat_translation_format o y
    | IH_canonical_line y ->
        o_byte o 38;
        o_stat_translation_format o y
    | IH_canonical_stat y ->
        o_byte o 39;
        o_stat_translation_format o y
    | IH_mod_value_to_item_class y ->
        o_byte o 40;
        o_stat_translation_format o y
    | IH_tempest_mod_text y ->
        o_byte o 41;
        o_stat_translation_format o y
    | IH_display_indexable_support y ->
        o_byte o 42;
        o_stat_translation_format o y
    | IH_tree_expansion_jewel_passive y ->
        o_byte o 43;
        o_stat_translation_format o y
    | IH_affliction_reward_type y ->
        o_byte o 44;
        o_stat_translation_format o y
    | IH_passive_hash y ->
        o_byte o 45;
        o_stat_translation_format o y
    | IH_reminderstring y ->
        o_byte o 46;
        o_stat_translation_format o y
    | IH_times_one_point_five y ->
        o_byte o 47;
        o_stat_translation_format o y
    | IH_double y ->
        o_byte o 48;
        o_stat_translation_format o y
    | IH_negate_and_double y ->
        o_byte o 49;
        o_stat_translation_format o y
    | IH_metamorphosis_reward_description y ->
        o_byte o 50;
        o_stat_translation_format o y
    | IH_divide_by_one_thousand y ->
        o_byte o 51;
        o_stat_translation_format o y

let rec i_stat_translation_format i: Stat_translation.format =
  match i_byte i with
    | 0 ->
        Number
    | 1 ->
        Plus_number
    | 2 ->
        let y = i_stat_translation_format i in
        IH_30pct_of_value y
    | 3 ->
        let y = i_stat_translation_format i in
        IH_60pct_of_value y
    | 4 ->
        let y = i_stat_translation_format i in
        IH_deciseconds_to_seconds y
    | 5 ->
        let y = i_stat_translation_format i in
        IH_divide_by_three y
    | 6 ->
        let y = i_stat_translation_format i in
        IH_divide_by_five y
    | 7 ->
        let y = i_stat_translation_format i in
        IH_divide_by_one_hundred y
    | 8 ->
        let y = i_stat_translation_format i in
        IH_divide_by_one_hundred_and_negate y
    | 9 ->
        let y = i_stat_translation_format i in
        IH_divide_by_one_hundred_2dp y
    | 10 ->
        let y = i_stat_translation_format i in
        IH_divide_by_two_0dp y
    | 11 ->
        let y = i_stat_translation_format i in
        IH_divide_by_four y
    | 12 ->
        let y = i_stat_translation_format i in
        IH_divide_by_six y
    | 13 ->
        let y = i_stat_translation_format i in
        IH_divide_by_ten_0dp y
    | 14 ->
        let y = i_stat_translation_format i in
        IH_divide_by_ten_1dp y
    | 15 ->
        let y = i_stat_translation_format i in
        IH_divide_by_ten_1dp_if_required y
    | 16 ->
        let y = i_stat_translation_format i in
        IH_divide_by_twelve y
    | 17 ->
        let y = i_stat_translation_format i in
        IH_divide_by_fifteen_0dp y
    | 18 ->
        let y = i_stat_translation_format i in
        IH_divide_by_twenty_then_double_0dp y
    | 19 ->
        let y = i_stat_translation_format i in
        IH_divide_by_fifty y
    | 20 ->
        let y = i_stat_translation_format i in
        IH_divide_by_one_hundred_2dp_if_required y
    | 21 ->
        let y = i_stat_translation_format i in
        IH_milliseconds_to_seconds y
    | 22 ->
        let y = i_stat_translation_format i in
        IH_milliseconds_to_seconds_0dp y
    | 23 ->
        let y = i_stat_translation_format i in
        IH_milliseconds_to_seconds_1dp y
    | 24 ->
        let y = i_stat_translation_format i in
        IH_milliseconds_to_seconds_2dp y
    | 25 ->
        let y = i_stat_translation_format i in
        IH_milliseconds_to_seconds_2dp_if_required y
    | 26 ->
        let y = i_stat_translation_format i in
        IH_multiplicative_damage_modifier y
    | 27 ->
        let y = i_stat_translation_format i in
        IH_multiplicative_permyriad_damage_modifier y
    | 28 ->
        let y = i_stat_translation_format i in
        IH_multiply_by_four y
    | 29 ->
        let y = i_stat_translation_format i in
        IH_negate y
    | 30 ->
        let y = i_stat_translation_format i in
        IH_old_leech_percent y
    | 31 ->
        let y = i_stat_translation_format i in
        IH_old_leech_permyriad y
    | 32 ->
        let y = i_stat_translation_format i in
        IH_per_minute_to_per_second y
    | 33 ->
        let y = i_stat_translation_format i in
        IH_per_minute_to_per_second_0dp y
    | 34 ->
        let y = i_stat_translation_format i in
        IH_per_minute_to_per_second_1dp y
    | 35 ->
        let y = i_stat_translation_format i in
        IH_per_minute_to_per_second_2dp y
    | 36 ->
        let y = i_stat_translation_format i in
        IH_per_minute_to_per_second_2dp_if_required y
    | 37 ->
        let y = i_stat_translation_format i in
        IH_times_twenty y
    | 38 ->
        let y = i_stat_translation_format i in
        IH_canonical_line y
    | 39 ->
        let y = i_stat_translation_format i in
        IH_canonical_stat y
    | 40 ->
        let y = i_stat_translation_format i in
        IH_mod_value_to_item_class y
    | 41 ->
        let y = i_stat_translation_format i in
        IH_tempest_mod_text y
    | 42 ->
        let y = i_stat_translation_format i in
        IH_display_indexable_support y
    | 43 ->
        let y = i_stat_translation_format i in
        IH_tree_expansion_jewel_passive y
    | 44 ->
        let y = i_stat_translation_format i in
        IH_affliction_reward_type y
    | 45 ->
        let y = i_stat_translation_format i in
        IH_passive_hash y
    | 46 ->
        let y = i_stat_translation_format i in
        IH_reminderstring y
    | 47 ->
        let y = i_stat_translation_format i in
        IH_times_one_point_five y
    | 48 ->
        let y = i_stat_translation_format i in
        IH_double y
    | 49 ->
        let y = i_stat_translation_format i in
        IH_negate_and_double y
    | 50 ->
        let y = i_stat_translation_format i in
        IH_metamorphosis_reward_description y
    | 51 ->
        let y = i_stat_translation_format i in
        IH_divide_by_one_thousand y
    | _ ->
        failwith "invalid stat translation format"

let o_stat_translation_string_part o (x: Stat_translation.string_part) =
  match x with
    | Constant str ->
        o_byte o 0;
        o_string o str
    | Stat index ->
        o_byte o 1;
        o_int o index

let i_stat_translation_string_part i: Stat_translation.string_part =
  match i_byte i with
    | 0 ->
        let str = i_string i in
        Constant str
    | 1 ->
        let index = i_int i in
        Stat index
    | _ ->
        failwith "invalid stat translation string part"

let o_stat_translation_translation o (
    { conditions; formats; string; stats }: Stat_translation.translation
  ) =
  o_list o_stat_translation_condition o conditions;
  o_list o_stat_translation_format o formats;
  o_list o_stat_translation_string_part o string;
  o_list o_id o stats

let i_stat_translation_translation i: Stat_translation.translation =
  let conditions = i_list i_stat_translation_condition i in
  let formats = i_list i_stat_translation_format i in
  let string = i_list i_stat_translation_string_part i in
  let stats = i_list i_id i in
  { conditions; formats; string; stats }

let o_stat_translation o (x: Stat_translation.t) =
  o_list o_stat_translation_translation o x

let i_stat_translation i: Stat_translation.t =
  i_list i_stat_translation_translation i

let o_essence_level o (level: Essence.level) =
  (* Start at 1 instead of 0 because it is more consistent with actual data files. *)
  match level with
    | Whispering -> o_byte o 1
    | Muttering -> o_byte o 2
    | Weeping -> o_byte o 3
    | Wailing -> o_byte o 4
    | Screaming -> o_byte o 5
    | Shrieking -> o_byte o 6
    | Deafening -> o_byte o 7
    | Corrupted -> o_byte o 8

let i_essence_level i: Essence.level =
  (* Start at 1 instead of 0 because it is more consistent with actual data files. *)
  match i_byte i with
    | 1 -> Whispering
    | 2 -> Muttering
    | 3 -> Weeping
    | 4 -> Wailing
    | 5 -> Screaming
    | 6 -> Shrieking
    | 7 -> Deafening
    | 8 -> Corrupted
    | _ -> failwith "invalid essence level"

let o_essence o (
    { id; name; item_level_restriction; level; on_amulet; on_belt; on_body_armour;
      on_boots; on_bow; on_claw; on_dagger; on_gloves; on_helmet; on_one_hand_axe;
      on_one_hand_mace; on_one_hand_sword; on_quiver; on_ring; on_sceptre; on_shield;
      on_staff; on_thrusting_one_hand_sword; on_two_hand_axe; on_two_hand_mace;
      on_two_hand_sword; on_wand }: Essence.t
  ) =
  o_id o id;
  o_id o name;
  o_option o_int o item_level_restriction;
  o_essence_level o level;
  o_id o on_amulet;
  o_id o on_belt;
  o_id o on_body_armour;
  o_id o on_boots;
  o_id o on_bow;
  o_id o on_claw;
  o_id o on_dagger;
  o_id o on_gloves;
  o_id o on_helmet;
  o_id o on_one_hand_axe;
  o_id o on_one_hand_mace;
  o_id o on_one_hand_sword;
  o_id o on_quiver;
  o_id o on_ring;
  o_id o on_sceptre;
  o_id o on_shield;
  o_id o on_staff;
  o_id o on_thrusting_one_hand_sword;
  o_id o on_two_hand_axe;
  o_id o on_two_hand_mace;
  o_id o on_two_hand_sword;
  o_id o on_wand

let i_essence i: Essence.t =
  let id = i_id i in
  let name = i_id i in
  let item_level_restriction = i_option i_int i in
  let level = i_essence_level i in
  let on_amulet = i_id i in
  let on_belt = i_id i in
  let on_body_armour = i_id i in
  let on_boots = i_id i in
  let on_bow = i_id i in
  let on_claw = i_id i in
  let on_dagger = i_id i in
  let on_gloves = i_id i in
  let on_helmet = i_id i in
  let on_one_hand_axe = i_id i in
  let on_one_hand_mace = i_id i in
  let on_one_hand_sword = i_id i in
  let on_quiver = i_id i in
  let on_ring = i_id i in
  let on_sceptre = i_id i in
  let on_shield = i_id i in
  let on_staff = i_id i in
  let on_thrusting_one_hand_sword = i_id i in
  let on_two_hand_axe = i_id i in
  let on_two_hand_mace = i_id i in
  let on_two_hand_sword = i_id i in
  let on_wand = i_id i in
  { id; name; item_level_restriction; level; on_amulet; on_belt; on_body_armour;
    on_boots; on_bow; on_claw; on_dagger; on_gloves; on_helmet; on_one_hand_axe;
    on_one_hand_mace; on_one_hand_sword; on_quiver; on_ring; on_sceptre; on_shield;
    on_staff; on_thrusting_one_hand_sword; on_two_hand_axe; on_two_hand_mace;
    on_two_hand_sword; on_wand }

let o_data o { base_items; mods; stat_translations; essences } =
  o_fixed_string o version;
  o_id_map_without_keys o_base_item o base_items;
  o_list o_mod o mods;
  o_id_map_with_keys o_stat_translation o stat_translations;
  o_id_map_without_keys o_essence o essences;
  (* For safety reasons, we store the version at the end too,
     so that we can check that we read everything. *)
  o_fixed_string o version

let i_data i =
  let file_version = i_fixed_string (String.length version) i in
  if file_version <> version then raise Wrong_version;
  let base_items = i_id_map_without_keys i_base_item (fun x -> x.id) i in
  let mods = i_list i_mod i in
  let stat_translations = i_id_map_with_keys i_stat_translation i in
  let essences = i_id_map_without_keys i_essence (fun x -> x.id) i in
  let file_version = i_fixed_string (String.length version) i in
  if file_version <> version then failwith "failed to read data until the end";
  {
    base_items;
    mods;
    stat_translations;
    essences;
  }

let export filename =
  let data =
    {
      base_items = Base_item.export ();
      mods = Mod.export ();
      stat_translations = Stat_translation.export ();
      essences = Essence.export ();
    }
  in
  let ch = open_out filename in
  Fun.protect ~finally: (fun () -> close_out ch) @@ fun () ->
  o_data ch data

type import_result =
  | Wrong_version
  | Failed_to_load
  | Loaded

let import filename =
  match
    let ch = open_in filename in
    Fun.protect ~finally: (fun () -> close_in ch) @@ fun () ->
    i_data ch
  with
    | exception (Failure _ | End_of_file) ->
        Failed_to_load
    | exception Wrong_version ->
        Wrong_version
    | { base_items; mods; stat_translations; essences } ->
        Base_item.import base_items;
        Mod.import mods;
        Stat_translation.import stat_translations;
        Essence.import essences;
        Loaded

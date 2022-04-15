(* USES uri *)
(* USES tls *)
(* USES cohttp-lwt-unix *)
(* USES lwt *)

open Misc

let (let*) = Lwt.bind
let return = Lwt.return

let http_get uri =
  Lwt_main.run @@
  let* (response, response_body) = Cohttp_lwt_unix.Client.call `GET uri in
  let* response_body = Cohttp_lwt.Body.to_string response_body in
  match response.status with
    | #Cohttp.Code.success_status ->
        return (JSON.parse ~origin: "poe.ninja's response" response_body)
    | status ->
        fail "poe.ninja responded with %s - %s"
          (Cohttp.Code.string_of_status status)
          response_body

let as_currencies json =
  let as_currency json =
    let name = JSON.(json |-> "currencyTypeName" |> as_string) in
    let cost = JSON.(json |-> "chaosEquivalent" |> as_float) in
    name, cost
  in
  JSON.(json |-> "lines" |> as_array) |> List.map as_currency |> String_map.of_list

let get_currencies league =
  Uri.(with_query' (of_string "https://poe.ninja/api/data/CurrencyOverview")) [
    "league", league;
    "type", "Currency";
    "language", "en";
  ]
  |> http_get
  |> as_currencies

let as_items json =
  let as_item json =
    let name = JSON.(json |-> "name" |> as_string) in
    let cost = JSON.(json |-> "chaosValue" |> as_float) in
    name, cost
  in
  JSON.(json |-> "lines" |> as_array) |> List.map as_item |> String_map.of_list

let get_items ~league item_type =
  Uri.(with_query' (of_string "https://poe.ninja/api/data/ItemOverview")) [
    "league", league;
    "type", item_type;
    "language", "en";
  ]
  |> http_get
  |> as_items

let get_essences league =
  get_items ~league "Essence"

let get_fossils league =
  get_items ~league "Fossil"

let get_resonators league =
  get_items ~league "Resonator"

let get_beasts league =
  get_items ~league "Beast"

let write_costs ~league ~filename =
  let currencies = get_currencies league in
  let essences = get_essences league in
  let fossils = get_fossils league in
  let resonators = get_resonators league in
  let beasts = get_beasts league in
  let c name = String_map.find_opt name currencies in
  let e name = String_map.find_opt name essences in
  let f name = String_map.find_opt name fossils in
  let r name = String_map.find_opt name resonators in
  let b name = String_map.find_opt name beasts in
  let cost: _ Cost.t =
    {
      transmute = c "Orb of Transmutation";
      augment = c "Orb of Augmentation";
      alt = c "Orb of Alteration";
      regal = c "Regal Orb";
      alch = c "Orb of Alchemy";
      bless = c "Blessed Orb";
      scour = c "Orb of Scouring";
      annul = c "Orb of Annulment";
      exalt = c "Exalted Orb";
      crusader_exalt = c "Crusader's Exalted Orb";
      hunter_exalt = c "Hunter's Exalted Orb";
      redeemer_exalt = c "Redeemer's Exalted Orb";
      warlord_exalt = c "Warlord's Exalted Orb";
      veiled_chaos = c "Veiled Chaos Orb";
      essence_of_anger = e "Deafening Essence of Anger";
      essence_of_anguish = e "Deafening Essence of Anguish";
      essence_of_contempt = e "Deafening Essence of Contempt";
      essence_of_doubt = e "Deafening Essence of Doubt";
      essence_of_dread = e "Deafening Essence of Dread";
      essence_of_envy = e "Deafening Essence of Envy";
      essence_of_fear = e "Deafening Essence of Fear";
      essence_of_greed = e "Deafening Essence of Greed";
      essence_of_hatred = e "Deafening Essence of Hatred";
      essence_of_loathing = e "Deafening Essence of Loathing";
      essence_of_misery = e "Deafening Essence of Misery";
      essence_of_rage = e "Deafening Essence of Rage";
      essence_of_scorn = e "Deafening Essence of Scorn";
      essence_of_sorrow = e "Deafening Essence of Sorrow";
      essence_of_spite = e "Deafening Essence of Spite";
      essence_of_suffering = e "Deafening Essence of Suffering";
      essence_of_torment = e "Deafening Essence of Torment";
      essence_of_woe = e "Deafening Essence of Woe";
      essence_of_wrath = e "Deafening Essence of Wrath";
      essence_of_zeal = e "Deafening Essence of Zeal";
      essence_of_delirium = e "Essence of Delirium";
      essence_of_horror = e "Essence of Horror";
      essence_of_hysteria = e "Essence of Hysteria";
      essence_of_insanity = e "Essence of Insanity";
      aberrant_fossil = f "Aberrant Fossil";
      aetheric_fossil = f "Aetheric Fossil";
      bound_fossil = f "Bound Fossil";
      corroded_fossil = f "Corroded Fossil";
      dense_fossil = f "Dense Fossil";
      faceted_fossil = f "Faceted Fossil";
      frigid_fossil = f "Frigid Fossil";
      jagged_fossil = f "Jagged Fossil";
      lucent_fossil = f "Lucent Fossil";
      metallic_fossil = f "Metallic Fossil";
      prismatic_fossil = f "Prismatic Fossil";
      pristine_fossil = f "Pristine Fossil";
      scorched_fossil = f "Scorched Fossil";
      serrated_fossil = f "Serrated Fossil";
      shuddering_fossil = f "Shuddering Fossil";
      fundamental_fossil = f "Fundamental Fossil";
      deft_fossil = f "Deft Fossil";
      primitive_resonator = r "Primitive Chaotic Resonator";
      potent_resonator = r "Potent Chaotic Resonator";
      powerful_resonator = r "Powerful Chaotic Resonator";
      prime_resonator = r "Prime Chaotic Resonator";
      awaken = c "Awakener's Orb";
      lesser_ember = c "Lesser Eldritch Ember";
      greater_ember = c "Greater Eldritch Ember";
      grand_ember = c "Grand Eldritch Ember";
      exceptional_ember = c "Exceptional Eldritch Ember";
      lesser_ichor = c "Lesser Eldritch Ichor";
      greater_ichor = c "Greater Eldritch Ichor";
      grand_ichor = c "Grand Eldritch Ichor";
      exceptional_ichor = c "Exceptional Eldritch Ichor";
      harvest_augment_attack = None;
      harvest_augment_caster = None;
      harvest_augment_chaos = None;
      harvest_augment_cold = None;
      harvest_augment_critical = None;
      harvest_augment_defences = None;
      harvest_augment_fire = None;
      harvest_augment_life = None;
      harvest_augment_lightning = None;
      harvest_augment_physical = None;
      harvest_augment_speed = None;
      harvest_non_attack_to_attack = None;
      harvest_non_caster_to_caster = None;
      harvest_non_chaos_to_chaos = None;
      harvest_non_cold_to_cold = None;
      harvest_non_critical_to_critical = None;
      harvest_non_defences_to_defences = None;
      harvest_non_fire_to_fire = None;
      harvest_non_life_to_life = None;
      harvest_non_lightning_to_lightning = None;
      harvest_non_physical_to_physical = None;
      harvest_non_speed_to_speed = None;
      harvest_reforge_attack = None;
      harvest_reforge_caster = None;
      harvest_reforge_chaos = None;
      harvest_reforge_cold = None;
      harvest_reforge_critical = None;
      harvest_reforge_defences = None;
      harvest_reforge_fire = None;
      harvest_reforge_life = None;
      harvest_reforge_lightning = None;
      harvest_reforge_physical = None;
      harvest_reforge_speed = None;
      harvest_reforge_keep_prefixes = None;
      harvest_reforge_keep_suffixes = None;
      beastcraft_aspect_of_the_avian = b "Saqawal, First of the Sky";
      beastcraft_aspect_of_the_cat = b "Farrul, First of the Plains";
      beastcraft_aspect_of_the_crab = b "Craiceann, First of the Deep";
      beastcraft_aspect_of_the_spider = b "Fenumus, First of the Night";
      beastcraft_split = b "Fenumal Plagued Arachnid";
      beastcraft_imprint = b "Craicic Chimeral";
      aisling = None;
    }
  in
  Cost.write_options cost filename

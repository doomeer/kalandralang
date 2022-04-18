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

let as_tft json =
  let as_item json =
    let name = JSON.(json |-> "name" |> as_string) in
    let cost = JSON.(json |-> "chaos" |> as_float) in
    name, cost
  in
  JSON.(json |-> "data" |> as_array) |> List.map as_item |> String_map.of_list

let get_tft league filename =
  Uri.of_string
    ("https://raw.githubusercontent.com/The-Forbidden-Trove/tft-data-prices/master/" ^
     league ^ "/" ^ filename)
  |> http_get
  |> as_tft

let write_costs ~ninja_league ~tft_league ~filename =
  let currencies = get_currencies ninja_league in
  let essences = get_essences ninja_league in
  let fossils = get_fossils ninja_league in
  let resonators = get_resonators ninja_league in
  let beasts = get_beasts ninja_league in
  let harvest_crafts = get_tft tft_league "harvest.json" in
  let services = get_tft tft_league "service.json" in
  let wrap kind f name =
    let result = f name in
    (
      match result with
        | None ->
            echo "%s: %s: failed to find value, will use default" kind name
        | Some value ->
            echo "%s: %s: %gc" kind name value
    );
    result
  in
  let c = wrap "Currency (poe.ninja)" @@ fun name -> String_map.find_opt name currencies in
  let e = wrap "Essence (poe.ninja)" @@ fun name -> String_map.find_opt name essences in
  let f = wrap "Fossil (poe.ninja)" @@ fun name -> String_map.find_opt name fossils in
  let r = wrap "Resonator (poe.ninja)" @@ fun name -> String_map.find_opt name resonators in
  let b = wrap "Beast (poe.ninja)" @@ fun name -> String_map.find_opt name beasts in
  let h = wrap "Harvest Craft (TFT)" @@ fun name -> String_map.find_opt name harvest_crafts in
  let s = wrap "Service (TFT)" @@ fun name -> String_map.find_opt name services in
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
      eldritch_annul = c "Eldritch Orb of Annulment";
      eldritch_exalt = c "Eldritch Exalted Orb";
      eldritch_chaos = c "Eldritch Chaos Orb";
      harvest_augment_attack = h "Augment Attack";
      harvest_augment_caster = h "Augment Caster";
      harvest_augment_chaos = h "Augment Chaos";
      harvest_augment_cold = h "Augment Cold";
      harvest_augment_critical = h "Augment Critical";
      harvest_augment_defences = h "Augment Defence";
      harvest_augment_fire = h "Augment Fire";
      harvest_augment_life = h "Augment Life";
      harvest_augment_lightning = h "Augment Lightning";
      harvest_augment_physical = h "Augment Physical";
      harvest_augment_speed = h "Augment Speed";
      harvest_non_attack_to_attack = h "Remove Non-Attack Add Attack";
      harvest_non_caster_to_caster = h "Remove Non-Caster Add Caster";
      harvest_non_chaos_to_chaos = h "Remove Non-Chaos Add Chaos";
      harvest_non_cold_to_cold = h "Remove Non-Cold Add Cold";
      harvest_non_critical_to_critical = h "Remove Non-Critical Add Critical";
      harvest_non_defences_to_defences = h "Remove Non-Defence Add Defence";
      harvest_non_fire_to_fire = h "Remove Non-Fire Add Fire";
      harvest_non_life_to_life = h "Remove Non-Life Add Life";
      harvest_non_lightning_to_lightning = h "Remove Non-Lightning Add Lightning";
      harvest_non_physical_to_physical = h "Remove Non-Physical Add Physical";
      harvest_non_speed_to_speed = h "Remove Non-Speed Add Speed";
      harvest_reforge_attack = h "Reforge Attack";
      harvest_reforge_caster = h "Reforge Caster";
      harvest_reforge_chaos = h "Reforge Chaos";
      harvest_reforge_cold = h "Reforge Cold";
      harvest_reforge_critical = h "Reforge Critical";
      harvest_reforge_defences = h "Reforge Defence";
      harvest_reforge_fire = h "Reforge Fire";
      harvest_reforge_life = h "Reforge Life";
      harvest_reforge_lightning = h "Reforge Lightning";
      harvest_reforge_physical = h "Reforge Physical";
      harvest_reforge_speed = h "Reforge Speed";
      harvest_reforge_keep_prefixes = h "Reforge keep Prefix";
      harvest_reforge_keep_suffixes = h "Reforge keep Suffix";
      beastcraft_aspect_of_the_avian = b "Saqawal, First of the Sky";
      beastcraft_aspect_of_the_cat = b "Farrul, First of the Plains";
      beastcraft_aspect_of_the_crab = b "Craiceann, First of the Deep";
      beastcraft_aspect_of_the_spider = b "Fenumus, First of the Night";
      beastcraft_split = b "Fenumal Plagued Arachnid";
      beastcraft_imprint = b "Craicic Chimeral";
      aisling = s "T4 Aisling";
    }
  in
  Cost.write_options cost filename

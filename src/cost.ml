open Misc

type source =
  | Ninja_currency
  | Ninja_essence
  | Ninja_fossil
  | Ninja_resonator
  | Ninja_beast
  | TFT_harvest
  | TFT_service

(* We use [name] when encoding to JSON.
   We use [id] for better performance otherwise. *)
type field =
  {
    id: int;
    name: string;
    default: float;
    source: source;
    source_name: string;
  }

let field_list: field list ref = ref []

let register =
  let next = ref 0 in
  fun source source_name name default ->
    let id = !next in
    incr next;
    let field =
      {
        id;
        name;
        default;
        source;
        source_name;
      }
    in
    field_list := field :: !field_list;
    field

let values: float Int_map.t ref = ref Int_map.empty

let get field =
  match Int_map.find_opt field.id !values with
    | None ->
        field.default
    | Some value ->
        value

let set field value =
  values := Int_map.add field.id value !values

let ex = 150.
let c = register Ninja_currency
let e = register Ninja_essence
let f = register Ninja_fossil
let r = register Ninja_resonator
let b = register Ninja_beast
let h = register TFT_harvest
let s = register TFT_service

let transmute: field =
  c "Orb of Transmutation" "transmute" 0.1

let augment: field =
  c "Orb of Augmentation" "augment" 0.04

let alt: field =
  c "Orb of Alteration" "alt" 0.15

let regal: field =
  c "Regal Orb" "regal" 0.33

let alch: field =
  c "Orb of Alchemy" "alch" 0.1

let bless: field =
  c "Blessed Orb" "bless" 1.

let scour: field =
  c "Orb of Scouring" "scour" 0.5

let annul: field =
  c "Orb of Annulment" "annul" 2.5

let exalt: field =
  c "Exalted Orb" "exalt" ex

let crusader_exalt: field =
  c "Crusader's Exalted Orb" "crusader_exalt" (0.5 *. ex)

let hunter_exalt: field =
  c "Hunter's Exalted Orb" "hunter_exalt" ex

let redeemer_exalt: field =
  c "Redeemer's Exalted Orb" "redeemer_exalt" (0.5 *. ex)

let warlord_exalt: field =
  c "Warlord's Exalted Orb" "warlord_exalt" (0.5 *. ex)

let veiled_chaos: field =
  c "Veiled Chaos Orb" "veiled_chaos" 5.

let essence_of_anger: field =
  e "Deafening Essence of Anger" "essence_of_anger" 5.

let essence_of_anguish: field =
  e "Deafening Essence of Anguish" "essence_of_anguish" 5.

let essence_of_contempt: field =
  e "Deafening Essence of Contempt" "essence_of_contempt" 5.

let essence_of_doubt: field =
  e "Deafening Essence of Doubt" "essence_of_doubt" 5.

let essence_of_dread: field =
  e "Deafening Essence of Dread" "essence_of_dread" 5.

let essence_of_envy: field =
  e "Deafening Essence of Envy" "essence_of_envy" 5.

let essence_of_fear: field =
  e "Deafening Essence of Fear" "essence_of_fear" 5.

let essence_of_greed: field =
  e "Deafening Essence of Greed" "essence_of_greed" 5.

let essence_of_hatred: field =
  e "Deafening Essence of Hatred" "essence_of_hatred" 5.

let essence_of_loathing: field =
  e "Deafening Essence of Loathing" "essence_of_loathing" 5.

let essence_of_misery: field =
  e "Deafening Essence of Misery" "essence_of_misery" 5.

let essence_of_rage: field =
  e "Deafening Essence of Rage" "essence_of_rage" 5.

let essence_of_scorn: field =
  e "Deafening Essence of Scorn" "essence_of_scorn" 5.

let essence_of_sorrow: field =
  e "Deafening Essence of Sorrow" "essence_of_sorrow" 5.

let essence_of_spite: field =
  e "Deafening Essence of Spite" "essence_of_spite" 5.

let essence_of_suffering: field =
  e "Deafening Essence of Suffering" "essence_of_suffering" 5.

let essence_of_torment: field =
  e "Deafening Essence of Torment" "essence_of_torment" 5.

let essence_of_woe: field =
  e "Deafening Essence of Woe" "essence_of_woe" 5.

let essence_of_wrath: field =
  e "Deafening Essence of Wrath" "essence_of_wrath" 5.

let essence_of_zeal: field =
  e "Deafening Essence of Zeal" "essence_of_zeal" 5.

let essence_of_delirium: field =
  e "Essence of Delirium" "essence_of_delirium" 10.

let essence_of_horror: field =
  e "Essence of Horror" "essence_of_horror" 25.

let essence_of_hysteria: field =
  e "Essence of Hysteria" "essence_of_hysteria" 10.

let essence_of_insanity: field =
  e "Essence of Insanity" "essence_of_insanity" 10.

let aberrant_fossil: field =
  f "Aberrant Fossil" "aberrant" 2.

let aetheric_fossil: field =
  f "Aetheric Fossil" "aetheric" 2.

let bound_fossil: field =
  f "Bound Fossil" "bound" 2.

let corroded_fossil: field =
  f "Corroded Fossil" "corroded" 2.

let dense_fossil: field =
  f "Dense Fossil" "dense" 2.

let faceted_fossil: field =
  f "Faceted Fossil" "faceted" 70.

let frigid_fossil: field =
  f "Frigid Fossil" "frigid" 2.

let jagged_fossil: field =
  f "Jagged Fossil" "jagged" 2.

let lucent_fossil: field =
  f "Lucent Fossil" "lucent" 2.

let metallic_fossil: field =
  f "Metallic Fossil" "metallic" 2.

let prismatic_fossil: field =
  f "Prismatic Fossil" "prismatic" 2.

let pristine_fossil: field =
  f "Pristine Fossil" "pristine" 2.

let scorched_fossil: field =
  f "Scorched Fossil" "scorched" 2.

let serrated_fossil: field =
  f "Serrated Fossil" "serrated" 2.

let shuddering_fossil: field =
  f "Shuddering Fossil" "shuddering" 2.

let fundamental_fossil: field =
  f "Fundamental Fossil" "fundamental" 2.

let deft_fossil: field =
  f "Deft Fossil" "deft" 2.

let primitive_resonator: field =
  r "Primitive Chaotic Resonator" "primitive_resonator" 2.

let potent_resonator: field =
  r "Potent Chaotic Resonator" "potent_resonator" 2.

let powerful_resonator: field =
  r "Powerful Chaotic Resonator" "powerful_resonator" 3.

let prime_resonator: field =
  r "Prime Chaotic Resonator" "prime_resonator" 40.

let awaken: field =
  c "Awakener's Orb" "awaken" ex

let lesser_ember: field =
  c "Lesser Eldritch Ember" "lesser_ember" 0.5

let greater_ember: field =
  c "Greater Eldritch Ember" "greater_ember" 2.

let grand_ember: field =
  c "Grand Eldritch Ember" "grand_ember" 10.

let exceptional_ember: field =
  c "Exceptional Eldritch Ember" "exceptional_ember" 50.

let lesser_ichor: field =
  c "Lesser Eldritch Ichor" "lesser_ichor" 0.5

let greater_ichor: field =
  c "Greater Eldritch Ichor" "greater_ichor" 2.

let grand_ichor: field =
  c "Grand Eldritch Ichor" "grand_ichor" 10.

let exceptional_ichor: field =
  c "Exceptional Eldritch Ichor" "exceptional_ichor" 80.

let eldritch_annul: field =
  c "Eldritch Orb of Annulment" "eldritch_annul" 10.

let eldritch_exalt: field =
  c "Eldritch Exalted Orb" "eldritch_exalt" 15.

let eldritch_chaos: field =
  c "Eldritch Chaos Orb" "eldritch_chaos" 30.

let harvest_augment_attack: field =
  h "Augment Attack" "harvest_augment_attack" (10. *. ex)

let harvest_augment_caster: field =
  h "Augment Caster" "harvest_augment_caster" (10. *. ex)

let harvest_augment_chaos: field =
  h "Augment Chaos" "harvest_augment_chaos" (10. *. ex)

let harvest_augment_cold: field =
  h "Augment Cold" "harvest_augment_cold" (10. *. ex)

let harvest_augment_critical: field =
  h "Augment Critical" "harvest_augment_critical" (10. *. ex)

let harvest_augment_defences: field =
  h "Augment Defence" "harvest_augment_defences" (10. *. ex)

let harvest_augment_fire: field =
  h "Augment Fire" "harvest_augment_fire" (10. *. ex)

let harvest_augment_life: field =
  h "Augment Life" "harvest_augment_life" (10. *. ex)

let harvest_augment_lightning: field =
  h "Augment Lightning" "harvest_augment_lightning" (10. *. ex)

let harvest_augment_physical: field =
  h "Augment Physical" "harvest_augment_physical" (10. *. ex)

let harvest_augment_speed: field =
  h "Augment Speed" "harvest_augment_speed" (10. *. ex)

let harvest_non_attack_to_attack: field =
  h "Remove Non-Attack Add Attack" "harvest_non_attack_to_attack" (1.5 *. ex)

let harvest_non_caster_to_caster: field =
  h "Remove Non-Caster Add Caster" "harvest_non_caster_to_caster" (1.5 *. ex)

let harvest_non_chaos_to_chaos: field =
  h "Remove Non-Chaos Add Chaos" "harvest_non_chaos_to_chaos" (1.5 *. ex)

let harvest_non_cold_to_cold: field =
  h "Remove Non-Cold Add Cold" "harvest_non_cold_to_cold" (1.5 *. ex)

let harvest_non_critical_to_critical: field =
  h "Remove Non-Critical Add Critical" "harvest_non_critical_to_critical" (1.5 *. ex)

let harvest_non_defences_to_defences: field =
  h "Remove Non-Defence Add Defence" "harvest_non_defences_to_defences" (1.5 *. ex)

let harvest_non_fire_to_fire: field =
  h "Remove Non-Fire Add Fire" "harvest_non_fire_to_fire" (1.5 *. ex)

let harvest_non_life_to_life: field =
  h "Remove Non-Life Add Life" "harvest_non_life_to_life" (1.5 *. ex)

let harvest_non_lightning_to_lightning: field =
  h "Remove Non-Lightning Add Lightning" "harvest_non_lightning_to_lightning" (1.5 *. ex)

let harvest_non_physical_to_physical: field =
  h "Remove Non-Physical Add Physical" "harvest_non_physical_to_physical" (1.5 *. ex)

let harvest_non_speed_to_speed: field =
  h "Remove Non-Speed Add Speed" "harvest_non_speed_to_speed" (1.5 *. ex)

let harvest_reforge_attack: field =
  h "Reforge Attack" "harvest_reforge_attack" 10.

let harvest_reforge_caster: field =
  h "Reforge Caster" "harvest_reforge_caster" 10.

let harvest_reforge_chaos: field =
  h "Reforge Chaos" "harvest_reforge_chaos" 10.

let harvest_reforge_cold: field =
  h "Reforge Cold" "harvest_reforge_cold" 10.

let harvest_reforge_critical: field =
  h "Reforge Critical" "harvest_reforge_critical" 10.

let harvest_reforge_defences: field =
  h "Reforge Defence" "harvest_reforge_defences" 10.

let harvest_reforge_fire: field =
  h "Reforge Fire" "harvest_reforge_fire" 10.

let harvest_reforge_life: field =
  h "Reforge Life" "harvest_reforge_life" 10.

let harvest_reforge_lightning: field =
  h "Reforge Lightning" "harvest_reforge_lightning" 10.

let harvest_reforge_physical: field =
  h "Reforge Physical" "harvest_reforge_physical" 10.

let harvest_reforge_speed: field =
  h "Reforge Speed" "harvest_reforge_speed" 10.

let harvest_reforge_keep_prefixes: field =
  h "Reforge keep Prefix" "harvest_reforge_keep_prefixes" (1.5 *. ex)

let harvest_reforge_keep_suffixes: field =
  h "Reforge keep Suffix" "harvest_reforge_keep_suffixes" (1.5 *. ex)

let beastcraft_aspect_of_the_avian: field =
  b "Saqawal, First of the Sky" "beastcraft_aspect_of_the_avian" 6.

let beastcraft_aspect_of_the_cat: field =
  b "Farrul, First of the Plains" "beastcraft_aspect_of_the_cat" 30.

let beastcraft_aspect_of_the_crab: field =
  b "Craiceann, First of the Deep" "beastcraft_aspect_of_the_crab" 3.

let beastcraft_aspect_of_the_spider: field =
  b "Fenumus, First of the Night" "beastcraft_aspect_of_the_spider" 30.

let beastcraft_split: field =
  b "Fenumal Plagued Arachnid" "beastcraft_split" 60.

let beastcraft_imprint: field =
  b "Craicic Chimeral" "beastcraft_imprint" 120.

let aisling: field =
  s "T4 Aisling" "aisling" (3. *. ex)

let get_currency (currency: AST.currency) =
  match currency with
    | Orb_of_transmutation ->
        get transmute
    | Orb_of_augmentation ->
        get augment
    | Orb_of_alteration ->
        get alt
    | Regal_orb ->
        get regal
    | Orb_of_alchemy ->
        get alch
    | Orb_of_scouring ->
        get scour
    | Blessed_orb ->
        get bless
    | Chaos_orb ->
        1.
    | Orb_of_annulment ->
        get annul
    | Exalted_orb ->
        get exalt
    | Crusader_exalted_orb ->
        get crusader_exalt
    | Hunter_exalted_orb ->
        get hunter_exalt
    | Redeemer_exalted_orb ->
        get redeemer_exalt
    | Warlord_exalted_orb ->
        get warlord_exalt
    | Veiled_chaos_orb ->
        get veiled_chaos
    | Essence Anger ->
        get essence_of_anger
    | Essence Anguish ->
        get essence_of_anguish
    | Essence Contempt ->
        get essence_of_contempt
    | Essence Doubt ->
        get essence_of_doubt
    | Essence Dread ->
        get essence_of_dread
    | Essence Envy ->
        get essence_of_envy
    | Essence Fear ->
        get essence_of_fear
    | Essence Greed ->
        get essence_of_greed
    | Essence Hatred ->
        get essence_of_hatred
    | Essence Loathing ->
        get essence_of_loathing
    | Essence Misery ->
        get essence_of_misery
    | Essence Rage ->
        get essence_of_rage
    | Essence Scorn ->
        get essence_of_scorn
    | Essence Sorrow ->
        get essence_of_sorrow
    | Essence Spite ->
        get essence_of_spite
    | Essence Suffering ->
        get essence_of_suffering
    | Essence Torment ->
        get essence_of_torment
    | Essence Woe ->
        get essence_of_woe
    | Essence Wrath ->
        get essence_of_wrath
    | Essence Zeal ->
        get essence_of_zeal
    | Essence Delirium ->
        get essence_of_delirium
    | Essence Horror ->
        get essence_of_horror
    | Essence Hysteria ->
        get essence_of_hysteria
    | Essence Insanity ->
        get essence_of_insanity
    | Fossils fossils ->
        let resonator =
          match List.length fossils with
            | 1 -> get primitive_resonator
            | 2 -> get potent_resonator
            | 3 -> get powerful_resonator
            | 4 -> get prime_resonator
            | _ -> 0.
        in
        let get_fossil: Fossil.t -> _ = function
          | Aberrant -> get aberrant_fossil
          | Aetheric -> get aetheric_fossil
          | Bound -> get bound_fossil
          | Corroded -> get corroded_fossil
          | Dense -> get dense_fossil
          | Faceted -> get faceted_fossil
          | Frigid -> get frigid_fossil
          | Jagged -> get jagged_fossil
          | Lucent -> get lucent_fossil
          | Metallic -> get metallic_fossil
          | Prismatic -> get prismatic_fossil
          | Pristine -> get pristine_fossil
          | Scorched -> get scorched_fossil
          | Serrated -> get serrated_fossil
          | Shuddering -> get shuddering_fossil
          | Fundamental -> get fundamental_fossil
          | Deft -> get deft_fossil
        in
        let fossils = List.fold_left (+.) 0. (List.map get_fossil fossils) in
        resonator +. fossils
    | Awakeners_orb ->
        get awaken
    | Ember Lesser ->
        get lesser_ember
    | Ember Greater ->
        get greater_ember
    | Ember Grand ->
        get grand_ember
    | Ember Exceptional ->
        get exceptional_ember
    | Ichor Lesser ->
        get lesser_ichor
    | Ichor Greater ->
        get greater_ichor
    | Ichor Grand ->
        get grand_ichor
    | Ichor Exceptional ->
        get exceptional_ichor
    | Eldritch_annul ->
        get eldritch_annul
    | Eldritch_exalt ->
        get eldritch_exalt
    | Eldritch_chaos ->
        get eldritch_chaos
    | Harvest_augment `attack ->
        get harvest_augment_attack
    | Harvest_augment `caster ->
        get harvest_augment_caster
    | Harvest_augment `chaos ->
        get harvest_augment_chaos
    | Harvest_augment `cold ->
        get harvest_augment_cold
    | Harvest_augment `critical ->
        get harvest_augment_critical
    | Harvest_augment `defences ->
        get harvest_augment_defences
    | Harvest_augment `fire ->
        get harvest_augment_fire
    | Harvest_augment `life ->
        get harvest_augment_life
    | Harvest_augment `lightning ->
        get harvest_augment_lightning
    | Harvest_augment `physical ->
        get harvest_augment_physical
    | Harvest_augment `speed ->
        get harvest_augment_speed
    | Harvest_non_to `attack ->
        get harvest_non_attack_to_attack
    | Harvest_non_to `caster ->
        get harvest_non_caster_to_caster
    | Harvest_non_to `chaos ->
        get harvest_non_chaos_to_chaos
    | Harvest_non_to `cold ->
        get harvest_non_cold_to_cold
    | Harvest_non_to `critical ->
        get harvest_non_critical_to_critical
    | Harvest_non_to `defences ->
        get harvest_non_defences_to_defences
    | Harvest_non_to `fire ->
        get harvest_non_fire_to_fire
    | Harvest_non_to `life ->
        get harvest_non_life_to_life
    | Harvest_non_to `lightning ->
        get harvest_non_lightning_to_lightning
    | Harvest_non_to `physical ->
        get harvest_non_physical_to_physical
    | Harvest_non_to `speed ->
        get harvest_non_speed_to_speed
    | Harvest_reforge `attack ->
        get harvest_reforge_attack
    | Harvest_reforge `caster ->
        get harvest_reforge_caster
    | Harvest_reforge `chaos ->
        get harvest_reforge_chaos
    | Harvest_reforge `cold ->
        get harvest_reforge_cold
    | Harvest_reforge `critical ->
        get harvest_reforge_critical
    | Harvest_reforge `defences ->
        get harvest_reforge_defences
    | Harvest_reforge `fire ->
        get harvest_reforge_fire
    | Harvest_reforge `life ->
        get harvest_reforge_life
    | Harvest_reforge `lightning ->
        get harvest_reforge_lightning
    | Harvest_reforge `physical ->
        get harvest_reforge_physical
    | Harvest_reforge `speed ->
        get harvest_reforge_speed
    | Harvest_reforge_keep_prefixes ->
        get harvest_reforge_keep_prefixes
    | Harvest_reforge_keep_suffixes ->
        get harvest_reforge_keep_suffixes
    | Beastcraft_aspect_of_the_avian ->
        get beastcraft_aspect_of_the_avian
    | Beastcraft_aspect_of_the_cat ->
        get beastcraft_aspect_of_the_cat
    | Beastcraft_aspect_of_the_crab ->
        get beastcraft_aspect_of_the_crab
    | Beastcraft_aspect_of_the_spider ->
        get beastcraft_aspect_of_the_spider
    | Beastcraft_split ->
        get beastcraft_split
    | Beastcraft_imprint ->
        get beastcraft_imprint
    | Aisling ->
        get aisling
    | Craft _ ->
        get transmute
    | Multimod ->
        2. *. get exalt
    | Prefixes_cannot_be_changed ->
        2. *. get exalt
    | Suffixes_cannot_be_changed ->
        2. *. get exalt
    | Cannot_roll_attack_mods ->
        get exalt
    | Cannot_roll_caster_mods ->
        5. *. get bless
    | Remove_crafted_mods ->
        get scour
    | Craft_any_prefix ->
        get transmute
    | Craft_any_suffix ->
        get transmute

let write_defaults filename =
  JSON.write_file filename @@
  `O (List.map (fun field -> field.name, `Float field.default) !field_list)

let write_current filename =
  JSON.write_file filename @@
  `O (List.map (fun field -> field.name, `Float (get field)) !field_list)

let load filename =
  let values = JSON.parse_file filename |> JSON.as_object in
  let add_value acc (name, value) = String_map.add name (JSON.as_float value) acc in
  let map = List.fold_left add_value String_map.empty values in
  let update field = Option.iter (set field) (String_map.find_opt field.name map) in
  List.iter update !field_list

let show_chaos_amount amount =
  sf "%.2fex (%dc)"
    (amount /. get exalt)
    (int_of_float amount)

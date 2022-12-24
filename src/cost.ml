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

let div = 200.
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
  c "Exalted Orb" "exalt" 20.

let divine: field =
  c "Divine Orb" "divine" div

let crusader_exalt: field =
  c "Crusader's Exalted Orb" "crusader_exalt" (0.5 *. div)

let hunter_exalt: field =
  c "Hunter's Exalted Orb" "hunter_exalt" div

let redeemer_exalt: field =
  c "Redeemer's Exalted Orb" "redeemer_exalt" (0.5 *. div)

let warlord_exalt: field =
  c "Warlord's Exalted Orb" "warlord_exalt" (0.5 *. div)

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

let orb_of_dominance: field =
  c "Orb of Dominance" "orb_of_dominance" div

let awaken: field =
  c "Awakener's Orb" "awaken" div

let armour_recombinator: field =
  c "Armour Recombinator" "armour_recombinator" 7.

let weapon_recombinator: field =
  c "Weapon Recombinator" "weapon_recombinator" 7.

let jewellery_recombinator: field =
  c "Jewellery Recombinator" "jewellery_recombinator" 7.

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

let wild_crystallised_lifeforce: field =
  c "Wild Crystallised Lifeforce" "wild_lifeforce" 0.02

let vivid_crystallised_lifeforce: field =
  c "Vivid Crystallised Lifeforce" "vivid_lifeforce" 0.02

let primal_crystallised_lifeforce: field =
  c "Primal Crystallised Lifeforce" "primal_lifeforce" 0.02

let sacred_crystallised_lifeforce: field =
  c "Sacred Crystallised Lifeforce" "sacred_lifeforce" 0.02

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
  s "T4 Aisling" "aisling" div

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
    | Divine_orb ->
        get divine
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
    | Orb_of_dominance ->
        get orb_of_dominance
    | Awakeners_orb ->
        get awaken
    | Armour_recombinator ->
        get armour_recombinator
    | Weapon_recombinator ->
        get weapon_recombinator
    | Jewellery_recombinator ->
        get jewellery_recombinator
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
    | Wild_crystallised_lifeforce ->
        get wild_crystallised_lifeforce
    | Vivid_crystallised_lifeforce ->
        get vivid_crystallised_lifeforce
    | Primal_crystallised_lifeforce ->
        get primal_crystallised_lifeforce
    | Sacred_crystallised_lifeforce ->
        get sacred_crystallised_lifeforce
    | Harvest_augment `fire ->
        15000. *. get wild_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `cold ->
        15000. *. get vivid_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `lightning ->
        15000. *. get primal_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `physical ->
        15000. *. get vivid_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `life ->
        17500. *. get wild_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `defences ->
        17500. *. get primal_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `chaos ->
        17500. *. get vivid_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `attack ->
        17500. *. get wild_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `caster ->
        17500. *. get primal_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `speed ->
        20000. *. get vivid_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_augment `critical ->
        20000. *. get primal_crystallised_lifeforce +.
        get sacred_crystallised_lifeforce
    | Harvest_non_to `attack ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `caster ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `chaos ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `cold ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `critical ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `defences ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `fire ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `life ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `lightning ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `physical ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_non_to `speed ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_reforge `fire | Harvest_reforge_more_common `fire ->
        50. *. get wild_crystallised_lifeforce
    | Harvest_reforge `cold | Harvest_reforge_more_common `cold ->
        50. *. get vivid_crystallised_lifeforce
    | Harvest_reforge `lightning | Harvest_reforge_more_common `lightning ->
        50. *. get primal_crystallised_lifeforce
    | Harvest_reforge `physical | Harvest_reforge_more_common `physical ->
        50. *. get vivid_crystallised_lifeforce
    | Harvest_reforge `life | Harvest_reforge_more_common `life ->
        75. *. get wild_crystallised_lifeforce
    | Harvest_reforge `defences | Harvest_reforge_more_common `defences ->
        75. *. get primal_crystallised_lifeforce
    | Harvest_reforge `chaos | Harvest_reforge_more_common `chaos ->
        100. *. get vivid_crystallised_lifeforce
    | Harvest_reforge `attack | Harvest_reforge_more_common `attack ->
        75. *. get wild_crystallised_lifeforce
    | Harvest_reforge `caster | Harvest_reforge_more_common `caster ->
        75. *. get primal_crystallised_lifeforce
    | Harvest_reforge `speed | Harvest_reforge_more_common `speed ->
        150. *. get vivid_crystallised_lifeforce
    | Harvest_reforge `critical | Harvest_reforge_more_common `critical ->
        150. *. get primal_crystallised_lifeforce
    | Harvest_reforge_keep_prefixes ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_reforge_keep_suffixes ->
        (* Deprecated. *)
        1.5 *. get divine
    | Harvest_reforge_more_likely ->
        200. *. get wild_crystallised_lifeforce
    | Harvest_reforge_less_likely ->
        200. *. get wild_crystallised_lifeforce
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
        2. *. get divine
    | Prefixes_cannot_be_changed ->
        2. *. get divine
    | Suffixes_cannot_be_changed ->
        2. *. get divine
    | Cannot_roll_attack_mods ->
        get divine
    | Cannot_roll_caster_mods ->
        get divine
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
  sf "%.2fdiv (%dc)"
    (amount /. get divine)
    (int_of_float amount)

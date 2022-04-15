open Misc

type 'a t =
  {
    transmute: 'a;
    augment: 'a;
    alt: 'a;
    regal: 'a;
    alch: 'a;
    bless: 'a;
    scour: 'a;
    annul: 'a;
    exalt: 'a;
    crusader_exalt: 'a;
    hunter_exalt: 'a;
    redeemer_exalt: 'a;
    warlord_exalt: 'a;
    veiled_chaos: 'a;
    essence_of_anger: 'a;
    essence_of_anguish: 'a;
    essence_of_contempt: 'a;
    essence_of_doubt: 'a;
    essence_of_dread: 'a;
    essence_of_envy: 'a;
    essence_of_fear: 'a;
    essence_of_greed: 'a;
    essence_of_hatred: 'a;
    essence_of_loathing: 'a;
    essence_of_misery: 'a;
    essence_of_rage: 'a;
    essence_of_scorn: 'a;
    essence_of_sorrow: 'a;
    essence_of_spite: 'a;
    essence_of_suffering: 'a;
    essence_of_torment: 'a;
    essence_of_woe: 'a;
    essence_of_wrath: 'a;
    essence_of_zeal: 'a;
    essence_of_delirium: 'a;
    essence_of_horror: 'a;
    essence_of_hysteria: 'a;
    essence_of_insanity: 'a;
    aberrant_fossil: 'a;
    aetheric_fossil: 'a;
    bound_fossil: 'a;
    corroded_fossil: 'a;
    dense_fossil: 'a;
    faceted_fossil: 'a;
    frigid_fossil: 'a;
    jagged_fossil: 'a;
    lucent_fossil: 'a;
    metallic_fossil: 'a;
    prismatic_fossil: 'a;
    pristine_fossil: 'a;
    scorched_fossil: 'a;
    serrated_fossil: 'a;
    shuddering_fossil: 'a;
    fundamental_fossil: 'a;
    deft_fossil: 'a;
    primitive_resonator: 'a;
    potent_resonator: 'a;
    powerful_resonator: 'a;
    prime_resonator: 'a;
    awaken: 'a;
    lesser_ember: 'a;
    greater_ember: 'a;
    grand_ember: 'a;
    exceptional_ember: 'a;
    lesser_ichor: 'a;
    greater_ichor: 'a;
    grand_ichor: 'a;
    exceptional_ichor: 'a;
    harvest_augment_attack: 'a;
    harvest_augment_caster: 'a;
    harvest_augment_chaos: 'a;
    harvest_augment_cold: 'a;
    harvest_augment_critical: 'a;
    harvest_augment_defences: 'a;
    harvest_augment_fire: 'a;
    harvest_augment_life: 'a;
    harvest_augment_lightning: 'a;
    harvest_augment_physical: 'a;
    harvest_augment_speed: 'a;
    harvest_non_attack_to_attack: 'a;
    harvest_non_caster_to_caster: 'a;
    harvest_non_chaos_to_chaos: 'a;
    harvest_non_cold_to_cold: 'a;
    harvest_non_critical_to_critical: 'a;
    harvest_non_defences_to_defences: 'a;
    harvest_non_fire_to_fire: 'a;
    harvest_non_life_to_life: 'a;
    harvest_non_lightning_to_lightning: 'a;
    harvest_non_physical_to_physical: 'a;
    harvest_non_speed_to_speed: 'a;
    harvest_reforge_attack: 'a;
    harvest_reforge_caster: 'a;
    harvest_reforge_chaos: 'a;
    harvest_reforge_cold: 'a;
    harvest_reforge_critical: 'a;
    harvest_reforge_defences: 'a;
    harvest_reforge_fire: 'a;
    harvest_reforge_life: 'a;
    harvest_reforge_lightning: 'a;
    harvest_reforge_physical: 'a;
    harvest_reforge_speed: 'a;
    harvest_reforge_keep_prefixes: 'a;
    harvest_reforge_keep_suffixes: 'a;
    beastcraft_aspect_of_the_avian: 'a;
    beastcraft_aspect_of_the_cat: 'a;
    beastcraft_aspect_of_the_crab: 'a;
    beastcraft_aspect_of_the_spider: 'a;
    beastcraft_split: 'a;
    beastcraft_imprint: 'a;
    aisling: 'a;
  }

type expression =
  | Chaos of float
  | Exalt of float

let default_exalt = 150.

let default =
  let deafening_essence = Chaos 5. in
  let corrupted_essence = Chaos 20. in
  let harvest_augment = Exalt 10. in
  let harvest_non_to = Exalt 1.5 in
  let harvest_reforge = Chaos 10. in
  let fossil = Chaos 2. in (* doesn't include Faceted Fossil *)
  {
    transmute = Chaos 0.1;
    augment = Chaos 0.04;
    alt = Chaos 0.15;
    regal = Chaos 0.33;
    alch = Chaos 0.1;
    bless = Chaos 1.;
    scour = Chaos 0.5;
    annul = Chaos 2.5;
    exalt = Chaos default_exalt;
    crusader_exalt = Exalt 0.5;
    hunter_exalt = Exalt 1.;
    redeemer_exalt = Exalt 0.5;
    warlord_exalt = Exalt 0.5;
    veiled_chaos = Chaos 5.;
    essence_of_anger = deafening_essence;
    essence_of_anguish = deafening_essence;
    essence_of_contempt = deafening_essence;
    essence_of_doubt = deafening_essence;
    essence_of_dread = deafening_essence;
    essence_of_envy = deafening_essence;
    essence_of_fear = deafening_essence;
    essence_of_greed = deafening_essence;
    essence_of_hatred = deafening_essence;
    essence_of_loathing = deafening_essence;
    essence_of_misery = deafening_essence;
    essence_of_rage = deafening_essence;
    essence_of_scorn = deafening_essence;
    essence_of_sorrow = deafening_essence;
    essence_of_spite = deafening_essence;
    essence_of_suffering = deafening_essence;
    essence_of_torment = deafening_essence;
    essence_of_woe = deafening_essence;
    essence_of_wrath = deafening_essence;
    essence_of_zeal = deafening_essence;
    essence_of_delirium = corrupted_essence;
    essence_of_horror = corrupted_essence;
    essence_of_hysteria = corrupted_essence;
    essence_of_insanity = corrupted_essence;
    aberrant_fossil = fossil;
    aetheric_fossil = fossil;
    bound_fossil = fossil;
    corroded_fossil = fossil;
    dense_fossil = fossil;
    faceted_fossil = Chaos 70.;
    frigid_fossil = fossil;
    jagged_fossil = fossil;
    lucent_fossil = fossil;
    metallic_fossil = fossil;
    prismatic_fossil = fossil;
    pristine_fossil = fossil;
    scorched_fossil = fossil;
    serrated_fossil = fossil;
    shuddering_fossil = fossil;
    fundamental_fossil = fossil;
    deft_fossil = fossil;
    primitive_resonator = Chaos 2.;
    potent_resonator = Chaos 2.;
    powerful_resonator = Chaos 3.;
    prime_resonator = Chaos 40.;
    awaken = Exalt 1.;
    lesser_ember = Chaos 0.5;
    greater_ember = Chaos 2.;
    grand_ember = Chaos 10.;
    exceptional_ember = Chaos 50.;
    lesser_ichor = Chaos 0.5;
    greater_ichor = Chaos 2.;
    grand_ichor = Chaos 10.;
    exceptional_ichor = Chaos 80.;
    harvest_augment_attack = harvest_augment;
    harvest_augment_caster = harvest_augment;
    harvest_augment_chaos = harvest_augment;
    harvest_augment_cold = harvest_augment;
    harvest_augment_critical = harvest_augment;
    harvest_augment_defences = harvest_augment;
    harvest_augment_fire = harvest_augment;
    harvest_augment_life = harvest_augment;
    harvest_augment_lightning = harvest_augment;
    harvest_augment_physical = harvest_augment;
    harvest_augment_speed = harvest_augment;
    harvest_non_attack_to_attack = harvest_non_to;
    harvest_non_caster_to_caster = harvest_non_to;
    harvest_non_chaos_to_chaos = harvest_non_to;
    harvest_non_cold_to_cold = harvest_non_to;
    harvest_non_critical_to_critical = harvest_non_to;
    harvest_non_defences_to_defences = harvest_non_to;
    harvest_non_fire_to_fire = harvest_non_to;
    harvest_non_life_to_life = harvest_non_to;
    harvest_non_lightning_to_lightning = harvest_non_to;
    harvest_non_physical_to_physical = harvest_non_to;
    harvest_non_speed_to_speed = harvest_non_to;
    harvest_reforge_attack = harvest_reforge;
    harvest_reforge_caster = harvest_reforge;
    harvest_reforge_chaos = harvest_reforge;
    harvest_reforge_cold = harvest_reforge;
    harvest_reforge_critical = harvest_reforge;
    harvest_reforge_defences = harvest_reforge;
    harvest_reforge_fire = harvest_reforge;
    harvest_reforge_life = harvest_reforge;
    harvest_reforge_lightning = harvest_reforge;
    harvest_reforge_physical = harvest_reforge;
    harvest_reforge_speed = harvest_reforge;
    harvest_reforge_keep_prefixes = Exalt 1.5;
    harvest_reforge_keep_suffixes = Exalt 1.5;
    beastcraft_aspect_of_the_avian = Chaos 6.;
    beastcraft_aspect_of_the_cat = Chaos 30.;
    beastcraft_aspect_of_the_crab = Chaos 3.;
    beastcraft_aspect_of_the_spider = Chaos 30.;
    beastcraft_split = Chaos 60.;
    beastcraft_imprint = Chaos 120.;
    aisling = Exalt 3.;
  }

let values: float t option ref = ref None

let get (currency: AST.currency) =
  let get get_float get_expression =
    match !values with
      | Some x ->
          get_float x
      | None ->
          match get_expression default with
            | Chaos x -> x
            | Exalt x -> x *. default_exalt
  in
  let transmute () = get (fun x -> x.transmute) (fun x -> x.transmute) in
  let scour () = get (fun x -> x.scour) (fun x -> x.scour) in
  let bless () = get (fun x -> x.bless) (fun x -> x.bless) in
  let exalt () = get (fun x -> x.exalt) (fun x -> x.exalt) in
  match currency with
    | Orb_of_transmutation ->
        transmute ()
    | Orb_of_augmentation ->
        get (fun x -> x.augment) (fun x -> x.augment)
    | Orb_of_alteration ->
        get (fun x -> x.alt) (fun x -> x.alt)
    | Regal_orb ->
        get (fun x -> x.regal) (fun x -> x.regal)
    | Orb_of_alchemy ->
        get (fun x -> x.alch) (fun x -> x.alch)
    | Orb_of_scouring ->
        scour ()
    | Blessed_orb ->
        bless ()
    | Chaos_orb ->
        1.
    | Orb_of_annulment ->
        get (fun x -> x.annul) (fun x -> x.annul)
    | Exalted_orb ->
        exalt ()
    | Crusader_exalted_orb ->
        get (fun x -> x.crusader_exalt) (fun x -> x.crusader_exalt)
    | Hunter_exalted_orb ->
        get (fun x -> x.hunter_exalt) (fun x -> x.hunter_exalt)
    | Redeemer_exalted_orb ->
        get (fun x -> x.redeemer_exalt) (fun x -> x.redeemer_exalt)
    | Warlord_exalted_orb ->
        get (fun x -> x.warlord_exalt) (fun x -> x.warlord_exalt)
    | Veiled_chaos_orb ->
        get (fun x -> x.veiled_chaos) (fun x -> x.veiled_chaos)
    | Essence Anger ->
        get (fun x -> x.essence_of_anger) (fun x -> x.essence_of_anger)
    | Essence Anguish ->
        get (fun x -> x.essence_of_anguish) (fun x -> x.essence_of_anguish)
    | Essence Contempt ->
        get (fun x -> x.essence_of_contempt) (fun x -> x.essence_of_contempt)
    | Essence Doubt ->
        get (fun x -> x.essence_of_doubt) (fun x -> x.essence_of_doubt)
    | Essence Dread ->
        get (fun x -> x.essence_of_dread) (fun x -> x.essence_of_dread)
    | Essence Envy ->
        get (fun x -> x.essence_of_envy) (fun x -> x.essence_of_envy)
    | Essence Fear ->
        get (fun x -> x.essence_of_fear) (fun x -> x.essence_of_fear)
    | Essence Greed ->
        get (fun x -> x.essence_of_greed) (fun x -> x.essence_of_greed)
    | Essence Hatred ->
        get (fun x -> x.essence_of_hatred) (fun x -> x.essence_of_hatred)
    | Essence Loathing ->
        get (fun x -> x.essence_of_loathing) (fun x -> x.essence_of_loathing)
    | Essence Misery ->
        get (fun x -> x.essence_of_misery) (fun x -> x.essence_of_misery)
    | Essence Rage ->
        get (fun x -> x.essence_of_rage) (fun x -> x.essence_of_rage)
    | Essence Scorn ->
        get (fun x -> x.essence_of_scorn) (fun x -> x.essence_of_scorn)
    | Essence Sorrow ->
        get (fun x -> x.essence_of_sorrow) (fun x -> x.essence_of_sorrow)
    | Essence Spite ->
        get (fun x -> x.essence_of_spite) (fun x -> x.essence_of_spite)
    | Essence Suffering ->
        get (fun x -> x.essence_of_suffering) (fun x -> x.essence_of_suffering)
    | Essence Torment ->
        get (fun x -> x.essence_of_torment) (fun x -> x.essence_of_torment)
    | Essence Woe ->
        get (fun x -> x.essence_of_woe) (fun x -> x.essence_of_woe)
    | Essence Wrath ->
        get (fun x -> x.essence_of_wrath) (fun x -> x.essence_of_wrath)
    | Essence Zeal ->
        get (fun x -> x.essence_of_zeal) (fun x -> x.essence_of_zeal)
    | Essence Delirium ->
        get (fun x -> x.essence_of_delirium) (fun x -> x.essence_of_delirium)
    | Essence Horror ->
        get (fun x -> x.essence_of_horror) (fun x -> x.essence_of_horror)
    | Essence Hysteria ->
        get (fun x -> x.essence_of_hysteria) (fun x -> x.essence_of_hysteria)
    | Essence Insanity ->
        get (fun x -> x.essence_of_insanity) (fun x -> x.essence_of_insanity)
    | Fossils fossils ->
        let resonator =
          match List.length fossils with
            | 1 -> get (fun x -> x.primitive_resonator) (fun x -> x.primitive_resonator)
            | 2 -> get (fun x -> x.potent_resonator) (fun x -> x.potent_resonator)
            | 3 -> get (fun x -> x.powerful_resonator) (fun x -> x.powerful_resonator)
            | 4 -> get (fun x -> x.prime_resonator) (fun x -> x.prime_resonator)
            | _ -> 0.
        in
        let get_fossil: Fossil.t -> _ = function
          | Aberrant -> get (fun x -> x.aberrant_fossil) (fun x -> x.aberrant_fossil)
          | Aetheric -> get (fun x -> x.aetheric_fossil) (fun x -> x.aetheric_fossil)
          | Bound -> get (fun x -> x.bound_fossil) (fun x -> x.bound_fossil)
          | Corroded -> get (fun x -> x.corroded_fossil) (fun x -> x.corroded_fossil)
          | Dense -> get (fun x -> x.dense_fossil) (fun x -> x.dense_fossil)
          | Faceted -> get (fun x -> x.faceted_fossil) (fun x -> x.faceted_fossil)
          | Frigid -> get (fun x -> x.frigid_fossil) (fun x -> x.frigid_fossil)
          | Jagged -> get (fun x -> x.jagged_fossil) (fun x -> x.jagged_fossil)
          | Lucent -> get (fun x -> x.lucent_fossil) (fun x -> x.lucent_fossil)
          | Metallic -> get (fun x -> x.metallic_fossil) (fun x -> x.metallic_fossil)
          | Prismatic -> get (fun x -> x.prismatic_fossil) (fun x -> x.prismatic_fossil)
          | Pristine -> get (fun x -> x.pristine_fossil) (fun x -> x.pristine_fossil)
          | Scorched -> get (fun x -> x.scorched_fossil) (fun x -> x.scorched_fossil)
          | Serrated -> get (fun x -> x.serrated_fossil) (fun x -> x.serrated_fossil)
          | Shuddering -> get (fun x -> x.shuddering_fossil) (fun x -> x.shuddering_fossil)
          | Fundamental -> get (fun x -> x.fundamental_fossil) (fun x -> x.fundamental_fossil)
          | Deft -> get (fun x -> x.deft_fossil) (fun x -> x.deft_fossil)
        in
        let fossils = List.fold_left (+.) 0. (List.map get_fossil fossils) in
        resonator +. fossils
    | Awakeners_orb ->
        get (fun x -> x.awaken) (fun x -> x.awaken)
    | Ember Lesser ->
        get (fun x -> x.lesser_ember) (fun x -> x.lesser_ember)
    | Ember Greater ->
        get (fun x -> x.greater_ember) (fun x -> x.greater_ember)
    | Ember Grand ->
        get (fun x -> x.grand_ember) (fun x -> x.grand_ember)
    | Ember Exceptional ->
        get (fun x -> x.exceptional_ember) (fun x -> x.exceptional_ember)
    | Ichor Lesser ->
        get (fun x -> x.lesser_ichor) (fun x -> x.lesser_ichor)
    | Ichor Greater ->
        get (fun x -> x.greater_ichor) (fun x -> x.greater_ichor)
    | Ichor Grand ->
        get (fun x -> x.grand_ichor) (fun x -> x.grand_ichor)
    | Ichor Exceptional ->
        get (fun x -> x.exceptional_ichor) (fun x -> x.exceptional_ichor)
    | Harvest_augment `attack ->
        get (fun x -> x.harvest_augment_attack) (fun x -> x.harvest_augment_attack)
    | Harvest_augment `caster ->
        get (fun x -> x.harvest_augment_caster) (fun x -> x.harvest_augment_caster)
    | Harvest_augment `chaos ->
        get (fun x -> x.harvest_augment_chaos) (fun x -> x.harvest_augment_chaos)
    | Harvest_augment `cold ->
        get (fun x -> x.harvest_augment_cold) (fun x -> x.harvest_augment_cold)
    | Harvest_augment `critical ->
        get (fun x -> x.harvest_augment_critical) (fun x -> x.harvest_augment_critical)
    | Harvest_augment `defences ->
        get (fun x -> x.harvest_augment_defences) (fun x -> x.harvest_augment_defences)
    | Harvest_augment `fire ->
        get (fun x -> x.harvest_augment_fire) (fun x -> x.harvest_augment_fire)
    | Harvest_augment `life ->
        get (fun x -> x.harvest_augment_life) (fun x -> x.harvest_augment_life)
    | Harvest_augment `lightning ->
        get (fun x -> x.harvest_augment_lightning) (fun x -> x.harvest_augment_lightning)
    | Harvest_augment `physical ->
        get (fun x -> x.harvest_augment_physical) (fun x -> x.harvest_augment_physical)
    | Harvest_augment `speed ->
        get (fun x -> x.harvest_augment_speed) (fun x -> x.harvest_augment_speed)
    | Harvest_non_to `attack ->
        get (fun x -> x.harvest_non_attack_to_attack)
          (fun x -> x.harvest_non_attack_to_attack)
    | Harvest_non_to `caster ->
        get (fun x -> x.harvest_non_caster_to_caster)
          (fun x -> x.harvest_non_caster_to_caster)
    | Harvest_non_to `chaos ->
        get (fun x -> x.harvest_non_chaos_to_chaos) (fun x -> x.harvest_non_chaos_to_chaos)
    | Harvest_non_to `cold ->
        get (fun x -> x.harvest_non_cold_to_cold) (fun x -> x.harvest_non_cold_to_cold)
    | Harvest_non_to `critical ->
        get (fun x -> x.harvest_non_critical_to_critical)
          (fun x -> x.harvest_non_critical_to_critical)
    | Harvest_non_to `defences ->
        get (fun x -> x.harvest_non_defences_to_defences)
          (fun x -> x.harvest_non_defences_to_defences)
    | Harvest_non_to `fire ->
        get (fun x -> x.harvest_non_fire_to_fire) (fun x -> x.harvest_non_fire_to_fire)
    | Harvest_non_to `life ->
        get (fun x -> x.harvest_non_life_to_life) (fun x -> x.harvest_non_life_to_life)
    | Harvest_non_to `lightning ->
        get (fun x -> x.harvest_non_lightning_to_lightning)
          (fun x -> x.harvest_non_lightning_to_lightning)
    | Harvest_non_to `physical ->
        get (fun x -> x.harvest_non_physical_to_physical)
          (fun x -> x.harvest_non_physical_to_physical)
    | Harvest_non_to `speed ->
        get (fun x -> x.harvest_non_speed_to_speed) (fun x -> x.harvest_non_speed_to_speed)
    | Harvest_reforge `attack ->
        get (fun x -> x.harvest_reforge_attack) (fun x -> x.harvest_reforge_attack)
    | Harvest_reforge `caster ->
        get (fun x -> x.harvest_reforge_caster) (fun x -> x.harvest_reforge_caster)
    | Harvest_reforge `chaos ->
        get (fun x -> x.harvest_reforge_chaos) (fun x -> x.harvest_reforge_chaos)
    | Harvest_reforge `cold ->
        get (fun x -> x.harvest_reforge_cold) (fun x -> x.harvest_reforge_cold)
    | Harvest_reforge `critical ->
        get (fun x -> x.harvest_reforge_critical) (fun x -> x.harvest_reforge_critical)
    | Harvest_reforge `defences ->
        get (fun x -> x.harvest_reforge_defences) (fun x -> x.harvest_reforge_defences)
    | Harvest_reforge `fire ->
        get (fun x -> x.harvest_reforge_fire) (fun x -> x.harvest_reforge_fire)
    | Harvest_reforge `life ->
        get (fun x -> x.harvest_reforge_life) (fun x -> x.harvest_reforge_life)
    | Harvest_reforge `lightning ->
        get (fun x -> x.harvest_reforge_lightning) (fun x -> x.harvest_reforge_lightning)
    | Harvest_reforge `physical ->
        get (fun x -> x.harvest_reforge_physical) (fun x -> x.harvest_reforge_physical)
    | Harvest_reforge `speed ->
        get (fun x -> x.harvest_reforge_speed) (fun x -> x.harvest_reforge_speed)
    | Harvest_reforge_keep_prefixes ->
        get (fun x -> x.harvest_reforge_keep_prefixes)
          (fun x -> x.harvest_reforge_keep_prefixes)
    | Harvest_reforge_keep_suffixes ->
        get (fun x -> x.harvest_reforge_keep_suffixes)
          (fun x -> x.harvest_reforge_keep_suffixes)
    | Beastcraft_aspect_of_the_avian ->
        get (fun x -> x.beastcraft_aspect_of_the_avian)
          (fun x -> x.beastcraft_aspect_of_the_avian)
    | Beastcraft_aspect_of_the_cat ->
        get (fun x -> x.beastcraft_aspect_of_the_cat)
          (fun x -> x.beastcraft_aspect_of_the_cat)
    | Beastcraft_aspect_of_the_crab ->
        get (fun x -> x.beastcraft_aspect_of_the_crab)
          (fun x -> x.beastcraft_aspect_of_the_crab)
    | Beastcraft_aspect_of_the_spider ->
        get (fun x -> x.beastcraft_aspect_of_the_spider)
          (fun x -> x.beastcraft_aspect_of_the_spider)
    | Beastcraft_split ->
        get (fun x -> x.beastcraft_split)
          (fun x -> x.beastcraft_split)
    | Beastcraft_imprint ->
        get (fun x -> x.beastcraft_imprint)
          (fun x -> x.beastcraft_imprint)
    | Aisling ->
        get (fun x -> x.aisling) (fun x -> x.aisling)
    | Craft _ ->
        transmute ()
    | Multimod -> 2. *. exalt ()
    | Prefixes_cannot_be_changed -> 2. *. exalt ()
    | Suffixes_cannot_be_changed -> 2. *. exalt ()
    | Cannot_roll_attack_mods -> exalt ()
    | Cannot_roll_caster_mods -> 5. *. bless ()
    | Remove_crafted_mods -> scour ()
    | Craft_any_prefix -> transmute ()
    | Craft_any_suffix -> transmute ()

let get_default used_by name =
  match name with
    | "chaos" -> Chaos 1.
    | "transmute" -> default.transmute
    | "augment" -> default.augment
    | "alt" -> default.alt
    | "regal" -> default.regal
    | "alch" -> default.alch
    | "bless" -> default.bless
    | "scour" -> default.scour
    | "annul" -> default.annul
    | "exalt" -> default.exalt
    | "crusader_exalt" -> default.crusader_exalt
    | "hunter_exalt" -> default.hunter_exalt
    | "redeemer_exalt" -> default.redeemer_exalt
    | "warlord_exalt" -> default.warlord_exalt
    | "veiled_chaos" -> default.veiled_chaos
    | "essence_of_anger" -> default.essence_of_anger
    | "essence_of_anguish" -> default.essence_of_anguish
    | "essence_of_contempt" -> default.essence_of_contempt
    | "essence_of_doubt" -> default.essence_of_doubt
    | "essence_of_dread" -> default.essence_of_dread
    | "essence_of_envy" -> default.essence_of_envy
    | "essence_of_fear" -> default.essence_of_fear
    | "essence_of_greed" -> default.essence_of_greed
    | "essence_of_hatred" -> default.essence_of_hatred
    | "essence_of_loathing" -> default.essence_of_loathing
    | "essence_of_misery" -> default.essence_of_misery
    | "essence_of_rage" -> default.essence_of_rage
    | "essence_of_scorn" -> default.essence_of_scorn
    | "essence_of_sorrow" -> default.essence_of_sorrow
    | "essence_of_spite" -> default.essence_of_spite
    | "essence_of_suffering" -> default.essence_of_suffering
    | "essence_of_torment" -> default.essence_of_torment
    | "essence_of_woe" -> default.essence_of_woe
    | "essence_of_wrath" -> default.essence_of_wrath
    | "essence_of_zeal" -> default.essence_of_zeal
    | "essence_of_delirium" -> default.essence_of_delirium
    | "essence_of_horror" -> default.essence_of_horror
    | "essence_of_hysteria" -> default.essence_of_hysteria
    | "essence_of_insanity" -> default.essence_of_insanity
    | "aberrant" -> default.aberrant_fossil
    | "aetheric" -> default.aetheric_fossil
    | "bound" -> default.bound_fossil
    | "corroded" -> default.corroded_fossil
    | "dense" -> default.dense_fossil
    | "faceted" -> default.faceted_fossil
    | "frigid" -> default.frigid_fossil
    | "jagged" -> default.jagged_fossil
    | "lucent" -> default.lucent_fossil
    | "metallic" -> default.metallic_fossil
    | "prismatic" -> default.prismatic_fossil
    | "pristine" -> default.pristine_fossil
    | "scorched" -> default.scorched_fossil
    | "serrated" -> default.serrated_fossil
    | "shuddering" -> default.shuddering_fossil
    | "fundamental" -> default.fundamental_fossil
    | "deft" -> default.deft_fossil
    | "primitive_resonator" -> default.primitive_resonator
    | "potent_resonator" -> default.potent_resonator
    | "powerful_resonator" -> default.powerful_resonator
    | "prime_resonator" -> default.prime_resonator
    | "awaken" -> default.awaken
    | "lesser_ember" -> default.lesser_ember
    | "greater_ember" -> default.greater_ember
    | "grand_ember" -> default.grand_ember
    | "exceptional_ember" -> default.exceptional_ember
    | "lesser_ichor" -> default.lesser_ichor
    | "greater_ichor" -> default.greater_ichor
    | "grand_ichor" -> default.grand_ichor
    | "exceptional_ichor" -> default.exceptional_ichor
    | "harvest_augment_attack" -> default.harvest_augment_attack
    | "harvest_augment_caster" -> default.harvest_augment_caster
    | "harvest_augment_chaos" -> default.harvest_augment_chaos
    | "harvest_augment_cold" -> default.harvest_augment_cold
    | "harvest_augment_critical" -> default.harvest_augment_critical
    | "harvest_augment_defences" -> default.harvest_augment_defences
    | "harvest_augment_fire" -> default.harvest_augment_fire
    | "harvest_augment_life" -> default.harvest_augment_life
    | "harvest_augment_lightning" -> default.harvest_augment_lightning
    | "harvest_augment_physical" -> default.harvest_augment_physical
    | "harvest_augment_speed" -> default.harvest_augment_speed
    | "harvest_non_attack_to_attack" -> default.harvest_non_attack_to_attack
    | "harvest_non_caster_to_caster" -> default.harvest_non_caster_to_caster
    | "harvest_non_chaos_to_chaos" -> default.harvest_non_chaos_to_chaos
    | "harvest_non_cold_to_cold" -> default.harvest_non_cold_to_cold
    | "harvest_non_critical_to_critical" -> default.harvest_non_critical_to_critical
    | "harvest_non_defences_to_defences" -> default.harvest_non_defences_to_defences
    | "harvest_non_fire_to_fire" -> default.harvest_non_fire_to_fire
    | "harvest_non_life_to_life" -> default.harvest_non_life_to_life
    | "harvest_non_lightning_to_lightning" -> default.harvest_non_lightning_to_lightning
    | "harvest_non_physical_to_physical" -> default.harvest_non_physical_to_physical
    | "harvest_non_speed_to_speed" -> default.harvest_non_speed_to_speed
    | "harvest_reforge_attack" -> default.harvest_reforge_attack
    | "harvest_reforge_caster" -> default.harvest_reforge_caster
    | "harvest_reforge_chaos" -> default.harvest_reforge_chaos
    | "harvest_reforge_cold" -> default.harvest_reforge_cold
    | "harvest_reforge_critical" -> default.harvest_reforge_critical
    | "harvest_reforge_defences" -> default.harvest_reforge_defences
    | "harvest_reforge_fire" -> default.harvest_reforge_fire
    | "harvest_reforge_life" -> default.harvest_reforge_life
    | "harvest_reforge_lightning" -> default.harvest_reforge_lightning
    | "harvest_reforge_physical" -> default.harvest_reforge_physical
    | "harvest_reforge_speed" -> default.harvest_reforge_speed
    | "harvest_reforge_keep_prefixes" -> default.harvest_reforge_keep_prefixes
    | "harvest_reforge_keep_suffixes" -> default.harvest_reforge_keep_suffixes
    | "beastcraft_aspect_of_the_avian" -> default.beastcraft_aspect_of_the_avian
    | "beastcraft_aspect_of_the_cat" -> default.beastcraft_aspect_of_the_cat
    | "beastcraft_aspect_of_the_crab" -> default.beastcraft_aspect_of_the_crab
    | "beastcraft_aspect_of_the_spider" -> default.beastcraft_aspect_of_the_spider
    | "beastcraft_split" -> default.beastcraft_split
    | "beastcraft_imprint" -> default.beastcraft_imprint
    | "aisling" -> default.aisling
    | name -> JSON.fail used_by (name ^ " is undefined")

let load filename =
  let json = JSON.parse_file filename in
  let rec get used_by seen field =
    match JSON.get field json |> JSON.as_option with
      | None ->
          (
            match get_default used_by field with
              | Chaos x -> x
              | Exalt x -> x *. default_exalt
          )
      | Some value ->
          match JSON.as_float_opt value with
            | Some value ->
                value
            | None ->
                match JSON.as_object_opt value with
                  | None ->
                      JSON.fail value "invalid value; expected a number or an object"
                  | Some amount ->
                      let add acc (currency, multiplier) =
                        if String_set.mem currency seen then
                          JSON.fail value "ill-founded recursion"
                        else
                          let currency_value =
                            get multiplier (String_set.add currency seen) currency
                          in
                          let multiplier = JSON.as_float multiplier in
                          acc +. multiplier *. currency_value
                      in
                      List.fold_left add 0. amount
  in
  let get = get json String_set.empty in
  values := Some {
    transmute = get "transmute";
    augment = get "augment";
    alt = get "alt";
    regal = get "regal";
    alch = get "alch";
    bless = get "bless";
    scour = get "scour";
    annul = get "annul";
    exalt = get "exalt";
    crusader_exalt = get "crusader_exalt";
    hunter_exalt = get "hunter_exalt";
    redeemer_exalt = get "redeemer_exalt";
    warlord_exalt = get "warlord_exalt";
    veiled_chaos = get "veiled_chaos";
    essence_of_anger = get "essence_of_anger";
    essence_of_anguish = get "essence_of_anguish";
    essence_of_contempt = get "essence_of_contempt";
    essence_of_doubt = get "essence_of_doubt";
    essence_of_dread = get "essence_of_dread";
    essence_of_envy = get "essence_of_envy";
    essence_of_fear = get "essence_of_fear";
    essence_of_greed = get "essence_of_greed";
    essence_of_hatred = get "essence_of_hatred";
    essence_of_loathing = get "essence_of_loathing";
    essence_of_misery = get "essence_of_misery";
    essence_of_rage = get "essence_of_rage";
    essence_of_scorn = get "essence_of_scorn";
    essence_of_sorrow = get "essence_of_sorrow";
    essence_of_spite = get "essence_of_spite";
    essence_of_suffering = get "essence_of_suffering";
    essence_of_torment = get "essence_of_torment";
    essence_of_woe = get "essence_of_woe";
    essence_of_wrath = get "essence_of_wrath";
    essence_of_zeal = get "essence_of_zeal";
    essence_of_delirium = get "essence_of_delirium";
    essence_of_horror = get "essence_of_horror";
    essence_of_hysteria = get "essence_of_hysteria";
    essence_of_insanity = get "essence_of_insanity";
    aberrant_fossil = get "aberrant";
    aetheric_fossil = get "aetheric";
    bound_fossil = get "bound";
    corroded_fossil = get "corroded";
    dense_fossil = get "dense";
    faceted_fossil = get "faceted";
    frigid_fossil = get "frigid";
    jagged_fossil = get "jagged";
    lucent_fossil = get "lucent";
    metallic_fossil = get "metallic";
    prismatic_fossil = get "prismatic";
    pristine_fossil = get "pristine";
    scorched_fossil = get "scorched";
    serrated_fossil = get "serrated";
    shuddering_fossil = get "shuddering";
    fundamental_fossil = get "fundamental";
    deft_fossil = get "deft";
    primitive_resonator = get "primitive_resonator";
    potent_resonator = get "potent_resonator";
    powerful_resonator = get "powerful_resonator";
    prime_resonator = get "prime_resonator";
    awaken = get "awaken";
    lesser_ember = get "lesser_ember";
    greater_ember = get "greater_ember";
    grand_ember = get "grand_ember";
    exceptional_ember = get "exceptional_ember";
    lesser_ichor = get "lesser_ichor";
    greater_ichor = get "greater_ichor";
    grand_ichor = get "grand_ichor";
    exceptional_ichor = get "exceptional_ichor";
    harvest_augment_attack = get "harvest_augment_attack";
    harvest_augment_caster = get "harvest_augment_caster";
    harvest_augment_chaos = get "harvest_augment_chaos";
    harvest_augment_cold = get "harvest_augment_cold";
    harvest_augment_critical = get "harvest_augment_critical";
    harvest_augment_defences = get "harvest_augment_defences";
    harvest_augment_fire = get "harvest_augment_fire";
    harvest_augment_life = get "harvest_augment_life";
    harvest_augment_lightning = get "harvest_augment_lightning";
    harvest_augment_physical = get "harvest_augment_physical";
    harvest_augment_speed = get "harvest_augment_speed";
    harvest_non_attack_to_attack = get "harvest_non_attack_to_attack";
    harvest_non_caster_to_caster = get "harvest_non_caster_to_caster";
    harvest_non_chaos_to_chaos = get "harvest_non_chaos_to_chaos";
    harvest_non_cold_to_cold = get "harvest_non_cold_to_cold";
    harvest_non_critical_to_critical = get "harvest_non_critical_to_critical";
    harvest_non_defences_to_defences = get "harvest_non_defences_to_defences";
    harvest_non_fire_to_fire = get "harvest_non_fire_to_fire";
    harvest_non_life_to_life = get "harvest_non_life_to_life";
    harvest_non_lightning_to_lightning = get "harvest_non_lightning_to_lightning";
    harvest_non_physical_to_physical = get "harvest_non_physical_to_physical";
    harvest_non_speed_to_speed = get "harvest_non_speed_to_speed";
    harvest_reforge_attack = get "harvest_reforge_attack";
    harvest_reforge_caster = get "harvest_reforge_caster";
    harvest_reforge_chaos = get "harvest_reforge_chaos";
    harvest_reforge_cold = get "harvest_reforge_cold";
    harvest_reforge_critical = get "harvest_reforge_critical";
    harvest_reforge_defences = get "harvest_reforge_defences";
    harvest_reforge_fire = get "harvest_reforge_fire";
    harvest_reforge_life = get "harvest_reforge_life";
    harvest_reforge_lightning = get "harvest_reforge_lightning";
    harvest_reforge_physical = get "harvest_reforge_physical";
    harvest_reforge_speed = get "harvest_reforge_speed";
    harvest_reforge_keep_prefixes = get "harvest_reforge_keep_prefixes";
    harvest_reforge_keep_suffixes = get "harvest_reforge_keep_suffixes";
    beastcraft_aspect_of_the_avian = get "beastcraft_aspect_of_the_avian";
    beastcraft_aspect_of_the_cat = get "beastcraft_aspect_of_the_cat";
    beastcraft_aspect_of_the_crab = get "beastcraft_aspect_of_the_crab";
    beastcraft_aspect_of_the_spider = get "beastcraft_aspect_of_the_spider";
    beastcraft_split = get "beastcraft_split";
    beastcraft_imprint = get "beastcraft_imprint";
    aisling = get "aisling";
  }

let write filename v =
  let json =
    `O (
      List.flatten [
        v "transmute"
          (fun x -> x.transmute)
          (fun x -> x.transmute);
        v "augment"
          (fun x -> x.augment)
          (fun x -> x.augment);
        v "alt"
          (fun x -> x.alt)
          (fun x -> x.alt);
        v "regal"
          (fun x -> x.regal)
          (fun x -> x.regal);
        v "alch"
          (fun x -> x.alch)
          (fun x -> x.alch);
        v "bless"
          (fun x -> x.bless)
          (fun x -> x.bless);
        v "scour"
          (fun x -> x.scour)
          (fun x -> x.scour);
        v "annul"
          (fun x -> x.annul)
          (fun x -> x.annul);
        v "exalt"
          (fun x -> x.exalt)
          (fun x -> x.exalt);
        v "crusader_exalt"
          (fun x -> x.crusader_exalt)
          (fun x -> x.crusader_exalt);
        v "hunter_exalt"
          (fun x -> x.hunter_exalt)
          (fun x -> x.hunter_exalt);
        v "redeemer_exalt"
          (fun x -> x.redeemer_exalt)
          (fun x -> x.redeemer_exalt);
        v "warlord_exalt"
          (fun x -> x.warlord_exalt)
          (fun x -> x.warlord_exalt);
        v "veiled_chaos"
          (fun x -> x.veiled_chaos)
          (fun x -> x.veiled_chaos);
        v "essence_of_anger"
          (fun x -> x.essence_of_anger)
          (fun x -> x.essence_of_anger);
        v "essence_of_anguish"
          (fun x -> x.essence_of_anguish)
          (fun x -> x.essence_of_anguish);
        v "essence_of_contempt"
          (fun x -> x.essence_of_contempt)
          (fun x -> x.essence_of_contempt);
        v "essence_of_doubt"
          (fun x -> x.essence_of_doubt)
          (fun x -> x.essence_of_doubt);
        v "essence_of_dread"
          (fun x -> x.essence_of_dread)
          (fun x -> x.essence_of_dread);
        v "essence_of_envy"
          (fun x -> x.essence_of_envy)
          (fun x -> x.essence_of_envy);
        v "essence_of_fear"
          (fun x -> x.essence_of_fear)
          (fun x -> x.essence_of_fear);
        v "essence_of_greed"
          (fun x -> x.essence_of_greed)
          (fun x -> x.essence_of_greed);
        v "essence_of_hatred"
          (fun x -> x.essence_of_hatred)
          (fun x -> x.essence_of_hatred);
        v "essence_of_loathing"
          (fun x -> x.essence_of_loathing)
          (fun x -> x.essence_of_loathing);
        v "essence_of_misery"
          (fun x -> x.essence_of_misery)
          (fun x -> x.essence_of_misery);
        v "essence_of_rage"
          (fun x -> x.essence_of_rage)
          (fun x -> x.essence_of_rage);
        v "essence_of_scorn"
          (fun x -> x.essence_of_scorn)
          (fun x -> x.essence_of_scorn);
        v "essence_of_sorrow"
          (fun x -> x.essence_of_sorrow)
          (fun x -> x.essence_of_sorrow);
        v "essence_of_spite"
          (fun x -> x.essence_of_spite)
          (fun x -> x.essence_of_spite);
        v "essence_of_suffering"
          (fun x -> x.essence_of_suffering)
          (fun x -> x.essence_of_suffering);
        v "essence_of_torment"
          (fun x -> x.essence_of_torment)
          (fun x -> x.essence_of_torment);
        v "essence_of_woe"
          (fun x -> x.essence_of_woe)
          (fun x -> x.essence_of_woe);
        v "essence_of_wrath"
          (fun x -> x.essence_of_wrath)
          (fun x -> x.essence_of_wrath);
        v "essence_of_zeal"
          (fun x -> x.essence_of_zeal)
          (fun x -> x.essence_of_zeal);
        v "essence_of_delirium"
          (fun x -> x.essence_of_delirium)
          (fun x -> x.essence_of_delirium);
        v "essence_of_horror"
          (fun x -> x.essence_of_horror)
          (fun x -> x.essence_of_horror);
        v "essence_of_hysteria"
          (fun x -> x.essence_of_hysteria)
          (fun x -> x.essence_of_hysteria);
        v "essence_of_insanity"
          (fun x -> x.essence_of_insanity)
          (fun x -> x.essence_of_insanity);
        v "aberrant"
          (fun x -> x.aberrant_fossil)
          (fun x -> x.aberrant_fossil);
        v "aetheric"
          (fun x -> x.aetheric_fossil)
          (fun x -> x.aetheric_fossil);
        v "bound"
          (fun x -> x.bound_fossil)
          (fun x -> x.bound_fossil);
        v "corroded"
          (fun x -> x.corroded_fossil)
          (fun x -> x.corroded_fossil);
        v "dense"
          (fun x -> x.dense_fossil)
          (fun x -> x.dense_fossil);
        v "faceted"
          (fun x -> x.faceted_fossil)
          (fun x -> x.faceted_fossil);
        v "frigid"
          (fun x -> x.frigid_fossil)
          (fun x -> x.frigid_fossil);
        v "jagged"
          (fun x -> x.jagged_fossil)
          (fun x -> x.jagged_fossil);
        v "lucent"
          (fun x -> x.lucent_fossil)
          (fun x -> x.lucent_fossil);
        v "metallic"
          (fun x -> x.metallic_fossil)
          (fun x -> x.metallic_fossil);
        v "prismatic"
          (fun x -> x.prismatic_fossil)
          (fun x -> x.prismatic_fossil);
        v "pristine"
          (fun x -> x.pristine_fossil)
          (fun x -> x.pristine_fossil);
        v "scorched"
          (fun x -> x.scorched_fossil)
          (fun x -> x.scorched_fossil);
        v "serrated"
          (fun x -> x.serrated_fossil)
          (fun x -> x.serrated_fossil);
        v "shuddering"
          (fun x -> x.shuddering_fossil)
          (fun x -> x.shuddering_fossil);
        v "fundamental"
          (fun x -> x.fundamental_fossil)
          (fun x -> x.fundamental_fossil);
        v "deft"
          (fun x -> x.deft_fossil)
          (fun x -> x.deft_fossil);
        v "primitive_resonator"
          (fun x -> x.primitive_resonator)
          (fun x -> x.primitive_resonator);
        v "potent_resonator"
          (fun x -> x.potent_resonator)
          (fun x -> x.potent_resonator);
        v "powerful_resonator"
          (fun x -> x.powerful_resonator)
          (fun x -> x.powerful_resonator);
        v "prime_resonator"
          (fun x -> x.prime_resonator)
          (fun x -> x.prime_resonator);
        v "awaken"
          (fun x -> x.awaken)
          (fun x -> x.awaken);
        v "lesser_ember"
          (fun x -> x.lesser_ember)
          (fun x -> x.lesser_ember);
        v "greater_ember"
          (fun x -> x.greater_ember)
          (fun x -> x.greater_ember);
        v "grand_ember"
          (fun x -> x.grand_ember)
          (fun x -> x.grand_ember);
        v "exceptional_ember"
          (fun x -> x.exceptional_ember)
          (fun x -> x.exceptional_ember);
        v "lesser_ichor"
          (fun x -> x.lesser_ichor)
          (fun x -> x.lesser_ichor);
        v "greater_ichor"
          (fun x -> x.greater_ichor)
          (fun x -> x.greater_ichor);
        v "grand_ichor"
          (fun x -> x.grand_ichor)
          (fun x -> x.grand_ichor);
        v "exceptional_ichor"
          (fun x -> x.exceptional_ichor)
          (fun x -> x.exceptional_ichor);
        v "harvest_augment_attack"
          (fun x -> x.harvest_augment_attack)
          (fun x -> x.harvest_augment_attack);
        v "harvest_augment_caster"
          (fun x -> x.harvest_augment_caster)
          (fun x -> x.harvest_augment_caster);
        v "harvest_augment_chaos"
          (fun x -> x.harvest_augment_chaos)
          (fun x -> x.harvest_augment_chaos);
        v "harvest_augment_cold"
          (fun x -> x.harvest_augment_cold)
          (fun x -> x.harvest_augment_cold);
        v "harvest_augment_critical"
          (fun x -> x.harvest_augment_critical)
          (fun x -> x.harvest_augment_critical);
        v "harvest_augment_defences"
          (fun x -> x.harvest_augment_defences)
          (fun x -> x.harvest_augment_defences);
        v "harvest_augment_fire"
          (fun x -> x.harvest_augment_fire)
          (fun x -> x.harvest_augment_fire);
        v "harvest_augment_life"
          (fun x -> x.harvest_augment_life)
          (fun x -> x.harvest_augment_life);
        v "harvest_augment_lightning"
          (fun x -> x.harvest_augment_lightning)
          (fun x -> x.harvest_augment_lightning);
        v "harvest_augment_physical"
          (fun x -> x.harvest_augment_physical)
          (fun x -> x.harvest_augment_physical);
        v "harvest_augment_speed"
          (fun x -> x.harvest_augment_speed)
          (fun x -> x.harvest_augment_speed);
        v "harvest_non_attack_to_attack"
          (fun x -> x.harvest_non_attack_to_attack)
          (fun x -> x.harvest_non_attack_to_attack);
        v "harvest_non_caster_to_caster"
          (fun x -> x.harvest_non_caster_to_caster)
          (fun x -> x.harvest_non_caster_to_caster);
        v "harvest_non_chaos_to_chaos"
          (fun x -> x.harvest_non_chaos_to_chaos)
          (fun x -> x.harvest_non_chaos_to_chaos);
        v "harvest_non_cold_to_cold"
          (fun x -> x.harvest_non_cold_to_cold)
          (fun x -> x.harvest_non_cold_to_cold);
        v "harvest_non_critical_to_critical"
          (fun x -> x.harvest_non_critical_to_critical)
          (fun x -> x.harvest_non_critical_to_critical);
        v "harvest_non_defences_to_defences"
          (fun x -> x.harvest_non_defences_to_defences)
          (fun x -> x.harvest_non_defences_to_defences);
        v "harvest_non_fire_to_fire"
          (fun x -> x.harvest_non_fire_to_fire)
          (fun x -> x.harvest_non_fire_to_fire);
        v "harvest_non_life_to_life"
          (fun x -> x.harvest_non_life_to_life)
          (fun x -> x.harvest_non_life_to_life);
        v "harvest_non_lightning_to_lightning"
          (fun x -> x.harvest_non_lightning_to_lightning)
          (fun x -> x.harvest_non_lightning_to_lightning);
        v "harvest_non_physical_to_physical"
          (fun x -> x.harvest_non_physical_to_physical)
          (fun x -> x.harvest_non_physical_to_physical);
        v "harvest_non_speed_to_speed"
          (fun x -> x.harvest_non_speed_to_speed)
          (fun x -> x.harvest_non_speed_to_speed);
        v "harvest_reforge_attack"
          (fun x -> x.harvest_reforge_attack)
          (fun x -> x.harvest_reforge_attack);
        v "harvest_reforge_caster"
          (fun x -> x.harvest_reforge_caster)
          (fun x -> x.harvest_reforge_caster);
        v "harvest_reforge_chaos"
          (fun x -> x.harvest_reforge_chaos)
          (fun x -> x.harvest_reforge_chaos);
        v "harvest_reforge_cold"
          (fun x -> x.harvest_reforge_cold)
          (fun x -> x.harvest_reforge_cold);
        v "harvest_reforge_critical"
          (fun x -> x.harvest_reforge_critical)
          (fun x -> x.harvest_reforge_critical);
        v "harvest_reforge_defences"
          (fun x -> x.harvest_reforge_defences)
          (fun x -> x.harvest_reforge_defences);
        v "harvest_reforge_fire"
          (fun x -> x.harvest_reforge_fire)
          (fun x -> x.harvest_reforge_fire);
        v "harvest_reforge_life"
          (fun x -> x.harvest_reforge_life)
          (fun x -> x.harvest_reforge_life);
        v "harvest_reforge_lightning"
          (fun x -> x.harvest_reforge_lightning)
          (fun x -> x.harvest_reforge_lightning);
        v "harvest_reforge_physical"
          (fun x -> x.harvest_reforge_physical)
          (fun x -> x.harvest_reforge_physical);
        v "harvest_reforge_speed"
          (fun x -> x.harvest_reforge_speed)
          (fun x -> x.harvest_reforge_speed);
        v "harvest_reforge_keep_prefixes"
          (fun x -> x.harvest_reforge_keep_prefixes)
          (fun x -> x.harvest_reforge_keep_prefixes);
        v "harvest_reforge_keep_suffixes"
          (fun x -> x.harvest_reforge_keep_suffixes)
          (fun x -> x.harvest_reforge_keep_suffixes);
        v "beastcraft_aspect_of_the_avian"
          (fun x -> x.beastcraft_aspect_of_the_avian)
          (fun x -> x.beastcraft_aspect_of_the_avian);
        v "beastcraft_aspect_of_the_cat"
          (fun x -> x.beastcraft_aspect_of_the_cat)
          (fun x -> x.beastcraft_aspect_of_the_cat);
        v "beastcraft_aspect_of_the_crab"
          (fun x -> x.beastcraft_aspect_of_the_crab)
          (fun x -> x.beastcraft_aspect_of_the_crab);
        v "beastcraft_aspect_of_the_spider"
          (fun x -> x.beastcraft_aspect_of_the_spider)
          (fun x -> x.beastcraft_aspect_of_the_spider);
        v "beastcraft_split"
          (fun x -> x.beastcraft_split)
          (fun x -> x.beastcraft_split);
        v "beastcraft_imprint"
          (fun x -> x.beastcraft_imprint)
          (fun x -> x.beastcraft_imprint);
        v "aisling"
          (fun x -> x.aisling)
          (fun x -> x.aisling);
      ]
    )
  in
  JSON.write_file filename json

let encode_default name get _ =
  match get default with
    | Chaos x -> [ name, `Float x ]
    | Exalt x -> [ name, `O [ "exalt", `Float x ] ]

let write_defaults filename =
  write filename encode_default

let write_options cost filename =
  write filename @@ fun name get1 get2 ->
  match get1 cost with
    | None -> encode_default name get2 get1
    | Some x -> [ name, `Float x ]

let show_chaos_amount amount =
  sf "%.2fex (%dc)"
    (amount /. get Exalted_orb)
    (int_of_float amount)

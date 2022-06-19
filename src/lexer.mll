{
  open Parser
  open AST

  let keyword = function
    (* Instructions *)
    | "buy" -> BUY
    | "exact" -> EXACT
    | "normal" -> NORMAL
    | "magic" -> MAGIC
    | "rare" -> RARE
    | "shaper" -> SHAPER
    | "elder" -> ELDER
    | "crusader" -> CRUSADER
    | "hunter" -> HUNTER
    | "redeemer" -> REDEEMER
    | "warlord" -> WARLORD
    | "exarch" -> EXARCH
    | "eater" -> EATER
    | "synthesized" -> SYNTHESIZED
    | "ilvl" -> ILVL
    | "with" -> WITH
    | "fractured" -> FRACTURED
    | "for" -> FOR
    | "if" -> IF
    | "then" -> THEN
    | "else" -> ELSE
    | "until" -> UNTIL
    | "repeat" -> REPEAT
    | "while" -> WHILE
    | "do" -> DO
    | "goto" -> GOTO
    | "stop" -> STOP
    | "set_aside" -> SET_ASIDE
    | "swap" -> SWAP
    | "use_imprint" -> USE_IMPRINT
    | "gain" -> GAIN
    | "echo" -> ECHO
    | "show" -> SHOW
    | "show_mod_pool" -> SHOW_MOD_POOL
    | "show_unveil_mod_pool" -> SHOW_UNVEIL_MOD_POOL
    | "unveil" -> UNVEIL
    (* Conditions *)
    | "true" -> TRUE
    | "false" -> FALSE
    | "not" -> NOT
    | "and" -> AND
    | "or" -> OR
    | "has" -> HAS
    | "has_mod" -> HAS_MOD
    | "has_group" -> HAS_GROUP
    | "is_base" -> IS_BASE
    | "prefix_count" -> PREFIX_COUNT
    | "no_prefix" -> NO_PREFIX
    | "open_prefix" -> OPEN_PREFIX
    | "full_prefixes" -> FULL_PREFIXES
    | "suffix_count" -> SUFFIX_COUNT
    | "no_suffix" -> NO_SUFFIX
    | "open_suffix" -> OPEN_SUFFIX
    | "full_suffixes" -> FULL_SUFFIXES
    | "no_affix" -> NO_AFFIX
    | "affix_count" -> AFFIX_COUNT
    | "open_affix" -> OPEN_AFFIX
    | "full_affixes" -> FULL_AFFIXES
    | "tier" -> TIER
    (* Currencies *)
    | "transmute" -> CURRENCY Orb_of_transmutation
    | "augment" -> CURRENCY Orb_of_augmentation
    | "alt" -> CURRENCY Orb_of_alteration
    | "regal" -> CURRENCY Regal_orb
    | "alch" -> CURRENCY Orb_of_alchemy
    | "bless" -> CURRENCY Blessed_orb
    | "scour" -> CURRENCY Orb_of_scouring
    | "chaos" -> CURRENCY Chaos_orb
    | "annul" -> CURRENCY Orb_of_annulment
    | "exalt" -> CURRENCY Exalted_orb
    | "crusader_exalt" -> CURRENCY Crusader_exalted_orb
    | "hunter_exalt" -> CURRENCY Hunter_exalted_orb
    | "redeemer_exalt" -> CURRENCY Redeemer_exalted_orb
    | "warlord_exalt" -> CURRENCY Warlord_exalted_orb
    | "veiled_chaos" -> CURRENCY Veiled_chaos_orb
    | "essence_of_anger" -> CURRENCY (Essence Anger)
    | "essence_of_anguish" -> CURRENCY (Essence Anguish)
    | "essence_of_contempt" -> CURRENCY (Essence Contempt)
    | "essence_of_doubt" -> CURRENCY (Essence Doubt)
    | "essence_of_dread" -> CURRENCY (Essence Dread)
    | "essence_of_envy" -> CURRENCY (Essence Envy)
    | "essence_of_fear" -> CURRENCY (Essence Fear)
    | "essence_of_greed" -> CURRENCY (Essence Greed)
    | "essence_of_hatred" -> CURRENCY (Essence Hatred)
    | "essence_of_loathing" -> CURRENCY (Essence Loathing)
    | "essence_of_misery" -> CURRENCY (Essence Misery)
    | "essence_of_rage" -> CURRENCY (Essence Rage)
    | "essence_of_scorn" -> CURRENCY (Essence Scorn)
    | "essence_of_sorrow" -> CURRENCY (Essence Sorrow)
    | "essence_of_spite" -> CURRENCY (Essence Spite)
    | "essence_of_suffering" -> CURRENCY (Essence Suffering)
    | "essence_of_torment" -> CURRENCY (Essence Torment)
    | "essence_of_woe" -> CURRENCY (Essence Woe)
    | "essence_of_wrath" -> CURRENCY (Essence Wrath)
    | "essence_of_zeal" -> CURRENCY (Essence Zeal)
    | "essence_of_delirium" -> CURRENCY (Essence Delirium)
    | "essence_of_horror" -> CURRENCY (Essence Horror)
    | "essence_of_hysteria" -> CURRENCY (Essence Hysteria)
    | "essence_of_insanity" -> CURRENCY (Essence Insanity)
    | "aberrant" -> FOSSIL Aberrant
    | "aetheric" -> FOSSIL Aetheric
    | "bound" -> FOSSIL Bound
    | "corroded" -> FOSSIL Corroded
    | "dense" -> FOSSIL Dense
    | "faceted" -> FOSSIL Faceted
    | "frigid" -> FOSSIL Frigid
    | "jagged" -> FOSSIL Jagged
    | "lucent" -> FOSSIL Lucent
    | "metallic" -> FOSSIL Metallic
    | "prismatic" -> FOSSIL Prismatic
    | "pristine" -> FOSSIL Pristine
    | "scorched" -> FOSSIL Scorched
    | "serrated" -> FOSSIL Serrated
    | "shuddering" -> FOSSIL Shuddering
    | "fundamental" -> FOSSIL Fundamental
    | "deft" -> FOSSIL Deft
    | "orb_of_dominance" -> CURRENCY Orb_of_dominance
    | "awaken" -> CURRENCY Awakeners_orb
    | "armour_recombinator" -> CURRENCY Armour_recombinator
    | "weapon_recombinator" -> CURRENCY Weapon_recombinator
    | "jewellery_recombinator" -> CURRENCY Jewellery_recombinator
    | "recombine" -> RECOMBINE
    | "lesser_ember" -> CURRENCY (Ember Lesser)
    | "greater_ember" -> CURRENCY (Ember Greater)
    | "grand_ember" -> CURRENCY (Ember Grand)
    | "exceptional_ember" -> CURRENCY (Ember Exceptional)
    | "lesser_ichor" -> CURRENCY (Ichor Lesser)
    | "greater_ichor" -> CURRENCY (Ichor Greater)
    | "grand_ichor" -> CURRENCY (Ichor Grand)
    | "exceptional_ichor" -> CURRENCY (Ichor Exceptional)
    | "eldritch_annul" -> CURRENCY Eldritch_annul
    | "eldritch_exalt" -> CURRENCY Eldritch_exalt
    | "eldritch_chaos" -> CURRENCY Eldritch_chaos
    | "harvest_augment_attack" -> CURRENCY (Harvest_augment `attack)
    | "harvest_augment_caster" -> CURRENCY (Harvest_augment `caster)
    | "harvest_augment_chaos" -> CURRENCY (Harvest_augment `chaos)
    | "harvest_augment_cold" -> CURRENCY (Harvest_augment `cold)
    | "harvest_augment_critical" -> CURRENCY (Harvest_augment `critical)
    | "harvest_augment_defences" -> CURRENCY (Harvest_augment `defences)
    | "harvest_augment_fire" -> CURRENCY (Harvest_augment `fire)
    | "harvest_augment_life" -> CURRENCY (Harvest_augment `life)
    | "harvest_augment_lightning" -> CURRENCY (Harvest_augment `lightning)
    | "harvest_augment_physical" -> CURRENCY (Harvest_augment `physical)
    | "harvest_augment_speed" -> CURRENCY (Harvest_augment `speed)
    | "harvest_non_attack_to_attack" -> CURRENCY (Harvest_non_to `attack)
    | "harvest_non_caster_to_caster" -> CURRENCY (Harvest_non_to `caster)
    | "harvest_non_chaos_to_chaos" -> CURRENCY (Harvest_non_to `chaos)
    | "harvest_non_cold_to_cold" -> CURRENCY (Harvest_non_to `cold)
    | "harvest_non_critical_to_critical" -> CURRENCY (Harvest_non_to `critical)
    | "harvest_non_defences_to_defences" -> CURRENCY (Harvest_non_to `defences)
    | "harvest_non_fire_to_fire" -> CURRENCY (Harvest_non_to `fire)
    | "harvest_non_life_to_life" -> CURRENCY (Harvest_non_to `life)
    | "harvest_non_lightning_to_lightning" -> CURRENCY (Harvest_non_to `lightning)
    | "harvest_non_physical_to_physical" -> CURRENCY (Harvest_non_to `physical)
    | "harvest_non_speed_to_speed" -> CURRENCY (Harvest_non_to `speed)
    | "harvest_reforge_attack" -> CURRENCY (Harvest_reforge `attack)
    | "harvest_reforge_caster" -> CURRENCY (Harvest_reforge `caster)
    | "harvest_reforge_chaos" -> CURRENCY (Harvest_reforge `chaos)
    | "harvest_reforge_cold" -> CURRENCY (Harvest_reforge `cold)
    | "harvest_reforge_critical" -> CURRENCY (Harvest_reforge `critical)
    | "harvest_reforge_defences" -> CURRENCY (Harvest_reforge `defences)
    | "harvest_reforge_fire" -> CURRENCY (Harvest_reforge `fire)
    | "harvest_reforge_life" -> CURRENCY (Harvest_reforge `life)
    | "harvest_reforge_lightning" -> CURRENCY (Harvest_reforge `lightning)
    | "harvest_reforge_physical" -> CURRENCY (Harvest_reforge `physical)
    | "harvest_reforge_speed" -> CURRENCY (Harvest_reforge `speed)
    | "harvest_reforge_attack_more_common" ->
        CURRENCY (Harvest_reforge_more_common `attack)
    | "harvest_reforge_caster_more_common" ->
        CURRENCY (Harvest_reforge_more_common `caster)
    | "harvest_reforge_chaos_more_common" ->
        CURRENCY (Harvest_reforge_more_common `chaos)
    | "harvest_reforge_cold_more_common" ->
        CURRENCY (Harvest_reforge_more_common `cold)
    | "harvest_reforge_critical_more_common" ->
        CURRENCY (Harvest_reforge_more_common `critical)
    | "harvest_reforge_defences_more_common" ->
        CURRENCY (Harvest_reforge_more_common `defences)
    | "harvest_reforge_fire_more_common" ->
        CURRENCY (Harvest_reforge_more_common `fire)
    | "harvest_reforge_life_more_common" ->
        CURRENCY (Harvest_reforge_more_common `life)
    | "harvest_reforge_lightning_more_common" ->
        CURRENCY (Harvest_reforge_more_common `lightning)
    | "harvest_reforge_physical_more_common" ->
        CURRENCY (Harvest_reforge_more_common `physical)
    | "harvest_reforge_speed_more_common" ->
        CURRENCY (Harvest_reforge_more_common `speed)
    | "harvest_reforge_keep_prefixes" -> CURRENCY Harvest_reforge_keep_prefixes
    | "harvest_reforge_keep_suffixes" -> CURRENCY Harvest_reforge_keep_suffixes
    | "harvest_reforge_more_likely" -> CURRENCY Harvest_reforge_more_likely
    | "harvest_reforge_less_likely" -> CURRENCY Harvest_reforge_less_likely
    | "beastcraft_aspect_of_the_avian" -> CURRENCY Beastcraft_aspect_of_the_avian
    | "beastcraft_aspect_of_the_cat" -> CURRENCY Beastcraft_aspect_of_the_cat
    | "beastcraft_aspect_of_the_crab" -> CURRENCY Beastcraft_aspect_of_the_crab
    | "beastcraft_aspect_of_the_spider" -> CURRENCY Beastcraft_aspect_of_the_spider
    | "beastcraft_split" -> CURRENCY Beastcraft_split
    | "beastcraft_imprint" -> CURRENCY Beastcraft_imprint
    | "aisling" -> CURRENCY Aisling
    | "craft" -> CRAFT
    | "multimod" -> CURRENCY Multimod
    | "prefixes_cannot_be_changed" -> CURRENCY Prefixes_cannot_be_changed
    | "suffixes_cannot_be_changed" -> CURRENCY Suffixes_cannot_be_changed
    | "cannot_roll_attack_mods" -> CURRENCY Cannot_roll_attack_mods
    | "cannot_roll_caster_mods" -> CURRENCY Cannot_roll_caster_mods
    | "remove_crafted_mods" -> CURRENCY Remove_crafted_mods
    | "craft_any_prefix" -> CURRENCY Craft_any_prefix
    | "craft_any_suffix" -> CURRENCY Craft_any_suffix
    | s -> failwith ("unknown keyword: " ^ s)
}

rule token = parse
  | [' ' '\t' '\r']
      { token lexbuf }
  | ('#' [^'\n']*)? '\n'
      { Lexing.new_line lexbuf; token lexbuf }
  | '-'? ['0'-'9']+ as x
      {
        match int_of_string_opt x with
          | None -> failwith "integer too large"
          | Some i -> INT i
      }
  | '.' ['a'-'z' 'A'-'Z' '0'-'9' '_']+ as x { LABEL x }
  | '"' ([^'"' '\n']* as x) '"' { STRING x }
  | ['a'-'z' '_']+ as x { keyword x }
  | ".." { DOT_DOT }
  | '(' { LPAR }
  | ')' { RPAR }
  | '{' { LBRACE }
  | '}' { RBRACE }
  | '[' { LBRACKET }
  | ']' { RBRACKET }
  | ':' { COLON }
  | '+' { PLUS }
  | '-' { MINUS }
  | '*' { STAR }
  | '/' { SLASH }
  | '=' { COMPARISON_OPERATOR EQ }
  | "<>" { COMPARISON_OPERATOR NE }
  | '<' { COMPARISON_OPERATOR LT }
  | "<=" { COMPARISON_OPERATOR LE }
  | '>' { COMPARISON_OPERATOR GT }
  | ">=" { COMPARISON_OPERATOR GE }
  | ('#' [^'\n']*)? eof { EOF }
  | _ { failwith "syntax error" }

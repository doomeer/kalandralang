open Influence

type item_type =
  | Amulet
  | Belt
  | Body_armour
  | Boots
  | Bow
  | Claw
  | Dagger
  | Gloves
  | Helmet
  | One_hand_axe
  | One_hand_mace
  | One_hand_sword
  | Quiver
  | Ring
  | Rune_dagger
  | Sceptre
  | Shield
  | Staff
  | Thrusting_one_hand_sword
  | Two_hand_axe
  | Two_hand_mace
  | Two_hand_sword
  | Wand
  | Warstaff
  | Other

module Tag =
struct
  (* Base Item Tags *)
  let amulet = Id.make "amulet"
  let axe = Id.make "axe"
  let belt = Id.make "belt"
  let body_armour = Id.make "body_armour"
  let boots = Id.make "boots"
  let bow = Id.make "bow"
  let claw = Id.make "claw"
  let dagger = Id.make "dagger"
  let gloves = Id.make "gloves"
  let helmet = Id.make "helmet"
  let mace = Id.make "mace"
  let quiver = Id.make "quiver"
  let ring = Id.make "ring"
  let rune_dagger = Id.make "rune_dagger"
  let sceptre = Id.make "sceptre"
  let shield = Id.make "shield"
  let staff = Id.make "staff"
  let sword = Id.make "sword"
  let wand = Id.make "wand"
  let warstaff = Id.make "warstaff"

  (* Base Item Additional Tags *)
  let twohand = Id.make "twohand" (* can also be two_hand_weapon *)
  let attack_dagger = Id.make "attack_dagger"

  (* Influenced Variants *)
  let _2h_axe_shaper = Id.make "2h_axe_shaper"
  let _2h_axe_elder = Id.make "2h_axe_elder"
  let _2h_axe_crusader = Id.make "2h_axe_crusader"
  let _2h_axe_basilisk = Id.make "2h_axe_basilisk"
  let _2h_axe_eyrie = Id.make "2h_axe_eyrie"
  let _2h_axe_adjudicator = Id.make "2h_axe_adjudicator"
  let _2h_mace_shaper = Id.make "2h_mace_shaper"
  let _2h_mace_elder = Id.make "2h_mace_elder"
  let _2h_mace_crusader = Id.make "2h_mace_crusader"
  let _2h_mace_basilisk = Id.make "2h_mace_basilisk"
  let _2h_mace_eyrie = Id.make "2h_mace_eyrie"
  let _2h_mace_adjudicator = Id.make "2h_mace_adjudicator"
  let _2h_sword_shaper = Id.make "2h_sword_shaper"
  let _2h_sword_elder = Id.make "2h_sword_elder"
  let _2h_sword_crusader = Id.make "2h_sword_crusader"
  let _2h_sword_basilisk = Id.make "2h_sword_basilisk"
  let _2h_sword_eyrie = Id.make "2h_sword_eyrie"
  let _2h_sword_adjudicator = Id.make "2h_sword_adjudicator"
  let amulet_shaper = Id.make "amulet_shaper"
  let amulet_elder = Id.make "amulet_elder"
  let amulet_crusader = Id.make "amulet_crusader"
  let amulet_basilisk = Id.make "amulet_basilisk"
  let amulet_eyrie = Id.make "amulet_eyrie"
  let amulet_adjudicator = Id.make "amulet_adjudicator"
  let axe_shaper = Id.make "axe_shaper"
  let axe_elder = Id.make "axe_elder"
  let axe_crusader = Id.make "axe_crusader"
  let axe_basilisk = Id.make "axe_basilisk"
  let axe_eyrie = Id.make "axe_eyrie"
  let axe_adjudicator = Id.make "axe_adjudicator"
  let mace_shaper = Id.make "mace_shaper"
  let mace_elder = Id.make "mace_elder"
  let mace_crusader = Id.make "mace_crusader"
  let mace_basilisk = Id.make "mace_basilisk"
  let mace_eyrie = Id.make "mace_eyrie"
  let mace_adjudicator = Id.make "mace_adjudicator"
  let sword_shaper = Id.make "sword_shaper"
  let sword_elder = Id.make "sword_elder"
  let sword_crusader = Id.make "sword_crusader"
  let sword_basilisk = Id.make "sword_basilisk"
  let sword_eyrie = Id.make "sword_eyrie"
  let sword_adjudicator = Id.make "sword_adjudicator"
  let belt_shaper = Id.make "belt_shaper"
  let belt_elder = Id.make "belt_elder"
  let belt_crusader = Id.make "belt_crusader"
  let belt_basilisk = Id.make "belt_basilisk"
  let belt_eyrie = Id.make "belt_eyrie"
  let belt_adjudicator = Id.make "belt_adjudicator"
  let body_armour_shaper = Id.make "body_armour_shaper"
  let body_armour_elder = Id.make "body_armour_elder"
  let body_armour_crusader = Id.make "body_armour_crusader"
  let body_armour_basilisk = Id.make "body_armour_basilisk"
  let body_armour_eyrie = Id.make "body_armour_eyrie"
  let body_armour_adjudicator = Id.make "body_armour_adjudicator"
  let boots_shaper = Id.make "boots_shaper"
  let boots_elder = Id.make "boots_elder"
  let boots_crusader = Id.make "boots_crusader"
  let boots_basilisk = Id.make "boots_basilisk"
  let boots_eyrie = Id.make "boots_eyrie"
  let boots_adjudicator = Id.make "boots_adjudicator"
  let bow_shaper = Id.make "bow_shaper"
  let bow_elder = Id.make "bow_elder"
  let bow_crusader = Id.make "bow_crusader"
  let bow_basilisk = Id.make "bow_basilisk"
  let bow_eyrie = Id.make "bow_eyrie"
  let bow_adjudicator = Id.make "bow_adjudicator"
  let claw_shaper = Id.make "claw_shaper"
  let claw_elder = Id.make "claw_elder"
  let claw_crusader = Id.make "claw_crusader"
  let claw_basilisk = Id.make "claw_basilisk"
  let claw_eyrie = Id.make "claw_eyrie"
  let claw_adjudicator = Id.make "claw_adjudicator"
  let dagger_shaper = Id.make "dagger_shaper"
  let dagger_elder = Id.make "dagger_elder"
  let dagger_crusader = Id.make "dagger_crusader"
  let dagger_basilisk = Id.make "dagger_basilisk"
  let dagger_eyrie = Id.make "dagger_eyrie"
  let dagger_adjudicator = Id.make "dagger_adjudicator"
  let gloves_shaper = Id.make "gloves_shaper"
  let gloves_elder = Id.make "gloves_elder"
  let gloves_crusader = Id.make "gloves_crusader"
  let gloves_basilisk = Id.make "gloves_basilisk"
  let gloves_eyrie = Id.make "gloves_eyrie"
  let gloves_adjudicator = Id.make "gloves_adjudicator"
  let helmet_shaper = Id.make "helmet_shaper"
  let helmet_elder = Id.make "helmet_elder"
  let helmet_crusader = Id.make "helmet_crusader"
  let helmet_basilisk = Id.make "helmet_basilisk"
  let helmet_eyrie = Id.make "helmet_eyrie"
  let helmet_adjudicator = Id.make "helmet_adjudicator"
  let quiver_shaper = Id.make "quiver_shaper"
  let quiver_elder = Id.make "quiver_elder"
  let quiver_crusader = Id.make "quiver_crusader"
  let quiver_basilisk = Id.make "quiver_basilisk"
  let quiver_eyrie = Id.make "quiver_eyrie"
  let quiver_adjudicator = Id.make "quiver_adjudicator"
  let ring_shaper = Id.make "ring_shaper"
  let ring_elder = Id.make "ring_elder"
  let ring_crusader = Id.make "ring_crusader"
  let ring_basilisk = Id.make "ring_basilisk"
  let ring_eyrie = Id.make "ring_eyrie"
  let ring_adjudicator = Id.make "ring_adjudicator"
  let rune_dagger_shaper = Id.make "rune_dagger_shaper"
  let rune_dagger_elder = Id.make "rune_dagger_elder"
  let rune_dagger_crusader = Id.make "rune_dagger_crusader"
  let rune_dagger_basilisk = Id.make "rune_dagger_basilisk"
  let rune_dagger_eyrie = Id.make "rune_dagger_eyrie"
  let rune_dagger_adjudicator = Id.make "rune_dagger_adjudicator"
  let sceptre_shaper = Id.make "sceptre_shaper"
  let sceptre_elder = Id.make "sceptre_elder"
  let sceptre_crusader = Id.make "sceptre_crusader"
  let sceptre_basilisk = Id.make "sceptre_basilisk"
  let sceptre_eyrie = Id.make "sceptre_eyrie"
  let sceptre_adjudicator = Id.make "sceptre_adjudicator"
  let shield_shaper = Id.make "shield_shaper"
  let shield_elder = Id.make "shield_elder"
  let shield_crusader = Id.make "shield_crusader"
  let shield_basilisk = Id.make "shield_basilisk"
  let shield_eyrie = Id.make "shield_eyrie"
  let shield_adjudicator = Id.make "shield_adjudicator"
  let staff_shaper = Id.make "staff_shaper"
  let staff_elder = Id.make "staff_elder"
  let staff_crusader = Id.make "staff_crusader"
  let staff_basilisk = Id.make "staff_basilisk"
  let staff_eyrie = Id.make "staff_eyrie"
  let staff_adjudicator = Id.make "staff_adjudicator"
  let wand_shaper = Id.make "wand_shaper"
  let wand_elder = Id.make "wand_elder"
  let wand_crusader = Id.make "wand_crusader"
  let wand_basilisk = Id.make "wand_basilisk"
  let wand_eyrie = Id.make "wand_eyrie"
  let wand_adjudicator = Id.make "wand_adjudicator"
  let warstaff_shaper = Id.make "warstaff_shaper"
  let warstaff_elder = Id.make "warstaff_elder"
  let warstaff_crusader = Id.make "warstaff_crusader"
  let warstaff_basilisk = Id.make "warstaff_basilisk"
  let warstaff_eyrie = Id.make "warstaff_eyrie"
  let warstaff_adjudicator = Id.make "warstaff_adjudicator"

  let influence_map =
    let bindings = [
        _2h_axe_shaper, Shaper;
        _2h_axe_elder, Elder;
        _2h_axe_crusader, Crusader;
        _2h_axe_basilisk, Hunter;
        _2h_axe_eyrie, Redeemer;
        _2h_axe_adjudicator, Warlord;
        _2h_mace_shaper, Shaper;
        _2h_mace_elder, Elder;
        _2h_mace_crusader, Crusader;
        _2h_mace_basilisk, Hunter;
        _2h_mace_eyrie, Redeemer;
        _2h_mace_adjudicator, Warlord;
        _2h_sword_shaper, Shaper;
        _2h_sword_elder, Elder;
        _2h_sword_crusader, Crusader;
        _2h_sword_basilisk, Hunter;
        _2h_sword_eyrie, Redeemer;
        _2h_sword_adjudicator, Warlord;
        amulet_shaper, Shaper;
        amulet_elder, Elder;
        amulet_crusader, Crusader;
        amulet_basilisk, Hunter;
        amulet_eyrie, Redeemer;
        amulet_adjudicator, Warlord;
        axe_shaper, Shaper;
        axe_elder, Elder;
        axe_crusader, Crusader;
        axe_basilisk, Hunter;
        axe_eyrie, Redeemer;
        axe_adjudicator, Warlord;
        mace_shaper, Shaper;
        mace_elder, Elder;
        mace_crusader, Crusader;
        mace_basilisk, Hunter;
        mace_eyrie, Redeemer;
        mace_adjudicator, Warlord;
        sword_shaper, Shaper;
        sword_elder, Elder;
        sword_crusader, Crusader;
        sword_basilisk, Hunter;
        sword_eyrie, Redeemer;
        sword_adjudicator, Warlord;
        belt_shaper, Shaper;
        belt_elder, Elder;
        belt_crusader, Crusader;
        belt_basilisk, Hunter;
        belt_eyrie, Redeemer;
        belt_adjudicator, Warlord;
        body_armour_shaper, Shaper;
        body_armour_elder, Elder;
        body_armour_crusader, Crusader;
        body_armour_basilisk, Hunter;
        body_armour_eyrie, Redeemer;
        body_armour_adjudicator, Warlord;
        boots_shaper, Shaper;
        boots_elder, Elder;
        boots_crusader, Crusader;
        boots_basilisk, Hunter;
        boots_eyrie, Redeemer;
        boots_adjudicator, Warlord;
        bow_shaper, Shaper;
        bow_elder, Elder;
        bow_crusader, Crusader;
        bow_basilisk, Hunter;
        bow_eyrie, Redeemer;
        bow_adjudicator, Warlord;
        claw_shaper, Shaper;
        claw_elder, Elder;
        claw_crusader, Crusader;
        claw_basilisk, Hunter;
        claw_eyrie, Redeemer;
        claw_adjudicator, Warlord;
        dagger_shaper, Shaper;
        dagger_elder, Elder;
        dagger_crusader, Crusader;
        dagger_basilisk, Hunter;
        dagger_eyrie, Redeemer;
        dagger_adjudicator, Warlord;
        gloves_shaper, Shaper;
        gloves_elder, Elder;
        gloves_crusader, Crusader;
        gloves_basilisk, Hunter;
        gloves_eyrie, Redeemer;
        gloves_adjudicator, Warlord;
        helmet_shaper, Shaper;
        helmet_elder, Elder;
        helmet_crusader, Crusader;
        helmet_basilisk, Hunter;
        helmet_eyrie, Redeemer;
        helmet_adjudicator, Warlord;
        quiver_shaper, Shaper;
        quiver_elder, Elder;
        quiver_crusader, Crusader;
        quiver_basilisk, Hunter;
        quiver_eyrie, Redeemer;
        quiver_adjudicator, Warlord;
        ring_shaper, Shaper;
        ring_elder, Elder;
        ring_crusader, Crusader;
        ring_basilisk, Hunter;
        ring_eyrie, Redeemer;
        ring_adjudicator, Warlord;
        rune_dagger_shaper, Shaper;
        rune_dagger_elder, Elder;
        rune_dagger_crusader, Crusader;
        rune_dagger_basilisk, Hunter;
        rune_dagger_eyrie, Redeemer;
        rune_dagger_adjudicator, Warlord;
        sceptre_shaper, Shaper;
        sceptre_elder, Elder;
        sceptre_crusader, Crusader;
        sceptre_basilisk, Hunter;
        sceptre_eyrie, Redeemer;
        sceptre_adjudicator, Warlord;
        shield_shaper, Shaper;
        shield_elder, Elder;
        shield_crusader, Crusader;
        shield_basilisk, Hunter;
        shield_eyrie, Redeemer;
        shield_adjudicator, Warlord;
        staff_shaper, Shaper;
        staff_elder, Elder;
        staff_crusader, Crusader;
        staff_basilisk, Hunter;
        staff_eyrie, Redeemer;
        staff_adjudicator, Warlord;
        wand_shaper, Shaper;
        wand_elder, Elder;
        wand_crusader, Crusader;
        wand_basilisk, Hunter;
        wand_eyrie, Redeemer;
        wand_adjudicator, Warlord;
        warstaff_shaper, Shaper;
        warstaff_elder, Elder;
        warstaff_crusader, Crusader;
        warstaff_basilisk, Hunter;
        warstaff_eyrie, Redeemer;
        warstaff_adjudicator, Warlord;
      ]
    in
    List.fold_left
      (fun acc (id, infl) -> Id.Map.add id infl acc)
      Id.Map.empty
      bindings
end

let get_item_type_from_tags item_tags =
  let has tag = Id.Set.mem tag item_tags in
  if has Tag.axe then
    if has Tag.twohand then Two_hand_axe
    else One_hand_axe
  else if has Tag.mace then
    if has Tag.twohand then Two_hand_mace
    else One_hand_mace
  else if has Tag.sword then
    if has Tag.twohand then Two_hand_sword
    else One_hand_sword
  else if has Tag.amulet then Amulet
  else if has Tag.belt then Belt
  else if has Tag.body_armour then Body_armour
  else if has Tag.boots then Boots
  else if has Tag.bow then Bow
  else if has Tag.claw then Claw
  else if has Tag.dagger then Dagger
  else if has Tag.gloves then Gloves
  else if has Tag.helmet then Helmet
  else if has Tag.quiver then Quiver
  else if has Tag.ring then Ring
  else if has Tag.rune_dagger then
    if has Tag.attack_dagger then Dagger
    else Rune_dagger
  else if has Tag.sceptre then Sceptre
  else if has Tag.shield then Shield
  else if has Tag.staff then Staff
  else if has Tag.wand then Wand
  else if has Tag.warstaff then Warstaff
  else Other

let get_influence_tag_for_2h_axe = function
  | Shaper -> Tag._2h_axe_shaper
  | Elder -> Tag._2h_axe_elder
  | Crusader -> Tag._2h_axe_crusader
  | Hunter -> Tag._2h_axe_basilisk
  | Redeemer -> Tag._2h_axe_eyrie
  | Warlord -> Tag._2h_axe_adjudicator

let get_influence_tag_for_2h_mace = function
  | Shaper -> Tag._2h_mace_shaper
  | Elder -> Tag._2h_mace_elder
  | Crusader -> Tag._2h_mace_crusader
  | Hunter -> Tag._2h_mace_basilisk
  | Redeemer -> Tag._2h_mace_eyrie
  | Warlord -> Tag._2h_mace_adjudicator

let get_influence_tag_for_2h_sword = function
  | Shaper -> Tag._2h_sword_shaper
  | Elder -> Tag._2h_sword_elder
  | Crusader -> Tag._2h_sword_crusader
  | Hunter -> Tag._2h_sword_basilisk
  | Redeemer -> Tag._2h_sword_eyrie
  | Warlord -> Tag._2h_sword_adjudicator

let get_influence_tag_for_amulet = function
  | Shaper -> Tag.amulet_shaper
  | Elder -> Tag.amulet_elder
  | Crusader -> Tag.amulet_crusader
  | Hunter -> Tag.amulet_basilisk
  | Redeemer -> Tag.amulet_eyrie
  | Warlord -> Tag.amulet_adjudicator

let get_influence_tag_for_1h_axe = function
  | Shaper -> Tag.axe_shaper
  | Elder -> Tag.axe_elder
  | Crusader -> Tag.axe_crusader
  | Hunter -> Tag.axe_basilisk
  | Redeemer -> Tag.axe_eyrie
  | Warlord -> Tag.axe_adjudicator

let get_influence_tag_for_1h_mace = function
  | Shaper -> Tag.mace_shaper
  | Elder -> Tag.mace_elder
  | Crusader -> Tag.mace_crusader
  | Hunter -> Tag.mace_basilisk
  | Redeemer -> Tag.mace_eyrie
  | Warlord -> Tag.mace_adjudicator

let get_influence_tag_for_1h_sword = function
  | Shaper -> Tag.sword_shaper
  | Elder -> Tag.sword_elder
  | Crusader -> Tag.sword_crusader
  | Hunter -> Tag.sword_basilisk
  | Redeemer -> Tag.sword_eyrie
  | Warlord -> Tag.sword_adjudicator

let get_influence_tag_for_belt = function
  | Shaper -> Tag.belt_shaper
  | Elder -> Tag.belt_elder
  | Crusader -> Tag.belt_crusader
  | Hunter -> Tag.belt_basilisk
  | Redeemer -> Tag.belt_eyrie
  | Warlord -> Tag.belt_adjudicator

let get_influence_tag_for_body_armour = function
  | Shaper -> Tag.body_armour_shaper
  | Elder -> Tag.body_armour_elder
  | Crusader -> Tag.body_armour_crusader
  | Hunter -> Tag.body_armour_basilisk
  | Redeemer -> Tag.body_armour_eyrie
  | Warlord -> Tag.body_armour_adjudicator

let get_influence_tag_for_boots = function
  | Shaper -> Tag.boots_shaper
  | Elder -> Tag.boots_elder
  | Crusader -> Tag.boots_crusader
  | Hunter -> Tag.boots_basilisk
  | Redeemer -> Tag.boots_eyrie
  | Warlord -> Tag.boots_adjudicator

let get_influence_tag_for_bow = function
  | Shaper -> Tag.bow_shaper
  | Elder -> Tag.bow_elder
  | Crusader -> Tag.bow_crusader
  | Hunter -> Tag.bow_basilisk
  | Redeemer -> Tag.bow_eyrie
  | Warlord -> Tag.bow_adjudicator

let get_influence_tag_for_claw = function
  | Shaper -> Tag.claw_shaper
  | Elder -> Tag.claw_elder
  | Crusader -> Tag.claw_crusader
  | Hunter -> Tag.claw_basilisk
  | Redeemer -> Tag.claw_eyrie
  | Warlord -> Tag.claw_adjudicator

let get_influence_tag_for_dagger = function
  | Shaper -> Tag.dagger_shaper
  | Elder -> Tag.dagger_elder
  | Crusader -> Tag.dagger_crusader
  | Hunter -> Tag.dagger_basilisk
  | Redeemer -> Tag.dagger_eyrie
  | Warlord -> Tag.dagger_adjudicator

let get_influence_tag_for_gloves = function
  | Shaper -> Tag.gloves_shaper
  | Elder -> Tag.gloves_elder
  | Crusader -> Tag.gloves_crusader
  | Hunter -> Tag.gloves_basilisk
  | Redeemer -> Tag.gloves_eyrie
  | Warlord -> Tag.gloves_adjudicator

let get_influence_tag_for_helmet = function
  | Shaper -> Tag.helmet_shaper
  | Elder -> Tag.helmet_elder
  | Crusader -> Tag.helmet_crusader
  | Hunter -> Tag.helmet_basilisk
  | Redeemer -> Tag.helmet_eyrie
  | Warlord -> Tag.helmet_adjudicator

let get_influence_tag_for_quiver = function
  | Shaper -> Tag.quiver_shaper
  | Elder -> Tag.quiver_elder
  | Crusader -> Tag.quiver_crusader
  | Hunter -> Tag.quiver_basilisk
  | Redeemer -> Tag.quiver_eyrie
  | Warlord -> Tag.quiver_adjudicator

let get_influence_tag_for_ring = function
  | Shaper -> Tag.ring_shaper
  | Elder -> Tag.ring_elder
  | Crusader -> Tag.ring_crusader
  | Hunter -> Tag.ring_basilisk
  | Redeemer -> Tag.ring_eyrie
  | Warlord -> Tag.ring_adjudicator

let get_influence_tag_for_rune_dagger = function
  | Shaper -> Tag.rune_dagger_shaper
  | Elder -> Tag.rune_dagger_elder
  | Crusader -> Tag.rune_dagger_crusader
  | Hunter -> Tag.rune_dagger_basilisk
  | Redeemer -> Tag.rune_dagger_eyrie
  | Warlord -> Tag.rune_dagger_adjudicator

let get_influence_tag_for_sceptre = function
  | Shaper -> Tag.sceptre_shaper
  | Elder -> Tag.sceptre_elder
  | Crusader -> Tag.sceptre_crusader
  | Hunter -> Tag.sceptre_basilisk
  | Redeemer -> Tag.sceptre_eyrie
  | Warlord -> Tag.sceptre_adjudicator

let get_influence_tag_for_shield = function
  | Shaper -> Tag.shield_shaper
  | Elder -> Tag.shield_elder
  | Crusader -> Tag.shield_crusader
  | Hunter -> Tag.shield_basilisk
  | Redeemer -> Tag.shield_eyrie
  | Warlord -> Tag.shield_adjudicator

let get_influence_tag_for_staff = function
  | Shaper -> Tag.staff_shaper
  | Elder -> Tag.staff_elder
  | Crusader -> Tag.staff_crusader
  | Hunter -> Tag.staff_basilisk
  | Redeemer -> Tag.staff_eyrie
  | Warlord -> Tag.staff_adjudicator

let get_influence_tag_for_wand = function
  | Shaper -> Tag.wand_shaper
  | Elder -> Tag.wand_elder
  | Crusader -> Tag.wand_crusader
  | Hunter -> Tag.wand_basilisk
  | Redeemer -> Tag.wand_eyrie
  | Warlord -> Tag.wand_adjudicator

let get_influence_tag_for_warstaff = function
  | Shaper -> Tag.warstaff_shaper
  | Elder -> Tag.warstaff_elder
  | Crusader -> Tag.warstaff_crusader
  | Hunter -> Tag.warstaff_basilisk
  | Redeemer -> Tag.warstaff_eyrie
  | Warlord -> Tag.warstaff_adjudicator

let get_influence_tag item_type influence =
  match item_type with
    | Amulet -> Some (get_influence_tag_for_amulet influence)
    | Belt -> Some (get_influence_tag_for_belt influence)
    | Body_armour -> Some (get_influence_tag_for_body_armour influence)
    | Boots -> Some (get_influence_tag_for_boots influence)
    | Bow -> Some (get_influence_tag_for_bow influence)
    | Claw -> Some (get_influence_tag_for_claw influence)
    | Dagger -> Some (get_influence_tag_for_dagger influence)
    | Gloves -> Some (get_influence_tag_for_gloves influence)
    | Helmet -> Some (get_influence_tag_for_helmet influence)
    | One_hand_axe -> Some (get_influence_tag_for_1h_axe influence)
    | One_hand_mace -> Some (get_influence_tag_for_1h_mace influence)
    | One_hand_sword -> Some (get_influence_tag_for_1h_sword influence)
    | Quiver -> Some (get_influence_tag_for_quiver influence)
    | Ring -> Some (get_influence_tag_for_ring influence)
    | Rune_dagger -> Some (get_influence_tag_for_rune_dagger influence)
    | Sceptre -> Some (get_influence_tag_for_sceptre influence)
    | Shield -> Some (get_influence_tag_for_shield influence)
    | Staff -> Some (get_influence_tag_for_staff influence)
    | Thrusting_one_hand_sword -> Some (get_influence_tag_for_1h_sword influence)
    | Two_hand_axe -> Some (get_influence_tag_for_2h_axe influence)
    | Two_hand_mace -> Some (get_influence_tag_for_2h_mace influence)
    | Two_hand_sword -> Some (get_influence_tag_for_2h_sword influence)
    | Wand -> Some (get_influence_tag_for_wand influence)
    | Warstaff -> Some (get_influence_tag_for_warstaff influence)
    | Other -> None

let get_influence_tag_for_tags item_tags influence =
  get_influence_tag (get_item_type_from_tags item_tags) influence

let get_influence_from_spawn_weights spawn_weights =
  List.find_map
    (fun (tag, _) -> Id.Map.find_opt tag Tag.influence_map)
    spawn_weights

## Getting Started

These instructions assume you are using Linux.
If you want to use Kalandralang on Windows, you can have a look at
https://fdopen.github.io/opam-repository-mingw/ but you're on your own.

### Installation

#### Compile

Install [opam](http://opam.ocaml.org/).
Create an Opam switch if you didn't already, with:
```sh
opam switch create 4.13.1
```
Clone Kalandralang:
```sh
git clone https://github.com/doomeer/kalandralang
```
Ask Opam to build and install Kalandralang:
```sh
opam install kalandralang
```
This puts the executable in `~/.opam/4.13.1/bin/kalandralang`, so if you have
`~/.opam/4.13.1/bin` in your `PATH` (which is the case if you told the opam
installer to update your config files and if you restarted your terminal),
you can run Kalandralang with:
```sh
kalandralang
```
If this doesn't work, try running this instead:
```sh
~/.opam/4.13.1/bin/kalandralang
```
If this works but `kalandralang` doesn't, it means that you need to fix your `PATH`.

#### Setup a Working Directory

Kalandralang requires data files from the [RePoE](https://github.com/brather1ng/RePoE)
project to run. Those data files contain the list of base items, modifiers etc.
Kalandralang looks for those files in a `data` subdirectory of the current directory.

First, create a directory for Kalandralang somewhere and `cd` into it, for instance:
```sh
mkdir ~/kalandralang-recipes
cd ~/kalandralang-recipes
```
Then, create the `data` subdirectory and download data files into it:
```sh
mkdir data
cd data
wget https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/base_items.json
wget https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/mods.json
wget https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/stat_translations.json
wget https://raw.githubusercontent.com/brather1ng/RePoE/master/RePoE/data/essences.json
cd ..
```
You can now put your recipes in `~/kalandralang-recipes` if you want.
You can put them somewhere else, but since Kalandralang must be ran from this directory
to find data files, it will make it easier for you.

Note that the first time Kalandralang reads the data files (e.g. the first time you
run a recipe), it will create a file named `kalandralang.cache` with the same data
but in binary format instead of JSON. Using this makes Kalandralang load faster.
Once you have this cache, you can delete the JSON files in the `data` directory if you want.

### Usage

#### Command-Line Help

Run Kalandralang with `--help` for documentation of command-line parameters:
```sh
kalandralang --help
```
You can request help for a given subcommand, such as `run` or `find`:
```sh
kalandralang run --help
kalandralang find --help
```

#### Running a Recipe

Write a recipe in a file, such as `busted-vaal-regalia.kld`
(start from an [Example Recipe](#example-recipe)),
and ask `kalandralang` to run it:
```sh
kalandralang run busted-vaal-regalia.kld
```

#### Finding Identifiers

Recipes contain identifiers for base object types and modifiers.
There are multiple ways to find those identifiers.

##### Using the Find Command

You can use the `find` command to find them.

For instance, to find the identifier for the Agate Amulet base type:
```sh
kalandralang find agate
```
This tells you that the identifier is `"Metadata/Items/Amulets/Amulet9"`.
This is the internal name in Path of Exile data files.

To find the identifier for the +1 to Level of all Chaos Skill Gems:
```sh
kalandralang find 'level*chaos skill'
```
This finds all base types and modifiers that match pattern `level*chaos skill`,
where `*` can be anything. This gives two results:
- `"GlobalChaosGemLevelInfluence1__"`, the old Hunter (known as "basilisk" internally)
  influence mod which now has a spawn weight of 0 and thus cannot spawn anymore;
- `"GlobalChaosGemLevel1"`, the 3.17 non-influenced version of the mod.

##### Using the Show Mod Pool Instruction

To find the identifier for a modifier, you can also use the `show_mod_pool`
instruction (see [Show Mod Pool](#show-mod-pool)).
For instance, here is a recipe that shows all modifiers that can spawn on a
non-influenced Agate Amulet:
```sh
buy "Metadata/Items/Amulets/Amulet9"

# We want the item to have no modifier so that we see all modifiers that can spawn.
# Otherwise, we would not see modifiers that are blocked by existing modifiers.
# But we cannot just scour because no modifier can spawn on normal items.
# So we use annul until there is no modifier.
# Orbs of Annulments keep the item rare.
until no_prefix && no_suffix do annul
show_mod_pool
```

#### Generate Cost Data

Kalandralang reads the cost of currencies, harvest crafts etc. from file `data/costs.json`.
It is a good idea to regularly update this file.
See [Costs](#costs) for more information.

##### From poe.ninja

The following command uses [poe.ninja](https://poe.ninja)'s API
to generate file `data/costs.json` :
```sh
kalandralang write-ninja-costs
```
If you are from the future, you may need to specify the league name:
```sh
kalandralang write-ninja-costs Archnemesis
```
Note that `write-ninja-costs` uses default values for crafts that are not
listed on [poe.ninja](https://poe.ninja):
- [Harvest crafts](#harvest-crafting);
- [Betrayal crafts](#betrayal-crafting).

##### With Default Values

The following command generates file `data/costs.json` with default values:
```sh
kalandralang write-default-costs
```

## Example Recipe

### Code

Here is an example recipe to make a fire amulet.
You can also find the code in `examples/fire-amulet.kld`.
```sh
# This recipe produces Citrine Amulets with:
# - +1 to Level of All Fire Skill Gems
# - Life
# - Increased Fire Damage
# - Increased Cast Speed
# - Increased Spell Damage

# First, we buy a base.
#
# Citrine Amulet's internal name is "Metadata/Items/Amulets/Amulet10".
# To find this identifier, run: kalandralang find citrine
#
# We buy one with item level 84 for 1 chaos.
# Kalandralang will choose a random rare amulet for us.
buy "Metadata/Items/Amulets/Amulet10" ilvl 84 for 1 chaos

# Let's display the current item.
echo "Item we bought:"
show

# Then, we start working on the suffixes.
# We spam Deafening Essence of Zeal until the amulet has both the essence mod
# (i.e. Increased Cast Speed) and Tier 1 Increased Fire Damage.
#
# Increased Fire Damage's internal name is "FireDamagePercent5".
# To find this identifier, run: kalandralang find 'increased fire damage'
# This gives a lot of results; an alternative is to go to
# https://poedb.tw/us/Amulets#ModifiersCalc, click on the mod you are interested in,
# click on the "i" icon next to the tier you want, and copy-paste the Mod Id.
#
# "repeat" causes the instruction (here "essence_of_zeal") to always be executed
# at least once. This ensures that we do have the essence mod even if the amulet
# already had "FireDamagePercent5" when we bought it.
repeat essence_of_zeal until has "FireDamagePercent5"

# Let's display the current item.
echo "Item after essence spam:"
show

# Now that we are happy with our suffixes, we start working on our prefixes.
#
# We will use Harvest to augment fire.
# But first we need to make sure the amulet has two open prefixes:
# - one for the augment itself;
# - and one to craft Adds # to # Fire Damage to Attacks
#   to ensure the augment gives us +1 to Level of All Fire Skill Gems.
#
# Additionally, we take the opportunity to ensure that we have Increased Spell Damage
# on the amulet.
#
# To do that, we use Harvest to reforge keeping suffixes until there are
# two open prefixes (i.e. exactly 1 prefix), and Increased Spell Damage.
# The internal name for this modifier is:
# - "SpellDamage5" for Tier 1;
# - "SpellDamage4" for Tier 2.
# We are happy with Tier 2, but it doesn't mean we don't want Tier 1,
# so our stopping condition checks for both mods.
#
# "until" does not execute the instruction (here "harvest_reforge_keep_suffixes")
# if the condition already holds.
until prefix_count 1 and (has "SpellDamage5" or has "SpellDamage4") do {
  harvest_reforge_keep_suffixes
}

# Let's display the current item.
echo "Item after harvest reforges:"
show

# Let's craft Adds # to # Fire Damage to Attacks and augment fire to get
# our +1 to Level of All Fire Skill Gems.
craft "EinharMasterAddedFireDamage1"
harvest_augment_fire

# Finally, let's craft life and call it a day!
remove_crafted_mods
craft "EinharMasterIncreasedLife3"

# Let's say that we can sell this for 10 Exalted Orbs.
gain 10 exalt
```

### Run Once

Run this recipe with:
```sh
kalandralang run examples/fire-amulet.kld
```
Here is an example run:
```
Item we bought:
--------
Citrine Amulet (Rare)
--------
(prefix) +29 to maximum Life (IncreasedLife2)
(prefix) 20% increased maximum Energy Shield (IncreasedEnergyShieldPercent7)
(suffix) +24% to Global Critical Strike Multiplier (CriticalMultiplier3)
(suffix) +17% to Cold Resistance (ColdResist2)
--------
Paid up to now: 0.01ex (1c)
Item after essence spam:
--------
Citrine Amulet (Rare)
--------
(prefix) 0.73% of Physical Attack Damage Leeched as Life (LifeLeechPermyriad2)
(suffix) 25% increased Fire Damage (FireDamagePercent5)
(suffix) 18% increased Cast Speed (IncreasedCastSpeed4)
(suffix) +38% to Global Critical Strike Multiplier (CriticalMultiplier6)
--------
Paid up to now: 3.49ex (604c)
Item after harvest reforges:
--------
Citrine Amulet (Rare)
--------
(prefix) 18% increased Spell Damage (SpellDamage4)
(suffix) 24% increased Fire Damage (FireDamagePercent5)
(suffix) 18% increased Cast Speed (IncreasedCastSpeed4)
(suffix) +36% to Global Critical Strike Multiplier (CriticalMultiplier6)
--------
Paid up to now: 18.49ex (3198c)
--------
Citrine Amulet (Rare)
--------
(prefix) 18% increased Spell Damage (SpellDamage4)
(prefix) +1 to Level of all Fire Skill Gems (GlobalFireGemLevel1_)
(suffix) 23% increased Fire Damage (FireDamagePercent5)
(suffix) 18% increased Cast Speed (IncreasedCastSpeed4)
(suffix) +38% to Global Critical Strike Multiplier (CriticalMultiplier6)
(prefix) {crafted} +45 to maximum Life (EinharMasterIncreasedLife3)
--------
Cost:
     1 × chaos
    10 × harvest_reforge_keep_suffixes
     1 × remove_crafted_mods
   201 × essence_of_zeal
     1 × harvest_augment_fire
     1 × craft "EinharMasterAddedFireDamage1"
     1 × craft "EinharMasterIncreasedLife3"
Total: 28.50ex (4928c) — Profit: -18.50ex (-3198c)
```

### Run 100 Times

Run this recipe 100 times with:
```sh
kalandralang run examples/fire-amulet.kld -c 100
```
Kalandralang eventually tells us:
```
Average cost (out of 100):
     1.00 × chaos
    75.55 × harvest_reforge_keep_suffixes
     1.00 × remove_crafted_mods
   152.01 × essence_of_zeal
     1.00 × harvest_augment_fire
     1.00 × craft "EinharMasterAddedFireDamage1"
     1.00 × craft "EinharMasterIncreasedLife3"
Total: 125.97ex (21785c) — Profit: -115.97ex (-20055c)

     █                                                                          
   ▆ █                                                                          
   █ █ ▅   ▅                                                                    
 ▃ █ █ █  ▃█                                                                    
 █ █ █ █ ▂██                                                                    
 █ █ █ █ ███                                                                    
 █ █████ ███                                                                    
 █▆█████▆███                                                                    
 ███████████▅ ▅      ▅                                                          
 ████████████ █▃▃▃  ▃█▃ ▃                                                       
▂████████████ ████▂ ███ █▂▂    ▂                ▂                               
█████████████ █████ ███ ███    █                █                               
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
0ex                                                                       1000ex
```
It looks like this recipe is really not worth it!

It looks like hoping to get Increased Spell Damage
with Harvest reforge keeping suffixes is very costly. Using Harvest augment fire
to get +1 to Level of All Fire Skill Gems is also not cheap, maybe we should have
started with the prefixes by spamming Alteration Orbs. Can you improve the recipe
to make it less ambitious but also less catastrophic?

## Costs

To estimate the cost of each craft, Kalandralang needs to know the value
of currencies, harvest crafts etc. Kalandralang has default values for each of
those, but those values are unlikely to be very accurate as values change
a lot over time. You can customize those values by creating a file named
`costs.json` in the `data` directory that you set up in
[Setup a Working Directory](#setup-a-working-directory).

To customize costs, it is recommended to generate `data/costs.json`
using `write-default-costs` or `write-ninja-costs`
(see [Generate Cost Data](#generate-cost-data)).
You can then edit the values in this file manually.

This file is a [JSON](https://www.json.org) file composed of one JSON object.
The name of each field is usually a keyword corresponding to an instruction.
For instance, field `"exalt"` specifies the value of Exalted Orbs,
field `"harvest_reforge_life"` specifies the cost of the `harvest_reforge_life`
[instruction](#harvest-crafting), and field `"pristine"` specifies the value
of Pristine Fossils. For resonators, the fields are named
`"primitive_resonator"`, `"potent_resonator"`, `"powerful_resonator"`
and `"prime_resonator"`.

The value of each field is either:
- a number, specifying the value in Chaos Orbs;
- or an object, specifying the value in terms of the value of other instructions.

For instance, the following `costs.json` file:
```json
{
  "exalt": 150,
  "hunter_exalt": { "exalt": 1.5 }
}
```
specifies that the value of Exalted Orbs is 150 Chaos Orbs,
and that the value of Hunter Exalted Orbs is 1.5 Exalted Orbs (i.e. 225 Chaos Orbs).

You can specify multiple fields in values. The resulting value is the sum.
For instance:
```json
{
  "hunter_exalt": { "exalt": 1.5, "chaos": 10 }
}
```
specifies that the value of Hunter Exalted Orbs is 1.5 Exalted Orbs, plus 10 Chaos Orbs.

You cannot specify the value of Chaos Orbs themselves, but you can use them in
definitions of other values. Most of the time though you would just put a number
directly as Chaos Orb is the default unit.

If the value of a given instruction is not specified (i.e. does not appear in the
file or is defined as `null`), its default value is used.

## Language Reference

### General Syntax Rules

#### Comments

Comments start with character `#` and end at the end of lines.
For instance:
```sh
# This line is a comment
exalt # This is also a comment, but "exalt" isn't
```
Comments are ignored by the interpreter.
Use them to make your code more readable.

#### Keywords

Keywords are composed of lowercase letters (`a` to `z`) and underscores `_`.
They are predefined and correspond to language instructions.
Here are some examples:
- `harvest_reforge_life`;
- `chaos`;
- `while`.

#### Numbers

Numbers are sequences of digits (`0` to `9`), optionally prefixed by
a minus character `-` for negative numbers.
Examples:
- `0`;
- `1234`;
- `-9`.

#### Identifiers

Identifiers start and end with double quotes `"`.
For instance:
```sh
if has "GlobalSkillGemLevel1" then gain 15 exalt
```
In this example, `"GlobalSkillGemLevel1"` is the identifier for the
+1 to Level of all Chaos Skill Gems modifier.

See also [Finding Identifiers](#finding-identifiers).

#### Labels

Labels start with a period `.` which is followed by lowercase or uppercase
letters (`a` to `z` and `A` to `Z`), digits (`0` to `9`), and underscores `_`.
They are used to refer to a given position in the code, to be able to jump
to this position from other parts of the code.
Here are some examples:
- `.attempt_to_reforge_life`;
- `.fail_miserably_for_the_3rd_time_and_try_again`.

Well-chosen label names help to make the code more readable.

#### Symbols

The language uses the following symbol characters:
- parentheses `(` and `)` in condition expressions;
- braces `{` and `}` for blocks of instructions;
- colon `:` after label definitions;
- dash `-` (also known as "minus") for ranges of values.

#### Whitespace

In general, whitespace (blanks, tabs and newlines) is ignored.
Although you do have to separate keywords and numbers with whitespace
(for instance `abc` is one keyword, but `a bc` is two), and
newlines do matter to end comments.

### Computational Model

#### Program Point

Recipes are sequences of instructions. For instance:
```sh
transmute
regal
exalt
```
is a recipe composed of three instructions. The first one is to apply
an Orb of Transmutation, the second one is to apply a Regal Orb, and
the third one is to apply an Exalted Orb.

When executing a recipe, Kalandralang keeps track of the *program point*,
which is the next instruction to perform. At the very start, this is the
first instruction of the program. After each instruction, the program point
automatically moves on to the next instruction in the sequence, except
if the instruction which was just executed is a
[Control-Flow Instruction](#control-flow-instructions), in which case
it may move somewhere else.

#### Current Item

When executing a recipe, Kalandralang stores a *current item* in memory.
At the very start, there is no current item, so usually the first instruction
is to `buy` a base (see [Buying a Base](#buying-a-base)).
After that, each instruction can modify the
current item or replace it completely. For instance, `transmute` is an instruction
that applies an Orb of Transmutation on the current item.

Some instructions contain conditions. Those conditions are evaluated on the current item.
For instance, `no_suffix` is a condition that evaluates to `true` if the current
item has no suffix.

#### Set-Aside Item

When executing a recipe, Kalandralang stores a *set-aside item* in memory.
At the very start, there is no set-aside item.
Use the `set_aside` instruction to set the current item aside (see [Set Aside](#set-aside)).
Items can be set aside for [Awakener's Orb](#awakeners-orb) in particular.
Note that [Splitting](#split) an item replaces the set-aside item.

#### Current Imprint

When executing a recipe, Kalandralang stores a *current imprint* in memory.
At the very start, there is no current imprint.
Use the `beastcraft_imprint` instruction to make an imprint of the current item
(see [Imprint](#imprint)). Use the `use_imprint` instruction to restore the current
item to the current imprint (see [Use Imprint](#use-imprint)).

#### Spendings and Gains

When executing a recipe, Kalandralang counts how much you spend.
Each instruction can add to this number.
For instance, `exalt` adds one Exalted Orb to your spendings.
Kalandralang also counts how much you gain (see [Selling](#selling)).
At the end, Kalandralang can show total spendings and earnings.

#### Errors

It may be possible for instructions to fail.
For instance, `transmute` fails if the current item is not of normal rarity.
Failures cause the recipe to stop immediately with an error message.
If this happens, you should modify your recipe to ensure that it does
not try to perform invalid instructions. For instance, you could add an `if`
instruction before an `augment` to only perform the `augment` if the item
has an open prefix or an open suffix:
```sh
if open_prefix or open_suffix then augment
```

### Buying a Base

`buy [<influence>] [<influence>] <identifier> [ilvl <number>]
[with [fractured] <identifier>]* [for <amount>]`
is an instruction that sets or replaces the current item to a given base.
- `<influence>` are keywords that can be used to specify that the item has this influence.
  Zero, one or two influences can be specified.
  Influence keywords are: `shaper`, `elder`, `crusader`, `hunter`, `redeemer`, `warlord`,
  `exarch`, `eater`, `synthesized`.
- The first identifier is the base type, such as `"Metadata/Items/Amulets/Amulet9"`
  for Agate Amulets.
- `ilvl <number>` is optional and sets the item level. It defaults to 100.
  For instance, `ilvl 84` sets the item level to 84.
- `with <identifier>` constrains the item to have a given modifier, specified
  with the given identifier. For instance, `with "GlobalChaosGemLevel1"` specifies
  that the item must have +1 to Level of all Chaos Skill Gems. This parameter is
  repeatable.
- `with fractured <identifier>` is the same as `with <identifier>` but the modifier
  is fractured.
- `for <amount>` specifies the cost of the item.
  It causes the given [Amount](#amounts) to be added to your
  [Spendings](#spendings-and-gains). It defaults to zero.

Note that the base item will be rare, with 4 to 6 modifiers, following the
distribution of chaos orbs. If you specify one modifier, the item will have
3 to 5 other modifiers at random. If you specify two modifiers, the item will
have 2 to 4 other modifiers at random. Etc.

For instance, here is how to start from a random rare Agate Amulet of item level 100:
```sh
buy "Metadata/Items/Amulets/Amulet9"
```
Here is how to start from a normal rarity, hunter-influenced Agate Amulet of item level 86:
```sh
buy hunter "Metadata/Items/Amulets/Amulet9" ilvl 86
scour
```
Here is how to start from a random rare hunter and warlord-influenced Agate Amulet
of item level 100:
```sh
buy hunter warlord "Metadata/Items/Amulets/Amulet9"
```
Here is how to start from a rare ilvl 86 Agate Amulet with
fractured +1 to Level of all Chaos Skill Gems
and Tier 1 Dexterity (and some other random modifiers),
bought for 10 Chaos Orbs:
```sh
buy "Metadata/Items/Amulets/Amulet9"
  ilvl 86
  with fractured "GlobalChaosGemLevel1"
  with "Dexterity9"
  for 10 chaos
```
Note that `"Dexterity9"` is Tier 1, not Tier 9. This is how modifiers are named
internally in the game.

### Crafting Instructions

#### Currencies

The following keywords are instructions to apply currency to the current item.

##### Basic Currencies

| Keyword | Currency |
| --- | --- |
| `transmute` | Orb of Transmutation |
| `augment` | Orb of Augmentation |
| `alt` | Orb of Alteration |
| `regal` | Regal Orb |
| `alch` | Orb of Alchemy |
| `scour` | Orb of Scouring |
| `bless` | Blessed Orb |
| `chaos` | Chaos Orb |
| `annul` | Orb of Annulment |
| `exalt` | Exalted Orb |

##### Conqueror Exalted Orbs

| Keyword | Currency |
| --- | --- |
| `crusader_exalt` | Crusader Exalted Orb |
| `hunter_exalt` | Hunter Exalted Orb |
| `redeemer_exalt` | Redeemer Exalted Orb |
| `warlord_exalt` | Warlord Exalted Orb |

##### Eldritch Currencies

| Keyword | Currency |
| --- | --- |
| `lesser_ember` | Lesser Eldritch Ember |
| `greater_ember` | Greater Eldritch Ember |
| `grand_ember` | Grand Eldritch Ember |
| `exceptional_ember` | Exceptional Eldritch Ember |
| `lesser_ichor` | Lesser Eldritch Ichor |
| `greater_ichor` | Greater Eldritch Ichor |
| `grand_ichor` | Grand Eldritch Ichor |
| `exceptional_ichor` | Exceptional Eldritch Ichor |
| `eldritch_annul` | Eldritch Orb of Annulment |
| `eldritch_exalt` | Eldritch Exalted Orb |
| `eldritch_chaos` | Eldritch Chaos Orb |

##### Betrayal Currencies

| Keyword | Currency |
| --- | --- |
| `veiled_chaos` | Veiled Chaos Orb |

##### Awakener's Orb

The `awaken` instruction applies an Awakener's Orb on the
[Set-Aside Item](#set-aside-item) to destroy it and add its influence
to the [Current Item](#current-item). For instance, here is how to
destroy a hunter-influenced Agate Amulet to add hunter influence
to a warlord Marble Amulet:
```sh
buy hunter "Metadata/Items/Amulets/Amulet9"
  with "AdditionalPierceInfluence1"
set_aside
buy warlord "Metadata/Items/Amulet/AmuletAtlas2"
  with "AreaOfEffectInfluence3"
awaken
```
This usually results in a Marble Amulet with the hunter modifier
Projectiles Pierce an additional Target and the warlord modifier
#% increased Area of Effect. But as both items could have more
than one influenced modifier, this is not guaranteed.

#### Essences

The following keywords are instructions to apply an essence to the current item.

| Keyword | Essence |
| --- | --- |
| `essence_of_anger` | Deafening Essence of Anger |
| `essence_of_anguish` | Deafening Essence of Anguish |
| `essence_of_contempt` | Deafening Essence of Contempt |
| `essence_of_doubt` | Deafening Essence of Doubt |
| `essence_of_dread` | Deafening Essence of Dread |
| `essence_of_envy` | Deafening Essence of Envy |
| `essence_of_fear` | Deafening Essence of Fear |
| `essence_of_greed` | Deafening Essence of Greed |
| `essence_of_hatred` | Deafening Essence of Hatred |
| `essence_of_loathing` | Deafening Essence of Loathing |
| `essence_of_misery` | Deafening Essence of Misery |
| `essence_of_rage` | Deafening Essence of Rage |
| `essence_of_scorn` | Deafening Essence of Scorn |
| `essence_of_sorrow` | Deafening Essence of Sorrow |
| `essence_of_spite` | Deafening Essence of Spite |
| `essence_of_suffering` | Deafening Essence of Suffering |
| `essence_of_torment` | Deafening Essence of Torment |
| `essence_of_woe` | Deafening Essence of Woe |
| `essence_of_wrath` | Deafening Essence of Wrath |
| `essence_of_zeal` | Deafening Essence of Zeal |
| `essence_of_delirium` | Essence of Delirium |
| `essence_of_horror` | Essence of Horror |
| `essence_of_hysteria` | Essence of Hysteria |
| `essence_of_insanity` | Essence of Insanity |

#### Fossils

The following keywords are instructions to apply fossils to the current item.
To apply multiple fossils, separate those keywords with `+`.

| Keyword | Fossil |
| --- | --- |
| `aberrant` | Aberrant Fossil |
| `aetheric` | Aetheric Fossil |
| `bound` | Bound Fossil |
| `corroded` | Corroded Fossil |
| `dense` | Dense Fossil |
| `faceted` | Faceted Fossil |
| `frigid` | Frigid Fossil |
| `jagged` | Jagged Fossil |
| `lucent` | Lucent Fossil |
| `metallic` | Metallic Fossil |
| `prismatic` | Prismatic Fossil |
| `pristine` | Pristine Fossil |
| `scorched` | Scorched Fossil |
| `serrated` | Serrated Fossil |
| `shuddering` | Shuddering Fossil |
| `fundamental` | Fundamental Fossil |
| `deft` | Deft Fossil |

For instance:
```sh
pristine
```
applies a Primitive Resonator socketed with a Pristine Fossil.
```sh
dense + fundamental
```
applies a Potent Resonator socketed with a Dense Fossil and a Fundamental Fossil.
```sh
faceted + aetheric + prismatic
```
applies a Powerful Resonator socketed with a Faceted Fossil, an Aetheric Fossil
and a Prismatic Fossil.
```sh
metallic + lucent + jagged + deft
```
applies a Prime Resonator socketed with a Metallic Fossil, a Lucent Fossil, a Jagged Fossil
and a Deft Fossil.

#### Crafting Bench

##### Built-Ins

The following keywords are instructions to apply a specify crafting bench
operation on the current item using the crafting bench. All of them
add a given modifier, except `remove_crafted_mods` which removes all
crafted modifiers.

| Keyword | Modifier |
| --- | --- |
| `multimod` | Can have up to 3 crafted modifiers |
| `prefixes_cannot_be_changed` | Prefixes cannot be changed |
| `suffixes_cannot_be_changed` | Suffixes cannot be changed |
| `cannot_roll_attack_mods` | Cannot roll attack modifiers |
| `cannot_roll_caster_mods` | Cannot roll caster modifiers |
| `remove_crafted_mods` | Remove crafted mods |
| `craft_any_prefix` | Add a cheap modifier chosen arbitrarily from the list of available prefixes |
| `craft_any_suffix` | Add a cheap modifier chosen arbitrarily from the list of available suffixes |

Use `craft_any_prefix` and `craft_any_suffix` when you want to craft a modifier without
care for which one, for instance to add a third prefix or suffix to prevent an exalt or a
reforge from adding a prefix or a suffix.

##### Other Modifiers

To add another mod using the crafting bench, use the `craft <identifier>`
instruction. The identifier specifies which mod to add.
See [Finding Identifiers](#finding-identifiers) to find out which identifier to use.
For instance, to add Adds # to # Cold Damage (lowest tier), use:
```sh
craft "DexMasterAddedColdDamageCrafted1"
```
Note that this operation has a very low estimated cost. It is intended to be used
to block modifiers. You can use it to add meta-mods but the cost will not be estimated
correctly. For meta-mods, use [Built-In](#build-ins) crafting bench operations instead.

#### Harvest Crafting

The following keywords are instructions to perform harvest crafts on the current item.

| Keyword | Craft |
| --- | --- |
| `harvest_augment_attack` | **Augment** an item with a new **Attack** modifier |
| `harvest_augment_caster` | **Augment** an item with a new **Caster** modifier |
| `harvest_augment_chaos` | **Augment** an item with a new **Chaos** modifier |
| `harvest_augment_cold` | **Augment** an item with a new **Cold** modifier |
| `harvest_augment_critical` | **Augment** an item with a new **Critical** modifier |
| `harvest_augment_defences` | **Augment** an item with a new **Defences** modifier |
| `harvest_augment_fire` | **Augment** an item with a new **Fire** modifier |
| `harvest_augment_life` | **Augment** an item with a new **Life** modifier |
| `harvest_augment_lightning` | **Augment** an item with a new **Lightning** modifier |
| `harvest_augment_physical` | **Augment** an item with a new **Physical** modifier |
| `harvest_augment_speed` | **Augment** an item with a new **Speed** modifier |
| `harvest_non_attack_to_attack` | **Remove** a random **non-Attack** modifier from an item and add a new **Attack** modifier |
| `harvest_non_caster_to_caster` | **Remove** a random **non-Caster** modifier from an item and add a new **Attack** modifier |
| `harvest_non_chaos_to_chaos` | **Remove** a random **non-Chaos** modifier from an item and add a new **Attack** modifier |
| `harvest_non_cold_to_cold` | **Remove** a random **non-Cold** modifier from an item and add a new **Attack** modifier |
| `harvest_non_critical_to_critical` | **Remove** a random **non-Critical** modifier from an item and add a new **Attack** modifier |
| `harvest_non_defences_to_defences` | **Remove** a random **non-Defences** modifier from an item and add a new **Attack** modifier |
| `harvest_non_fire_to_fire` | **Remove** a random **non-Fire** modifier from an item and add a new **Attack** modifier |
| `harvest_non_life_to_life` | **Remove** a random **non-Life** modifier from an item and add a new **Attack** modifier |
| `harvest_non_lightning_to_lightning` | **Remove** a random **non-Lightning** modifier from an item and add a new **Attack** modifier |
| `harvest_non_physical_to_physical` | **Remove** a random **non-Physical** modifier from an item and add a new **Attack** modifier |
| `harvest_non_speed_to_speed` | **Remove** a random **non-Speed** modifier from an item and add a new **Attack** modifier |
| `harvest_reforge_attack` | **Reforge** an item as a rare item with random modifiers, including an **Attack** modifier |
| `harvest_reforge_caster` | **Reforge** an item as a rare item with random modifiers, including a **Caster** modifier |
| `harvest_reforge_chaos` | **Reforge** an item as a rare item with random modifiers, including a **Chaos** modifier |
| `harvest_reforge_cold` | **Reforge** an item as a rare item with random modifiers, including a **Cold** modifier |
| `harvest_reforge_critical` | **Reforge** an item as a rare item with random modifiers, including a **Critical** modifier |
| `harvest_reforge_defences` | **Reforge** an item as a rare item with random modifiers, including a **Defences** modifier |
| `harvest_reforge_fire` | **Reforge** an item as a rare item with random modifiers, including a **Fire** modifier |
| `harvest_reforge_life` | **Reforge** an item as a rare item with random modifiers, including a **Life** modifier |
| `harvest_reforge_lightning` | **Reforge** an item as a rare item with random modifiers, including a **Lightning** modifier |
| `harvest_reforge_physical` | **Reforge** an item as a rare item with random modifiers, including a **Physical** modifier |
| `harvest_reforge_speed` | **Reforge** an item as a rare item with random modifiers, including a **Speed** modifier |
| `harvest_reforge_keep_prefixes` | **Reforge** a rare item, keeping all **Prefixes** |
| `harvest_reforge_keep_suffixes` | **Reforge** a rare item, keeping all **Suffixes** |

#### Beastcrafting

The following keywords are instructions to perform beastcrafts on the current item.

| Keyword | Craft |
| --- | --- |
| `beastcraft_aspect_of_the_avian` | Add Aspect of the Avian |
| `beastcraft_aspect_of_the_cat` | Add Aspect of the Cat |
| `beastcraft_aspect_of_the_crab` | Add Aspect of the Crab |
| `beastcraft_aspect_of_the_spider` | Add Aspect of the Spider |
| `beastcraft_split` | See [Split](#split) |
| `beastcraft_imprint` | See [Imprint](#imprint) |

##### Split

`beastcraft_split` splits the current item into two items.
One of them becomes the [Current Item](#current-item),
the other becomes the [Set-Aside Item](#set-aside-item).

You can [Swap](#swap) the current item and the set-aside item
to access the second item created by a split.
For instance, to split an item that has +1 to Level of all Chaos Skill Gems
and set the current item to the item that kept this modifier:
```sh
beastcraft_split
if not has "GlobalChaosGemLevel1" then swap
```

##### Imprint

`beastcraft_imprint` sets the [Current Imprint](#current-imprint)
to an imprint of the current item.

The item can then be restored by [Using the Imprint](#use-imprint).
For instance, to try and add a suffix to an item which only has one prefix
which is +1 to Level of All Skill Gems:
```sh
.try_again:
  beastcraft_imprint
  regal
  if prefix_count 2 then {
    use_imprint
    goto .try_again
  }
```

#### Betrayal Crafting

The following keywords are instructions to perform crafting obtained
through the Immortal Syndicate on the current item.

| Keyword | Craft |
| --- | --- |
| `aisling` | Aisling T4: remove a random modifier and add a new veiled modifier |

#### Set Aside

The `set_aside` instruction sets the [Set-Aside Item](#set-aside-item) to the
[Current Item](#current-item), then sets the current item to no item.
You usually want to [buy](#buying-a-base) another item after that to get a new
current item. Then you usually want to use an [Awakener's Orb](#awakeners-orb).

#### Swap

The `swap` instructions exchanges the [Current Item](#current-item)
and the [Set-Aside Item](#set-aside-item). It is in particular useful
when [Splitting](#split) items.

#### Use Imprint

The `use_imprint` instruction sets the [Current Item](#current-item)
to the [Current Imprint](#current-imprint), and sets the current imprint to no imprint.

### Control-Flow Instructions

Interesting crafts are not linear: what to do after a given step often depends
on the state of the item. Kalandralang allows you to express [Conditions](#conditions)
and to jump to a different [Program Point](#program-point), expressed with the use
of a [Label](#labels), depending on whether the condition holds or not.

#### Blocks

Everywhere you can write an instruction, you can write a block of instructions instead.
A block is a sequence of instructions inside braces `{ ... }`.
For instance:
```sh
{
  prefixes_cannot_be_changed
  scour
}
```
is equivalent to:
```sh
prefixes_cannot_be_changed
scour
```

Typically, blocks are used in conditionals and loops. For instance:
```sh
if open_suffix then {
  prefixes_cannot_be_changed
  scour
}
```
is *not* equivalent to:
```sh
if open_suffix then
  prefixes_cannot_be_changed
  scour
```
The latter recipe applies an Orb of Scouring whether there was an open suffix or not,
which is probably not what is intended according to the indentation.

Blocks can have any number of instructions, including zero or one:
`{}` is a valid block which does nothing, and `{ alt }` is equivalent to `alt`.

#### Nesting Complex Instructions

Complex instructions are:
- [If Conditionals](#if-conditionals);
- [While Loops](#while-loops);
- [Until Loops](#while-loops);
- [Repeat Loops](#while-loops).

Complex instructions cannot be used directly inside other complex instructions.
They need to be put in a [Block](#blocks). For instance:
```sh
if open_suffix then
  if open_prefix then
    multimod
  else
    scour
```
will fail to parse. You should write this instead:
```sh
if open_suffix then {
  if open_prefix then
    multimod
  else
    scour
}
```

#### Label Definitions

A [Label](#labels) followed by a colon `:` gives a name to a program point to be able
to jump to it from anywhere else in the recipe. For instance:
```sh
.start:
```
defines a label named `.start`. You can put this label at the beginning of your recipe
to be able to jump to it later if you brick your item.

#### Goto

The `goto <label>` instruction sets the [Program Point](#program-point) to
the instruction that follows the given label's definition. For instance:
```sh
.chaos-spam:
  chaos
  goto .chaos-spam
```
creates an infinite loop of chaos spamming. This will in fact never end and you will
have to interrupt Kalandralang using Ctrl+C.

`goto` instructions can often be avoided using [If Conditionals](#if-conditionals)
and [Loops](#loops). In large programs, it is recommended to avoid them at all costs.
But crafting recipes are often small, and gotos can sometimes actually make the
recipe more readable.

#### Stop

The `stop` instruction sets the [Program Point](#program-point) to just after
the last instruction of the recipe. This effectively causes the run to stop immediately.
This is equivalent to putting a [Label](#labels) at the end and using
[Goto](#goto) to jump to it.

#### If Conditionals

`if <condition> then <instruction>` executes the given instruction, but only
if the condition holds. For instance:
```sh
if no_prefix then augment
```
causes an Orb of Augmentation to be applied on the current item if it has no prefix.

Another form of if conditionals is `if <condition> then <instruction> else <instruction>`.
It executes the `then` instruction if the condition holds, or the `else` instruction
if it doesn't. For instance:
```sh
if open_suffix then exalt else annul
```
causes an Exalted Orb to be applied on the current item if it has an open suffix,
and an Orb of Annulment it its suffixes are full.

#### Loops

##### While Loops

`while <condition> do <instruction>` executes the given instruction until the
given condition no longer holds. If the condition already does not hold
before the while loop, the instruction is not executed at all.
For instance:
```sh
while not has "GlobalChaosGemLevel1" do alt
```
is a recipe which spams Orbs of Alteration on the current item until the item
has +1 to Level of all Chaos Skill Gems. If the item already has this modifier
before the loop starts, no Orb of Alteration is used at all. It is equivalent to:
```sh
.loop:
  if has "GlobalChaosGemLevel1" then goto .stop
  alt
  goto .loop
.stop:
```

##### Until Loops

`until <condition> do <instruction>` executes the given instruction until the
given condition holds. If the condition already holds before the while loop,
the instruction is not executed at all.
For instance:
```sh
until has "GlobalChaosGemLevel1" do alt
```
is equivalent to:
```sh
while not has "GlobalChaosGemLevel1" do alt
```

##### Repeat Loops

`repeat <instruction> until <condition>` executes the given instruction until the
given condition holds. The instruction is always executed at least once.
For instance:
```sh
repeat alt until has "GlobalChaosGemLevel1"
```
is equivalent to:
```sh
alt
until has "GlobalChaosGemLevel1" do alt
```
and to:
```sh
.loop:
  alt
  if not has "GlobalChaosGemLevel1" then goto .loop
```

### Selling

`gain <amount>` causes the given [Amount](#amounts) to be added to your earnings.
It is typically used at the end of recipes to estimate profit margins.
For instance, let's say that you want to estimate whether spamming Orbs of Alteration
to get +1 to Level of all Chaos Skill Gems is more efficient than buying on the trade site,
assuming you can sell the result for 20 chaos:
```sh
buy "Metadata/Items/Amulets/Amulet9"
until has "GlobalChaosGemLevel1" alt
gain 20 chaos
```
Kalandralang will execute the recipe and display your spendings,
your earnings (here 20 Chaos Orbs), and the difference between the two.

This is not a very interesting example though because you can just add 20 chaos
from the spendings in your head. However, when combined with
[If Conditionals](#if-conditionals), you can tell Kalandralang that the selling
price depends on which mods the item has. For instance:
```sh
buy "Metadata/Items/Amulets/Amulet9"
until has "GlobalChaosGemLevel1" alt
gain 20 chaos
if has "Dexterity9" gain 30 chaos
```
The earnings of this recipe depend on whether the item ends up with Tier 1 Dexterity
or not. If it does end up with Tier 1 Dexterity, the earnings are 50 chaos.
Otherwise, they are 20 chaos.
This is particularly useful for recipes that can fail but for which the resulting
item is still sellable.

### Other Instructions

#### Echo

`echo <string>` causes Kalandralang to output the given string.
This is useful to know what is happening when debugging recipes,
or simply to comment on what is going on. For instance:
```sh
echo "Will now try to obtain a veiled mod through Aisling."
```

#### Show

`show` causes Kalandralang to output the current item and the total amount we spent up to now.
This is useful when debugging recipes, or simply to mark milestones in the recipe.
It can typically be preceded by `echo`, for instance:
```sh
echo "Prefixes are done:"
show
```

#### Show Mod Pool

`show_mod_pool` causes Kalandralang to output the mods that could be added to the
current item and the chance to add them when adding a single modifier (e.g. using
an Exalted Orb). This also shows the [Identifier](#identifiers) of each mod.

This does not show mods that are blocked by other existing modifiers.
If the suffixes are full, it will not show any suffix, and if the prefixes are full,
it will not show any prefix. In particular, if the item rarity is normal, this will
never show anything.

Example:
```sh
echo "Modifiers that can be added:"
show_mod_pool
```

### Amounts

Amounts are sequences of numbers followed by currencies.
More precisely, amounts are of the form `(<number> <currency>)*`.
For instance:
- `10 chaos` means 10 Chaos Orbs;
- `1 exalt 10 annul` means 1 Exalted Orb and 10 Orbs of Annulment.

All [Crafting Instructions](#crafting-instructions) can be used as currencies.
This includes [Currency](#currencies) instructions of course, but also
[Harvest Crafts](#harvest-crafting), [Beastcrafts](#beastcrafting),
[Betrayal Crafting](#betrayal-crafting), and all operations from the
[Crafting Bench](#crafting-bench). For instance, `1 harvest_augment_fire`
is a valid amount.

### Conditions

Conditions are expressions that can be used in [If Conditionals](#if-conditionals)
and [Loops](#loops).

#### Constants

The following keywords are conditions expressions:

| Keyword | Meaning |
| --- | --- |
| `true` | A condition which always holds |
| `false` | A condition which never holds |

#### Boolean Operators

The following operators can be used to combine conditions:

| Keyword | Usage | Meaning |
| --- | --- | --- |
| `not` | `not <condition>` | Negate a condition |
| `and` | `<condition> and <condition>` | Conjunction of two conditions: holds if both conditions hold |
| `or` | `<condition> or <condition>` | Disjunction of two conditions: holds if at least one of the two conditions hold |

#### Parentheses

`not` has higher precedence than `and`, which has higher precedence than `or`.
What this means is that the following expression:
```sh
not open_suffix or no_prefix and full_prefixes
```
Is equivalent to:
```sh
((not open_suffix) or (no_prefix and full_prefixes))
```

Parentheses `( ... )` can be used around any condition.
If operator precedence does not result in what you want, use parentheses.
For instance:
```sh
not ((open_suffix or no_prefix) and full_prefixes)
```
gives a completely different meaning to the expression.
If you don't understand precedence, just use parentheses everywhere!

#### Predicates on Current Item

The following expressions are conditions that hold depending on the current item.

| Keyword | Usage | Meaning |
| --- | --- | --- |
| `has` | `has <identifier>` | Holds if the item has the modifier denoted by the given identifier. |
| `prefix_count` | `prefix_count <number1>..<number2>` | Holds if the item has at least `<number1>` prefixes and at most `<number2>` prefixes. |
| | `prefix_count <number>` | Holds if the item has exactly the given number of prefix modifiers. Same as `prefix_count <number>..<number>`. |
| `no_prefix` | `no_prefix` | Holds if the item has no prefixes. Same as `prefix_count 0`. |
| `open_prefix` | `open_prefix` | Holds if the item has at least one open prefix. This is *not* equivalent to `prefix_count 0..2` as it depends on the item's rarity. |
| `full_prefixes` | `full_prefixes` | Holds if the item cannot have more prefixes. This is *not* equivalent to `prefix_count 3` as it depends on the item's rarity. |
| `suffix_count` | `suffix_count <number1>..<number2>` | Holds if the item has at least `<number1>` suffixes and at most `<number2>` suffixes. |
| | `suffix_count <number>` | Holds if the item has exactly the given number of suffix modifiers. Same as `suffix_count <number>..<number>`. |
| `no_suffix` | `no_suffix` | Holds if the item has no suffixes. Same as `suffix_count 0`. |
| `open_suffix` | `open_suffix` | Holds if the item has at least one open suffix. This is *not* equivalent to `suffix_count 0..2` as it depends on the item's rarity. |
| `full_suffixes` | `full_suffixes` | Holds if the item cannot have more suffixes. This is *not* equivalent to `suffix_count 3` as it depends on the item's rarity. |

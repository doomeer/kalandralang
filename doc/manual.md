## Getting Started

These instructions assume you are using Linux.
If you want to use Kalandralang on Windows, you can have a look at
https://fdopen.github.io/opam-repository-mingw/ but you're on your own.

### Installation

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

Once Kalandralang is installed, you probably want to:
- [Update Game Data](#update-game-data);
- [Update Cost Data](#update-cost-data).

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

#### Update Game Data

Kalandralang requires data files from the [repoe](https://github.com/repoe-fork/repoe)
project to run. Those data files contain the list of base items, modifiers etc.
Kalandralang looks for those files:
- on Linux: in `~/.kalandralang/data`;
- on other platforms: in `./data`.

Kalandralang can download those files for you; just run:
```
kalandralang update-data
```

You probably also want to [Update Cost Data](#update-cost-data).

#### Update Cost Data

Kalandralang reads the cost of currencies, harvest crafts etc. from file
`data/costs.json` (see [Update Game Data](#update-game-data)).  It is a
good idea to regularly update this file.  See [Costs](#costs) for more
information.

##### From poe.ninja and TFT

The following command uses [poe.ninja](https://poe.ninja)'s API
and reads from The Forbidden Trove's
[repository](https://github.com/The-Forbidden-Trove/tft-data-prices/tree/master/lsc)
to generate file `data/costs.json` :
```sh
kalandralang update-costs
```
If you are from the future, you may need to specify the league name:
```sh
kalandralang update-costs --ninja-league Keepers
```
You can also specify the folder to read from TFT's repository:
```
kalandralang update-costs --tft-league lsc
```

##### Use Default Values

The following command generates file `data/costs.json` with default values:
```sh
kalandralang write-default-costs
```
If for some reason `update-costs` does not work for you, you can use
`write-default-costs` to start with a base file that you can then edit manually
(see [Costs](#costs)).

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

## Example Recipe

### Code

Here is an example recipe to make a fire amulet.
It uses the old Harvest augments though, it would no longer work after Kalandra league.
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
(prefix) +29 to maximum Life
(prefix) 20% increased maximum Energy Shield
(suffix) +24% to Global Critical Strike Multiplier
(suffix) +17% to Cold Resistance
--------
Paid up to now: 0.01ex (1c)
Item after essence spam:
--------
Citrine Amulet (Rare)
--------
(prefix) 0.73% of Physical Attack Damage Leeched as Life
(suffix) 25% increased Fire Damage
(suffix) 18% increased Cast Speed
(suffix) +38% to Global Critical Strike Multiplier
--------
Paid up to now: 3.49ex (604c)
Item after harvest reforges:
--------
Citrine Amulet (Rare)
--------
(prefix) 18% increased Spell Damage
(suffix) 24% increased Fire Damage
(suffix) 18% increased Cast Speed
(suffix) +36% to Global Critical Strike Multiplier
--------
Paid up to now: 18.49ex (3198c)
--------
Citrine Amulet (Rare)
--------
(prefix) 18% increased Spell Damage
(prefix) +1 to Level of all Fire Skill Gems
(suffix) 23% increased Fire Damage
(suffix) 18% increased Cast Speed
(suffix) +38% to Global Critical Strike Multiplier
(prefix) {crafted} +45 to maximum Life
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
[Update Game Data](#update-game-data).

To customize costs, it is recommended to generate `data/costs.json`
using `write-default-costs` or `update-costs`
(see [Update Cost Data](#update-cost-data)).
You can then edit the values in this file manually.

This file is a [JSON](https://www.json.org) file composed of one JSON object.
The name of each field is usually a keyword corresponding to an instruction.
For instance, field `"exalt"` specifies the value of Exalted Orbs,
field `"harvest_reforge_life"` specifies the cost of the `harvest_reforge_life`
[instruction](#harvest-crafting), and field `"pristine"` specifies the value
of Pristine Fossils. For resonators, the fields are named
`"primitive_resonator"`, `"potent_resonator"`, `"powerful_resonator"`
and `"prime_resonator"`. The value of each field is the cost in Chaos Orbs.

For instance, the following `costs.json` file:
```json
{
  "exalt": 150,
  "hunter_exalt": 225
}
```
specifies that the value of Exalted Orbs is 150 Chaos Orbs,
and that the value of Hunter Exalted Orbs is 225 Chaos Orbs.

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
- `harvest_reforge_life`
- `chaos`
- `while`

#### Numbers

Numbers are sequences of digits (`0` to `9`), optionally prefixed by
a minus character `-` for negative numbers.
Examples:
- `0`
- `1234`
- `-9`

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
- `.attempt_to_reforge_life`
- `.fail_miserably_for_the_3rd_time_and_try_again`

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

#### Set-Aside Item Stack

When executing a recipe, Kalandralang stores a stack of *set-aside items* in memory.
At the very start, there is no set-aside item.
Use the `set_aside` instruction to set the current item aside (see [Set Aside](#set-aside)).
This pushes the current item on top of the stack.
It can then be used as input of an [Awakener's Orb](#awakeners-orb)
or a [Recombinator](#recombinators) in particular.
Note that [Splitting](#split) an item also pushes one of the two resulting items aside.

Since set-aside items form a stack, you can set-aside multiple items.
For instance, if you push one item A, then set-aside another item B,
item B will be on top of the stack, followed by item A. Using a recombinator for
instance will thus take item B and remove it from the stack. Item A is then
on top of the stack and can be used as input of another recombinator.

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

#### Assertions

To help with debugging of your programs you can add assertions.  These are
conditions that are checked at that specific point of the program and ensure
that the condition holds for *current item*.

For example, if you want to add a guaranteed suffix with an Exalted Orb and make
sure you will also have one open suffix afterwards (for bench crafting the last
suffix) you can add an assertion that will check for this condition.  Once you
implement the logic correctly, you can delete the assertion but it can stay
there in case you will update your program in the future.

To add an assertion, use `assert` keyword with a condition optionally followed
by `:` and a string error message.

``` sh
assert rare and full_prefixes and suffix_count = 1 : "Must have full prefixes and two open suffixes"
```

If the assertion fails, the program will exit with a failure.

Assertions are not used for controlling how your program crafts, only to check
the conditions of your current state inbetween instructions.  If you only want
to do an action if some condition holds, use [If
Conditionals](#if-conditionals).

### Buying a Base

`buy [exact] [<rarity>] [<influence>] [<influence>] <identifier> [ilvl <number>]
[with [fractured] <identifier>]* [for <amount>]`
is an instruction that sets or replaces the current item to a given base.
- `exact` disables automatic generation of random mods. Without it, additional modifiers
  are spawned as if the item was found on the ground.
- `<rarity>` can be `normal`, `magic` or `rare`. It specifies the rarity of the item.
  Default is maximum rarity (which may not be `rare`, e.g. for flasks it is `magic`).
- `<influence>` are keywords that can be used to specify that the item has this influence.
  Zero, one or two influences can be specified.
  Influence keywords are: `shaper`, `elder`, `crusader`, `hunter`, `redeemer`, `warlord`,
  `exarch`, `eater`, `synthesized`, `fractured`.
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

Here is how to start from a magic ring with Tier 1 Maximum Life and nothing else:
```
buy exact magic "Metadata/Items/Rings/Ring2" with "IncreasedLife7"
```

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
| `divine` | Divine Orb |
| `orb_of_dominance` | Orb of Dominance |
| `fracture` | Fracturing Orb |

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
| `veiled_chaos` | Veiled Chaos Orb (see also [Unveiling](#unveiling)) |

##### Awakener's Orb

The `awaken` instruction applies an Awakener's Orb on the item which is on top of the
[Set-Aside Item Stack](#set-aside-item-stack) to destroy it and add its influence
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

##### Recombinators (Sentinel league)

| Keyword | Currency |
| --- | --- |
| `armour_recombinator` | Armour Recombinator |
| `weapon_recombinator` | Weapon Recombinator |
| `jewellery_recombinator` | Jewellery Recombinator |
| `recombine` | Armour Recombinator, Weapon Recombinator, or Jewellery Recombinator (chosen according to the base type of the current item) |

All recombinator instructions recombine the [Current Item](#current-item) and the
item which is on top of the [Set-Aside Item Stack](#set-aside-item-stack) together.
Both item are deleted and the current item becomes the result of the recombination.

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
| `harvest_augment_attack` | **Augment** an item with a new **Attack** modifier, then remove a random modifier |
| `harvest_augment_caster` | **Augment** an item with a new **Caster** modifier, then remove a random modifier |
| `harvest_augment_chaos` | **Augment** an item with a new **Chaos** modifier, then remove a random modifier |
| `harvest_augment_cold` | **Augment** an item with a new **Cold** modifier, then remove a random modifier |
| `harvest_augment_critical` | **Augment** an item with a new **Critical** modifier, then remove a random modifier |
| `harvest_augment_defences` | **Augment** an item with a new **Defences** modifier, then remove a random modifier |
| `harvest_augment_fire` | **Augment** an item with a new **Fire** modifier, then remove a random modifier |
| `harvest_augment_life` | **Augment** an item with a new **Life** modifier, then remove a random modifier |
| `harvest_augment_lightning` | **Augment** an item with a new **Lightning** modifier, then remove a random modifier |
| `harvest_augment_physical` | **Augment** an item with a new **Physical** modifier, then remove a random modifier |
| `harvest_augment_speed` | **Augment** an item with a new **Speed** modifier, then remove a random modifier |
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
| `harvest_reforge_attack_more_common` | **Reforge** an item as a rare item with random modifiers, including an **Attack** modifier. Attack modifiers are more common |
| `harvest_reforge_caster_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Caster** modifier. Caster modifiers are more common |
| `harvest_reforge_chaos_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Chaos** modifier. Chaos modifiers are more common |
| `harvest_reforge_cold_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Cold** modifier. Cold modifiers are more common |
| `harvest_reforge_critical_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Critical** modifier. Critical modifiers are more common |
| `harvest_reforge_defences_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Defences** modifier. Defences modifiers are more common |
| `harvest_reforge_fire_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Fire** modifier. Fire modifiers are more common |
| `harvest_reforge_life_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Life** modifier. Life modifiers are more common |
| `harvest_reforge_lightning_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Lightning** modifier. Lightning modifiers are more common |
| `harvest_reforge_physical_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Physical** modifier. Physical modifiers are more common |
| `harvest_reforge_speed_more_common` | **Reforge** an item as a rare item with random modifiers, including a **Speed** modifier. Speed modifiers are more common |
| `harvest_reforge_keep_prefixes` | **Reforge** a rare item, keeping all **Prefixes** |
| `harvest_reforge_keep_suffixes` | **Reforge** a rare item, keeping all **Suffixes** |
| `harvest_reforge_more_likely` | **Reforge** a rare item, being much **more likely** to receive the same modifier types |
| `harvest_reforge_less_likely` | **Reforge** a rare item, being much **less likely** to receive the same modifier types |

#### Beastcrafting

The following keywords are instructions to perform beastcrafts on the current item.

| Keyword                               | Craft                                 |
|---------------------------------------|---------------------------------------|
| `beastcraft_aspect_of_the_avian`      | Add Aspect of the Avian               |
| `beastcraft_aspect_of_the_cat`        | Add Aspect of the Cat                 |
| `beastcraft_aspect_of_the_crab`       | Add Aspect of the Crab                |
| `beastcraft_aspect_of_the_spider`     | Add Aspect of the Spider              |
| `beastcraft_add_prefix_remove_suffix` | Add prefix and remove a random suffix |
| `beastcraft_add_suffix_remove_prefix` | Add suffix and remove a random prefix |
| `beastcraft_split`                    | See [Split](#split)                   |
| `beastcraft_imprint`                  | See [Imprint](#imprint)               |

##### Split

`beastcraft_split` splits the current item into two items.
One of them becomes the [Current Item](#current-item),
the other is pushed on top of the [Set-Aside Item Stack](#set-aside-item-stack).

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
| `aisling` | Aisling T4: remove a random modifier and add a new veiled modifier (deprecated, use [Veiled Exalted Orb](#betrayal-currencies))|

##### Unveiling

`unveil <mods> [else <instruction>]` is an instruction that unveils an item with
a veiled modifier. `<mods>` is a list of modifier identifiers separated by `or`.
The [Show Unveil Mod Pool](#show-unveil-mod-pool) instruction can be used to easily
get the identifiers for the modifiers you want to unveil.
If the first modifier in `<mods>` has been unveiled, it is chosen.
Else, if the second modifier in this list has been unveiled, it is chosen.
And so on. The optional `else` branch is executed if none of the modifiers were unveiled
and another modifier had to be chosen instead.

For instance, here is how to try to unveil life on an amulet:
```sh
buy "Metadata/Items/Amulets/Amulet9"
veiled_chaos
unveil "JunMasterVeiledBaseLifeAndManaRegen_"
```
Here is how to try to unveil life or area damage or projectile damage, in this order
of priority:
```sh
buy "Metadata/Items/Amulets/Amulet9"
veiled_chaos
unveil
  "JunMasterVeiledBaseLifeAndManaRegen_" or
  "JunMasterVeiledAreaDamageAndAreaOfEffect" or
  "JunMasterVeiledProjectileDamageAndProjectileSpeed"
```
Finally, here is how to unveil life or try again:
```sh
  buy "Metadata/Items/Amulets/Amulet9"
.try_again:
  veiled_chaos
  unveil "JunMasterVeiledBaseLifeAndManaRegen_" else goto .try_again
```
This is equivalent to using an `if` as follows:
```sh
  buy "Metadata/Items/Amulets/Amulet9"
.try_again:
  veiled_chaos
  unveil "JunMasterVeiledBaseLifeAndManaRegen_"
  if not has "JunMasterVeiledBaseLifeAndManaRegen_" then goto .try_again
```

#### Set Aside

The `set_aside` instruction pushes the [Current Item](#current-item) on top of
the [Set-Aside Item Stack](#set-aside-item-stack),
then sets the current item to no item.
You usually want to [buy](#buying-a-base) another item after that to get a new
current item. Then you usually want to use an [Awakener's Orb](#awakeners-orb)
or a [Recombinator](#recombinators).

#### Swap

The `swap` instructions exchanges the [Current Item](#current-item)
and the item on top of the [Set-Aside Item Stack](#set-aside-item-stack).
It is in particular useful when [Splitting](#split) items.

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

#### Show Unveil Mod Pool

`show_unveil_mod_pool` causes Kalandralang to output the mods that could be unveiled
on the current item. This also shows the [Identifier](#identifiers) of each mod.

This does not show mods that are blocked by other existing modifiers.
It requires a veiled mod to be present and it only shows prefixes or suffixes, depending
on whether the veiled mod is a prefix or suffix.

Example:
```sh
veiled_chaos
echo "Modifiers that can be unveiled:"
show_unveil_mod_pool
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

#### Parentheses in Conditions

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
| `has_mod` | `has_mod <identifier>` | Holds if the item has the modifier denoted by the given identifier. |
| `has_mod fractured` | `has_mod fractured <identifier>` | Holds if the item has the modifier denoted by the given identifier and this modifier is fractured. |
| `has_group` | `has_group <identifier>` | Holds if the item has a modifier from the modifier group denoted by the given identifier. |
| `has_group fractured` | `has_group fractured <identifier>` | Holds if the item has a modifier from the modifier group denoted by the given identifier and this modifier is fractured. |
| `has` | `has <identifier>` | Equivalent to `has_mod <identifier> or has_group <identifier>`. |
| `has fractured` | `has fractured <identifier>` | Equivalent to `has_mod fractured <identifier> or has_group fractured <identifier>`. |
| `is_base` | `is_base <identifier>` | Holds if the base type of the item is `<identifier>`. |
| `open_prefix` | `open_prefix` | Holds if the item has at least one open prefix. This is *not* equivalent to `prefix_count 0..2` as it depends on the item's rarity. |
| `full_prefixes` | `full_prefixes` | Holds if the item cannot have more prefixes. This is *not* equivalent to `prefix_count 3` as it depends on the item's rarity. |
| `open_suffix` | `open_suffix` | Holds if the item has at least one open suffix. This is *not* equivalent to `suffix_count 0..2` as it depends on the item's rarity. |
| `full_suffixes` | `full_suffixes` | Holds if the item cannot have more suffixes. This is *not* equivalent to `suffix_count 3` as it depends on the item's rarity. |
| `open_affix` | `open_affix` | Holds if the item has at least one open prefix or suffix. This is *not* equivalent to `affix_count 0..5` as it depends on the item's rarity. |
| `full_affixes` | `full_affixes` | Holds if the item can have neither more prefixes nor more suffixes. This is *not* equivalent to `affix_count 6` as it depends on the item's rarity. |
| `normal` | `normal` | Holds if the item has normal rarity. |
| `magic` | `magic` | Holds if the item is magic. |
| `rare` | `rare` | Holds if the item is rare. |
| `shaper` | `shaper` | Holds if the item has Shaper influence. |
| `elder` | `elder` | Holds if the item has Elder influence. |
| `crusader` | `crusader` | Holds if the item has Crusader influence. |
| `hunter` | `hunter` | Holds if the item has Hunter influence. |
| `redeemer` | `redeemer` | Holds if the item has Redeemer influence. |
| `warlord` | `warlord` | Holds if the item has Warlord influence. |
| `exarch` | `exarch` | Holds if the item has Searing Exarch influence. |
| `eater` | `eater` | Holds if the item has Eater of Worlds influence. |
| `synthesized` | `synthesized` | Holds if the item is synthesized. |
| `fractured` | `fractured` | Holds if the item is fractured. |

The following expressions are deprecated and may be removed in future versions,
use [Comparisons](#comparisons) on [Item Properties](#item-properties) instead:

| Keyword | Usage | Meaning |
| --- | --- | --- |
| `prefix_count` | `prefix_count <number1>..<number2>` | Same as `<number1> <= prefix_count <= <number2>`. |
| | `prefix_count <number>` | Same as `prefix_count = <number>`. |
| `no_prefix` | `no_prefix` | Same as `prefix_count = 0`. |
| `suffix_count` | `suffix_count <number1>..<number2>` | Same as `<number1> <= suffix_count <= <number2>`. |
| | `suffix_count <number>` | Same as `suffix_count = <number>`. |
| `no_suffix` | `no_suffix` | Same as `suffix_count = 0`. |
| `affix_count` | `affix_count <number1>..<number2>` | Same as `<number1> <= affix_count <= <number2>`. |
| | `affix_count <number>` | Same as `affix_count = <number>`. |
| `no_affix` | `no_affix` | Same as `affix_count = 0`. |

#### Comparisons

The following expressions allow to compare the result of
[Arithmetic Expressions](#arithmetic-expressions) together.

| Operator | Usage | Meaning |
| --- | --- | --- |
| `=` | `<expr1> = <expr2>` | `<expr1>` is equal to `<expr2>` |
| `<>` | `<expr1> <> <expr2>` | `<expr1>` is not equal to `<expr2>` |
| `<` | `<expr1> < <expr2>` | `<expr1>` is smaller than `<expr2>` |
| `<=` | `<expr1> <= <expr2>` | `<expr1>` is smaller than, or equal to `<expr2>` |
| `>` | `<expr1> > <expr2>` | `<expr1>` is greater than `<expr2>` |
| `>=` | `<expr1> >= <expr2>` | `<expr1>` is greater than, or equal to `<expr2>` |

You can also write double comparisons `<expr1> <operator1> <expr2> <operator2> <expr3>`.
Those are equivalent to `<expr1> <operator1> <expr2> and <expr2> <operator2> <expr3>`.
For instance:
```
1 <= prefix_count <= 3
```
is a condition that holds if the current item has between 1 and 3 prefixes.

### Arithmetic Expressions

Arithmetic expressions are expressions that evaluate into numbers.
They can be used in [Comparisons](#comparisons).

#### Constants

Integer constants are sequences of digits (`0` to `9`).
Negative numbers are prefixed by a minus character (`-`).
For instance, `1234`, `01` and `-32` are integer constants.

#### Operators

The following expressions allow to perform arithmetic operations on
arithmetic expressions.

| Operator | Usage | Meaning |
| --- | --- | --- |
| `-` (unary) | `- <expr1>` | Negation of `<expr1>` |
| `+` | `<expr1> + <expr2>` | Addition of `<expr1>` and `<expr2>` |
| `-` (binary) | `<expr1> - <expr2>` | Subtraction of `<expr1>` and `<expr2>` |
| `*` | `<expr1> * <expr2>` | Multiplication of `<expr1>` and `<expr2>` |
| `/` | `<expr1> / <expr2>` | Division of `<expr1>` by `<expr2>` |

#### Parentheses in Arithmetic Expressions

Operators follow the usual precedence rules:
`*` and `/` have higher precedence than `+` and `-` (binary).
`-` (unary) have the highest precedence.
All operators are left-associative.

Parentheses `( ... )` can be used around any arithmetic expression.

See also [Parentheses in Conditions](#parentheses-in-conditions).

#### Item Properties

The following expressions allow to get numeric properties from the current item.

| Keyword | Usage | Meaning |
| --- | --- | --- |
| `prefix_count` | `prefix_count` | Evaluates to the number of prefixes the current item has. |
| `suffix_count` | `suffix_count` | Evaluates to the number of suffixes the current item has. |
| `affix_count` | `affix_count` | Evaluates to the number of affixes (prefixes + suffixes) the current item has. |
| `tier` | `tier <mod_group>` | See [Modifier Tiers](#modifier-tiers). |

##### Modifier Groups

Mod groups are [Identifiers](#identifiers) that are shared by several modifiers.
For instance, all modifiers that add Strength are part of mod group `"Strength"`.
The [Find Command](#finding-identifiers) can tell you the mod group of modifiers.

Items can only ever have one modifier from a mod group. You can use this to
block certain modifiers from appearing on the item when crafting, for example
bench crafting mana modifier to prevent Exalted Orb from adding explicit mana
prefix.

The [Find Command](#finding-identifiers) can tell you the mod group of
modifiers. You can also search only for modifiers from a certain group by using
the `--group` option.

##### Modifier Tiers

Mod types are [Identifiers](#identifiers) that are shared by several modifiers
of the same "type".  For instance, all modifiers that add fire resistance (and
only fire resistance) are part of mod type `"FireResistance"` and have ids like
`"FireResist1"`.  They are also part of the mod group called
`"FireResistance"`.

But the temple modifier which adds fire resistance and also added fire damage
against burning enemies is of type `"FireResistanceAilments"` and its id is
`"FireResistEnhancedModAilments"` while still being in the mod group
`"FireResistance"` so they can't both appear on the same item.

The [Find Command](#finding-identifiers) can tell you the mod type of
modifiers. You can also search only for modifiers from a certain group by using
the `--mod-type` option.

If the current item has a modifier of type `<mod_type>`, expression `tier
<mod_type>` evaluates to the tier that this modifier has in this set of
modifiers.  If the current item has no modifier of this type, this expression
evaluates to 999.

For instance, if the item has the best possible Strength modifier that can spawn
on the current item, `tier "Strength"` evaluates to 1.
If the item has the second best possible Strength modifier,
this expression evaluates to 2, and so on.

Note that tiers depend on the item. For instance, the best +#-# to Maximum Life
modifier is not the same modifier for Body Armours and for Gloves.
Tier 1 Life on Gloves adds 80 to 89 Life, while this mod is only Tier 5 on
Body Armours.

For instance, here is how to chaos spam an item until it has three attribute
modifiers, either Tier 1 + Tier 1 + Tier 4 or better,
or Tier 1 + Tier 2 + Tier 3 or better,
or Tier 2 + Tier 2 + Tier 2 or better:
```
until
  tier "Dexterity" +
  tier "Intelligence" +
  tier "Strength" <= 6
do
  chaos
```

#### Converting Condition to Arithmetic Expressions

Brackets `[ ... ]` convert [Conditions](#conditions) to arithmetic expressions.
If the condition inside the brackets holds, the arithmetic expression evaluates
to `1`. Else, it evaluates to `0`.

For instance:
```
buy "Metadata/Items/Amulets/Amulet9"
until
  [tier "Intelligence" <= 3] +
  [tier "Dexterity" <= 3] +
  [tier "Strength" <= 3]
  >= 2
do chaos
```
is a recipe that uses Chaos Orbs on an Agate Amulet
until it has at least two attribute modifiers, both of them tier 3 or better.

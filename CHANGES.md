# Kalandralang Changelog

## Next Release

### Eldritch Crafting

- Added Eldritch currencies: Eldritch Ichors, Eldritch Embers, Eldritch Orbs of Annulment,
  Eldritch Exalted Orbs, and Eldritch Chaos Orbs. As a side-effect, I now know
  how to write "Eldritch".

- You can now specify that your base item has Eldritch influence(s).

### Betrayal Crafting

- Added instruction `show_unveil_mod_pool` which outputs the list of mods that
  can be unveiled on the current item.

- Added instruction `unveil`, which allows you to unveil an item by specifying
  which mods to select in priority.

### Fetching Costs

- Command `write-ninja-costs` has been renamed to `update-costs`.

- `update-costs` now also fetches Harvest and Aisling costs
  from The Forbidden Trove's repository.

- The `tls` dependency is now mandatory. This should fix the
  "no SSL or TLS support compiled into Conduit" error.

- You can no longer specify costs as sums of other currencies in `costs.json`.
  This was already not very useful and is even less useful now that `update-costs`
  fetches all costs. And it would have been more code to maintain.

### Beastcrafting

- Fixed interaction between imprints and splits.
  You can now imprint split items.
  However you cannot use an imprint to revert a split item to a non-split version.
  (Contributed by AR-234.)

- Item splitting now requires the current item to be rare.
  (Contributed by AR-234.)

- Item splitting now requires the current item to have at least two modifiers.

- Item splitting now always puts at least one modifier on each item.

### Harvest Crafting

- Added Harvest crafts: reforge more likely, reforge less likely
  and reforge more common for all tags.

### Command-Line Interface

- Added command-line option `--show-seed`.
  The seed it gives you can be used with `--seed` to reproduce the run.

- Added options to configure the output: `--no-item`, `--no-cost`,
  `--no-total`, `--no-echo`, `--no-histogram`, `--short` (short-hand: `-s`),
  `--summary` (short-hand: `-S`).
  Run `kalandralang run --help` to see a description of these options.

- Added option `--show-time` to display total and average crafting time
  used by Kalandralang.
  (Contributed by AR-234.)

- Added option `--timeout` to tell Kalandralang to stop after a given amount of time.
  (Contributed by AR-234.)

- Added option `--loop` to tell Kalandralang to run the recipe forever
  (or until the given `--timeout` is reached or until you press Ctrl+C).
  (Contributed by AR-234.)

### Miscellaneous

- The default data directory on Linux is now ~/.kalandralang/data
  (instead of ./data).
  (Contributed by AR-234.)

- Added command `update-data` which downloads data from RePoE.
  It only downloads files if they have changed.
  Thanks to this command you do not have to download data yourself anymore.
  (Contributed by AR-234.)

- Added support for arithmetic operations.
  Those can involve affix counts and modifier tiers.
  For instance: `tier "Intelligence" <= 3` is a condition meaning
  that the item has at tier 3 intelligence or better.
  (With help from AR-234 and nebuchenazarr
  even though I'm not sure nebuchenazarr is aware of it.)

- `no_prefix`, `prefix_count N`, `prefix_count N..M`,
  `no_suffix`, `suffix_count N`, `suffix_count N..M`,
  `no_affix`, `affix_count N` and `affix_count N..M` are now deprecated.
  You can use the following instead:
  `prefix_count = 0`, `prefix_count = N`, `N <= prefix_count <= M`,
  `suffix_count = 0`, `suffix_count = N`, `N <= suffix_count <= M`,
  `affix_count = 0`, `affix_count = N` and `N <= affix_count <= M`
  which are instances of the more general arithmetic operation feature.

- Added support for flasks.
  (Contributed by AR-234.)

- Recipes are checked for errors before running.
  Errors are: `goto` to labels that do not exist; modifier identifiers that do
  not exist; modifier group identifiers that do not exist; base item identifiers
  that do not exist. Additionally, defining a label but not using it with `goto`
  causes a warning to be emitted.

- You can now specify that your base is synthesized.
  You cannot specify the implicits but Kalandralang will prevent you from using
  crafts that cannot be performed on synthesized items.

- Made the output of `show_mod_pool` slightly more pretty.

- Fixed an issue where some modifiers were incorrectly displayed, such as
  local physical damage increase modifiers displaying as "No physical damage".
  (Contributed by Olxinos.)

- Jewels now sometimes get 3 modifiers instead of always 4.
  (Contributed by Raphaël Rieu-Helft.)

- The chance to get 4, 5 or 6 modifiers has been updated to more accurately reflect
  past in-game experiments.
  (Contributed by Raphaël Rieu-Helft.)

- Significantly improved performance. Quick experiments show a 10× to 20× speedup
  depending on the recipe.

- Added predicates `affix_count`, `no_affix`, `open_affix` and `full_affixes`.
  (Contributed by AR-234.)

- You can no longer use an Awakener's Orb if both items have the same influence.
  (Contributed by AR-234.)

- Added predicates `has_mod <id>` and `has_group <id>`.
  Predicate `has_mod <id>` holds if the current item has a modifier with the given
  modifier identifier (i.e. the old behavior of `has`).
  Predicate `has_group <id>` holds if the current item has a modifier with the given
  modifier group identifier.
  Predicate `has <id>` is now equivalent to `has_mod <id> or has_group <id>`.

## Version 0.1.0

First released version.

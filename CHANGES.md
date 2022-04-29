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

- Added support for flasks.
  (Contributed by AR-234.)

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

## Version 0.1.0

First released version.

# Kalandralang Changelog

## Next Release

### Eldritch Crafting

- Added Eldritch currencies: Eldritch Ichors, Eldritch Embers, Eldritch Orbs of Annulment,
  Eldritch Exalted Orbs, and Eldritch Chaos Orbs. As a side-effect, I now know
  how to write "Eldritch".

- You can now specify that your base item has Eldritch influence(s).

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

### Miscellaneous

- You can now specify that your base is synthesized.
  You cannot specify the implicits but Kalandralang will prevent you from using
  crafts that cannot be performed on synthesized items.

- Added command-line option `--show-seed`.
  The seed it gives you can be used with `--seed` to reproduce the run.

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

## Version 0.1.0

First released version.

# Kalandralang

Kalandralang is a DSL (Domain-Specific programming Language) to express crafting
methods for Path of Exile, and an interpreter for this language.
The interpreter runs in the command-line. You give it a recipe source file and it
executes the recipe, showing you the final item and the total ingredient cost.
You can tell Kalandralang to execute the recipe multiple
times to get an idea of the average cost of the recipe. It even shows you
pretty graphs:

![Pretty Graph](doc/pretty-graph.png)

## Supported Operating Systems

Kalandralang runs on Linux. It may run on other platform, including Windows, but
no instructions are provided to get it to run on them; you're on your own.

## User Manual

The [Kalandralang User Manual](https://doomeer.github.io/kalandralang/doc/manual.html)
contains:
- [installation instructions](https://doomeer.github.io/kalandralang/doc/manual.html#installation);
- [usage instructions](https://doomeer.github.io/kalandralang/doc/manual.html#usage);
- an [example recipe](https://doomeer.github.io/kalandralang/doc/manual.html#example-recipe);
- and the full [language reference](https://doomeer.github.io/kalandralang/doc/manual.html#language-reference).

You can also find more examples in the
[examples](https://github.com/doomeer/kalandralang/tree/master/examples) directory.

## Features

Kalandralang supports:
- basic currencies;
- Eldricht currencies except Orb of Conflict;
- Awakener's Orb;
- essences;
- most fossils;
- the crafting bench;
- most relevant Harvest crafts;
- beastcrafting: imprinting and splitting items;
- Betrayal crafting: Aisling;
- unveiling;
- influenced items;
- synthesized items.

Kalandralang does not support in particular:
- Hollow and Sanctified Fossils;
- Orb of Dominance;
- cluster jewels;
- implicits other than Eldritch implicits;
- actual modifier values and currencies and crafts that affect those values
  (Blessed Orb, Divine Orb, Harvest rerolls, lucky Harvest reforges) — currently
  Kalandralang just displays a random value in the range of possible values;
- Orb of Conflict.

See also the [Changelog](CHANGES.md).

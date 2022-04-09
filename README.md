# Kalandralang

Kalandralang is a DSL (Domain-Specific programming Language) to express crafting
methods for Path of Exile, and an interpreter for this language.
The interpreter runs in the command-line. You give it a recipe source file and it
executes the recipe, showing you the final item and the total ingredient cost.
You can tell Kalandralang to execute the recipe multiple
times to get an idea of the average cost of the recipe. It even shows you
pretty graphs:
```
  █                                                                             
  █  ▇                                                                          
  █  █                                                                          
  █  █                                                                          
  █▅▅█                                                                          
  ████ ▄                                                                        
  ████ █ ▄  ▄                                                                   
  ████▃█ █▃▃█  ▃ ▃                                                              
  ██████ ████  █ █  ▂    ▂                                                      
  ██████ ████▁▁█▁█  █  ▁ █▁                                                     
 ▁██████▁█████████▁ █▁ █ ██▁       ▁▁ ▁▁   ▁      ▁     ▁   ▁                   
 ██████████████████ ██ █ ███       ██ ██   █      █     █   █                   
‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
0ex                                                                        500ex
```

## Supported Operating Systems

Kalandralang runs on Linux. It may run on other platform, including Windows, but
no instructions are provided to get it to run on them; you're on your own.

## User Manual

The [Kalandralang User Manual](doc/manual.html) contains:
- [installation instructions](doc/manual.html#installation);
- [usage instructions](doc/manual.html#usage);
- an [example recipe](doc/manual.html#example-recipe);
- and the full [language reference](doc/manual.html#language-reference).

You can also find more examples in the [examples](examples) directory.

## Features

Kalandralang supports:
- basic currencies;
- Awakener's Orb;
- essences;
- most fossils;
- the crafting bench;
- most relevant Harvest crafts;
- beastcrafting: imprinting and splitting items;
- Betrayal crafting: Aisling;
- influenced items.

Kalandralang does not support in particular:
- unveiling;
- Hollow and Sanctified Fossils;
- Orb of Dominance;
- Eldricht currencies;
- lucky Harvest crafts;
- "reforge more common" Harvest crafts;
- flasks (unless you like the idea of having rare flasks);
- synthesized items;
- implicits in general.

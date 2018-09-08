#  DungeonBuilder

A 2D dungeon maze builder written in Swift.

The code is based on the Perl and JavaScript versions written by [Donjon](https://donjon.bin.sh). The Perl and JavaScript versions can be found in the [Donjon directory](https://github.com/wolf81/DungeonBuilder/tree/master/Donjon) for reference.

## Features

- Dungeons of various sizes, from fine to collosal
- Rooms of various sizes, from small to collosal
- Rooms can be densely packed or scattered
- Corridors can be straight, curved or in between
- Optionally remove some or all dead-ends
- Dungeons can be created using various layouts, e.g. keep or hexagon
- Different types of doors are placed, e.g.: normal, trapped, locked, etc...
- Optionally use your own (random) number generator

## Usage

1. Add this project as a library to some other project.
2. Create an instance of `DungeonBuilder` and provide it with a `Configuration` and optionally your own number generator that conforms to `NumberGeneratable`.
3. Call the `build` method on your instance of `DungeonBuilder` to create a dungeon. A `Dungeon` will be returned.

By default a build-in seeded random number generator is used. This build-in random number generator is seeded with the name of the dungeon. This means that everytime the same name is used to build a dungeon, the same dungeon is re-created as long as the same `Configuration` is re-used as well.   

The `Dungeon` contains a 2-dimensional array of nodes. Each `Node` is an `OptionSet`. Use the various flags to see what the node represents.  E.g.: 

    if node.contains(.room) {
        // this node is a room
    } 
    
    if node.contains(.corridor) {
        // this node is a corridor
    }

Print the dungeon to see a simplified map in the debug console. For example when printing out a small sized dungeon, the output might look as follows:

    + + + + + + + + +   + + + + + + + + + + + + + Φ · · · · · · · · · · · ‼ +   + + + + +  
    Π   ⁑       +       +   ⁑                       · · · · · · · · · · ·   +           +  
    · · · · ·   + + + + + Π · · · · · · · · · · ·   · · · · · · · · · · · Φ + + + + + + +  
    · · · · ·               · · · · · · · · · · ·   · · · · · · · · · · ·               +  
    · · · · · Φ             · · · · · · · · · · · ‼ · · · · · · · · · · · Π · · · · ·   +  
    · · · · ·               · · · · · · · · · · ·   · · · · · 1 4 · · · ·   · · · · ·   +  
    · · · · · ‼             · · · · · 2 · · · · · ‡ · · · · · · · · · · · Π · · · · ·   +  
    · · 1 2 ·               · · · · · · · · · · ·   · · · · · · · · · · ·   · · · · ·   +  
    · · · · · Π · · · · ·   · · · · · · · · · · · Π · · · · · · · · · · · ‼ · · · · ·   +  
    · · · · ·   · · · · ·   · · · · · · · · · · ·   · · · · · · · · · · ·   · · 7 · ·   +  
    · · · · · ‼ · · 1 · · ‼ · · · · · · · · · · ·   · · · · · · · · · · ·   · · · · ·   +  
    · · · · ·   · · · · ·           Π       Π       ∩   Π   Π   ‼           · · · · ·   +  
    · · · · ·   · · · · ·           +       · · · · · · · · · · · · · ∩ + Π · · · · ·   +  
        ⁑       Π   Φ               +       · · · · · · · · · · · · ·   +   · · · · ·   +  
    + Π · · · · · · · · · · · Π + + +       · · · · · · · · · · · · ·   +   · · · · ·   +  
    +   · · · · · · · · · · ·               · · · · · · · · · · · · ·   +       Φ       +  
    +   · · · · · · · · · · ·   + + + + +   · · · · · · 6 · · · · · · Π + Π · · · · · ⁑ +  
    +   · · · · · · · · · · ·   +   +   +   · · · · · · · · · · · · ·   +   · · · · ·      
    + Π · · · · · · · · · · ·   +   +   + ⁑ · · · · · · · · · · · · · Φ +   · · · · · Π +  
    +   · · · · · 3 · · · · ·   +   +       · · · · · · · · · · · · ·   +   · · · · ·   +  
    + Φ · · · · · · · · · · ·   +   +       · · · · · · · · · · · · ·   +   · · · · · Π +  
    +   · · · · · · · · · · ·       +           ∩                       +   · · 8 · ·   +  
    +   · · · · · · · · · · · ∩ + + +       + + + + + + + + +       + + +   · · · · ·   +  
    +   · · · · · · · · · · ·               +               +       +       · · · · ·   +  
    +   · · · · · · · · · · ·               +               + + + + +   +   · · · · ·   +  
    +           ‼                           +                           +   · · · · ·   +  
    + + + + + + + + + + + + + + + + + + + + +   · · · · · · · · ·   + + +   · · · · ·   +  
                +                               · · · · · · · · ·   +   +       Φ       +  
    · · · · · Φ + + + + + + + + + + +           · · · · · · · · ·   +   +   + + + + + + +  
    · · · · ·               Π                   · · · · · · · · ·   +   +       +       +  
    · · · · · ∩ +       · · · · · · · · ·       · · · · 4 · · · · Π +   + + + + +       +  
    · · · · ·   +       · · · · · · · · ·       · · · · · · · · ·   +                   +  
    · · · · · ‡ +       · · · · 1 0 · · ·   + Π · · · · · · · · ·   + Π · · · · ·       +  
    · · 9 · ·           · · · · · · · · ·   +   · · · · · · · · ·   +   · · · · ·       +  
    · · · · ·           · · · · · · · · ·   +   · · · · · · · · ·   + ⁑ · · · · ·       +  
    · · · · ·               ‡               +       ⁑                   · · · · ·       +  
    · · · · ·           + + + + +   + + + + +   · · · · · · · · · · ·   · · 1 1 ·       +  
    · · · · ·           +       Π           +   · · · · · · · · · · ·   · · · · ·       +  
    · · · · ·           +   · · · · · · ·   + Π · · · · · · · · · · ·   · · · · ·       +  
    Φ   Π               +   · · · · · · ·   +   · · · · · 5 · · · · ·   · · · · ·       +  
    + + + + + + + + + + +   · · · 1 3 · · ‼ +   · · · · · · · · · · · Π · · · · ·       +  
    +                       · · · · · · ·       · · · · · · · · · · ·   ‡               +  
    + + + + + + + + + + +   · · · · · · ·       · · · · · · · · · · ·   + + + + + + + + +  

    ┌─── LEGEND ─────────────────────────────┐
    │ ·  roomspace  ∩  arch     ⁑  secret    │
    │ +  corridor   Π  door     ‼  trapped   │
    │               Φ  locked   ‡ portcullis │
    └────────────────────────────────────────┘

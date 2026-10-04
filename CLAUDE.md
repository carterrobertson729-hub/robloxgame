# Thrift store tycoon (Roblox) — project guide

This file is the full plan for the game, written from the design conversation Carter had with Claude before moving to Claude Code. Read it at the start of every session. When Carter makes a new decision or adds an idea, update this file in the same session so it stays the single source of truth.

## Who you're working with

- Carter owns the project and makes the design decisions. He adds ideas as the build goes along, so expect the plan to grow.
- Assume he is new to Roblox Studio and to coding. Explain each step in plain language, say where to click, and have him test after every step.
- He wants a high-quality game that lots of people will want to play, not a beginner-looking one. Hold the work to that bar (see "Quality bar").
- The goal is a published, public Roblox game.

## The game in one paragraph

The player runs a thrift resale business from one building. They go out and find clothes, bring them back, wash them in the back room, then choose to sell each piece in person in the store or online. Money buys workers who automate the jobs, better luck, better items, and decorations. Clothes are the focus. Cards and other collectibles are occasional bonus finds.

## Core loop

1. **Find**: search for all types of clothes. Each piece rolls a brand, a rarity, and a condition.
2. **Wash**: clean the clothes on a washing machine in the back of the store.
3. **Choose where it sells**: each piece goes either onto a rack in the front of the store or gets listed online from the back.
4. **Sell**
   - In person: a customer picks it off the rack and pays at checkout.
   - Online: it is listed, sells after a wait, then gets packed and shipped.
5. **Spend**: workers, luck upgrades, better items and sourcing spots, decorations.

## Selling: online versus in person

This is a firm rule from Carter: online pays more but takes longer; in person sells faster but pays less.

| | In person | Online |
|---|---|---|
| Sale price | About 70% of the item's value | About 120% of the item's value |
| Time to sell | Seconds to a minute once a customer picks it up | Several minutes, longer for rarer items |
| Extra work | Checkout only | Listing, then packing and shipping |
| Best for | Common items, fast cash early | Rare pieces worth the wait |

The percentages and times are starting points to tune after playtesting. Keep them in one settings module, never scattered through scripts.

**Online marketplaces.** Carter wants parody versions of real resale sites, not the real names: an auction site (he suggested "eFay") and a resale app in the style of Depop. Final names are not chosen. Keep each name, logo, and color scheme clearly different from the real company; the further from the real name, the safer.

**Packing.** Packing an order well earns more money. The earlier design gave a bonus and a higher seller rating for good packing, with seller rating raising prices.

## The store

Everything happens in one building, a store with a warehouse-style back room. There is no apartment or separate home for now.

- **Front room**: clothing racks and a checkout counter for in-person customers.
- **Back room**: washing machines, a listing desk with a computer, and a packing table.

## Workers

Workers automate jobs the player first does by hand. Hiring the first one should feel like getting time back.

| Role | Job |
|---|---|
| Cashier | Checks customers out |
| Stocker | Moves clean clothes onto the racks |
| Washer | Runs the washing machines |
| Lister | Puts items online |
| Packer | Packs and ships orders |

- Each role comes in tiers. Cheap workers are slow; expensive workers are fast.
- The player can hire more than one of each role as the store grows.
- Staffing ties into the selling rule: a cashier speeds up the in-person side, listers and packers shorten the online wait.

## Items

- **Clothes are the main content.** All types of clothing, with invented brands, rarity tiers (five to start), and a condition.
- **Bonus finds are secondary.** Now and then the player finds a card pack, a plush, or a sealed collectible worth much more than the clothes around it. Carter prefers a monster-card style over sports cards.
- **Limited-edition items** that are only findable for a short time or during an event, in the style of things popular on TikTok, were part of Carter's first idea.

## Rules that must not be broken

- **No real brands, characters, or products.** Roblox takes games down for this. All clothing brands are invented lookalikes.
- **No Pokémon.** Carter asked for Pokémon cards; the answer is an original monster card line with its own names, art, packs, holos, and chase cards. Never use Pokémon names, characters, or card designs.
- **Don't copy Hit The Thrift's specifics** (see below). Same genre is fine; copied names, characters, and systems are not.
- Everything in the game is either made for this project or a free asset that is allowed to be used.

## The competitor: Hit The Thrift

A Roblox game by the group With Tag, launched August 2025. Players hunt through racks for rare clothes, wash them at a separate laundromat, and resell them to an NPC named Craig. Wearing finds earns Aura, which sets leaderboard rank and unlocks secret locations with limited pieces. Its brands are parodies of real ones. Guides say money is not really a problem in it, so its selling side is thin.

How this game is different:

- Selling is the heart of the game: two ways to sell with a real trade-off, plus packing and shipping.
- It is a store tycoon with hired workers, which Hit The Thrift is not.
- Progress is about growing the store and business, not outfits and Aura.
- Washing happens on the player's own machines in their back room, not as a trip to a laundromat.

Avoid: a title styled like theirs, a quest-giver like Craig, a laundromat trip, an Aura system.

## Build order

1. **Version 1 — everything by hand.** One sourcing spot, about 25 clothing items across five rarities, washing, both ways to sell, packing, one luck upgrade, and saving.
2. **Version 2 — workers.** Start with the washer and the cashier, then the rest.
3. **Version 3 — growth.** Decorations, more luck upgrades, more sourcing spots, bonus finds such as card packs.

Workers come second because they only automate jobs that already exist, so the jobs must work first. Build every stage with placeholder blocks, get it fun, then replace the blocks with real art.

## Current state

- **Workflow: Rojo + GitHub** (Carter's choice). Code lives in `src/`, synced into Studio. See `README.md` for setup. `tools/BuildStore.lua` is the Command Bar store builder (rewritten to the layout below; Carter has not run it yet).
- Built so far: `Settings`, `ItemData` (rarities, conditions, placeholder brands, 10 clothing types), server `ItemRoller`, `PlayerData` (DataStore with retry and no-overwrite-on-failed-load), `Main.server.lua`. Not yet tested in Studio.
- Built next: `FindService` (ProximityPrompt on the DonationBin, server rolls item, cooldown, bag limit), `FindReveal` client card. Re-run BuildStore to add the `DonationBin` (Station = Sourcing) outside the front door at Z = 10.
- Built after that: `Net` (remotes), `Sync` (cash+inventory to client), `WashService` (washer prompts, load up to 3 dirty items, collect after timer, saved in player data), client `Hud` (cash + Bag panel), `Notices`. Untested in Studio.
- Next: listing items, selling in person (racks + checkout), selling online.
- Open question for Carter: is the store private per player or shared by everyone in a server? Washer jobs are per-player for now.

- A starter script, `BuildStore.txt`, was written for the Studio Command Bar. Carter has the file. It has not been confirmed as run in Studio yet, so check before assuming the store exists.
- It was syntax-checked and its layout was tested against a stand-in for Studio, but never run in Studio itself.
- It builds `Workspace.Store` (a Model) on the Baseplate template, 33 anchored parts, no roof yet:
  - `Store.Building`: floor, walls, a front door gap facing the spawn, a divider wall with a door between the front and back rooms, and a sign reading "MY THRIFT STORE" (placeholder name).
  - `Store.Stations`: nine Models, each with a `PrimaryPart` and a `Station` attribute for scripts to find them.

| Station models | `Station` attribute | Room |
|---|---|---|
| `Rack1` to `Rack4` | `Rack` | Front |
| `Checkout` | `Checkout` | Front |
| `Washer1`, `Washer2` | `Washer` | Back |
| `ListingDesk` | `Listing` | Back |
| `PackingTable` | `Packing` | Back |

- The building covers X from -40 to 40 and Z from -20 (front wall) to -120 (back wall), with the divider at Z = -80.
- Re-running the script deletes and rebuilds `Workspace.Store`.
- No gameplay scripts exist yet. The next step is the first real gameplay: finding clothes, carrying them to the back, and washing them.

## Quality bar

Four things separate a polished game from a beginner one. Plan for all of them:

- **Art**: real 3D models, a designed UI, sounds, and animations. The current store is plain blocks, which is fine for a prototype only. Carter still has to decide where the art comes from: learning Blender, quality free assets, or a paid modeler.
- **Game feel**: finding a rare piece should feel great, with a reveal, sound, and effects by rarity.
- **Balance**: prices, wait times, and upgrade costs tuned so the player always has a next goal.
- **The front door**: icon, thumbnails, and title decide whether anyone clicks.

Keep the first release small and polished rather than large and unfinished.

## Engineering standards

- The server owns money, inventory, item rolls, and sales. Never trust the client for anything that affects them; validate every remote call.
- All tuning numbers (prices, percentages, timers, odds, worker speeds, costs) live in one settings module.
- Item, brand, and worker definitions are data in ModuleScripts, so adding content never means editing game logic.
- Player data saves reliably and is tested for losing progress before anything else is built on it.
- Test each feature in Studio before moving on, and tell Carter exactly how to test it himself.

## Donation bin ideas (from Carter, in progress)

- The bin must be movable by Carter in Studio without moving the building. It is its own model (`Stations.DonationBin`, attribute `Station = Sourcing`); BuildStore.lua keeps its position when re-run. More bins can be added by copying it.
- Free search limit of 3. Extra searches cost Robux, with bigger packs for more Robux. Needs decisions: how free searches refresh, pack sizes and prices. Roblox requires odds disclosure for paid random items, so the find odds must be shown in the game.

## Ideas raised but not decided

These came up in planning. Ask Carter before building any of them.

- Player-to-player trading.
- Other players walking through your store to see your best finds.
- Customers who haggle on in-person sales.
- Timed bidding on the auction site, where rare items can sell well above value.
- Fakes mixed into finds, with an authenticate-and-grade step.
- Photographing an item for its listing, with better photos raising the price.
- A server-wide announcement when someone finds a top-tier item.
- A small weekly drop of limited items.
- Game passes and other paid extras.

## Open decisions

- The game's name.
- Names for the auction site and the resale app.
- The invented clothing brands.
- The name and look of the monster card line.
- Where the art comes from.

# Thrift Store Tycoon

Roblox game. Full plan and rules are in [CLAUDE.md](CLAUDE.md).

## One-time setup (Windows or Mac)

1. Install Roblox Studio (you have this).
2. Install the **Rojo plugin** in Studio (Plugins tab > Manage Plugins > search "Rojo" > Install),
   and the **Rojo extension** in VS Code (Extensions > search "Rojo"), which also installs the Rojo program.
3. Clone this repo to your computer and open the folder in VS Code.

## Every work session

1. In VS Code, run the command `Rojo: Open Menu` > `Start Rojo server` (or run `rojo serve` in a terminal).
2. In Studio, open your place (a new Baseplate is fine), click **Rojo** in the Plugins tab, then **Connect**.
3. Scripts from `src/` now appear in Studio and update live as files change.

## Build the store (first test)

1. In Studio, open **View > Command Bar**.
2. Open `tools/BuildStore.lua`, copy everything, paste into the command bar, press Enter.
3. You should see a building appear in Workspace as `Store`, with an Output line `Store built: ...`.

## Check the server works

Press Play. The Output window should show `Thrift Store Tycoon server started`.
Studio blocks saving data until you turn on **Game Settings > Security > Enable Studio Access to API Services**
(needed once the place is published).

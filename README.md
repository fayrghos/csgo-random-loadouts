# Random Loadouts
This script randomize a CS:GO loadout and gives it to each player every 15 seconds, including primaries, secondaries, knives, danger zone weapons and playermodels.

Not compatible with CS2. Still usable in the `csgo_demo_viewer` branch.

## Usage
The script is compatible with every Defusal/Hostage map. It's highly recommended to initialize maps via console in Casual gamemode since initializing it in War Games or Deathmatch may break some stuff.

The host needs to execute the cfg every **map** start.
```
exec randmode
```

And then execute the script every **round** start.
```
script RL_RoundStart()
```

## Bugs
- Receiving a new loadout interrupts you from planting the bomb.
- Some viewmodels may become invisible.
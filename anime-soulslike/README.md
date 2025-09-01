# Anime Soulslike (Godot 4)

A minimal 2D soulslike prototype with anime-inspired visuals. Move, roll, and attack enemies, with checkpoints and respawn.

## Controls
- WASD / Arrow Keys: Move
- Left Mouse / J: Attack
- Space / K: Roll
- E: Interact

## Requirements
- Godot Engine 4.x

## Run
1. Open Godot, click "Import/Scan" and select the `project.godot` in this folder.
2. Press F5 (Run). The main scene is `scenes/Main.tscn`.

## Export (PC)
1. In Godot, install export templates (Editor > Manage Export Templates).
2. Project > Export > Add "Linux/X11" or "Windows Desktop".
3. Set path and press Export.

## Structure
- `scenes/` core scenes (`Main`, `Player`, `Enemy`, `HUD`, `Checkpoint`)
- `scripts/` gameplay scripts
- `shaders/` toon shader for anime-like posterization

## Notes
This is a prototype: movement, attack hitbox, simple AI, HUD, and checkpoint system are implemented for quick iteration.
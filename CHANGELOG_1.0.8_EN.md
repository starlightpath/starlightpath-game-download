# Starlight Path: A Promise in the Forest — Beta 1.0.8

**Target engine:** Godot 4.7.2 stable  
**Release type:** Beta  
**Date:** November 5, 2026

## Added

- **Five save slots:** Start a new adventure, continue a saved game, or choose a save slot from the pause menu. Save files are named `slot_1.json` through `slot_5.json`.
- **Achievement system:** Eight unlockable achievements for exploration, collecting items, helping characters, and discovering stories. An achievement gallery is available from the title and pause menus.
- **Expanded story:** Additional opening narration, dialogue with the Starlight Elder, and a village mayor epilogue after helping Mimi.
- **English by default:** Fresh installations start in English. Existing language preferences stored in settings remain unchanged.
- **Updated interface:** Improved title menu styling, a save-slot selection window, an achievement gallery, and a Beta 1.0.8 version label.

## Changed

- **Portable Windows saves:** Exported Windows builds store progress in the `game_save_data` folder next to `StarlightPath.exe` (when the directory is writable).
- **Quick save and load:** `F5` saves to the active slot; `F9` loads that slot.
- **Legacy save compatibility:** Slot 1 can read the older `game_save_data/save.json` or `user://savegame.json` when a new slot file does not exist.
- **Website:** Updated the game website's version, features, save instructions, and news in English, Traditional Chinese, and Japanese.

## Save layout

```text
StarlightPath/
├── StarlightPath.exe
└── game_save_data/
    ├── slot_1.json
    ├── slot_2.json
    ├── slot_3.json
    ├── slot_4.json
    └── slot_5.json
```

Only slots that have been saved will have files. New Game selects a slot; the file is created when the player saves.

## Notes and known limitations

- The ancient shrine and additional exploration areas remain planned future content.
- The website is a static informational page; it cannot read or launch local Windows save files.
- **Testing status:** Archive integrity and source-level checks have been performed, but the project has not been compiled or play-tested in the Godot 4.7.2 engine in this environment. Please test the exported Windows build before publishing.

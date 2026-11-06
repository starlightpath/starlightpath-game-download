# Starlight Path — Beta 1.0.8 (Godot 4.7.2)

## Added
- Five independent save slots (`game_save_data/slot_1.json` through `slot_5.json`). Choose a slot on New Game, Continue, or Pause > Save.
- 8 persistent achievements; access from title and pause menu.
- Extended intro, elder dialogue and mayor epilogue (triggered after helping Mimi).
- Default language is English on a fresh install. Existing language preference in `user://settings.json` is preserved.
- Beta 1.0.8 indicator on the title screen.

## Important
- New Game selects a slot, but progress is written only when you save (F5 or Pause > Save).
- F5 saves to the currently selected slot. F9 reloads that slot.
- The previous `game_save_data/save.json` and `user://savegame.json` can still be loaded through slot 1.
- Save directory is next to the exported Windows executable, so avoid protected folders such as Program Files.
- Website is static and cannot directly open local save files.
- **Not engine-tested**: please test on Godot 4.7.2 before publishing an EXE.

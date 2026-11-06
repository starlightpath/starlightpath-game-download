# Beta 1.0.8 — Visual and UX Update

- Added illustrated title background with mountains, star field and pine silhouettes.
- Reordered title menu: Continue above New Game.
- Added confirmation dialog before starting a new game in an occupied save slot. Existing file is not deleted until the next save.
- Added traveler appearance customization: hair, skin and outfit palettes. Appearance is serialized in each save slot; existing saves default to original palette.
- Improved player and NPC drawing and lantern fixtures.
- Added three houses and three directional signs in the village, plus two forest signs.
- Added six achievements (14 total).

## Testing

Open project.godot in Godot 4.7.2, import assets and press F5. Test all five save slots, overwrite cancellation, customization persistence, NPC interaction, collisions and scene transitions. This environment does not have Godot installed, so runtime validation was not performed.

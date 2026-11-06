extends AcceptDialog
## Achievement collection, displayed in the active language.
func _ready() -> void:
	title = "Achievements" if GameState.language == "en" else "成就圖鑑"
	min_size = Vector2i(480, 420)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(430, 340)
	add_child(scroll)
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	var count := Label.new()
	count.text = "%d / %d unlocked" % [GameState.achievements.size(), GameState.ACHIEVEMENTS.size()] if GameState.language == "en" else "已解鎖 %d / %d" % [GameState.achievements.size(), GameState.ACHIEVEMENTS.size()]
	list.add_child(count)
	for id in GameState.ACHIEVEMENTS:
		var label := Label.new()
		var unlocked: bool = GameState.achievements.has(id)
		label.text = ("★ " if unlocked else "☆ ") + GameState.achievement_title(id) + "\n   " + (GameState.achievement_description(id) if unlocked else ("Not yet unlocked" if GameState.language == "en" else "尚未解鎖"))
		label.add_theme_color_override("font_color", Color("#ffe27a") if unlocked else Color("#8796af"))
		list.add_child(label)

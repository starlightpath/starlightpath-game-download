extends Control
## 主選單：新遊戲、繼續遊戲、設定、離開。

const INTRO_SCENE := "res://scenes/intro.tscn"
const FOREST_SCENE := "res://scenes/forest.tscn"

var _time := 0.0
var _stars: Array[Vector2] = []
var _continue_button: Button
var _first_button: Button
var _message: Label
const SlotPicker = preload("res://scripts/ui/save_slots.gd")
const AchievementPanel = preload("res://scripts/ui/achievements_panel.gd")


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	for i in range(90):
		_stars.append(Vector2(randf(), randf()))
	_build_menu()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	# 夜空漸層與閃爍星星
	var bands := 12
	for i in range(bands):
		var t := float(i) / bands
		draw_rect(Rect2(0, size.y * t, size.x, size.y / bands + 1), Color("#1d2b53").lerp(Color("#3d5a80"), t))
	# Mountain silhouettes and forest foreground create a dedicated title backdrop.
	var w: float = size.x
	var h: float = size.y
	var mountains := PackedVector2Array([Vector2(0, h * 0.76), Vector2(0, h * 0.59), Vector2(w * 0.12, h * 0.42), Vector2(w * 0.24, h * 0.64), Vector2(w * 0.40, h * 0.38), Vector2(w * 0.55, h * 0.67), Vector2(w * 0.72, h * 0.43), Vector2(w * 0.89, h * 0.61), Vector2(w, h * 0.48), Vector2(w, h * 0.76)])
	draw_colored_polygon(mountains, Color("#233a55"))
	draw_rect(Rect2(0, h * 0.76, w, h * 0.24), Color("#142e39"))
	for i in range(15):
		var x: float = w * float(i) / 14.0
		var y: float = h * (0.73 + 0.035 * sin(float(i) * 2.0))
		var tree := PackedVector2Array([Vector2(x - 32, y + 55), Vector2(x, y - 54 - float(i % 3) * 13), Vector2(x + 32, y + 55)])
		draw_colored_polygon(tree, Color("#0b252e"))
	for i in range(_stars.size()):
		var alpha := 0.5 + 0.5 * sin(_time * 2.0 + i)
		draw_circle(_stars[i] * size, 1.5, Color(1, 0.95, 0.7, alpha))


func _build_menu() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	center.add_child(box)

	var title := Label.new()
	title.text = GameState.t("星光小徑")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#ffe27a"))
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = GameState.t("森林的約定")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color("#f4e9d8"))
	box.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	box.add_child(spacer)

	_continue_button = _make_button("繼續遊戲", _on_continue)
	_continue_button.disabled = not (GameState.has_save(1) or GameState.has_save(2) or GameState.has_save(3) or GameState.has_save(4) or GameState.has_save(5))
	box.add_child(_continue_button)
	_first_button = _make_button("新遊戲", _on_new_game)
	box.add_child(_first_button)
	box.add_child(_make_button("自訂角色", _on_character))

	box.add_child(_make_button("成就", _on_achievements))
	box.add_child(_make_button("設定", _on_settings))
	box.add_child(_make_button("English" if GameState.language == "zh" else "中文", _on_toggle_language))
	box.add_child(_make_button("離開", _on_quit))
	var version := Label.new()
	version.text = "Beta 1.0.9  ·  Godot 4.7.2"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_color_override("font_color", Color("#a9b4d0"))
	box.add_child(version)

	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 14)
	_message.add_theme_color_override("font_color", Color("#ffe27a"))
	box.add_child(_message)

	(_continue_button if not _continue_button.disabled else _first_button).grab_focus()


func _make_button(text: String, handler: Callable) -> Button:
	var button := Button.new()
	button.text = GameState.t(text)
	button.custom_minimum_size = Vector2(220, 42)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("#1d2b53"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#ffe7a0")
	normal.set_corner_radius_all(12)
	normal.set_content_margin_all(10)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color("#fff5cf")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := normal.duplicate()
	pressed.bg_color = Color("#d9b870")
	button.add_theme_stylebox_override("pressed", pressed)
	button.pressed.connect(handler)
	return button


func _open_slots(mode: String) -> void:
	var picker = SlotPicker.new()
	picker.slot_mode = mode
	add_child(picker)
	picker.slot_chosen.connect(func(slot: int): _on_slot_selected(mode, slot))
	picker.popup_centered()


func _on_slot_selected(mode: String, slot: int) -> void:
	if mode == "new":
		if GameState.has_save(slot):
			_confirm_overwrite(slot)
		else:
			_start_new_game(slot)
	elif GameState.load_game():
		get_tree().change_scene_to_file(GameState.current_scene)
	else:
		_message.text = GameState.t("讀取失敗，存檔可能已損毀。")


func _start_new_game(slot: int) -> void:
	GameState.select_slot(slot)
	GameState.reset_new_game()
	get_tree().change_scene_to_file(INTRO_SCENE)


func _confirm_overwrite(slot: int) -> void:
	var confirm := ConfirmationDialog.new()
	confirm.title = "Overwrite Save?" if GameState.language == "en" else "覆蓋存檔？"
	confirm.dialog_text = ("Slot %d already has progress. Start over? Existing progress will be overwritten when you save." if GameState.language == "en" else "第 %d 格已有進度。確定開始新遊戲？再次儲存時將覆蓋原進度。") % slot
	add_child(confirm)
	confirm.confirmed.connect(func(): _start_new_game(slot))
	confirm.confirmed.connect(confirm.queue_free)
	confirm.canceled.connect(confirm.queue_free)
	confirm.popup_centered()


func _on_character() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Character Appearance" if GameState.language == "en" else "角色外觀"
	dialog.min_size = Vector2i(390, 280)
	add_child(dialog)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	dialog.add_child(content)
	var hint := Label.new()
	hint.text = "Customize your traveler (saved in your game slot)." if GameState.language == "en" else "自訂旅行者外觀（儲存於遊戲存檔）。"
	content.add_child(hint)
	var choices: Array[OptionButton] = []
	var labels: Array = ["Hair / 髮色", "Skin / 膚色", "Outfit / 服裝"]
	var options: Array = [["Brown", "Black", "Blonde", "Rose", "Silver"], ["Light", "Tan", "Warm", "Deep"], ["Blue", "Green", "Rose", "Gold", "Violet"]]
	var values: Array = [GameState.character_hair, GameState.character_skin, GameState.character_outfit]
	for i in range(3):
		var label := Label.new()
		label.text = labels[i]
		content.add_child(label)
		var choice := OptionButton.new()
		for option in options[i]:
			choice.add_item(option)
		choice.select(int(values[i]))
		content.add_child(choice)
		choices.append(choice)
	dialog.confirmed.connect(func(): GameState.set_character_look(choices[0].selected, choices[1].selected, choices[2].selected))
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()


func _on_new_game() -> void:
	_open_slots("new")


func _on_continue() -> void:
	_open_slots("load")


func _on_achievements() -> void:
	var panel = AchievementPanel.new()
	add_child(panel)
	panel.popup_centered()


func _on_settings() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = GameState.t("設定")
	dialog.min_size = Vector2i(360, 230)
	add_child(dialog)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	dialog.add_child(box)
	var volume_label := Label.new()
	volume_label.text = GameState.t("主音量")
	box.add_child(volume_label)
	var volume := HSlider.new()
	volume.min_value = 0.0
	volume.max_value = 1.0
	volume.step = 0.05
	volume.value = GameState.master_volume
	volume.custom_minimum_size = Vector2(280, 28)
	volume.value_changed.connect(func(v: float): GameState.set_master_volume(v))
	box.add_child(volume)
	var fullscreen_box := CheckBox.new()
	fullscreen_box.text = GameState.t("全螢幕")
	fullscreen_box.button_pressed = GameState.fullscreen
	fullscreen_box.toggled.connect(func(v: bool): GameState.set_fullscreen(v))
	box.add_child(fullscreen_box)
	var save_hint := Label.new()
	save_hint.text = GameState.t("存檔位置：遊戲資料夾 / game_save_data")
	box.add_child(save_hint)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()


func _on_toggle_language() -> void:
	GameState.set_language("en" if GameState.language == "zh" else "zh")
	get_tree().reload_current_scene()


func _on_quit() -> void:
	get_tree().quit()

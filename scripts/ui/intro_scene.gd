extends Control
## 開場劇情：打字機效果逐段播放旁白與對話。E / 空白鍵繼續，ESC 跳過。

const FOREST_SCENE := "res://scenes/forest.tscn"
const SECONDS_PER_CHAR := 0.04

var _lines: Array = StoryData.INTRO
var _index := 0
var _typing := false
var _tween: Tween
var _speaker: Label
var _text: Label
var _time := 0.0
var _stars: Array[Vector2] = []


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	for i in range(80):
		_stars.append(Vector2(randf(), randf()))
	_build_ui()
	_show_line()


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#141b33"))
	for i in range(_stars.size()):
		var alpha := 0.3 + 0.7 * absf(sin(_time * 1.5 + i))
		draw_circle(_stars[i] * size, 1.2, Color(1, 0.95, 0.7, alpha))


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 40
	panel.offset_right = -40
	panel.offset_top = -170
	panel.offset_bottom = -30
	add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.2, 0.9)
	style.set_corner_radius_all(14)
	style.set_border_width_all(3)
	style.border_color = Color("#ffe27a")
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	_speaker = Label.new()
	_speaker.add_theme_font_size_override("font_size", 18)
	_speaker.add_theme_color_override("font_color", Color("#ffe27a"))
	vbox.add_child(_speaker)

	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("font_size", 20)
	_text.add_theme_color_override("font_color", Color("#f4e9d8"))
	vbox.add_child(_text)

	var hint := Label.new()
	hint.text = GameState.t("E / 空白鍵 繼續　　ESC 跳過")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#9aa3c7"))
	vbox.add_child(hint)


func _show_line() -> void:
	var line: Dictionary = _lines[_index]
	_speaker.text = GameState.t(str(line["speaker"]))
	_text.text = GameState.t(str(line["text"]))
	_text.visible_ratio = 0.0
	_typing = true

	if _tween:
		_tween.kill()
	_tween = create_tween()
	var duration := _text.text.length() * SECONDS_PER_CHAR
	_tween.tween_property(_text, "visible_ratio", 1.0, duration)
	_tween.finished.connect(func(): _typing = false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()
		return
	if event.is_action_pressed("advance"):
		get_viewport().set_input_as_handled()
		if _typing:
			# 文字還在打字中：直接顯示完整句子
			_tween.kill()
			_text.visible_ratio = 1.0
			_typing = false
		else:
			_index += 1
			if _index >= _lines.size():
				_finish()
			else:
				_show_line()


func _finish() -> void:
	GameState.set_flag("intro_done")
	get_tree().change_scene_to_file(FOREST_SCENE)

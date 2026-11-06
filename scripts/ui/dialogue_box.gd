class_name DialogueBox
extends CanvasLayer
## 對話框：逐句顯示台詞，按 E 或空白鍵繼續。

signal finished

var is_open := false
var _lines: Array = []
var _index := 0
var _cooldown := 0.0       # 開啟後短暫忽略輸入，避免同一次按鍵直接跳過
var _label: Label
var _panel: PanelContainer


func _ready() -> void:
	layer = 10
	visible = false

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = 24
	_panel.offset_right = -24
	_panel.offset_top = -130
	_panel.offset_bottom = -24

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.97, 0.9, 0.95)
	style.set_corner_radius_all(14)
	style.set_border_width_all(3)
	style.border_color = Color("#c9a77c")
	style.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	_panel.add_child(vbox)

	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color("#4a3b2a"))
	vbox.add_child(_label)

	var hint := Label.new()
	hint.text = GameState.t("E / 空白鍵 繼續")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", Color("#9a8570"))
	vbox.add_child(hint)


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta


func open(lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_cooldown = 0.2
	is_open = true
	visible = true
	_label.text = GameState.t(str(_lines[0]))


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or _cooldown > 0.0:
		return
	if event.is_action_pressed("advance"):
		get_viewport().set_input_as_handled()
		_index += 1
		if _index >= _lines.size():
			_close()
		else:
			_label.text = GameState.t(str(_lines[_index]))


func _close() -> void:
	is_open = false
	visible = false
	finished.emit()

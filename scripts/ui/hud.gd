class_name HUD
extends CanvasLayer
## 介面提示：左上角顯示目前目標，靠近互動物件時右下角顯示互動提示。

var _objective: Label
var _prompt: Label


func _ready() -> void:
	layer = 4

	var panel := PanelContainer.new()
	panel.position = Vector2(14, 12)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.2, 0.75)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	_objective = Label.new()
	_objective.add_theme_font_size_override("font_size", 14)
	_objective.add_theme_color_override("font_color", Color("#ffe27a"))
	panel.add_child(_objective)

	_prompt = Label.new()
	_prompt.text = GameState.t("E 互動")
	_prompt.anchor_left = 1.0
	_prompt.anchor_right = 1.0
	_prompt.anchor_top = 1.0
	_prompt.anchor_bottom = 1.0
	_prompt.offset_left = -160
	_prompt.offset_right = -20
	_prompt.offset_top = -60
	_prompt.offset_bottom = -30
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_prompt.add_theme_font_size_override("font_size", 16)
	_prompt.add_theme_color_override("font_color", Color("#fff3c4"))
	_prompt.visible = false
	add_child(_prompt)


func refresh(objective: String, show_prompt: bool) -> void:
	_objective.text = GameState.t("目標：") + GameState.t(objective)
	_prompt.visible = show_prompt

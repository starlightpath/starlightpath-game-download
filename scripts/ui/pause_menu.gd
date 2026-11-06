class_name PauseMenu
extends CanvasLayer
signal resume_requested
signal save_requested
const SlotPicker = preload("res://scripts/ui/save_slots.gd")
const AchievementPanel = preload("res://scripts/ui/achievements_panel.gd")
var _first_button: Button

func _ready() -> void:
    layer = 15
    visible = false
    var shade := ColorRect.new()
    shade.set_anchors_preset(Control.PRESET_FULL_RECT)
    shade.color = Color(0.025,0.055,0.11,0.77)
    shade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(shade)
    var center := CenterContainer.new()
    center.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(360,365)
    center.add_child(panel)
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#152a42")
    style.border_color = Color("#d6b773")
    style.set_border_width_all(2)
    style.set_corner_radius_all(19)
    style.shadow_color = Color(0,0,0,0.45)
    style.shadow_size = 14
    style.set_content_margin_all(24)
    panel.add_theme_stylebox_override("panel",style)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",12)
    panel.add_child(box)
    var star := Label.new()
    star.text = "✦  ✧  ✦"
    star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    star.add_theme_color_override("font_color",Color("#f5d78b"))
    box.add_child(star)
    var title := Label.new()
    title.text = "PAUSED" if GameState.language == "en" else "遊戲暫停"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size",30)
    title.add_theme_color_override("font_color",Color("#ffe3a0"))
    box.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "Your journey is waiting" if GameState.language == "en" else "星光正在等待你的旅程"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_color_override("font_color",Color("#b5cbe0"))
    box.add_child(subtitle)
    _first_button = _make_button("繼續遊戲",func(): resume_requested.emit())
    box.add_child(_first_button)
    box.add_child(_make_button("存檔（F5）",_choose_save_slot))
    box.add_child(_make_button("成就",_show_achievements))
    box.add_child(_make_button("返回主選單",_on_back_to_title))
    var hint := Label.new()
    hint.text = "ESC · Resume     F5 · Save" if GameState.language == "en" else "ESC · 繼續     F5 · 存檔"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.add_theme_color_override("font_color",Color("#9bb1c9"))
    box.add_child(hint)

func open() -> void:
    visible = true
    _first_button.grab_focus()

func close() -> void:
    visible = false

func _make_button(text: String, handler: Callable) -> Button:
    var button := Button.new()
    button.text = GameState.t(text)
    button.custom_minimum_size = Vector2(290,43)
    button.add_theme_font_size_override("font_size",17)
    button.add_theme_color_override("font_color",Color("#f6e8c5"))
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#2a4960")
    style.border_color = Color("#52778b")
    style.set_border_width_all(1)
    style.set_corner_radius_all(9)
    style.set_content_margin_all(8)
    button.add_theme_stylebox_override("normal",style)
    var hover := style.duplicate() as StyleBoxFlat
    hover.bg_color = Color("#466a7e")
    hover.border_color = Color("#e7c37c")
    button.add_theme_stylebox_override("hover",hover)
    var pressed := style.duplicate() as StyleBoxFlat
    pressed.bg_color = Color("#6c7481")
    button.add_theme_stylebox_override("pressed",pressed)
    button.pressed.connect(handler)
    return button

func _on_back_to_title() -> void:
    visible = false
    get_tree().change_scene_to_file("res://scenes/title.tscn")

func _choose_save_slot() -> void:
    var picker = SlotPicker.new()
    picker.slot_mode = "save"
    add_child(picker)
    picker.slot_chosen.connect(func(_slot: int): save_requested.emit())
    picker.popup_centered()

func _show_achievements() -> void:
    var panel = AchievementPanel.new()
    add_child(panel)
    panel.popup_centered()

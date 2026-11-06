class_name InventoryUI
extends CanvasLayer
## Beta 1.0.9: illustrated inventory grid with keyboard navigation.

const ITEM_ICONS := {
    "mushroom": preload("res://assets/ui/inventory/mushroom.png"),
    "flower": preload("res://assets/ui/inventory/flower.png"),
    "wood": preload("res://assets/ui/inventory/wood.png"),
    "carrot": preload("res://assets/ui/inventory/carrot.png"),
    "star_shard": preload("res://assets/ui/inventory/star_shard.png"),
    "berry": preload("res://assets/ui/inventory/berry.png"),
    "lantern": preload("res://assets/ui/inventory/lantern.png"),
}
const DESCRIPTIONS := {
    "mushroom": ["森林裡的小蘑菇。", "A little mushroom from the forest."],
    "flower": ["柔和芬芳的花朵。", "A fragrant forest flower."],
    "wood": ["可以用來修補物品的木材。", "Wood useful for repairs."],
    "carrot": ["兔子喜愛的胡蘿蔔。", "A carrot loved by rabbits."],
    "star_shard": ["閃耀著微光的星星碎片。", "A shard of shimmering starlight."],
    "berry": ["森林裡採集的野莓。", "Wild berries from the forest."],
    "lantern": ["能照亮小徑的燈籠。", "A lantern to light the path."],
}

var _shade: ColorRect
var _panel: PanelContainer
var _grid: GridContainer
var _detail: Label
var _counter: Label
var _buttons: Array[Button] = []
var _selected: String = ""

func _ready() -> void:
    layer = 5
    _shade = ColorRect.new()
    _shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _shade.color = Color(0.025, 0.045, 0.09, 0.72)
    _shade.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(_shade)
    _panel = PanelContainer.new()
    _panel.set_anchors_preset(Control.PRESET_CENTER)
    _panel.offset_left = -260
    _panel.offset_top = -205
    _panel.offset_right = 260
    _panel.offset_bottom = 205
    _panel.add_theme_stylebox_override("panel", _style(Color("#17263d"), Color("#c9a86d"), 3, 20))
    add_child(_panel)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 22)
    margin.add_theme_constant_override("margin_right", 22)
    margin.add_theme_constant_override("margin_top", 17)
    margin.add_theme_constant_override("margin_bottom", 17)
    _panel.add_child(margin)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 12)
    margin.add_child(layout)
    var header := HBoxContainer.new()
    layout.add_child(header)
    var heading := Label.new()
    heading.text = "✦  Inventory" if GameState.language == "en" else "✦  背包"
    heading.add_theme_font_size_override("font_size", 25)
    heading.add_theme_color_override("font_color", Color("#f6d997"))
    heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(heading)
    _counter = Label.new()
    _counter.add_theme_color_override("font_color", Color("#b9c8d9"))
    header.add_child(_counter)
    var divider := HSeparator.new()
    layout.add_child(divider)
    _grid = GridContainer.new()
    _grid.columns = 4
    _grid.add_theme_constant_override("h_separation", 10)
    _grid.add_theme_constant_override("v_separation", 10)
    layout.add_child(_grid)
    _detail = Label.new()
    _detail.custom_minimum_size.y = 54
    _detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _detail.add_theme_color_override("font_color", Color("#e6e2d5"))
    layout.add_child(_detail)
    var hint := Label.new()
    hint.text = "I / Esc — Close" if GameState.language == "en" else "I / Esc — 關閉"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hint.add_theme_color_override("font_color", Color("#8fa4bc"))
    layout.add_child(hint)
    GameState.inventory_changed.connect(_refresh)
    visible = false

func _style(bg: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border_color
    s.set_border_width_all(border_width)
    s.set_corner_radius_all(radius)
    s.set_content_margin_all(6)
    return s

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("inventory"):
        _toggle()
        get_viewport().set_input_as_handled()
    elif visible and event.is_action_pressed("ui_cancel"):
        visible = false
        get_viewport().set_input_as_handled()

func _toggle() -> void:
    visible = not visible
    if visible:
        _refresh()
        if not _buttons.is_empty():
            _buttons[0].grab_focus()

func _refresh() -> void:
    if _grid == null:
        return
    for child in _grid.get_children():
        _grid.remove_child(child)
        child.queue_free()
    _buttons.clear()
    var total: int = 0
    for item_id in ItemData.ITEM_IDS:
        var count: int = GameState.get_item_count(item_id)
        if count > 0:
            total += 1
        var b := Button.new()
        b.custom_minimum_size = Vector2(107, 94)
        b.add_theme_stylebox_override("normal", _style(Color("#243751") if count > 0 else Color("#1c2b3e"), Color("#5d7691") if count > 0 else Color("#34465b"), 1, 10))
        b.add_theme_stylebox_override("hover", _style(Color("#304b68"), Color("#d5b578"), 2, 10))
        b.add_theme_stylebox_override("focus", _style(Color.TRANSPARENT, Color("#f4d78f"), 2, 10))
        b.add_theme_stylebox_override("pressed", _style(Color("#385373"), Color("#f4d78f"), 2, 10))
        var content := VBoxContainer.new()
        content.mouse_filter = Control.MOUSE_FILTER_IGNORE
        content.alignment = BoxContainer.ALIGNMENT_CENTER
        b.add_child(content)
        content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        var pic := TextureRect.new()
        pic.texture = ITEM_ICONS[item_id]
        pic.custom_minimum_size = Vector2(42, 54)
        pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        pic.modulate.a = 1.0 if count > 0 else 0.32
        pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
        content.add_child(pic)
        var amount := Label.new()
        amount.text = "×%d" % count if count > 0 else "—"
        amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        amount.add_theme_color_override("font_color", Color("#f7dc9d") if count > 0 else Color("#60748a"))
        amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
        content.add_child(amount)
        b.pressed.connect(_select_item.bind(item_id))
        _grid.add_child(b)
        _buttons.append(b)
    _counter.text = "%d / %d" % [total, ItemData.ITEM_IDS.size()]
    if _selected == "" or not ItemData.ITEM_IDS.has(_selected):
        _selected = ItemData.ITEM_IDS[0]
    _select_item(_selected)

func _select_item(item_id: String) -> void:
    _selected = item_id
    var name: String = GameState.t(ItemData.item_name(item_id))
    var desc: Array = DESCRIPTIONS.get(item_id, ["", ""])
    var explanation: String = str(desc[1] if GameState.language == "en" else desc[0])
    var amount: int = GameState.get_item_count(item_id)
    _detail.text = "%s  ×%d
%s" % [name, amount, explanation]

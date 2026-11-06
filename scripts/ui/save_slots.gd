extends AcceptDialog
## Reusable five-slot picker for starting, loading, and saving.
signal slot_chosen(slot: int)
var slot_mode: String = "load"

func _ready() -> void:
	title = "Save Slots" if GameState.language == "en" else "存檔格"
	min_size = Vector2i(430, 360)
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)
	add_child(container)
	var header := Label.new()
	header.text = "Choose one of five slots" if GameState.language == "en" else "請選擇五個存檔格之一"
	container.add_child(header)
	for slot in range(1, 6):
		var button := Button.new()
		button.custom_minimum_size = Vector2(370, 43)
		button.text = "%02d  ·  %s" % [slot, GameState.slot_summary(slot)]
		button.pressed.connect(_choose.bind(slot))
		container.add_child(button)
	get_ok_button().hide()

func _choose(slot: int) -> void:
	GameState.select_slot(slot)
	slot_chosen.emit(slot)
	queue_free()

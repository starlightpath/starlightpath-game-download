class_name NPC
extends StaticBody2D
## NPC：有碰撞、可互動、頭上顯示名字。實際台詞由 QuestData / StoryData 決定。

signal interacted(npc: NPC)

var npc_id := ""
var npc_name := ""
var shirt_color := Color(0.96, 0.64, 0.38)


func _ready() -> void:
	add_to_group("interactable")
	var shape := RectangleShape2D.new()
	shape.size = Vector2(12, 10)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, 4)
	add_child(col)


func interact(_player: Node) -> void:
	interacted.emit(self)


func _draw() -> void:
	var skin := Color("#f2c49f")
	var hair := shirt_color.darkened(0.48)
	draw_circle(Vector2(0, 9), 6.0, Color(0.02, 0.04, 0.07, 0.22))
	draw_rect(Rect2(-4, 5, 3, 4), Color("#343449"))
	draw_rect(Rect2(1, 5, 3, 4), Color("#343449"))
	draw_rect(Rect2(-6, -2, 12, 8), shirt_color.darkened(0.25))
	draw_rect(Rect2(-4, -2, 8, 8), shirt_color)
	draw_rect(Rect2(-7, 0, 2, 4), skin)
	draw_rect(Rect2(5, 0, 2, 4), skin)
	draw_circle(Vector2(0, -7), 5.0, skin)
	draw_rect(Rect2(-5, -12, 10, 3), hair)
	draw_rect(Rect2(-5, -10, 2, 4), hair)
	draw_circle(Vector2(-2, -6), 0.8, Color("#303047"))
	draw_circle(Vector2(2, -6), 0.8, Color("#303047"))
	draw_string(ThemeDB.fallback_font, Vector2(-30, -17), GameState.t(npc_name), HORIZONTAL_ALIGNMENT_CENTER, 60, 10, Color("#fff3c4"))

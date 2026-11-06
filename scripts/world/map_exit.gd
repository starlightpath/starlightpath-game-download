class_name MapExit
extends Area2D
## 地圖出口：玩家走入後切換到指定場景，並設定抵達時的出生點。

var exit_size := Vector2(20, 20)
var target_scene := ""
var spawn_point := Vector2.ZERO
var _used := false


func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = exit_size
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _used or not body.is_in_group("player"):
		return
	_used = true
	GameState.player_position = spawn_point
	get_tree().change_scene_to_file(target_scene)

extends CharacterBody2D
## 玩家角色：四方向移動、走路動畫、提燈照明、與互動物件互動。

const SPEED := 90.0
const LightUtilScript := preload("res://scripts/world/light_util.gd")

var facing := Vector2.DOWN
var input_enabled := true     # 對話、背包或暫停選單開啟時由地圖關閉
var camera: Camera2D
var _walk_time := 0.0


func _ready() -> void:
	add_to_group("player")

	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 8)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, 5)
	add_child(col)

	# 提燈光源：夜晚中照亮周圍
	var light := PointLight2D.new()
	light.texture = LightUtilScript.make_texture()
	light.texture_scale = 1.4
	light.color = Color(1.0, 0.9, 0.65)
	light.energy = 1.1
	add_child(light)

	camera = Camera2D.new()
	camera.zoom = Vector2(2, 2)
	add_child(camera)
	camera.make_current()


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if input_enabled:
		dir = _snap_to_four(Input.get_vector("move_left", "move_right", "move_up", "move_down"))

	velocity = dir * SPEED
	if dir != Vector2.ZERO:
		facing = dir
		_walk_time += delta
	else:
		_walk_time = 0.0

	move_and_slide()
	queue_redraw()


## 將斜向輸入對齊到四方向。
func _snap_to_four(v: Vector2) -> Vector2:
	if v == Vector2.ZERO:
		return v
	if absf(v.x) > absf(v.y):
		return Vector2(signf(v.x), 0)
	return Vector2(0, signf(v.y))


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		return
	if event.is_action_pressed("interact"):
		var target := find_interactable()
		if target:
			get_viewport().set_input_as_handled()
			target.call("interact", self)


## 在面前一小段距離內尋找最近的互動物件（公開給地圖與 HUD 使用）。
func find_interactable() -> Node2D:
	var probe := global_position + facing * 12.0
	var best: Node2D = null
	var best_dist := 22.0
	for node in get_tree().get_nodes_in_group("interactable"):
		var target := node as Node2D
		if target == null:
			continue
		var d := target.global_position.distance_to(probe)
		if d < best_dist:
			best = target
			best_dist = d
	return best


func _draw() -> void:
	var bob: float = sin(_walk_time * 14.0) if _walk_time > 0.0 else 0.0
	var step := Vector2(0, -absf(bob))
	var coat := Color(GameState.OUTFIT_COLORS[GameState.character_outfit])
	var hair := Color(GameState.HAIR_COLORS[GameState.character_hair])
	var skin := Color(GameState.SKIN_COLORS[GameState.character_skin])
	# Contact shadow, boots, trousers and detailed coat.
	draw_circle(Vector2(0, 8), 6.0, Color(0.02, 0.05, 0.09, 0.23))
	draw_rect(Rect2(-4 + bob, 5, 3, 4), Color("#28324a"))
	draw_rect(Rect2(1 - bob, 5, 3, 4), Color("#28324a"))
	draw_rect(Rect2(-5, -3, 10, 9), coat.darkened(0.22))
	draw_rect(Rect2(-4, -3, 8, 7), coat)
	draw_rect(Rect2(-1, -1, 2, 6), Color("#f3dc9d"))
	draw_rect(Rect2(-7, -1, 2, 5), skin.darkened(0.1))
	draw_rect(Rect2(5, -1, 2, 5), skin.darkened(0.1))
	draw_circle(Vector2(0, -7) + step, 5.2, skin)
	draw_rect(Rect2(-5, -12, 10, 3), hair)
	draw_rect(Rect2(-6, -10, 3, 5), hair.darkened(0.12))
	draw_rect(Rect2(3, -10, 3, 5), hair.darkened(0.12))
	draw_circle(Vector2(-2, -6) + step, 0.75, Color("#26334a"))
	draw_circle(Vector2(2, -6) + step, 0.75, Color("#26334a"))

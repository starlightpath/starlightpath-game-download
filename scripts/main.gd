extends "res://scripts/world/map_base.gd"
## 星光森林：夜晚的森林，有居民、物品，以及通往星光村的小路。

const TREES := [
	Vector2(60, 60), Vector2(100, 70), Vector2(40, 140), Vector2(580, 60),
	Vector2(610, 120), Vector2(560, 200), Vector2(40, 300), Vector2(60, 380),
	Vector2(560, 320), Vector2(600, 420), Vector2(250, 60), Vector2(300, 40),
	Vector2(200, 400), Vector2(260, 450), Vector2(140, 450),
]
const LAKE := Rect2(410, 280, 140, 90)
const FLOWERS := [
	Vector2(170, 260), Vector2(180, 262), Vector2(470, 150), Vector2(495, 160),
	Vector2(330, 360), Vector2(120, 330), Vector2(520, 230),
]


func scene_path() -> String:
	return "res://scenes/forest.tscn"


func ground_color() -> Color:
	return Color("#4f7a5a")


func firefly_count() -> int:
	return 16


func enter_flag() -> String:
	return "forest_welcome"


func on_enter() -> void:
	if GameState.has_flag("intro_done"):
		_dialogue.open([
			"旅行者：這裡就是星光森林……夜裡的光好柔和。",
			"旁白：去和森林裡的居民打個招呼吧，他們或許知道回家的路。",
		])


func blockers() -> Array:
	var list: Array = []
	for pos in TREES:
		list.append(Rect2(pos.x - 6, pos.y - 2, 12, 10))
	list.append(LAKE)
	return list


func draw_map() -> void:
	# 草地紋理
	for x in range(0, 640, 16):
		for y in range(0, 480, 16):
			if (x * 7 + y * 13) % 5 == 0:
				draw_rect(Rect2(x + 4, y + 6, 3, 2), Color("#5b8a66"))

	# 小路（一路延伸到東邊出口）
	draw_rect(Rect2(280, 150, 40, 330), Color("#b9a783"))
	draw_rect(Rect2(100, 220, 540, 30), Color("#b9a783"))

	# 湖泊與波紋
	draw_rect(LAKE, Color("#3f6f99"))
	for i in range(3):
		var y := LAKE.position.y + 20 + i * 25
		draw_line(Vector2(LAKE.position.x + 15, y), Vector2(LAKE.position.x + 60, y), Color("#6d9cc2"), 2.0)

	for pos in FLOWERS:
		draw_circle(pos, 2.5, Color("#c77d97"))
		draw_circle(pos + Vector2(0, -3), 1.0, Color("#e8d27a"))

	for pos in TREES:
		draw_tree(pos)

	# Direction signs for travelers.
	draw_rect(Rect2(304, 173, 3, 24), Color("#513927"))
	draw_rect(Rect2(287, 163, 42, 13), Color("#d9b47b"))
	draw_string(ThemeDB.fallback_font, Vector2(290, 173), "VILLAGE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#473322"))
	draw_rect(Rect2(112, 193, 3, 24), Color("#513927"))
	draw_rect(Rect2(98, 183, 34, 13), Color("#d9b47b"))
	draw_string(ThemeDB.fallback_font, Vector2(100, 193), "TRAIL", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#473322"))
	# 東邊出口的路標
	draw_rect(Rect2(600, 196, 3, 22), Color("#5c3d24"))
	draw_rect(Rect2(590, 186, 22, 10), Color("#d8c39a"))


func npc_data() -> Array:
	return [
		{"id": "bunny", "name": "小兔子", "pos": Vector2(190, 190), "color": Color(0.96, 0.85, 0.75)},
		{"id": "villager", "name": "村民", "pos": Vector2(330, 200), "color": Color(0.55, 0.78, 0.6)},
		{"id": "fox", "name": "小狐狸", "pos": Vector2(480, 380), "color": Color(0.95, 0.6, 0.35)},
		{"id": "elder", "name": "星光長老", "pos": Vector2(470, 110), "color": Color(0.7, 0.7, 0.95)},
		{"id": "squirrel", "name": "松果", "pos": Vector2(240, 300), "color": Color(0.7, 0.5, 0.3)},
		{"id": "fairy", "name": "精靈露露", "pos": Vector2(395, 330), "color": Color(0.8, 0.95, 1.0)},
	]


func pickup_data() -> Array:
	return [
		{"uid": "forest_carrot", "item": "carrot", "pos": Vector2(90, 120)},
		{"uid": "forest_flower", "item": "flower", "pos": Vector2(360, 110)},
		{"uid": "forest_mushroom_1", "item": "mushroom", "pos": Vector2(150, 380)},
		{"uid": "forest_mushroom_2", "item": "mushroom", "pos": Vector2(520, 410)},
		{"uid": "forest_wood", "item": "wood", "pos": Vector2(360, 440)},
		{"uid": "forest_berry", "item": "berry", "pos": Vector2(250, 330)},
	]


func exit_data() -> Array:
	return [
		{"rect": Rect2(612, 222, 24, 36), "target": "res://scenes/village.tscn", "spawn": Vector2(60, 240)},
	]


func lamp_positions() -> Array:
	return [Vector2(300, 200), Vector2(420, 230), Vector2(120, 250)]

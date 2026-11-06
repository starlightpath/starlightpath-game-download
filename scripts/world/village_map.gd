extends "res://scripts/world/map_base.gd"
## 星光村：夜晚的小村莊。有廣場、噴水池、數棟房屋與各種村民，是本作的第一座城市。

const HOUSES := [
	{"rect": Rect2(260, 60, 120, 80), "wall": "#d8c39a", "roof": "#7a4a32"},   # 村長家
	{"rect": Rect2(60, 120, 110, 80), "wall": "#b8a58a", "roof": "#5c3b2a"},   # 鐵匠鋪
	{"rect": Rect2(440, 180, 130, 90), "wall": "#e0c08a", "roof": "#8a4b3a"},  # 旅店
	{"rect": Rect2(60, 340, 100, 70), "wall": "#c7b48f", "roof": "#6b4a36"},   # 商人小屋
	{"rect": Rect2(440, 330, 110, 70), "wall": "#cdb89a", "roof": "#6e4c3b"},  # 民宅
]
const EXTRA_HOUSES := [
	{"rect": Rect2(40, 30, 82, 58), "wall": "#d3b88d", "roof": "#675074"},
	{"rect": Rect2(448, 40, 86, 62), "wall": "#b9c3b0", "roof": "#536d77"},
	{"rect": Rect2(275, 342, 88, 65), "wall": "#d5bd99", "roof": "#765145"},
]
const FOUNTAIN := Vector2(320, 240)
const TREES := [
	Vector2(20, 60), Vector2(200, 30), Vector2(560, 40), Vector2(600, 120),
	Vector2(40, 420), Vector2(230, 420), Vector2(600, 300), Vector2(520, 440),
]


func scene_path() -> String:
	return "res://scenes/village.tscn"


func ground_color() -> Color:
	return Color("#4d6248")


func firefly_count() -> int:
	return 8


func enter_flag() -> String:
	return "village_arrived"


func on_enter() -> void:
	_dialogue.open([
		"旁白：夜幕降臨，星光村的燈火一盞盞亮了起來。",
		"守衛阿力：喔，來了新面孔？村長住在廣場北邊，有事可以去找他。",
		"守衛阿力：鐵匠石頭伯最近在找木頭，你可以去看看他需要什麼幫忙。",
	])


func blockers() -> Array:
	var list: Array = []
	for house in HOUSES + EXTRA_HOUSES:
		list.append(house["rect"])
	list.append(Rect2(FOUNTAIN.x - 18, FOUNTAIN.y - 16, 36, 32))
	for pos in TREES:
		list.append(Rect2(pos.x - 6, pos.y - 2, 12, 10))
	return list


func draw_map() -> void:
	# 進村的石板路與中央廣場
	draw_rect(Rect2(0, 222, 260, 36), Color("#8f8470"))
	draw_rect(Rect2(260, 180, 120, 120), Color("#948a76"))
	for x in range(260, 380, 12):
		draw_line(Vector2(x, 180), Vector2(x, 300), Color("#7d7360"), 1.0)
	for y in range(180, 300, 12):
		draw_line(Vector2(260, y), Vector2(380, y), Color("#7d7360"), 1.0)

	# 噴水池
	draw_circle(FOUNTAIN, 16.0, Color("#4f7fa3"))
	draw_circle(FOUNTAIN, 8.0, Color("#8fbcd9"))
	draw_circle(FOUNTAIN, 3.0, Color("#c9e6f5"))

	# 房屋：牆面、屋頂、門與發光的窗戶
	for house in HOUSES + EXTRA_HOUSES:
		var r: Rect2 = house["rect"]
		draw_rect(r, Color(house["wall"]))
		draw_colored_polygon(PackedVector2Array([
			Vector2(r.position.x - 6, r.position.y),
			Vector2(r.end.x + 6, r.position.y),
			Vector2(r.position.x + r.size.x / 2, r.position.y - 22),
		]), Color(house["roof"]))
		draw_rect(Rect2(r.position.x + r.size.x / 2 - 6, r.end.y - 18, 12, 18), Color("#5c3d24"))
		draw_rect(Rect2(r.position.x + 12, r.position.y + 16, 12, 12), Color("#ffd98a"))
		draw_rect(Rect2(r.end.x - 24, r.position.y + 16, 12, 12), Color("#ffd98a"))

	# Wooden wayfinding signs with readable labels.
	_draw_sign(Vector2(215, 203), "INN", true)
	_draw_sign(Vector2(396, 216), "SHOP", false)
	_draw_sign(Vector2(320, 322), "FOREST", false)
	# 小花圃與樹木
	for pos in [Vector2(220, 160), Vector2(410, 300), Vector2(180, 380)]:
		draw_circle(pos, 3.0, Color("#c77d97"))
	for pos in TREES:
		draw_tree(pos)

	# 村口出口的路標（指向森林）
	draw_rect(Rect2(28, 196, 3, 22), Color("#5c3d24"))
	draw_rect(Rect2(14, 186, 26, 10), Color("#d8c39a"))


func _draw_sign(pos: Vector2, label: String, point_right: bool) -> void:
	draw_rect(Rect2(pos.x - 2, pos.y - 1, 4, 20), Color("#513927"))
	draw_rect(Rect2(pos.x - 22, pos.y - 13, 44, 13), Color("#a97849"))
	draw_rect(Rect2(pos.x - 20, pos.y - 11, 40, 9), Color("#e5c18b"))
	var tip: float = 26.0 if point_right else -26.0
	draw_colored_polygon(PackedVector2Array([Vector2(pos.x + (20 if point_right else -20), pos.y - 13), Vector2(pos.x + tip, pos.y - 7), Vector2(pos.x + (20 if point_right else -20), pos.y)]), Color("#a97849"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(-20, -3), label, HORIZONTAL_ALIGNMENT_CENTER, 40, 9, Color("#392a2a"))


func npc_data() -> Array:
	return [
		{"id": "mayor", "name": "村長老維", "pos": Vector2(320, 160), "color": Color(0.6, 0.45, 0.7)},
		{"id": "blacksmith", "name": "鐵匠石頭伯", "pos": Vector2(180, 224), "color": Color(0.45, 0.45, 0.5)},
		{"id": "innkeeper", "name": "旅店老闆娘小芽", "pos": Vector2(500, 292), "color": Color(0.9, 0.5, 0.5)},
		{"id": "child", "name": "小女孩米米", "pos": Vector2(360, 304), "color": Color(0.95, 0.8, 0.4)},
		{"id": "merchant", "name": "旅行商人阿珂", "pos": Vector2(200, 300), "color": Color(0.5, 0.7, 0.8)},
		{"id": "guard", "name": "守衛阿力", "pos": Vector2(320, 390), "color": Color(0.3, 0.5, 0.3)},
	]


func pickup_data() -> Array:
	return [
		{"uid": "village_berry", "item": "berry", "pos": Vector2(120, 300)},
		{"uid": "village_mushroom", "item": "mushroom", "pos": Vector2(540, 400)},
	]


func exit_data() -> Array:
	return [
		{"rect": Rect2(0, 222, 24, 36), "target": "res://scenes/forest.tscn", "spawn": Vector2(590, 240)},
	]


func lamp_positions() -> Array:
	return [Vector2(250, 170), Vector2(390, 170), Vector2(250, 300), Vector2(390, 300), Vector2(120, 260)]

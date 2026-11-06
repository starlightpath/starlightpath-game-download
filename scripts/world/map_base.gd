extends Node2D
## 地圖基底：生成角色、NPC、物品、出口、夜晚光影與系統介面。
## 子類別覆寫下方的地圖資料函式即可建立新地圖（森林、星光村……）。

const PlayerScript := preload("res://scripts/player/player.gd")
const HUDScript := preload("res://scripts/ui/hud.gd")
const MapExitScript := preload("res://scripts/world/map_exit.gd")
const LightUtilScript := preload("res://scripts/world/light_util.gd")
const TREE_TEXTURES := [
	preload("res://assets/environment/tree_1.png"),
	preload("res://assets/environment/tree_2.png"),
	preload("res://assets/environment/tree_3.png"),
]

var _player  # 玩家節點（以 Node 型別使用，避免靜態型別檢查失敗）
var _dialogue: DialogueBox
var _inventory: InventoryUI
var _pause: PauseMenu
var _hud
var _time := 0.0
var _firefly_home: Array[Vector2] = []


# ---------- 地圖資料（子類別覆寫） ----------

func map_size() -> Vector2:
	return Vector2(640, 480)


func scene_path() -> String:
	return ""


func ground_color() -> Color:
	return Color("#6f9f6c")


## 不可通行區域（樹木、建築、湖泊等）
func blockers() -> Array:
	return []


## 地面紋理、道路、建築、樹木等地圖繪製
func draw_map() -> void:
	pass


func npc_data() -> Array:
	return []


func pickup_data() -> Array:
	return []


## 出口：{"rect": Rect2, "target": 場景路徑, "spawn": 抵達後的出生點}
func exit_data() -> Array:
	return []


func lamp_positions() -> Array:
	return []


func firefly_count() -> int:
	return 0


## 第一次進入此地圖時觸發的事件旗標（空字串代表不觸發）
func enter_flag() -> String:
	return ""


## 第一次進入時呼叫，子類別可在此使用 _dialogue 顯示事件對話
func on_enter() -> void:
	pass


# ---------- 生命週期 ----------

func _ready() -> void:
	GameState.current_scene = scene_path()
	GameState.unlock_achievement("first_steps")
	_build_night_light()
	_build_blockers()
	_build_systems()
	_spawn_player()
	_spawn_exits()
	_spawn_npcs()
	_spawn_pickups()
	_spawn_lamps()
	_setup_fireflies()
	_check_enter_event()


func _process(delta: float) -> void:
	_time += delta
	# 對話、背包或暫停選單開啟時，鎖定玩家移動
	_player.input_enabled = not _dialogue.is_open and not _inventory.visible and not _pause.visible
	# 引導進度：依玩家實際操作設定旗標
	if _player.velocity.length() > 0.1:
		GameState.set_flag("tut_move")
	if _inventory.visible:
		GameState.set_flag("tut_inventory")
	var near: bool = (_player.find_interactable() != null) and bool(_player.input_enabled)
	_hud.refresh(StoryData.objective_text(), near)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F5:
			_save()
		elif event.keycode == KEY_F9:
			_load()

	if event.is_action_pressed("ui_cancel") and not _dialogue.is_open and not _inventory.visible:
		get_viewport().set_input_as_handled()
		if _pause.visible:
			_pause.close()
		else:
			_pause.open()


# ---------- 繪製 ----------

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, map_size()), ground_color())
	draw_map()

	# 路燈柱（燈光由 PointLight2D 提供）
	for pos in lamp_positions():
		draw_circle(pos + Vector2(0, 2), 5.0, Color(0.02, 0.04, 0.06, 0.24))
		draw_rect(Rect2(pos.x - 2, pos.y - 13, 4, 16), Color("#3e3032"))
		draw_rect(Rect2(pos.x - 1, pos.y - 13, 1, 15), Color("#8b6c49"))
		draw_rect(Rect2(pos.x - 5, pos.y - 20, 10, 9), Color("#2c3440"))
		draw_rect(Rect2(pos.x - 3, pos.y - 19, 6, 7), Color("#ffe6a3"))
		draw_rect(Rect2(pos.x - 2, pos.y - 18, 4, 5), Color("#fff7d4"))
		draw_rect(Rect2(pos.x - 6, pos.y - 22, 12, 2), Color("#26323e"))

	# 螢火蟲：在家位置附近緩緩飛舞並閃爍
	for home in _firefly_home:
		var p := home + Vector2(sin(_time * 0.8 + home.x) * 12.0, cos(_time * 0.6 + home.y) * 8.0)
		var alpha := 0.3 + 0.7 * absf(sin(_time * 2.0 + home.x))
		draw_circle(p, 1.5, Color(0.85, 1.0, 0.5, alpha))


## Transparent pixel-art trees. Position denotes the trunk base, matching existing blockers.
## Drawn in map coordinates; no collision or save-game changes.
func draw_tree(pos: Vector2) -> void:
	var variant: int = absi(int(pos.x * 7.0 + pos.y * 11.0)) % TREE_TEXTURES.size()
	var texture: Texture2D = TREE_TEXTURES[variant]
	var size: Vector2 = Vector2(48, 55)
	# Subtle grounding shadow, followed by the textured tree canopy.
	draw_ellipse_shadow(pos)
	draw_texture_rect(texture, Rect2(pos.x - 24.0, pos.y - 47.0, size.x, size.y), false)


func draw_ellipse_shadow(pos: Vector2) -> void:
	draw_circle(pos + Vector2(0, 3), 10.0, Color(0.06, 0.15, 0.12, 0.18))


# ---------- 生成 ----------

## 夜晚色調：整個地圖（不含 UI）染上深藍色調。
func _build_night_light() -> void:
	var mod := CanvasModulate.new()
	mod.color = Color(0.42, 0.46, 0.68)
	add_child(mod)


func _build_blockers() -> void:
	var s := map_size()
	var rects: Array = blockers()
	# 地圖邊界
	rects.append(Rect2(-10, 0, 10, s.y))
	rects.append(Rect2(s.x, 0, 10, s.y))
	rects.append(Rect2(0, -10, s.x, 10))
	rects.append(Rect2(0, s.y, s.x, 10))
	for rect in rects:
		_add_blocker(rect)


func _add_blocker(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	add_child(body)


func _build_systems() -> void:
	_dialogue = DialogueBox.new()
	add_child(_dialogue)

	_inventory = InventoryUI.new()
	add_child(_inventory)

	_hud = HUDScript.new()
	add_child(_hud)

	_pause = PauseMenu.new()
	add_child(_pause)
	_pause.resume_requested.connect(_pause.close)
	_pause.save_requested.connect(_on_pause_save)
	GameState.achievement_unlocked.connect(_on_achievement_unlocked)


func _spawn_player() -> void:
	_player = PlayerScript.new()
	_player.position = GameState.player_position
	add_child(_player)
	var s := map_size()
	_player.camera.limit_left = 0
	_player.camera.limit_top = 0
	_player.camera.limit_right = int(s.x)
	_player.camera.limit_bottom = int(s.y)


func _spawn_exits() -> void:
	for data in exit_data():
		var rect: Rect2 = data["rect"]
		var exit = MapExitScript.new()
		exit.exit_size = rect.size
		exit.target_scene = data["target"]
		exit.spawn_point = data["spawn"]
		exit.position = rect.get_center()
		add_child(exit)


func _spawn_npcs() -> void:
	for data in npc_data():
		var npc := NPC.new()
		npc.npc_id = data["id"]
		npc.npc_name = data["name"]
		npc.shirt_color = data["color"]
		npc.position = data["pos"]
		add_child(npc)
		npc.interacted.connect(_on_npc_interacted)


func _spawn_pickups() -> void:
	for data in pickup_data():
		# 已撿取過的物品不再生成
		if data["uid"] in GameState.collected_pickups:
			continue
		var pickup := Pickup.new()
		pickup.uid = data["uid"]
		pickup.item_id = data["item"]
		pickup.position = data["pos"]
		add_child(pickup)
		pickup.picked.connect(_on_item_picked)


func _spawn_lamps() -> void:
	for pos in lamp_positions():
		var light := PointLight2D.new()
		light.texture = LightUtilScript.make_texture()
		light.texture_scale = 1.2
		light.color = Color(1.0, 0.85, 0.55)
		light.energy = 0.9
		light.position = pos + Vector2(0, -12)
		add_child(light)


func _setup_fireflies() -> void:
	var s := map_size()
	for i in range(firefly_count()):
		_firefly_home.append(Vector2(randf_range(20, s.x - 20), randf_range(20, s.y - 20)))


func _check_enter_event() -> void:
	var flag := enter_flag()
	if flag == "" or GameState.has_flag(flag):
		return
	GameState.set_flag(flag)
	on_enter()


# ---------- 事件處理 ----------

func _on_npc_interacted(npc: NPC) -> void:
	GameState.set_flag("tut_talk")
	_dialogue.open(QuestData.talk(npc.npc_id))


func _on_item_picked(item_id: String) -> void:
	GameState.set_flag("tut_pick")
	_dialogue.open([GameState.t("你撿到了：%s") % GameState.t(ItemData.item_name(item_id))])


func _on_pause_save() -> void:
	_pause.close()
	_save()


# ---------- 存讀檔 ----------

func _save() -> void:
	GameState.set_flag("tut_save")
	GameState.player_position = _player.global_position
	GameState.current_scene = scene_path()
	var ok := GameState.save_game()
	_dialogue.open(["已儲存進度。"] if ok else ["存檔失敗。"])


func _load() -> void:
	if GameState.load_game():
		# 回到存檔時所在的地圖
		get_tree().change_scene_to_file(GameState.current_scene)
	else:
		_dialogue.open(["還沒有存檔喔。"])


func _on_achievement_unlocked(id: String) -> void:
	if _dialogue != null and not _dialogue.is_open:
		_dialogue.open([("Achievement unlocked: " if GameState.language == "en" else "解鎖成就：") + GameState.achievement_title(id)])

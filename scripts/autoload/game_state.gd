extends Node
## 全域狀態（Autoload）：背包、任務、劇情旗標、已撿取物品、存讀檔與輸入對應。

signal inventory_changed
signal quest_changed(quest_id: String)

# Windows 匯出版：EXE 旁的 game_save_data；編輯器：專案根目錄。
# 注意：需放在可寫入資料夾，不能放在 Program Files。
const SAVE_FILE := "save.json"
const LEGACY_SAVE_PATH := "user://savegame.json"
const SETTINGS_PATH := "user://settings.json"
const EN_TEXT := preload("res://scripts/data/en_text.gd")

var master_volume: float = 1.0
var fullscreen: bool = false
var active_slot: int = 1
var achievements: Dictionary = {}
signal achievement_unlocked(achievement_id: String)

const ACHIEVEMENTS := {
	"first_steps": ["初踏星徑", "First Steps", "踏入星光森林。", "Enter Starlight Forest."],
	"first_pickup": ["森林收藏家", "Forest Collector", "撿起第一件物品。", "Pick up your first item."],
	"bunny_friend": ["兔子的朋友", "Bunny Friend", "找回兔子的胡蘿蔔。", "Return Bunny’s carrot."],
	"flower_keeper": ["花朵守護者", "Flower Keeper", "幫村民找回花朵。", "Return the villager’s flower."],
	"elder_trust": ["星光的信任", "Starlight’s Trust", "得到長老的認可。", "Earn the elder’s trust."],
	"village_visitor": ["村莊的客人", "Village Visitor", "抵達星光村。", "Reach Starlight Village."],
	"light_bringer": ["點燈人", "Light Bringer", "幫助米米重新點亮燈籠。", "Help Mimi relight her lantern."],
	"story_listener": ["傾聽星語", "Star Whisperer", "聽完村長的古老傳說。", "Hear the mayor’s old tale."],
	"first_save": ["留下足跡", "A Trail Remembered", "首次儲存進度。", "Save your journey for the first time."],
	"new_look": ["獨特旅人", "Your Own Look", "自訂旅行者外觀。", "Customize your traveler's appearance."],
	"lantern_path": ["燈火之路", "Lantern Path", "走進星光村的燈火。", "Discover the lantern-lit village."],
	"forest_explorer": ["森林探險家", "Forest Explorer", "蒐集三種不同物品。", "Collect three different kinds of items."],
	"helping_hand": ["溫暖之手", "Helping Hand", "完成兩項任務。", "Complete two quests."],
	"night_walker": ["夜行旅人", "Night Walker", "探索森林並拜訪村莊。", "Explore the forest and visit the village."],

}


var character_hair: int = 0
var character_skin: int = 0
var character_outfit: int = 0
const HAIR_COLORS := ["#a76b3b", "#302b45", "#e4c35f", "#ad5975", "#d4d6e2"]
const SKIN_COLORS := ["#ffd9b3", "#c68d65", "#e8b48d", "#8c5e48"]
const OUTFIT_COLORS := ["#5b8fd9", "#71ae8d", "#bc7398", "#d7a258", "#8884c9"]

func set_character_look(hair: int, skin: int, outfit: int) -> void:
	character_hair = clampi(hair, 0, HAIR_COLORS.size() - 1)
	character_skin = clampi(skin, 0, SKIN_COLORS.size() - 1)
	character_outfit = clampi(outfit, 0, OUTFIT_COLORS.size() - 1)
	unlock_achievement("new_look")

var language := "en"   # Default English for Beta 1.0.9; user choices saved.
const START_POSITION := Vector2(320, 420)

var inventory: Dictionary = {}        # item_id -> 數量
var quests: Dictionary = {}           # quest_id -> "inactive" / "active" / "done"
var flags: Dictionary = {}            # 劇情旗標：flag_name -> true
var collected_pickups: Array = []     # 已撿取的地上物品 uid
var player_position := START_POSITION
var current_scene := "res://scenes/forest.tscn"   # 目前所在地圖，存檔後可回到同一地點


func _ready() -> void:
	_load_settings()
	_apply_settings()
	_setup_input_map()
	_setup_font()


## 讓所有 UI 文字使用支援中文的系統字型（Godot 預設字型不含中文）。
func _setup_font() -> void:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Microsoft JhengHei", "PingFang TC", "Noto Sans CJK TC", "Noto Sans TC", "sans-serif"])
	ThemeDB.fallback_font = font


## 以程式碼建立輸入對應。ui_* 會讓主選單與按鈕也能用 W/S/E 操作。
func _setup_input_map() -> void:
	var actions := {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"interact": [KEY_E],
		"advance": [KEY_SPACE, KEY_E],
		"inventory": [KEY_I],
		"ui_up": [KEY_W],
		"ui_down": [KEY_S],
		"ui_accept": [KEY_E],
	}
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in actions[action]:
			var ev := InputEventKey.new()
			ev.physical_keycode = key
			InputMap.action_add_event(action, ev)


# ---------- 語言 ----------

## 將中文原文轉換為目前語言；英文模式下找不到對應時回傳原文。
func t(text: String) -> String:
	if language == "en" and EN_TEXT.TABLE.has(text):
		return EN_TEXT.TABLE[text]
	return text


func set_language(lang: String) -> void:
	language = lang
	_save_settings()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_settings()
	_save_settings()


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled
	_apply_settings()
	_save_settings()


func _apply_settings() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_volume, 0.0001)))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)


func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"language": language, "language_selected": true, "master_volume": master_volume, "fullscreen": fullscreen}))
		file.close()


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		language = str(parsed.get("language", "en")) if bool(parsed.get("language_selected", false)) else "en"
		if language != "zh" and language != "en":
			language = "en"
		master_volume = clampf(float(parsed.get("master_volume", 1.0)), 0.0, 1.0)
		fullscreen = bool(parsed.get("fullscreen", false))


# ---------- 新遊戲 ----------

## 開始新遊戲時清空所有進度。
func reset_new_game() -> void:
	inventory = {}
	quests = {}
	flags = {}
	collected_pickups = []
	achievements = {}
	player_position = START_POSITION
	current_scene = "res://scenes/forest.tscn"
	inventory_changed.emit()


# ---------- 劇情旗標 ----------

func set_flag(flag: String) -> void:
	flags[flag] = true
	if flag == "elder_revealed":
		unlock_achievement("elder_trust")
	elif flag == "village_arrived":
		unlock_achievement("village_visitor")
		unlock_achievement("lantern_path")
		if has_flag("forest_welcome"):
			unlock_achievement("night_walker")


func has_flag(flag: String) -> bool:
	return flags.get(flag, false)


# ---------- 背包 ----------

func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = get_item_count(item_id) + amount
	inventory_changed.emit()
	if amount > 0:
		unlock_achievement("first_pickup")
		if inventory.size() >= 3:
			unlock_achievement("forest_explorer")


func remove_item(item_id: String, amount: int = 1) -> bool:
	if get_item_count(item_id) < amount:
		return false
	inventory[item_id] -= amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	inventory_changed.emit()
	return true


func get_item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


# ---------- 任務 ----------

func quest_state(quest_id: String) -> String:
	return quests.get(quest_id, "inactive")


func start_quest(quest_id: String) -> void:
	quests[quest_id] = "active"
	quest_changed.emit(quest_id)


func complete_quest(quest_id: String) -> void:
	quests[quest_id] = "done"
	quest_changed.emit(quest_id)
	if _completed_count(quests) >= 2:
		unlock_achievement("helping_hand")
	match quest_id:
		"bunny_carrot": unlock_achievement("bunny_friend")
		"villager_flower": unlock_achievement("flower_keeper")
		"child_lantern": unlock_achievement("light_bringer")


func unlock_achievement(achievement_id: String) -> void:
	if achievements.has(achievement_id) or not ACHIEVEMENTS.has(achievement_id):
		return
	achievements[achievement_id] = true
	achievement_unlocked.emit(achievement_id)


func achievement_title(achievement_id: String) -> String:
	var entry: Array = ACHIEVEMENTS.get(achievement_id, [])
	if entry.is_empty():
		return achievement_id
	return str(entry[1] if language == "en" else entry[0])


func achievement_description(achievement_id: String) -> String:
	var entry: Array = ACHIEVEMENTS.get(achievement_id, [])
	if entry.is_empty():
		return ""
	return str(entry[3] if language == "en" else entry[2])


# ---------- 存讀檔 ----------

func get_save_directory() -> String:
	var base_dir: String
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")
	else:
		base_dir = OS.get_executable_path().get_base_dir()
	return base_dir.path_join("game_save_data")


func get_save_path(slot: int = 0) -> String:
	var target: int = active_slot if slot == 0 else slot
	return get_save_directory().path_join("slot_%d.json" % clampi(target, 1, 5))


func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(get_save_path(slot)) or (slot <= 1 and FileAccess.file_exists(get_save_directory().path_join(SAVE_FILE))) or (slot <= 1 and FileAccess.file_exists(LEGACY_SAVE_PATH))


func select_slot(slot: int) -> void:
	active_slot = clampi(slot, 1, 5)


func slot_summary(slot: int) -> String:
	if not has_save(slot):
		return "Empty" if language == "en" else "空白存檔"
	var path: String = get_save_path(slot)
	if not FileAccess.file_exists(path):
		return "Legacy save" if language == "en" else "舊版存檔"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return "Unreadable" if language == "en" else "無法讀取"
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return "Corrupted" if language == "en" else "存檔損壞"
	var scene_name: String = "Village" if "village" in str(parsed.get("scene", "")) else "Forest"
	if language == "zh":
		scene_name = "星光村" if scene_name == "Village" else "星光森林"
	return "%s · %d/4 quests" % [scene_name, _completed_count(parsed.get("quests", {}))] if language == "en" else "%s · %d/4 任務" % [scene_name, _completed_count(parsed.get("quests", {}))]


func _completed_count(saved_quests: Dictionary) -> int:
	var total: int = 0
	for quest_id in saved_quests:
		if saved_quests[quest_id] == "done":
			total += 1
	return total


func save_game() -> bool:
	unlock_achievement("first_save")
	var data: Dictionary = {
		"version": "1.0.8", "slot": active_slot,
		"inventory": inventory, "quests": quests, "flags": flags,
		"achievements": achievements,
		"scene": current_scene, "collected_pickups": collected_pickups,
		"position": [player_position.x, player_position.y],
		"character": {"hair": character_hair, "skin": character_skin, "outfit": character_outfit},
	}
	var save_path: String = get_save_path()
	var err: Error = DirAccess.make_dir_recursive_absolute(save_path.get_base_dir())
	if err != OK:
		push_error("Save directory creation failed: %s" % error_string(err))
		return false
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write save: %s" % save_path)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func load_game() -> bool:
	var save_path: String = get_save_path()
	if not FileAccess.file_exists(save_path):
		if active_slot == 1 and FileAccess.file_exists(get_save_directory().path_join(SAVE_FILE)):
			save_path = get_save_directory().path_join(SAVE_FILE)
		elif active_slot == 1 and FileAccess.file_exists(LEGACY_SAVE_PATH):
			save_path = LEGACY_SAVE_PATH
		else:
			return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return false
	var data: Dictionary = parsed
	var loaded_inventory: Variant = data.get("inventory", {})
	if not (loaded_inventory is Dictionary):
		return false
	inventory = {}
	for key in loaded_inventory:
		inventory[key] = int(loaded_inventory[key])
	quests = data.get("quests", {})
	flags = data.get("flags", {})
	achievements = data.get("achievements", {})
	var look: Dictionary = data.get("character", {})
	character_hair = clampi(int(look.get("hair", 0)), 0, HAIR_COLORS.size() - 1)
	character_skin = clampi(int(look.get("skin", 0)), 0, SKIN_COLORS.size() - 1)
	character_outfit = clampi(int(look.get("outfit", 0)), 0, OUTFIT_COLORS.size() - 1)
	current_scene = str(data.get("scene", "res://scenes/forest.tscn"))
	if current_scene not in ["res://scenes/forest.tscn", "res://scenes/village.tscn"]:
		current_scene = "res://scenes/forest.tscn"
	collected_pickups = data.get("collected_pickups", [])
	var pos: Array = data.get("position", [START_POSITION.x, START_POSITION.y])
	if pos.size() < 2:
		return false
	player_position = Vector2(float(pos[0]), float(pos[1]))
	inventory_changed.emit()
	return true

class_name StoryData
extends RefCounted
## 劇情資料：開場、目標提示、以及沒有任務的 NPC 台詞。台詞會依任務進度與劇情旗標改變。

const INTRO := [
	{"speaker": "旁白", "text": "很久很久以前，夜空中掛著一條由星光鋪成的小徑，一路通往森林深處。"},
	{"speaker": "旁白", "text": "星光照亮了每一棵樹、每一朵花，讓森林裡的動物們永遠不會迷路。"},
	{"speaker": "旁白", "text": "但某一天，最明亮的一顆星星碎片墜落到了森林裡……從那天起，小徑開始變得暗淡。"},
	{"speaker": "旅行者", "text": "這裡是……哪裡？我明明只是沿著山路走，怎麼會來到這片森林？"},
	{"speaker": "旅行者", "text": "好安靜的森林。等等……我好像聽見了細細的歌聲，是從樹林深處傳來的。"},
	{"speaker": "旁白", "text": "夜色已深，提著燈的旅行者，你的冒險，就從這片星光森林開始了。"},
	{"speaker": "旁白", "text": "微風送來一封沒有署名的信：『當五個願望在夜裡亮起，回家的道路就會出現。』"},
	{"speaker": "旅行者", "text": "五個願望……是五顆星星嗎？還是五個等待幫助的人？"},
]


## 左上角顯示的目標：依引導進度與任務狀態決定。
static func objective_text() -> String:
	if not GameState.has_flag("tut_move"):
		return "用 WASD 或方向鍵移動，探索夜晚的森林"
	if not GameState.has_flag("tut_talk"):
		return "走向附近的居民，按 E 與他們對話"
	if not GameState.has_flag("tut_pick"):
		return "撿起發光的物品，靠近後按 E 撿取"
	if not GameState.has_flag("tut_inventory"):
		return "按 I 查看背包"
	if not GameState.has_flag("tut_save"):
		return "按 F5 存檔，按 ESC 可開啟暫停選單"
	if GameState.quest_state("bunny_carrot") != "done":
		return "幫小兔子找回胡蘿蔔"
	if GameState.quest_state("villager_flower") != "done":
		return "幫村民找回一朵花"
	if not GameState.has_flag("elder_revealed"):
		return "前往森林深處，尋找星光長老"
	if not GameState.has_flag("village_arrived"):
		return "往東邊的小路走，前往星光村"
	if GameState.quest_state("blacksmith_wood") != "done":
		return "幫鐵匠石頭伯找一根木材"
	if GameState.quest_state("child_lantern") != "done":
		return "把燈籠交給廣場附近的小女孩米米"
	return "回到村長身邊，聽聽星光與五個願望的傳說" if not GameState.has_flag("mayor_story") else "星光村的故事仍在延續，自由探索吧"


## 依 NPC 與劇情進度回傳台詞（沒有任務的 NPC 使用這裡）。
static func npc_lines(npc_id: String) -> Array:
	match npc_id:
		"fox":
			return _fox_lines()
		"elder":
			return _elder_lines()
		"squirrel":
			return _squirrel_lines()
		"fairy":
			return _fairy_lines()
		"mayor":
			return _mayor_lines()
		"innkeeper":
			return _innkeeper_lines()
		"merchant":
			return _merchant_lines()
		"guard":
			return _guard_lines()
	return ["……"]


# ---------- 森林居民 ----------

static func _fox_lines() -> Array:
	if not GameState.has_flag("intro_done"):
		return ["小狐狸：我好像迷路了…但是森林的空氣好舒服喔。"]
	if GameState.quest_state("bunny_carrot") == "done":
		return ["小狐狸：聽說你幫小兔子找回了胡蘿蔔，你真是個好心的旅人呢！"]
	return [
		"小狐狸：你也是被星光帶來的旅人嗎？我好像迷路了…回家的路不見了。",
		"小狐狸：如果你看到一間有紅色屋頂的小木屋，記得告訴我喔。",
	]


static func _elder_lines() -> Array:
	if GameState.has_flag("elder_revealed"):
		return ["星光長老：森林已經漸漸恢復光亮了。往東邊的小路走，會看見一座熱鬧的村莊。", "星光長老：你每幫助一位朋友，失落的小徑就亮起一段。不要急著追逐終點，沿途的溫柔才是森林真正的秘密。"]
	var both_done := GameState.quest_state("bunny_carrot") == "done" \
		and GameState.quest_state("villager_flower") == "done"
	if both_done:
		GameState.set_flag("elder_revealed")
		return [
			"星光長老：你願意幫助森林裡的每一位朋友，星光也看見了你的善意。",
			"星光長老：很久以前，最亮的那顆星星碎片墜落在森林深處，守護著通往神殿的路。",
			"星光長老：森林之外還有人類的村莊，他們的燈火也需要被照亮。往東邊去吧。",
		]
	return [
		"星光長老：年輕的旅人，星光不會回應陌生人的呼喚。",
		"星光長老：先去幫助森林裡需要幫忙的朋友吧，他們的感謝會成為照亮小徑的光。",
	]


static func _squirrel_lines() -> Array:
	if GameState.has_flag("village_arrived"):
		return [
			"松鼠松果：吱吱！聽說村子裡的鐵匠在找木頭呢，你要是有多的，就幫幫他吧！",
			"松鼠松果：村子的廣場中央有個噴水池，夜裡水聲特別好聽喔。",
		]
	return [
		"松鼠松果：吱吱！你是新來的嗎？我藏了好多橡果，結果忘記藏在哪裡了！",
		"松鼠松果：如果你看到橡果，記得告訴我喔。",
	]


static func _fairy_lines() -> Array:
	if not GameState.has_flag("tut_inventory"):
		return [
			"精靈露露：夜晚的森林有很多小秘密喔。",
			"精靈露露：按 I 可以打開背包，看看你身上有什麼吧。",
		]
	return [
		"精靈露露：湖面映出的星光，是在等待有人喚醒它們。",
		"精靈露露：星光小徑的盡頭，據說連著一座古老的神殿，但只有在星光醒來時才會開啟。",
	]


# ---------- 星光村 ----------

static func _mayor_lines() -> Array:
	if GameState.has_flag("child_helped"):
		if not GameState.has_flag("mayor_story"):
			GameState.set_flag("mayor_story")
			GameState.unlock_achievement("story_listener")
			return ["村長老維：你知道嗎？從前每一顆星星都代表一個願意守護他人的心願。", "村長老維：小兔子的勇氣、村民的花、鐵匠的燈，以及米米的笑容，都是星光留下的回音。", "村長老維：還有最後一個願望尚未說出口。也許，當你找到回家的路時，就會明白它是什麼。", "旅行者：原來星光從來不是為了指引某一個人，而是讓每個迷路的人都能找到彼此。"]
		return [
			"村長老維：聽說你幫小女孩找回了燈籠，謝謝你。",
			"村長老維：這個村子需要更多像你這樣願意幫忙的人。",
		]
	return [
		"村長老維：歡迎來到星光村。自從星光變暗後，村子的夜晚就特別冷清。",
		"村長老維：村裡的人都很善良，只是最近大家都有些擔心。你可以四處看看。",
	]


static func _innkeeper_lines() -> Array:
	if GameState.has_flag("child_helped"):
		return [
			"旅店老闆娘小芽：孩子們都很喜歡你呢，夜裡的燈籠又亮起來了。",
			"旅店老闆娘小芽：今晚的房間還空著，住一晚再走吧，窗外的星星很漂亮。",
		]
	return ["旅店老闆娘小芽：今晚的房間還空著喔，住一晚再走吧，窗外的星星很漂亮。"]


static func _merchant_lines() -> Array:
	return [
		"旅行商人阿珂：我走遍了不少地方，聽說北方有座古老的星光神殿。",
		"旅行商人阿珂：要是你找到了神殿的入口，記得告訴我，我想去看看。",
	]


static func _guard_lines() -> Array:
	return [
		"守衛阿力：夜裡要注意安全喔，森林那邊偶爾會有奇怪的風聲。",
		"守衛阿力：如果看到有人需要幫忙，就去幫一把吧，村子就是靠大家互相照應。",
	]

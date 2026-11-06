class_name QuestData
extends RefCounted
## 任務資料。依任務進度（inactive / active / done）回傳不同台詞。
## requires：需先完成的任務；set_flag：完成時設定的劇情旗標。

const QUESTS := {
	"bunny_carrot": {
		"giver": "bunny",
		"need_item": "carrot",
		"reward_item": "star_shard",
		"reward_amount": 1,
		"lines_offer": [
			"小兔子：嗚嗚…我的胡蘿蔔不見了。今天早上我明明把它放在洞口的。",
			"小兔子：你可以幫我在森林裡找找看嗎？我好害怕它被大風吹走了…",
		],
		"lines_waiting": ["小兔子：胡蘿蔔還沒找到嗎？我記得它是橘色的，可能掉在森林的某個角落喔。"],
		"lines_done": [
			"小兔子：啊！是我的胡蘿蔔！你真的找到了！",
			"小兔子：謝謝你！這個星星碎片是我在洞穴旁撿到的，送給你當作謝禮吧。",
		],
		"lines_after": ["小兔子：有你在，森林變得更安心了呢。"],
	},
	"villager_flower": {
		"giver": "villager",
		"need_item": "flower",
		"reward_item": "mushroom",
		"reward_amount": 2,
		"lines_offer": [
			"村民：唉，昨晚的風好大，花圃裡的花都被吹散了。",
			"村民：如果你能找到一朵花，我會好好謝謝你。草地上應該還有幾朵呢。",
		],
		"lines_waiting": ["村民：花朵還沒找到嗎？小路邊和湖邊都可以找找看。"],
		"lines_done": [
			"村民：哇，這朵花好漂亮！謝謝你，我正好需要它來裝飾村子的入口。",
			"村民：這些蘑菇是我今早採的，拿去吃吧，走路會更有力氣喔。",
		],
		"lines_after": ["村民：花圃又恢復漂亮了，大家都很感謝你。"],
	},
	"blacksmith_wood": {
		"giver": "blacksmith",
		"need_item": "wood",
		"reward_item": "lantern",
		"reward_amount": 1,
		"lines_offer": [
			"鐵匠石頭伯：嘿，旅人！我正缺一根木材來修補燈籠的支架。",
			"鐵匠石頭伯：森林裡應該有幾根掉落的木頭，幫我找一根回來，我就做一盞燈籠報答你。",
		],
		"lines_waiting": ["鐵匠石頭伯：木頭還沒找到嗎？森林裡地上那些棕色的木段都可以。"],
		"lines_done": [
			"鐵匠石頭伯：好木頭！說到做到，這盞燈籠送你。",
			"鐵匠石頭伯：夜裡走路得有光才行，但它也能照亮別人的路。",
		],
		"lines_after": ["鐵匠石頭伯：燈籠還亮著嗎？那就好。我的爐火也還沒熄呢。"],
	},
	"child_lantern": {
		"giver": "child",
		"requires": "blacksmith_wood",
		"need_item": "lantern",
		"reward_item": "berry",
		"reward_amount": 3,
		"set_flag": "child_helped",
		"lines_locked": ["小女孩米米：嗚…我的燈籠被風吹熄了，爸爸說要等鐵匠伯伯有空才能修。"],
		"lines_offer": [
			"小女孩米米：你好！我的燈籠被風吹熄了…如果你有燈籠，可以借我照一下路嗎？",
		],
		"lines_waiting": ["小女孩米米：燈籠…還沒有嗎？鐵匠伯伯那邊應該有喔。"],
		"lines_done": [
			"小女孩米米：哇！燈籠又亮起來了！謝謝你，這些野莓是我早上採的，送給你！",
		],
		"lines_after": ["小女孩米米：晚上的廣場現在好亮喔，我都不怕了。"],
	},
}


## 與 NPC 對話時呼叫，回傳這次要顯示的台詞，並更新任務狀態。
static func talk(npc_id: String) -> Array:
	for quest_id in QUESTS:
		var q: Dictionary = QUESTS[quest_id]
		if q["giver"] != npc_id:
			continue
		if q.has("requires") and GameState.quest_state(q["requires"]) != "done":
			return q["lines_locked"]
		match GameState.quest_state(quest_id):
			"inactive":
				GameState.start_quest(quest_id)
				return q["lines_offer"]
			"active":
				if GameState.get_item_count(q["need_item"]) >= 1:
					GameState.remove_item(q["need_item"], 1)
					GameState.add_item(q["reward_item"], q["reward_amount"])
					GameState.complete_quest(quest_id)
					if q.has("set_flag"):
						GameState.set_flag(q["set_flag"])
					return q["lines_done"]
				return q["lines_waiting"]
			"done":
				return q["lines_after"]
	return StoryData.npc_lines(npc_id)

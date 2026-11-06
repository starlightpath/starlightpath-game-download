class_name ItemData
extends RefCounted
## 物品定義：名稱與顏色集中管理，方便之後替換成正式圖示。

const ITEM_IDS := ["mushroom", "flower", "wood", "carrot", "star_shard", "berry", "lantern"]


static func item_name(item_id: String) -> String:
	match item_id:
		"mushroom": return "蘑菇"
		"flower": return "花朵"
		"wood": return "木材"
		"carrot": return "胡蘿蔔"
		"star_shard": return "星星碎片"
		"berry": return "野莓"
		"lantern": return "燈籠"
	return item_id


static func item_color(item_id: String) -> Color:
	match item_id:
		"mushroom": return Color("#e76f51")
		"flower": return Color("#f4a7c0")
		"wood": return Color("#a0714f")
		"carrot": return Color("#f48c3a")
		"star_shard": return Color("#ffe27a")
		"berry": return Color("#d6336c")
		"lantern": return Color("#ffb347")
	return Color.WHITE

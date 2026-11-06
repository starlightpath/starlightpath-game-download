class_name Pickup
extends Node2D
## Distinct illustrated silhouettes for each collectible.
signal picked(item_id: String)
var item_id := ""
var uid := ""
var _time := 0.0

func _ready() -> void:
    add_to_group("interactable")

func _process(delta: float) -> void:
    _time += delta
    queue_redraw()

func interact(_player: Node) -> void:
    GameState.add_item(item_id, 1)
    GameState.collected_pickups.append(uid)
    picked.emit(item_id)
    queue_free()

func _draw() -> void:
    var bob: float = sin(_time * 2.6) * 1.5
    var glow: float = 0.16 + 0.08 * sin(_time * 4.0)
    draw_circle(Vector2(0, 3), 10, Color(1.0, 0.87, 0.52, glow))
    draw_ellipse_shadow()
    draw_set_transform(Vector2(0, bob))
    match item_id:
        "mushroom":
            draw_rect(Rect2(-2, -1, 4, 9), Color("#f4d9b4"))
            draw_colored_polygon(PackedVector2Array([Vector2(-9,0),Vector2(-7,-6),Vector2(-3,-10),Vector2(3,-10),Vector2(8,-5),Vector2(9,0)]),Color("#d95b58"))
            draw_circle(Vector2(-3,-5),1.5,Color("#fff2db"))
            draw_circle(Vector2(4,-3),1.5,Color("#fff2db"))
        "flower":
            draw_line(Vector2(0,7),Vector2(0,-4),Color("#548f61"),2)
            draw_line(Vector2(0,3),Vector2(-5,0),Color("#6db77b"),2)
            for a in range(5):
                var v := Vector2.RIGHT.rotated(float(a)*TAU/5.0)*4.5
                draw_circle(Vector2(0,-6)+v,3.2,Color("#f5a4d1"))
            draw_circle(Vector2(0,-6),2.5,Color("#ffe184"))
        "wood":
            draw_line(Vector2(-7,5),Vector2(7,-5),Color("#523c30"),7)
            draw_line(Vector2(-7,5),Vector2(7,-5),Color("#ae7952"),4)
            draw_circle(Vector2(-7,5),2.3,Color("#dfb783"))
        "carrot":
            draw_colored_polygon(PackedVector2Array([Vector2(-5,-4),Vector2(5,-4),Vector2(0,9)]),Color("#f28b40"))
            draw_line(Vector2(0,-4),Vector2(-4,-10),Color("#69ae64"),2)
            draw_line(Vector2(0,-4),Vector2(4,-11),Color("#69ae64"),2)
            draw_line(Vector2(0,-4),Vector2(0,-12),Color("#8ac975"),2)
        "star_shard":
            draw_colored_polygon(PackedVector2Array([Vector2(0,-12),Vector2(5,-2),Vector2(3,7),Vector2(-4,11),Vector2(-6,-1)]),Color("#ffe486"))
            draw_line(Vector2(0,-9),Vector2(-2,6),Color("#fff8ce"),2)
        "berry":
            draw_circle(Vector2(-4,1),4,Color("#c83e71"))
            draw_circle(Vector2(3,2),4,Color("#a72e64"))
            draw_circle(Vector2(0,-4),4,Color("#df4b82"))
            draw_line(Vector2(0,-6),Vector2(2,-11),Color("#71b96a"),2)
        "lantern":
            draw_rect(Rect2(-5,-6,10,12),Color("#7c533e"))
            draw_rect(Rect2(-3,-4,6,8),Color("#ffd47a"))
            draw_line(Vector2(-5,-7),Vector2(5,-7),Color("#d6ac67"),2)
            draw_arc(Vector2(0,-7),4,PI,TAU,9,Color("#d6ac67"),1.5)
        _:
            draw_circle(Vector2.ZERO,5,ItemData.item_color(item_id))
    draw_set_transform(Vector2.ZERO)

func draw_ellipse_shadow() -> void:
    draw_colored_polygon(PackedVector2Array([Vector2(-7,9),Vector2(7,9),Vector2(10,11),Vector2(-10,11)]),Color(0,0,0,0.22))

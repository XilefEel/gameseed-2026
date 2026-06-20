class_name BlackHole
extends Node2D

@onready var grid: TileMapLayer = get_parent()
var cell := Vector2i(4, 4)

func _ready() -> void:
    add_to_group("blackholes")
    position = grid.map_to_local(cell)


func distance_to(other: Vector2i) -> int:
    return abs(other.x - cell.x) + abs(other.y - cell.y)


func is_red_zone(other: Vector2i) -> bool:
    return distance_to(other) == 1


func is_yellow_zone(other: Vector2i) -> bool:
    return distance_to(other) == 2


func is_on_blackhole(other: Vector2i) -> bool:
    return other == cell
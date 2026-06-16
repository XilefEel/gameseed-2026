extends Node2D

@onready var grid: TileMapLayer = get_parent()

var path := [
	Vector2i(3,0),
	Vector2i(3,1),
	Vector2i(3,2),
	Vector2i(3,3),
	Vector2i(3,4),
	Vector2i(4,4),
	Vector2i(4,5),
	Vector2i(4,6),
	Vector2i(4,7),
] 

var path_index := 0


func _ready() -> void:
	position = grid.map_to_local(path[0])


func step() -> void:
	path_index = (path_index + 1) % path.size()  # loops
	position = grid.map_to_local(path[path_index])


func get_cell() -> Vector2i:
	return path[path_index]

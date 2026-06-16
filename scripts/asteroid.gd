extends Node2D

@onready var grid: TileMapLayer = get_parent()
@export var path: Array[Vector2i] = [] 

var path_index := 0


func _ready() -> void:
	add_to_group("asteroids")
	position = grid.map_to_local(path[0])
	grid.mark_asteroid_path(path)


func step() -> void:
	path_index = (path_index + 1) % path.size()  # loops
	position = grid.map_to_local(path[path_index])


func get_cell() -> Vector2i:
	return path[path_index]

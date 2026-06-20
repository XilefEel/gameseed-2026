class_name Asteroid
extends Node2D

@onready var grid: TileMapLayer = get_parent()
@export var path: Array[Vector2i] = [] 

var path_index := 0


func _ready() -> void:
	add_to_group("asteroids")
	position = grid.map_to_local(path[0])


func step() -> void:
	path_index = (path_index + 1) % path.size()
	var target_pos = grid.map_to_local(path[path_index])
	var duration = position.distance_to(target_pos) / 200.0

	if path_index == 0:
		position = target_pos
	else:
		create_tween().tween_property(
			self,
			"position",
			target_pos,
			duration
		)


func get_cell() -> Vector2i:
	return path[path_index]


func get_next_cell() -> Vector2i:
	return path[(path_index + 1) % path.size()]
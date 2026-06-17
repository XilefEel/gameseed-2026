class_name PlayerHazards
extends Node

var player: Node2D

var asteroids: Array:
	get:
		return get_tree().get_nodes_in_group("asteroids")

var blackholes: Array:
	get:
		return get_tree().get_nodes_in_group("blackholes")

func _ready() -> void:
	player = get_parent()


func step_asteroids() -> Dictionary:
	var prev_cells := {}
	
	for a in asteroids:
		prev_cells[a] = a.get_cell()
		a.step()

	return prev_cells

func check_asteroid_collisions(prev_cells: Dictionary, cell: Vector2i) -> bool:
	for a in asteroids:
		var hit = a.get_cell() == cell
		var swapped = prev_cells[a] == cell
		
		if hit or swapped:
			return true

	return false


func is_on_blackhole(cell: Vector2i) -> bool:
	for b in blackholes:
		if b.is_on_blackhole(cell):
			return true
			
	return false


func is_in_red_zone(cell: Vector2i) -> bool:
	for b in blackholes:
		if b.is_red_zone(cell):
			return true

	return false


func is_in_yellow_zone(cell: Vector2i) -> bool:
	for b in blackholes:
		if b.is_yellow_zone(cell):
			return true
			
	return false


func game_over() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")


func win() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/Win.tscn")
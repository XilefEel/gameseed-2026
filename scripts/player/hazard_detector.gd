class_name HazardDetector
extends Node

var player: Player

var asteroids: Array:
	get:
		return get_tree().get_nodes_in_group("asteroids")

var blackholes: Array:
	get:
		return get_tree().get_nodes_in_group("blackholes")

var pirates: Array:
	get:
		return get_tree().get_nodes_in_group("pirates")


func _ready() -> void:
	player = get_parent()


func step_asteroids() -> void:
	for a in asteroids:
		a.step()


func is_asteroid_at(cell: Vector2i) -> bool:
	for a in asteroids:
		if a.get_cell() == cell:
			return true
			
	return false


func destroy_asteroid_at(cell: Vector2i) -> void:
	for a in asteroids:
		if a.get_cell() == cell:
			a.destroy()
			return


func step_pirates(player_cell: Vector2i) -> void:
	for p in pirates:
		p.step(player_cell)
		p.check_line_of_sight(player_cell)


func is_pirate_at(cell: Vector2i) -> bool:
	for p in pirates:
		if p.cell == cell:
			return true
			
	return false


func remove_pirate_at(cell: Vector2i) -> void:
	for p in pirates:
		if p.cell == cell:
			p.queue_free()
			return


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



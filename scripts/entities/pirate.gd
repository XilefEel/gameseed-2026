class_name Pirate
extends Node2D

@onready var grid: TileMapLayer = get_parent()
@onready var sfx_found := $"SFX_Found"

var cell := Vector2i(1, 7)

var is_chasing := false
var astar := AStarGrid2D.new()

func _ready() -> void:
	add_to_group("pirates")
	position = grid.map_to_local(cell)
	setup_astar()


func check_line_of_sight(player_cell: Vector2i) -> void:
	if is_chasing:
		return

	if player_cell.x != cell.x and player_cell.y != cell.y:
		return
	
	var dir := Vector2i(
		sign(player_cell.x - cell.x),
		sign(player_cell.y - cell.y)
	)

	var check_cell := cell + dir
	while check_cell != player_cell:
		if grid.is_debris(check_cell) or grid.is_house(check_cell) or grid.is_portal(check_cell):
			return

		check_cell += dir

	is_chasing = true
	AudioManager.play_sfx(AudioManager.SFX.PIRATE_NOTICE)


func setup_astar() -> void:
	await grid.grid_ready

	astar.region = Rect2i(0, 0, grid.size, grid.size)
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for x in range(grid.size):
		for y in range(grid.size):
			var c := Vector2i(x, y)
			if  grid.is_debris(c) or grid.is_house(c) or grid.is_portal(c):
				astar.set_point_solid(c)


func step(player_cell: Vector2i) -> void:
	if not is_chasing:
		return

	var path := astar.get_point_path(cell, player_cell)

	if path.size() < 2:
		return

	cell = Vector2i(path[1])
	var target_pos = grid.map_to_local(cell)
	var duration = position.distance_to(target_pos) / 600.0

	create_tween().tween_property(
		self,
		"position",
		target_pos,
		duration
	)

	for a in get_tree().get_nodes_in_group("asteroids"):
		if a.get_next_cell() == cell:
			die()
			return

	for b in get_tree().get_nodes_in_group("blackholes"):
		if b.is_on_blackhole(cell):
			die()
			return


func die() -> void:
	queue_free()

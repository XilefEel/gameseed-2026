class_name PlayerMovement
extends Node

var player: Player
var grid: Grid
var hazards: PlayerHazards


func _ready() -> void:
	player = get_parent()
	grid = player.get_parent()
	hazards = player.get_node("Hazards")
	

func move(dir: Vector2i) -> void:
	if hazards.is_in_red_zone(player.current_cell):
		await hazards.game_over()
		return

	var next = player.current_cell + dir
	if not grid.is_in_bounds(next) or grid.is_wall(next):
		return

	if hazards.is_on_blackhole(next):
		await hazards.game_over()
		return

	var cost = 2 if hazards.is_in_yellow_zone(player.current_cell) else 1

	if player.moves_left < cost:
		return

	var prev_cells = hazards.step_asteroids()
	player.current_cell = next
	await move_to_cell(player.current_cell)

	if hazards.check_asteroid_collisions(prev_cells, player.current_cell):
		await hazards.game_over()
		return
	
	player.moves_left -= cost

	if grid.is_end_cell(player.current_cell):
		await hazards.win()


func dash(dir: Vector2i) -> void:
	if player.dashes_left <= 0 or player.moves_left <= 0:
		return

	var dash_path := []
	var curve := Vector2i.ZERO

	for b in hazards.blackholes:
		for i in range(1, 4):
			var path_cell = player.current_cell + dir * i
			if b.is_yellow_zone(path_cell) or b.is_red_zone(path_cell):
				curve = get_curve_direction(dir, b.cell)
				break

	if curve == Vector2i.ZERO:
		for i in range(1, 4):
			dash_path.append(player.current_cell + dir * i)
	else:
		dash_path = [
			player.current_cell + dir,
			player.current_cell + dir * 2,
			player.current_cell + dir * 2 + curve
		]

	var _prev_cells = hazards.step_asteroids()

	for cell in dash_path:
		if not grid.is_in_bounds(cell) or grid.is_wall(cell) or hazards.is_on_blackhole(cell):
			player.current_cell = cell if grid.is_in_bounds(cell) else dash_path[-2]
			
			await move_to_cell(player.current_cell)
			await hazards.game_over()
			return

		for a in hazards.asteroids:
			if a.get_cell() == cell:
				player.current_cell = cell
				
				await move_to_cell(player.current_cell)
				await hazards.game_over()
				return

	player.current_cell = dash_path[-1]
	await move_to_cell(player.current_cell)
	player.dashes_left -= 1
	player.moves_left -= 1

	if grid.is_end_cell(player.current_cell):
		await hazards.win()


func move_to_cell(cell: Vector2i) -> void:
	player.is_moving = true
	
	var target = grid.map_to_local(cell)
	var duration = player.position.distance_to(target) / player.MOVE_SPEED
	
	await create_tween().tween_property(
		player,
		"position",
		target,
		duration
	).finished

	player.is_moving = false


func get_curve_direction(dir: Vector2i, blackhole: Vector2i) -> Vector2i:
	var to_blackhole = blackhole - player.current_cell
	var cross = dir.x * to_blackhole.y - dir.y * to_blackhole.x

	if cross > 0:
		return Vector2i(-dir.y, dir.x)
	
	if cross < 0:
		return Vector2i(dir.y, -dir.x)
	
	return Vector2i.ZERO

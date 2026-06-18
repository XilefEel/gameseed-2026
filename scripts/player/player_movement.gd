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
		await get_sucked_in()
		return

	var next = player.current_cell + dir
	if not grid.is_in_bounds(next) or grid.is_wall(next):
		return

	if hazards.is_on_blackhole(next):
		await hazards.game_over()
		return

	await move_to_cell(next)

	hazards.step_pirates(player.current_cell)
	
	if hazards.is_pirate_at(player.current_cell):
		await hazards.game_over()
		return

	if hazards.is_asteroid_at(player.current_cell):
		await hazards.game_over()
		return

	hazards.step_asteroids()
		
	if !try_consume_move():
		return
	
	if grid.is_end_cell(player.current_cell):
		await hazards.win()

	if player.moves_left <= 0:
		await hazards.game_over()
		return


func move_to_cell(new_cell: Vector2i) -> void:
	player.current_cell = new_cell
	player.is_moving = true
	
	var target = grid.map_to_local(new_cell)
	var duration = player.position.distance_to(target) / player.MOVE_SPEED
	
	await create_tween().tween_property(
		player,
		"position",
		target,
		duration
	).finished

	player.is_moving = false


func try_consume_move() -> bool:
	var cost = 2 if hazards.is_in_yellow_zone(player.current_cell) else 1
	if player.moves_left < cost:
		return false

	player.moves_left -= cost
	return true
	

func dash(dir: Vector2i) -> void:
	if player.moves_left <= 0:
		return

	var dash_path := []
	var dash_length = 2 if hazards.is_in_red_zone(player.current_cell) else 3
	var curve := Vector2i.ZERO

	var found_blackhole := false
	for b in hazards.blackholes:
		if found_blackhole:
			break

		for i in range(1, dash_length + 1):
			var path_cell = player.current_cell + dir * i
			
			if b.is_yellow_zone(path_cell) or b.is_red_zone(path_cell):
				curve = get_curve_direction(dir, b.cell)
				found_blackhole = true
				break
	
	if curve == Vector2i.ZERO:
		for i in range(1, dash_length + 1):
			dash_path.append(player.current_cell + dir * i)
	else:
		if dash_length == 2:
			dash_path = [
				player.current_cell + dir,
				player.current_cell + dir + curve
			]
		else:
			dash_path = [
				player.current_cell + dir,
				player.current_cell + dir * 2,
				player.current_cell + dir * 2 + curve
			]

	for cell in dash_path:
		if not grid.is_in_bounds(cell) or grid.is_wall(cell) or hazards.is_on_blackhole(cell):
			await move_to_cell(cell if grid.is_in_bounds(cell) else dash_path[-2])
			await hazards.game_over()
			return

		if hazards.is_asteroid_at(cell):
			await move_to_cell(cell)
			await hazards.game_over()
			return

	await move_to_cell(dash_path[-1])

	hazards.step_pirates(player.current_cell)

	if hazards.is_pirate_at(player.current_cell):
		await hazards.game_over()
		return

	hazards.step_asteroids()

	if !try_consume_move():
		return

	if grid.is_end_cell(player.current_cell):
		await hazards.win()

	if player.moves_left <= 0:
		await hazards.game_over()
		return


func get_curve_direction(dir: Vector2i, blackhole: Vector2i) -> Vector2i:
	var to_blackhole = blackhole - player.current_cell
	var cross = dir.x * to_blackhole.y - dir.y * to_blackhole.x

	if cross > 0:
		return Vector2i(-dir.y, dir.x)
	
	if cross < 0:
		return Vector2i(dir.y, -dir.x)
	
	return Vector2i.ZERO


func get_sucked_in() -> void:
	player.is_moving = true
	
	for b in hazards.blackholes:
		if b.is_red_zone(player.current_cell):
			var target = grid.map_to_local(b.cell)
			var duration = player.position.distance_to(target) / player.MOVE_SPEED
			
			await create_tween().tween_property(
				player,
				"position",
				target,
				duration
			).finished

			break

	player.is_moving = false
	await hazards.game_over()

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
	if not grid.is_in_bounds(next) or grid.is_debris(next):
		return

	if hazards.is_on_blackhole(next):
		await hazards.game_over()
		return

	if not hazards.is_asteroid_at(next) and not hazards.is_pirate_at(next):
		player.current_cell = next


	if grid.is_portal(next) and grid.get_portal(next)["dir"] == dir:
		move_through_portal()
	else:
		await move_to_cell(player.current_cell)

	hazards.step_pirates(player.current_cell)
	if hazards.is_pirate_at(player.current_cell):
		await hazards.game_over()
		return

	hazards.step_asteroids()
	if hazards.is_asteroid_at(player.current_cell):
		await hazards.game_over()
		return

	if not try_consume_move():
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


func move_through_portal() -> void:
	var portal = grid.get_portal(player.current_cell)
	var landing = portal["exit"] + portal["exit_dir"]

	if not grid.is_in_bounds(landing) or grid.is_debris(landing) or grid.is_house(landing):
		return
	
	player.current_cell = landing
	player.position = grid.map_to_local(landing)


func try_consume_move() -> bool:
	var cost = 2 if hazards.is_in_yellow_zone(player.current_cell) else 1
	if player.moves_left < cost:
		return false

	player.moves_left -= cost
	return true
	

func dash(dir: Vector2i) -> void:
	if player.moves_left <= 0:
		return

	var start_cell = player.current_cell
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

	var dash_info = build_dash_path(dir, dash_length, curve)
	dash_path = dash_info["path"]
	var used_portal = dash_info["used_portal"]

	for cell in dash_path:
		for p in hazards.pirates:
			p.check_line_of_sight(cell)

		if not grid.is_in_bounds(cell):
			await move_to_cell(dash_path[dash_path.find(cell) - 1])
			return
		
		if grid.is_debris(cell) or grid.is_house(cell) or hazards.is_on_blackhole(cell):
			await move_to_cell(cell if grid.is_in_bounds(cell) else dash_path[-2])
			await hazards.game_over()
			return

		if hazards.is_asteroid_at(cell) or hazards.is_pirate_at(cell):
			await move_to_cell(cell)
			await hazards.game_over()
			return

	if used_portal:
		player.current_cell = dash_path[-1]
		player.position = grid.map_to_local(dash_path[-1])
	else:
		await move_to_cell(dash_path[-1])

	var behind = start_cell - dir
	
	if grid.is_in_bounds(behind):
		if grid.is_debris(behind):
			grid.set_cell(behind, 0, grid.EMPTY)
			
		elif grid.is_house(behind):
			grid.set_cell(behind, 0, grid.EMPTY)
			await hazards.game_over()
			return

	hazards.step_pirates(player.current_cell)

	if hazards.is_pirate_at(player.current_cell):
		await hazards.game_over()
		return

	hazards.step_asteroids()

	if not try_consume_move():
		return

	if grid.is_end_cell(player.current_cell):
		await hazards.win()

	if player.moves_left <= 0:
		await hazards.game_over()
		return


func build_dash_path(dir: Vector2i, dash_length: int, curve: Vector2i) -> Dictionary:
	if curve != Vector2i.ZERO:
		if dash_length == 2:
			return {
				"path": [
					player.current_cell + dir,
					player.current_cell + dir + curve
				],
				"used_portal": false
			}
		else:
			return {
				"path": [
					player.current_cell + dir,
					player.current_cell + dir * 2,
					player.current_cell + dir * 2 + curve
				],
				"used_portal": false
			}

	var path := []
	var current_dir = dir
	var current_pos = player.current_cell
	var used_portal := false

	for i in range(1, dash_length + 1):
		var next_cell = current_pos + current_dir

		if grid.is_portal(next_cell) and grid.get_portal(next_cell)["dir"] == current_dir:
			var portal = grid.get_portal(next_cell)
			var landing = portal["exit"] + portal["exit_dir"]

			path.append(landing)
			current_pos = landing
			current_dir = portal["exit_dir"]

			used_portal = true
		else:
			path.append(next_cell)
			current_pos = next_cell

	return {
		"path": path,
		"used_portal": used_portal
	}


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

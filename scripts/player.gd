extends Node2D

@onready var grid: TileMapLayer = get_parent()
@onready var move_label := $"../../UI/MovesLeft"
@onready var dashes_label := $"../../UI/DashesLeft"

const MOVE_SPEED := 200.0
var is_moving := false
var current_cell := Vector2i.ZERO

var moves_left := 150 :
	set(value):
		moves_left = value
		move_label.text = "MOVES LEFT: %d" % moves_left

var dashes_left := 3 :
	set(value):
		dashes_left = value
		dashes_label.text = "DASHES LEFT: %d" % dashes_left

var asteroids :Array :
	get:
		return get_tree().get_nodes_in_group("asteroids")

var blackholes: Array :
	get:
		return get_tree().get_nodes_in_group("blackholes")


func _ready() -> void:
	current_cell = grid.start_cell
	position = grid.map_to_local(current_cell)
	moves_left = moves_left
	dashes_left = dashes_left


func _unhandled_input(event) -> void:
	if is_moving:
		return

	if Input.is_physical_key_pressed(KEY_E):
		recharge()
		return

	var dir := Vector2i.ZERO

	if event.is_action_pressed("ui_up"):
		dir = Vector2i.UP
	elif event.is_action_pressed("ui_down"):
		dir = Vector2i.DOWN
	elif event.is_action_pressed("ui_left"):
		dir = Vector2i.LEFT
	elif event.is_action_pressed("ui_right"):
		dir = Vector2i.RIGHT

	if dir != Vector2i.ZERO:
		if Input.is_physical_key_pressed(KEY_SHIFT):
			dash(dir)
		else:
			move(dir)


func move(dir: Vector2i) -> void:
	if is_in_red_zone(current_cell):
		await game_over()
		return

	var next = current_cell + dir
	if not grid.is_in_bounds(next) or grid.is_wall(next):
		return

	if is_on_blackhole(next):
		await game_over()
		return

	var cost = 2 if is_in_yellow_zone(current_cell) else 1

	if moves_left < cost:
		return

	var prev_cells = step_asteroids()
	current_cell = next
	await move_to_cell(current_cell)

	if check_asteroid_collisions(prev_cells):
		await game_over()
		return
	
	moves_left -= cost

	if grid.is_end_cell(current_cell):
		await win()


func dash(dir: Vector2i) -> void:
	if dashes_left <= 0 or moves_left <= 0:
		return

	var dash_path := []
	var curve := Vector2i.ZERO

	for b in blackholes:
		for i in range(1, 4):
			var path_cell = current_cell + dir * i
			if b.is_yellow_zone(path_cell) or b.is_red_zone(path_cell):
				curve = get_curve_direction(dir, b.cell)
				break

	if curve == Vector2i.ZERO:
		for i in range(1, 4):
			dash_path.append(current_cell + dir * i)
	else:
		dash_path = [
			current_cell + dir,
			current_cell + dir * 2,
			current_cell + dir * 2 + curve
		]

	var _prev_cells = step_asteroids()

	for cell in dash_path:
		if not grid.is_in_bounds(cell) or grid.is_wall(cell) or is_on_blackhole(cell):
			current_cell = cell if grid.is_in_bounds(cell) else dash_path[-2]
			await move_to_cell(current_cell)
			await game_over()
			return

		for a in asteroids:
			if a.get_cell() == cell:
				current_cell = cell
				await move_to_cell(current_cell)
				await game_over()
				return

	current_cell = dash_path[-1]
	await move_to_cell(current_cell)
	dashes_left -= 1
	moves_left -= 1

	if grid.is_end_cell(current_cell):
		await win()


func move_to_cell(cell: Vector2i) -> void:
	is_moving = true
	
	var target = grid.map_to_local(cell)
	var duration = position.distance_to(target) / MOVE_SPEED
	
	await create_tween().tween_property(
		self,
		"position",
		target,
		duration
	).finished

	is_moving = false


func step_asteroids() -> Dictionary:
	var prev_cells := {}
	
	for a in asteroids:
		prev_cells[a] = a.get_cell()
		a.step()

	return prev_cells


func check_asteroid_collisions(prev_cells: Dictionary) -> bool:
	for a in asteroids:
		var hit = a.get_cell() == current_cell
		var swapped = prev_cells[a] == current_cell
		
		if hit or swapped:
			return true

	return false


func recharge() -> void:
	if moves_left <= 0 or dashes_left >= 3 :
		return

	dashes_left += 1
	moves_left -= 1


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


func get_curve_direction(dir: Vector2i, blackhole: Vector2i) -> Vector2i:
	var to_blackhole = blackhole - current_cell
	var cross = dir.x * to_blackhole.y - dir.y * to_blackhole.x

	if cross > 0:
		return Vector2i(-dir.y, dir.x)
	
	if cross < 0:
		return Vector2i(dir.y, -dir.x)
	
	return Vector2i.ZERO



func game_over() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")


func win() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://scenes/Win.tscn")
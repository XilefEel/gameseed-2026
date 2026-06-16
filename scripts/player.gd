extends Node2D

@onready var grid: TileMapLayer = get_parent()
@onready var move_label := $"../../UI/Label"
@onready var asteroid = $"../Asteroid"

var is_moving := false
var move_speed := 200.0
var moves_left := 15 :
	set(value):
		moves_left = value
		move_label.text = "MOVES LEFT: %d" % moves_left

var current_cell := Vector2i.ZERO
var path: Array[Vector2i] = []


func _ready() -> void:
	current_cell = grid.start_cell
	path.append(current_cell)
	position = grid.map_to_local(current_cell)
	moves_left = moves_left


func _unhandled_input(event) -> void:
	if is_moving:
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
		move(dir)


func move(dir: Vector2i) -> void:
	var next = current_cell + dir

	if not grid.is_in_bounds(next):
		return

	if grid.is_wall(next):
		return

	var previous = path[-2] if path.size() >= 2 else null

	if previous != null and next == previous:
		var removed = path.pop_back()
		grid.clear_path(removed)

		current_cell = next
		await move_to_cell(next)

		moves_left += 1
		return

	if path.has(next):
		return

	if moves_left <= 0:
		return

	path.append(next)
	grid.mark_path(next)
	current_cell = next
	await move_to_cell(next)

	moves_left -= 1

	if grid.is_end_cell(current_cell):
		get_tree().change_scene_to_file("res://scenes/Win.tscn")


func move_to_cell(cell: Vector2i) -> void:
	is_moving = true
	
	var asteroid_prev = asteroid.get_cell()
	asteroid.step()
	
	var target = grid.map_to_local(cell)
	var duration = position.distance_to(target) / move_speed
	
	var tween = create_tween()
	tween.tween_property(
		self,
		"position",
		target,
		duration
	)
	
	await tween.finished
	
	var hit = asteroid.get_cell() == current_cell 
	var swapped = asteroid_prev == current_cell
	
	if hit or swapped:
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		
	is_moving = false

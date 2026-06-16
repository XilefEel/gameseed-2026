extends Node2D

@export var move_speed := 200.0
@onready var grid: TileMapLayer = get_parent()

var current_cell := Vector2i.ZERO
var path: Array[Vector2i] = []

var is_moving := false
var has_won := false


func _ready() -> void:
	current_cell = grid.start_cell
	path.append(current_cell)
	position = grid.map_to_local(current_cell)

func _unhandled_input(event) -> void:
	if is_moving: return
	
	if has_won: return

	var dir := Vector2i.ZERO

	if event.is_action_pressed("ui_up"):
		dir = Vector2i.UP
	elif event.is_action_pressed("ui_down"):
		dir = Vector2i.DOWN
	elif event.is_action_pressed("ui_left"):
		dir = Vector2i.LEFT
	elif event.is_action_pressed("ui_right"):
		dir = Vector2i.RIGHT

	if dir != Vector2i.ZERO: move(dir)


func move(dir: Vector2i) -> void:
	var next = current_cell + dir

	if !grid.is_in_bounds(next): return

	var previous = path[-2] if path.size() >= 2 else null

	# Backtracking
	if previous != null and next == previous:
		var removed = path.pop_back()

		grid.clear_path(removed)

		current_cell = next
		await move_to_cell(next)
		return

	# Prevent walking through your own trail
	if path.has(next):
		return

	path.append(next)
	grid.mark_path(next)

	current_cell = next
	await move_to_cell(next)

	if grid.is_end_cell(current_cell):
		has_won = true
		get_tree().change_scene_to_file("res://scenes/Win.tscn")
		print("WIN!")


func move_to_cell(cell: Vector2i) -> void:
	is_moving = true

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
	is_moving = false

extends Node2D

@onready var grid: TileMapLayer = get_parent()
@onready var move_label := $"../../UI/Label"

const MOVE_SPEED := 200.0
var is_moving := false
var moves_left := 15 :
	set(value):
		moves_left = value
		move_label.text = "MOVES LEFT: %d" % moves_left

var current_cell := Vector2i.ZERO


func _ready() -> void:
	current_cell = grid.start_cell
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

	if moves_left <= 0:
		await get_tree().create_timer(0.3).timeout
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
		return

	current_cell = next
	await move_to_cell(next)
	moves_left -= 1

	if grid.is_end_cell(current_cell):
		get_tree().change_scene_to_file("res://scenes/Win.tscn")


func move_to_cell(cell: Vector2i) -> void:
	is_moving = true
	
	var asteroid_prev_cells = {}

	for a in get_tree().get_nodes_in_group("asteroids"):
		asteroid_prev_cells[a] = a.get_cell()
		a.step()

	var target = grid.map_to_local(cell)
	var duration = position.distance_to(target) / MOVE_SPEED
	
	var tween = create_tween().tween_property(
		self,
		"position",
		target,
		duration
	)
	
	await tween.finished
	
	for a in get_tree().get_nodes_in_group("asteroids"):
		var hit = a.get_cell() == current_cell 
		var swapped = asteroid_prev_cells[a] == current_cell
		
		if hit or swapped:
			await get_tree().create_timer(0.3).timeout
			get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
			return
		
	is_moving = false

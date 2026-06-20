class_name Player
extends Node2D

@onready var grid: Grid = get_parent()
@onready var movement: PlayerMovement = $Movement
@onready var move_label := $"../../UI/MovesLeft"

@onready var sfx_move := $"SFX_Move"
@onready var sfx_dash := $"SFX_Dash"
@onready var sfx_die := $"SFX_Die"

const MOVE_SPEED := 200.0
var is_moving := false
var current_cell := Vector2i.ZERO

var moves_left := 120 :
	set(value):
		moves_left = value
		move_label.text = "MOVES LEFT: %d" % moves_left


func _ready() -> void:
	await grid.grid_ready

	current_cell = grid.start_cell
	position = grid.map_to_local(grid.start_cell)


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
		if Input.is_physical_key_pressed(KEY_SHIFT):
			movement.dash(dir)
		else:
			movement.move(dir)
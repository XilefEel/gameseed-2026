class_name Player
extends Node2D

@onready var grid: Grid = get_parent()
@onready var movement: PlayerMovement = $Movement
@onready var move_label := $"../../UI/MovesLeft"
@onready var package_type_label := $"../../UI/ParcelType"
@onready var fragile_label := $"../../UI/FragileDashLeft"

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

var parcel_type := "normal" :
	set(value):
		parcel_type = value
		package_type_label.text = "PARCEL TYPE: %s" % value

var fragile_dashes := 4 :
	set(value):
		fragile_dashes = value
		fragile_label.text = "%d/4" % fragile_dashes


func _ready() -> void:
	await grid.grid_ready

	current_cell = grid.start_cell
	position = grid.map_to_local(grid.start_cell)
	parcel_type = parcel_type


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
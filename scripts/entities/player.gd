class_name Player
extends Node2D

@onready var grid: Grid = get_parent()
@onready var movement: PlayerMovement = $Movement

@onready var move_label := $"../../UI/MovesLeft"
@onready var parcel_type_label := $"../../UI/ParcelType"
@onready var parcel_status_label := $"../../UI/ParcelStatus"

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

var parcel_type := "none" :
	set(value):
		parcel_type = value
		parcel_type_label.text = "PARCEL TYPE: %s" % value
		update_parcel_ui()

var fragile_dashes := 4 :
	set(value):
		fragile_dashes = value
		update_parcel_ui()

var heat_gauge := 0 :
	set(value):
		heat_gauge = value
		update_parcel_ui()

var is_burning := false :
	set(value):
		is_burning = value
		update_parcel_ui()

var burn_turns := 0 :
	set(value):
		burn_turns = value
		update_parcel_ui()


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


func update_parcel_ui() -> void:
	match parcel_type:
		"normal":
			parcel_status_label.text = ""

		"fragile":
			parcel_status_label.text = "FRAGILE: %d dashes left" % fragile_dashes

		"flammable":
			if is_burning:
				parcel_status_label.text = "BURNING! %d turns left" % (4 - burn_turns)
			else:
				parcel_status_label.text = "HEAT: %d/3" % heat_gauge

		_:
			parcel_status_label.text = ""
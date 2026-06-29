class_name Player
extends Node2D

signal moves_changed(moves_left: int, max_moves: int)
signal parcel_type_changed(parcel_type: String)
signal parcel_status_changed(parcel_status: String)
signal is_alive_changed(is_alive: bool)

@onready var grid: Grid = get_parent()
@onready var movement: MovementController = $Movement
@onready var sprite: AnimatedSprite2D = $Sprite2D

const MOVE_SPEED := 600.0
var is_moving := false
var current_cell := Vector2i.ZERO
var last_dir := Vector2i.ZERO

var is_alive := true :
	set(value):
		is_alive = value
		is_alive_changed.emit(value)

var max_moves := 15

var moves_left := 15 :
	set(value):
		moves_left = value
		moves_changed.emit(value, max_moves)

var parcel_type := "none" :
	set(value):
		parcel_type = value
		parcel_type_changed.emit(value)

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
	update_animation()


func update_animation() -> void:
	match last_dir:
		Vector2i.UP: sprite.play("idle_up")
		Vector2i.DOWN: sprite.play("idle_down")
		Vector2i.LEFT: sprite.play("idle_left")
		Vector2i.RIGHT: sprite.play("idle_right")


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
		last_dir = dir
		update_animation()
		if Input.is_physical_key_pressed(KEY_SHIFT):
			movement.dash(dir)
		else:
			movement.move(dir)


func update_parcel_ui() -> void:
	match parcel_type:
		"normal":
			parcel_status_changed.emit("")

		"fragile":
			parcel_status_changed.emit("%d dashes left" % fragile_dashes)

		"flammable":
			if is_burning:
				parcel_status_changed.emit("BURNING! %d turns left" % (4 - burn_turns))
			else:
				parcel_status_changed.emit("HEAT: %d/3" % heat_gauge)

		_:
			parcel_status_changed.emit("")

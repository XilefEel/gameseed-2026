class_name Parcel
extends Node

enum Type {
	NORMAL,
	FRAGILE,
	FLAMMABLE
}

var player: Player
var movement: MovementController
var hazards: HazardDetector
var grid: Grid

func _ready() -> void:
	player = get_parent()
	movement = player.get_node("Movement")
	hazards = player.get_node("Hazards")
	grid = player.get_parent()


func check_flammable() -> void:
	if player.parcel_type != Type.FLAMMABLE:
		return

	if grid.is_hotspot(player.current_cell):
		player.heat_gauge = min(player.heat_gauge + 1, 3)
	else:
		player.heat_gauge = max(player.heat_gauge - 1, 0)

	if player.heat_gauge >= 3 and not player.is_burning:
		player.is_burning = true

	if player.is_burning:
		player.burn_turns += 1
		if player.burn_turns > 3:
			await movement.game.game_over()


func check_fragile() -> bool:
	if player.parcel_type != Type.FRAGILE:
		return true

	player.fragile_dashes -= 1
	if player.fragile_dashes <= 0:
		await movement.game.game_over()
		return false

	return true
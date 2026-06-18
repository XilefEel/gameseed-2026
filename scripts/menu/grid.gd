class_name Grid
extends TileMapLayer

const GRID_SIZE := 8

const EMPTY := Vector2i(0, 0)
const START := Vector2i(1, 0)
const END := Vector2i(2, 0)
const ASTEROID_PATH := Vector2i(1, 1)
const DEBRIS := Vector2i(0, 2)
const HOUSE := Vector2i(1, 2)
const PORTAL_IN := Vector2i(0, 3)
const PORTAL_OUT := Vector2i(1, 3)

var start_cell := Vector2i(0, 0)
var end_cell := Vector2i(7, 7)

var portals := {
    Vector2i(1, 1): {
		"exit": Vector2i(6, 5),
		"dir": Vector2i.RIGHT,
		"exit_dir": Vector2i.DOWN
	},
	Vector2i(7, 2): {
		"exit": Vector2i(0, 7),
		"dir": Vector2i.RIGHT,
		"exit_dir": Vector2i.UP
	},
}


func _ready() -> void:
	set_cell(start_cell, 0, START)
	set_cell(end_cell, 0, END)

	for cell in portals.keys():
		set_cell(cell, 0, PORTAL_IN, get_portal_transform(portals[cell]["dir"]))
		set_cell(portals[cell]["exit"], 0, PORTAL_OUT, get_portal_transform(portals[cell]["exit_dir"]))


func is_in_bounds(cell: Vector2i) -> bool:
	return (
		cell.x >= 0 and
		cell.x < GRID_SIZE and
		cell.y >= 0 and
		cell.y < GRID_SIZE
	)


func is_end_cell(cell: Vector2i) -> bool:
	return cell == end_cell


func is_debris(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == DEBRIS


func is_house(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == HOUSE


func is_portal(cell: Vector2i) -> bool:
	return cell in portals


func get_portal(cell: Vector2i) -> Dictionary:
	return portals[cell]


func get_portal_transform(dir: Vector2i) -> int:
	if dir == Vector2i.RIGHT:
		return 0
	if dir == Vector2i.DOWN:
		return TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_H
	if dir == Vector2i.LEFT:
		return TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V
	if dir == Vector2i.UP:
		return TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
	return 0


func mark_asteroid_path(cells: Array[Vector2i]) -> void:
	for cell in cells:
		set_cell(cell, 0, ASTEROID_PATH)

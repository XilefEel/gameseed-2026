class_name Grid
extends TileMapLayer

const GRID_SIZE := 8

const EMPTY := Vector2i(0, 0)
const START := Vector2i(1, 0)
const END := Vector2i(2, 0)
const ASTEROID_PATH := Vector2i(1, 1)
const DEBRIS := Vector2i(0, 2)
const HOUSE := Vector2i(1, 2)

var start_cell := Vector2i(0, 0)
var end_cell := Vector2i(7, 7)

func _ready() -> void:
	set_cell(start_cell, 0, START)
	set_cell(end_cell, 0, END)


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


func mark_asteroid_path(cells: Array[Vector2i]) -> void:
	for cell in cells:
		set_cell(cell, 0, ASTEROID_PATH)

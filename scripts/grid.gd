extends TileMapLayer

const GRID_SIZE := 8

const EMPTY := Vector2i(0, 0)
const START := Vector2i(1, 0)
const END := Vector2i(2, 0)
const PATH := Vector2i(0, 1)

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


func mark_path(cell: Vector2i) -> void:
	if cell == start_cell or cell == end_cell: return
	set_cell(cell, 0, PATH)


func clear_path(cell: Vector2i) -> void:
	if cell == start_cell or cell == end_cell: return
	set_cell(cell, 0, EMPTY)

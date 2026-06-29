class_name Grid
extends TileMapLayer

@onready var camera: Camera2D = $"../Camera2D"

signal grid_ready

const EMPTY := Vector2i(0, 0)
const START := Vector2i(1, 0)
const END := Vector2i(2, 0)
const DEBRIS := Vector2i(0, 2)
const HOUSE := Vector2i(1, 2)
const PORTAL_IN := Vector2i(0, 3)
const HOTSPOT := Vector2i(1, 1)

var start_cell := Vector2i(0, 0)
var end_cell := Vector2i(7, 7)
var size := 8

var portals := {}


func _ready() -> void:
	clear()
	LevelLoader.load_level(LevelLoader.current_level_path, self)
	draw_grid()
	camera.setup_camera(size)
	
	grid_ready.emit()


func draw_grid() -> void:
	for x in range(size):
		for y in range(size):
			if get_cell_source_id(Vector2i(x, y)) == -1:
				set_cell(Vector2i(x, y), 0, EMPTY)


func is_in_bounds(cell: Vector2i) -> bool:
	return (
		cell.x >= 0 and
		cell.x < size and
		cell.y >= 0 and
		cell.y < size
	)


func is_end_cell(cell: Vector2i) -> bool:
	return cell == end_cell


func is_debris(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == DEBRIS


func is_house(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == HOUSE


func add_portal_pair(a: Vector2i, a_dir: Vector2i, b: Vector2i, b_dir: Vector2i) -> void:
	portals[a] = {"exit": b, "dir": a_dir, "exit_dir": b_dir}
	portals[b] = {"exit": a, "dir": b_dir, "exit_dir": a_dir}


func is_portal(cell: Vector2i) -> bool:
	return portals.has(cell)


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


func is_hotspot(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == HOTSPOT

# func mark_asteroid_path(cells: Array[Vector2i]) -> void:
# 	for cell in cells:
# 		set_cell(cell, 0, ASTEROID_PATH)

class_name LevelLoader

const PIRATE_SCENE = preload("res://scenes/entities/Pirate.tscn")
const BLACKHOLE_SCENE = preload("res://scenes/entities/Blackhole.tscn")
const ASTEROID_SCENE = preload("res://scenes/entities/Asteroid.tscn")

const DIR_MAP = {
	"up": Vector2i.UP,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT
}


static func load_level(file_path: String, grid: Grid) -> LevelData:
	var file := FileAccess.open(file_path, FileAccess.READ)

	if not file:
		push_error("Failed to open level file: " + file_path)
		return

	var json := JSON.new()
	json.parse(file.get_as_text())

	var level = LevelData.new(json.get_data())

	setup_player(level, grid)
	setup_grid(level, grid)
	spawn_entities(level, grid)

	return level


static func setup_player(level: LevelData, grid: Grid) -> void:
	var player: Player = grid.get_node("Player")

	player.moves_left = level.moves
	player.max_moves = level.moves
	player.parcel_type = level.parcel_type


static func setup_grid(level: LevelData, grid: Grid) -> void:
	grid.size = level.grid_size
	grid.start_cell = level.start_cell
	grid.end_cell = level.end_cell

	grid.draw_grid()

	grid.set_cell(grid.start_cell, 0, grid.START)
	grid.set_cell(grid.end_cell, 0, grid.END)

	for cell in level.debris:
		grid.set_cell(cell, 0, grid.DEBRIS)

	for cell in level.houses:
		grid.set_cell(cell, 0, grid.HOUSE)

	for cell in level.hotspots:
		grid.set_cell(cell, 0, grid.HOTSPOT)


static func spawn_entities(level: LevelData, grid: Grid) -> void:
	for cell in level.pirates:
		var pirate = PIRATE_SCENE.instantiate()
		pirate.cell = cell
		grid.add_child(pirate)

	for cell in level.blackholes:
		var blackhole = BLACKHOLE_SCENE.instantiate()
		blackhole.cell = cell
		grid.add_child(blackhole)

	for asteroid_data in level.asteroids:
		var asteroid = ASTEROID_SCENE.instantiate()

		var path: Array[Vector2i] = []
		for p in asteroid_data["path"]:
			path.append(Vector2i(p[0], p[1]))

		asteroid.path = path
		grid.add_child(asteroid)

	for i in range(0, level.portals.size() - 1, 2):
		var a = level.portals[i]
		var b = level.portals[i + 1]

		var a_cell = Vector2i(a["cell"]["x"], a["cell"]["y"])
		var b_cell = Vector2i(b["cell"]["x"], b["cell"]["y"])

		var a_dir = DIR_MAP[a["dir"]]
		var b_dir = DIR_MAP[b["dir"]]

		grid.add_portal_pair(a_cell, a_dir, b_cell, b_dir)

		grid.set_cell(a_cell, 0, grid.PORTAL_IN, grid.get_portal_transform(a_dir))
		grid.set_cell(b_cell, 0, grid.PORTAL_IN, grid.get_portal_transform(b_dir))
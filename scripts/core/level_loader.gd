class_name LevelLoader

static var current_level_path := ""
static var current_level: LevelData = null

static var current_chapter := 1
static var current_chapter_scene := "res://scenes/ui/chapters/Chapter1.tscn"
static var last_stars := 0

const PIRATE_SCENE = preload("res://scenes/entities/Pirate.tscn")
const BLACKHOLE_SCENE = preload("res://scenes/entities/Blackhole.tscn")
const ASTEROID_SCENE = preload("res://scenes/entities/Asteroid.tscn")

const DIR_MAP = {
	"up": Vector2i.UP,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT
}


static func load_level(file_path: String, grid: Grid) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)

	if not file:
		push_error("Failed to open level file: " + file_path)
		return

	var json := JSON.new()
	json.parse(file.get_as_text())

	current_level = LevelData.new(json.get_data())
	current_level_path = file_path

	setup_player(grid)
	setup_grid(grid)
	spawn_entities(grid)


static func setup_player(grid: Grid) -> void:
	var player: Player = grid.get_node("Player")

	player.moves_left = current_level.moves
	player.max_moves = current_level.moves
	player.parcel_type = current_level.parcel_type


static func setup_grid(grid: Grid) -> void:
	grid.size = current_level.grid_size
	grid.start_cell = current_level.start_cell
	grid.end_cell = current_level.end_cell

	grid.set_cell(grid.start_cell, 0, grid.START)
	grid.set_cell(grid.end_cell, 0, grid.END)

	for cell in current_level.debris:
		grid.set_cell(cell, 0, grid.DEBRIS)

	for cell in current_level.houses:
		grid.set_cell(cell, 0, grid.HOUSE)

	for cell in current_level.hotspots:
		grid.set_cell(cell, 0, grid.HOTSPOT)


static func spawn_entities(grid: Grid) -> void:
	for cell in current_level.pirates:
		var pirate = PIRATE_SCENE.instantiate()
		pirate.cell = cell
		grid.add_child(pirate)

	for cell in current_level.blackholes:
		var blackhole = BLACKHOLE_SCENE.instantiate()
		blackhole.cell = cell
		grid.add_child(blackhole)

	for asteroid_data in current_level.asteroids:
		var asteroid = ASTEROID_SCENE.instantiate()

		var path: Array[Vector2i] = []
		for p in asteroid_data["path"]:
			path.append(Vector2i(p[0], p[1]))

		asteroid.path = path
		grid.add_child(asteroid)

	for i in range(0, current_level.portals.size() - 1, 2):
		var a = current_level.portals[i]
		var b = current_level.portals[i + 1]

		var a_cell = Vector2i(a["cell"]["x"], a["cell"]["y"])
		var b_cell = Vector2i(b["cell"]["x"], b["cell"]["y"])

		var a_dir = DIR_MAP[a["dir"]]
		var b_dir = DIR_MAP[b["dir"]]

		grid.add_portal_pair(a_cell, a_dir, b_cell, b_dir)

		grid.set_cell(a_cell, 0, grid.PORTAL_IN, grid.get_portal_transform(a_dir))
		grid.set_cell(b_cell, 0, grid.PORTAL_IN, grid.get_portal_transform(b_dir))
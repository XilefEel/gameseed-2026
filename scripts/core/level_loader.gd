class_name LevelLoader

static var current_level := "res://levels/level_01.json"

const PIRATE_SCENE = preload("res://scenes/entities/Pirate.tscn")
const BLACKHOLE_SCENE = preload("res://scenes/entities/Blackhole.tscn")
const ASTEROID_SCENE = preload("res://scenes/entities/Asteroid.tscn")


const DIR_MAP = {
	"up": Vector2i.UP,
	"down": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT
}

static var current_dialogue: Dictionary = {}


static func load_level(file_path: String, grid: Grid) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)

	if not file:
		push_error("Failed to open level file: " + file_path)
		return
	
	var json = JSON.new()
	json.parse(file.get_as_text())
	var data = json.get_data()

	var player = grid.get_node("Player")
	player.moves_left = data["moves"]
	player.parcel_type = data["parcel_type"]

	current_dialogue = data.get("dialogue", {
		"positions": {},
		"lines": []
	})

	grid.size = data["grid_size"]
	grid.start_cell = Vector2i(data["start_cell"][0], data["start_cell"][1])
	grid.end_cell = Vector2i(data["end_cell"][0], data["end_cell"][1])

	grid.set_cell(grid.start_cell, 0, grid.START)
	grid.set_cell(grid.end_cell, 0, grid.END)

	for d in data["debris"]:
		var cell = Vector2i(d[0], d[1])
		grid.set_cell(cell, 0, grid.DEBRIS)

	for h in data["houses"]:
		var cell = Vector2i(h[0], h[1])
		grid.set_cell(cell, 0, grid.HOUSE)

	for p in data["pirates"]:
		var pirate = PIRATE_SCENE.instantiate()
		pirate.cell = Vector2i(p[0], p[1])
		grid.add_child(pirate)

	for b in data["blackholes"]:
		var blackhole = BLACKHOLE_SCENE.instantiate()
		blackhole.cell = Vector2i(b[0], b[1])
		grid.add_child(blackhole)

	for a in data["asteroids"]:
		var asteroid = ASTEROID_SCENE.instantiate()
		var path_data = a["path"]

		var path: Array[Vector2i] = []
		for p in path_data:
			path.append(Vector2i(p[0], p[1]))

		asteroid.path = path
		grid.add_child(asteroid)

	for i in range(0, data["portals"].size() - 1, 2):
		var a = data["portals"][i]
		var b = data["portals"][i + 1]
		
		var a_cell = Vector2i(a["cell"]["x"], a["cell"]["y"])
		var b_cell = Vector2i(b["cell"]["x"], b["cell"]["y"])
		
		var a_dir = DIR_MAP[a["dir"]]
		var b_dir = DIR_MAP[b["dir"]]
		
		grid.add_portal_pair(a_cell, a_dir, b_cell, b_dir)
		grid.set_cell(a_cell, 0, grid.PORTAL_IN, grid.get_portal_transform(a_dir))
		grid.set_cell(b_cell, 0, grid.PORTAL_IN, grid.get_portal_transform(b_dir))

	for h in data["hotspots"]:
		var cell = Vector2i(h[0], h[1])
		grid.set_cell(cell, 0, grid.HOTSPOT)

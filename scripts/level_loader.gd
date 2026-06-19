class_name LevelLoader


static func load_level(path: String, grid: Grid) -> void:
	var file = FileAccess.open(path, FileAccess.READ)

	if not file:
		push_error("Failed to open level file: " + path)
		return
	
	var json = JSON.new()
	json.parse(file.get_as_text())
	var data = json.get_data()

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

	
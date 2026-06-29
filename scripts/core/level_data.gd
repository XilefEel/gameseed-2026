class_name LevelData

const PARCEL_TYPES = {
	"normal": Parcel.Type.NORMAL,
	"fragile": Parcel.Type.FRAGILE,
	"flammable": Parcel.Type.FLAMMABLE,
}

var name: String

var grid_size: int
var moves: int
var parcel_type: Parcel.Type

var start_cell: Vector2i
var end_cell: Vector2i

var debris: Array[Vector2i] = []
var houses: Array[Vector2i] = []

var asteroids: Array = []
var blackholes: Array[Vector2i] = []
var pirates: Array[Vector2i] = []
var portals: Array = []
var hotspots: Array[Vector2i] = []

var star_thresholds: Array[int] = []

var dialogue: Dictionary = {
	"positions": {},
	"lines": []
}


func _init(data: Dictionary) -> void:
	name = data["name"]

	grid_size = data["grid_size"]
	moves = data["moves"]
	parcel_type = PARCEL_TYPES[data["parcel_type"]]

	start_cell = parse_cell(data["start_cell"])
	end_cell = parse_cell(data["end_cell"])

	debris = parse_cells(data.get("debris", []))
	houses = parse_cells(data.get("houses", []))
	blackholes = parse_cells(data.get("blackholes", []))
	pirates = parse_cells(data.get("pirates", []))
	hotspots = parse_cells(data.get("hotspots", []))

	asteroids = data.get("asteroids", [])
	portals = data.get("portals", [])

	star_thresholds.assign(data.get("star_thresholds", []))

	dialogue = data.get("dialogue", {
		"positions": {},
		"lines": []
	})


static func parse_cell(cell: Array) -> Vector2i:
	return Vector2i(cell[0], cell[1])


static func parse_cells(cells: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []

	for cell in cells:
		result.append(parse_cell(cell))

	return result
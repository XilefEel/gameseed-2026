extends Control

@onready var moves_left_label: Label = %MovesLeft
@onready var parcel_status_label: Label = %ParcelStatus

@onready var parcel_image: TextureRect = %ParcelImage
@onready var player_image: TextureRect = %PlayerImage

const PARCEL_TEXTURES = {
	"normal": preload("res://assets/sprites/parcel/normal.png"),
	"fragile": preload("res://assets/sprites/parcel/fragile.png"),
	"flammable": preload("res://assets/sprites/parcel/flammable.png"),
}

const PLAYER_TEXTURES = {
	"alive": preload("res://assets/sprites/player/cahyo.png"),
	"dead": preload("res://assets/sprites/player/cahyo_dead.png")
}

func setup(player: Player) -> void:
	player.moves_changed.connect(func(moves_left):
		moves_left_label.text = "MOVES LEFT: %d" % moves_left
	)

	player.parcel_type_changed.connect(func(parcel_type):
		parcel_image.texture = PARCEL_TEXTURES.get(parcel_type, null)
	)

	player.parcel_status_changed.connect(func(parcel_status):
		parcel_status_label.text = parcel_status
	)

	player.is_alive_changed.connect(func(is_alive):
		player_image.texture = PLAYER_TEXTURES["alive"] if is_alive else PLAYER_TEXTURES["dead"]
	)
	
	moves_left_label.text = "MOVES LEFT: %d" % player.moves_left
	parcel_image.texture = PARCEL_TEXTURES.get(player.parcel_type, null)
	player.update_parcel_ui()


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")


func _on_retry_pressed():
	get_tree().reload_current_scene()

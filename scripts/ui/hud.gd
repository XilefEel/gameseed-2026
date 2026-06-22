extends Control

@onready var moves_left_label: Label = %MovesLeft
@onready var parcel_type_label: Label = %ParcelType
@onready var parcel_status_label: Label = %ParcelStatus


func setup(player: Player) -> void:
	player.moves_changed.connect(func(moves_left):
		moves_left_label.text = "MOVES LEFT: %d" % moves_left
	)
	player.parcel_type_changed.connect(func(parcel_type):
		parcel_type_label.text = parcel_type
	)
	player.parcel_status_changed.connect(func(parcel_status):
		parcel_status_label.text = parcel_status
	)

	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")


func _on_retry_pressed():
	get_tree().reload_current_scene()

extends Control

@onready var moves_left_label: Label = %MovesLeft
@onready var parcel_status_label: Label = %ParcelStatus

@onready var parcel_image: TextureRect = %ParcelImage
@onready var player_image: TextureRect = %PlayerImage

@onready var stopwatch: TextureProgressBar = %StopWatch
@onready var clockhand: Sprite2D = %ClockHand

@onready var three_star_label: Label = %ThreeStarLabel
@onready var two_star_label: Label = %TwoStarLabel

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
	player.moves_changed.connect(func(moves_left, max_moves):
		moves_left_label.text = str(moves_left)
		update_stopwatch(moves_left, max_moves)
		update_star_requirements(moves_left)
	)

	player.parcel_type_changed.connect(func(parcel_type):
		parcel_image.texture = PARCEL_TEXTURES.get(parcel_type)
	)

	player.parcel_status_changed.connect(func(parcel_status):
		parcel_status_label.text = parcel_status
	)

	player.is_alive_changed.connect(func(is_alive):
		player_image.texture = PLAYER_TEXTURES["alive"] if is_alive else PLAYER_TEXTURES["dead"]
	)

	parcel_image.texture = PARCEL_TEXTURES.get(player.parcel_type)
	player.update_parcel_ui()

	update_stopwatch(player.moves_left, player.max_moves)
	update_star_requirements(player.moves_left)


func update_star_requirements(moves_left: int) -> void:
	var three_star_threshold = LevelLoader.current_star_thresholds[0]
	var two_star_threshold = LevelLoader.current_star_thresholds[1]

	update_requirement(
		three_star_label,
		moves_left >= three_star_threshold,
		three_star_threshold
	)

	update_requirement(
		two_star_label,
		moves_left >= two_star_threshold,
		two_star_threshold
	)


func update_requirement(label: Label, possible: bool, threshold: int) -> void:
	if possible:
		label.text = "✅ Moves left ≥ %d" % threshold
		label.modulate = Color.WHITE
	else:
		label.text = "❌ Moves left ≥ %d" % threshold
		label.modulate = Color(0.5, 0.5, 0.5)


func update_stopwatch(moves: int, maximum: int) -> void:
	var ratio = float(moves) / float(maximum)
	var target_val = ratio * 100
	var target_rotation = lerp(0.0, TAU, 1.0 - ratio)

	var tween = create_tween()
	tween.tween_property(clockhand, "rotation", target_rotation, 0.2)
	tween.parallel().tween_property(stopwatch, "value", target_val, 0.2)


func _on_back_pressed():
	get_tree().change_scene_to_file(LevelLoader.current_chapter_scene)


func _on_retry_pressed():
	get_tree().reload_current_scene()
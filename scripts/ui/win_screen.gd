extends Control

@onready var stars := [
	%Star1,
	%Star2,
	%Star3
]

const STAR_FILLED = preload("res://assets/ui/star_filled.png")
const STAR_EMPTY = preload("res://assets/ui/star_empty.png")

func _ready():
	for star in stars:
		star.pivot_offset = star.size / 2.0

	await animate_stars(Game.last_stars)


func animate_stars(count: int) -> void:
	for i in count:
		await get_tree().create_timer(0.35).timeout

		stars[i].texture = STAR_FILLED
		stars[i].scale = Vector2(1.5, 1.5)

		var tween = create_tween()
		tween.tween_property(
			stars[i],
			"scale",
			Vector2.ONE,
			0.2
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

		AudioManager.play_ui(AudioManager.UI.STAR)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Game.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file(Game.current_chapter_scene)

extends Control

@onready var stars := [
	%Star1,
	%Star2,
	%Star3
]

const STAR_FILLED = preload("res://assets/ui/star_filled.png")
const STAR_EMPTY = preload("res://assets/ui/star_empty.png")

func _ready():
	show_stars(LevelLoader.last_stars)


func show_stars(count: int) -> void:
	for i in stars.size():
		stars[i].texture = STAR_FILLED if i < count else STAR_EMPTY


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Game.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file(LevelLoader.current_chapter_scene)

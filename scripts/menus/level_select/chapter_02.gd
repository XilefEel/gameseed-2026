extends Node2D

@onready var level_container = $HBoxContainer/CenterContainer/VBoxContainer/LevelContainer
@onready var font = preload("res://assets/fonts/font.ttf")


const LEVELS = [
	"res://levels/ch_02/level_01.json",
	"res://levels/ch_02/level_02.json",
	"res://levels/ch_02/level_03.json",
	"res://levels/ch_02/level_04.json",
	"res://levels/ch_02/level_05.json",
]


func _ready() -> void:
	for i in range(LEVELS.size()):
		var button = Button.new()
		button.text = "Level " + str(i + 1)
		button.position = Vector2(100, 100 + i * 50)
		button.add_theme_font_override("font", font)
		button.add_theme_font_size_override("font_size", 20)
		level_container.add_child(button)

		var level_path = LEVELS[i]
		button.pressed.connect(func() -> void:
			LevelLoader.current_level = level_path
			LevelLoader.current_chapter = 2
			LevelLoader.current_chapter_scene = "res://scenes/menus/level_select/Chapter2.tscn"
			get_tree().change_scene_to_file("res://scenes/levels/Game.tscn")
		)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/level_select/Chapter1.tscn")


func _on_button_pressed_2() -> void:
	pass

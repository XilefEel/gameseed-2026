extends Node2D

@onready var level_container = $CenterContainer/VBoxContainer/LevelContainer

const LEVELS = [
	"res://levels/level_01.json",
	"res://levels/level_02.json",
	"res://levels/level_03.json",
	"res://levels/level_04.json",
	"res://levels/level_05.json",
	"res://levels/level_06.json",
	"res://levels/level_07.json",
]


func _ready() -> void:
	for i in range(LEVELS.size()):
		var button = Button.new()
		button.text = "Level " + str(i + 1)
		button.position = Vector2(100, 100 + i * 50)
		level_container.add_child(button)

		var level_path = LEVELS[i]
		button.pressed.connect(func() -> void:
			LevelLoader.current_level = level_path
			get_tree().change_scene_to_file("res://scenes/levels/Game.tscn")
		)

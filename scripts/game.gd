class_name Game
extends Node2D

@onready var player: Player = $Grid/Player
@onready var grid: Grid = $Grid
@onready var hud: Control = $"UI/HUD"
@onready var dialogue_box := $DialogueBox
@onready var camera: Camera2D = $Camera2D

var level: LevelData = null

static var current_level_path := ""
static var current_chapter := 1
static var current_chapter_scene := "res://scenes/ui/chapters/Chapter1.tscn"

static var last_stars := 0

func _ready() -> void:
	grid.initialize()
	level = LevelLoader.load_level(current_level_path, grid)
	hud.setup(player, level)
	grid.grid_ready.emit()

	camera.setup_camera(grid.size)
	
	player.set_process_unhandled_input(false)
	
	var dialogue = level.dialogue
	if dialogue.size() > 0:
		await dialogue_box.play(dialogue)

	player.set_process_unhandled_input(true)


func calculate_stars() -> int:
	if player.moves_left >= level.star_thresholds[0]:
		return 3
	elif player.moves_left >= level.star_thresholds[1]:
		return 2

	return 1


func game_over() -> void:
	AudioManager.play_sfx(AudioManager.SFX.DIE)
	player.is_moving = true
	player.is_alive = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")


func win() -> void:
	last_stars = calculate_stars()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Win.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(current_chapter_scene)

class_name Game
extends Node2D

@onready var player: Player = $Grid/Player
@onready var grid: Grid = $Grid
@onready var hud: Control = $"UI/HUD"
@onready var dialogue_box := $DialogueBox

func _ready() -> void:
	player.set_process_unhandled_input(false)
	hud.setup(player)
	
	var dialogue = LevelLoader.current_dialogue
	if dialogue.size() > 0:
		await dialogue_box.play(dialogue)

	player.set_process_unhandled_input(true)


func game_over() -> void:
	AudioManager.play_sfx(AudioManager.SFX.DIE)
	player.is_moving = true
	player.is_alive = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")


func win() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Win.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(LevelLoader.current_chapter_scene)

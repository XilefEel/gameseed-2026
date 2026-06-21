class_name Game
extends Node2D

@onready var grid: Grid = $Grid
@onready var player: Player = $Grid/Player

func game_over() -> void:
	player.sfx_die.play()
	player.is_moving = true
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
	

func win() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Win.tscn")


func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

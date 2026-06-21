class_name Game
extends Node2D

@onready var player: Player = $Grid/Player

func game_over() -> void:
	player.sfx_die.play()
	player.is_moving = true
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
	

func win() -> void:
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Win.tscn")

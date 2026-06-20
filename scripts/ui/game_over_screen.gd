extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/Game.tscn")


func _on_button_pressed_2() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

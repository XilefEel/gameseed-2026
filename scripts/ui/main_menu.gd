extends Control

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/chapters/Chapter1.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()

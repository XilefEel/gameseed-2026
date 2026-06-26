extends CanvasLayer

signal finished

@onready var name_label: Label = %CharacterName
@onready var dialogue_label: Label = %DialogueText
@onready var character_sprite: TextureRect = %CharacterSprite
@onready var sprite_container: HBoxContainer = %SpriteContainer

var lines: Array = []
var current_line := 0
var is_typing := false

const CHAR_DELAY := 0.03

const CHARACTER_SPRITES = {
	"Cahyo": preload("res://assets/sprites/player/cahyo.png"),
	"Boss": preload("res://assets/sprites/player/boss.png")
}

func play(dialogue: Array) -> void:
	lines = dialogue
	current_line = 0
	show()
	show_line()
	await finished


func show_line() -> void:
	var entry = lines[current_line]

	name_label.text = entry["character"]
	dialogue_label.text = entry["text"]

	var position = entry.get("position", "left")
	character_sprite.texture = CHARACTER_SPRITES.get(entry["character"], null)
	sprite_container.size_flags_horizontal = (
		Control.SIZE_SHRINK_BEGIN
		if position == "left"
		else Control.SIZE_SHRINK_END
	)

	dialogue_label.visible_characters = 0
	is_typing = true

	while dialogue_label.visible_characters < dialogue_label.text.length():
		dialogue_label.visible_characters += 1
		await get_tree().create_timer(CHAR_DELAY).timeout

	is_typing = false


func _unhandled_input(event) -> void:
	if !event.is_action_pressed("ui_accept"):
		return

	if is_typing:
		dialogue_label.visible_characters = dialogue_label.text.length()
		is_typing = false
		return

	current_line += 1

	if current_line >= lines.size():
		hide()
		finished.emit()
	else:
		show_line()

extends CanvasLayer

signal finished

@onready var name_label: Label = %CharacterName
@onready var dialogue_label: Label = %DialogueText

@onready var portrait_slots := {
	"left": %LeftPortrait,
	"center": %CenterPortrait,
	"right": %RightPortrait,
}

@onready var sfx_talk: AudioStreamPlayer2D = %SFX_Talk

var lines: Array = []
var character_positions: Dictionary = {}
var current_line := 0
var is_typing := false

const CHARACTER_SPRITES = {
	"Cahyo": preload("res://assets/sprites/player/cahyo.png"),
	"Boss": preload("res://assets/sprites/player/boss.png")
}

const DIALOGUE_DELAYS = {
	"normal": 0.03,
	"comma": 0.15,
	"period": 0.3,
}

const SILENT_CHARS = [".", ",", "!", "?", "\n"]
const ACTIVE_COLOR := Color.WHITE
const INACTIVE_COLOR := Color(0.35, 0.35, 0.35, 0.6)

const ACTIVE_SCALE := Vector2(1.05, 1.05)
const INACTIVE_SCALE := Vector2(1.0, 1.0)


func _ready():
	await get_tree().process_frame

	for slot in portrait_slots.values():
		slot.pivot_offset = slot.size / 2.0


func play(dialogue: Dictionary) -> void:
	lines = dialogue["lines"]
	character_positions = dialogue["positions"]

	if lines.is_empty():
		finished.emit()
		return

	setup_portraits()

	current_line = 0
	show()
	show_line()
	await finished


func show_line() -> void:
	var entry = lines[current_line]

	name_label.text = entry["character"]
	dialogue_label.text = entry["text"]

	update_portraits(entry["character"])

	dialogue_label.visible_characters = 0
	is_typing = true

	while dialogue_label.visible_characters < dialogue_label.text.length():
		dialogue_label.visible_characters += 1
		
		var c = dialogue_label.text[dialogue_label.visible_characters - 1]
		if c not in SILENT_CHARS:
			sfx_talk.pitch_scale = randf_range(0.9, 1.1)
			sfx_talk.play()

		var delay := DIALOGUE_DELAYS["normal"]

		match c:
			",":
				delay = DIALOGUE_DELAYS["comma"]
			".", "!", "?":
				delay = DIALOGUE_DELAYS["period"]

		await get_tree().create_timer(delay).timeout

	is_typing = false


func setup_portraits():
	for position in portrait_slots:
		var slot = portrait_slots[position]
		var character = character_positions.get(position)

		if character == null:
			slot.hide()
			continue

		slot.show()
		slot.texture = CHARACTER_SPRITES.get(character)

	update_portraits("")


func update_portraits(active_character: String):
	for position in portrait_slots:
		var slot = portrait_slots[position]
		var character = character_positions.get(position)

		if character == null:
			continue

		slot.modulate = (
			ACTIVE_COLOR
			if character == active_character
			else INACTIVE_COLOR
		)

		var target_scale = (
			ACTIVE_SCALE
			if character == active_character
			else INACTIVE_SCALE
		)
		
		create_tween().tween_property(
			slot,
			"scale",
			target_scale,
			0.15
		)

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

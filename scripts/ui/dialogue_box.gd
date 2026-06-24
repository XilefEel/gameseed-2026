extends CanvasLayer

signal finished

@onready var name_label: Label = %CharacterName
@onready var dialogue_label: Label = %DialogueText

var lines: Array = []
var current_line := 0

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


func _unhandled_input(event) -> void:
    if event.is_action_pressed("ui_accept"):
        current_line += 1
        if current_line >= lines.size():
            hide()
            finished.emit()
        else:
            show_line()
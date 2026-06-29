extends Node

enum UI {
	CLICK,
	STAR
}

enum SFX {
	MOVE,
	DASH,
	TALK,
	DIE,
	PIRATE_NOTICE,
}

@onready var music_player: AudioStreamPlayer = $BGMPlayer
@onready var ui_player: AudioStreamPlayer = $UIPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

const UI_SOUNDS: Dictionary = {
	UI.CLICK: preload("res://assets/sfx/ui/click.wav"),
	UI.STAR: preload("res://assets/sfx/ui/star.mp3")
}

const SFX_SOUNDS: Dictionary = {
	SFX.MOVE: preload("res://assets/sfx/player/move.wav"),
	SFX.DASH: preload("res://assets/sfx/player/dash.wav"),
	SFX.TALK: preload("res://assets/sfx/ui/talk.mp3"),
	SFX.DIE: preload("res://assets/sfx/player/death.mp3"),
	SFX.PIRATE_NOTICE: preload("res://assets/sfx/entities/pirate_notice.mp3"),
}


func _ready() -> void:
	sfx_player.stream = AudioStreamPolyphonic.new()
	sfx_player.play()


func play_ui(sound: UI) -> void:
	var stream: AudioStream = UI_SOUNDS.get(sound, null)

	if stream:
		ui_player.stream = stream
		ui_player.play()


func play_sfx(sound: SFX) -> void:
	var stream = SFX_SOUNDS.get(sound, null)
	if not stream:
		return

	var playback = sfx_player.get_stream_playback() as AudioStreamPlaybackPolyphonic
	
	if sound == SFX.TALK:
		playback.play_stream(stream, 0, 0, randf_range(0.9, 1.1))
	else:
		playback.play_stream(stream)


extends Node2D
class_name StartCinematic

## For development purposes to launch faster
@export var skip_sequence: bool = false
@export var player: Player = null

signal finish_cinematic

@onready var black_screen: ColorRect = $Filter/ColorRect
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

func _ready():
	if skip_sequence:
		visible = false
		get_node("Filter").visible = false
		call_deferred("skip")
	else:
		visible = true
		get_node("Filter").visible = true

func skip():
	finish_cinematic.emit()

func play_sequence():
	if skip_sequence: return

	var tween = create_tween()
	tween.tween_property(black_screen, "modulate", Color.TRANSPARENT, 4).set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_EXPO)
	# call some wakeup animation in player
	tween.tween_interval(1) # simulate wake up animation
	tween.tween_property(player, "rotation", PI / 4, 0.75)
	tween.tween_interval(0.3)
	tween.tween_property(player, "rotation", PI * 3 / 4, 0.75)
	tween.tween_callback(func(): HELPERS.play_audio(audio_player))
	tween.tween_interval(0.2)
	tween.tween_property(player, "rotation", -PI / 2, 0.25)
	tween.tween_interval(0.75)
	tween.tween_property(player, "rotation", -PI * 3 / 4, 0.4).set_trans(Tween.TransitionType.TRANS_QUINT).set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.tween_interval(1.25)
	tween.tween_callback(func(): finish_cinematic.emit())
	tween.play()

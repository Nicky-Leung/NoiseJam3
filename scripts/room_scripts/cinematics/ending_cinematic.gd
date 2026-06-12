extends Node2D
class_name EndingCinematic

@export var skip_sequence: bool = false
@onready var black_screen: ColorRect = $Filter/ColorRect
@onready var title_card: Label = $Filter/Label
@onready var rustle: AudioStreamPlayer2D = $Rustle
@onready var metal: AudioStreamPlayer2D = $Metal
@onready var defib: AudioStreamPlayer2D = $Defib
@onready var drop: AudioStreamPlayer2D = $Drop
@onready var music: AudioStreamPlayer = $Music

signal finish_cinematic

func _ready():
	visible = false
	get_node("Filter").visible = false
	title_card.visible = false
	black_screen.modulate = Color.TRANSPARENT
	music.volume_db = HELPERS.factor_to_db(OPTIONS.MUSIC)

func play_sequence():
	if skip_sequence:
		finish_cinematic.emit()
		return

	get_node("Filter").visible = true
	var tween = create_tween()
	tween.tween_property(black_screen, "modulate", Color.WHITE, 1)
	tween.tween_callback(func(): HELPERS.play_audio(rustle, 0, 0, 10))
	tween.tween_interval(rustle.stream.get_length())
	tween.tween_callback(func(): HELPERS.play_audio(metal, 0, 0, 10))
	tween.tween_interval(metal.stream.get_length())
	tween.tween_callback(func(): HELPERS.play_audio(defib, 0, 0, 10))
	tween.tween_interval(defib.stream.get_length())
	tween.tween_callback(func(): HELPERS.play_audio(drop, 0, 0, 10))
	tween.tween_interval(drop.stream.get_length())
	tween.tween_callback(func():
		music.play()
		title_card.visible = true
	)
	tween.tween_interval(7)
	tween.tween_property(music, "volume_db", -60, 5)
	tween.tween_callback(func(): finish_cinematic.emit())
	tween.play()

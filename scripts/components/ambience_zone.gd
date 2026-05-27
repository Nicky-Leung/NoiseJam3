extends Node2D

@export var ambience_collection: Array[AudioStream]
@export var area2d_sound_zone: Area2D
@export var frames_per_check = 240 # i.e. number of frames must pass before a check is ran
@export var chance_to_play_per_check = 0.05
@export var min_distance_from_player = 30
@export var max_distance_from_player = 300

@onready var sound_player: AudioStreamPlayer2D = $SoundPlayer

var player: Player = null
var is_in_range: bool = false

func _ready():
	area2d_sound_zone.body_entered.connect(on_body_entered)
	area2d_sound_zone.body_exited.connect(on_body_exited)

func _physics_process(_delta):
	if Engine.get_process_frames() % frames_per_check != 0 || !is_in_range || player == null: return
	try_play_ambience()

func try_play_ambience():
	if randf() > chance_to_play_per_check: return

	var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	var magnitude = randi_range(min_distance_from_player, max_distance_from_player)
	sound_player.global_position = player.global_position + direction * magnitude

	sound_player.stream = ambience_collection.pick_random()
	HELPERS.play_audio(sound_player)

func on_body_entered(body: Node2D):
	if !(body is Player): return
	player = body as Player
	is_in_range = true

func on_body_exited(body: Node2D):
	if !(body is Player): return
	player = body as Player
	is_in_range = false

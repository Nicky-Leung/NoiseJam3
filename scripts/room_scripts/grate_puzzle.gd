extends Node2D

@export var correct_sfx: AudioStream = null
@export var wrong_sfx: AudioStream = null
@export var finish_sfx: AudioStream = null

# Components
@onready var north_grate: Area2D = $North # 1
@onready var south_grate: Area2D = $South # 2
@onready var east_grate: Area2D = $East # 3
@onready var west_grate: Area2D = $West # 4
@onready var unlock_key: Pickup = $Pickup
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

# Run time variables
var current_grate_number: int = 0
var is_completed: bool = false

# solution order -> N, S, E, W
func _ready():
    north_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 1))
    south_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 2))
    east_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 3))
    west_grate.body_entered.connect(func(body: Node2D): on_grate_entered(body, 4))
    unlock_key.visible = false

func get_grate_location(grate_number: int) -> Vector2:
    if grate_number == 1: return north_grate.global_position
    elif grate_number == 2: return south_grate.global_position
    elif grate_number == 3: return east_grate.global_position
    else: return west_grate.global_position

func on_grate_entered(body: Node2D, grate_number: int):
    if body is not Player || current_grate_number == grate_number || is_completed: return

    var is_correct_order = grate_number - current_grate_number == 1
    current_grate_number = grate_number if is_correct_order else 0

    audio_player.stream = correct_sfx if is_correct_order else wrong_sfx
    audio_player.global_position = get_grate_location(grate_number)
    HELPERS.play_audio(audio_player)

    if current_grate_number != 4: return
    is_completed = true
    unlock_key.visible = true
    unlock_key.allow_pickup(true)

    audio_player.stream = finish_sfx # will override above sound
    HELPERS.play_audio(audio_player)
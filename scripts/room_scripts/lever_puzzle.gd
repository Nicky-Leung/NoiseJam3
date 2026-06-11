extends Node2D

@export var pull_order: Array[Lever] = []
@export var correct_sfx: AudioStream = null
@export var wrong_sfx: AudioStream = null
@export var finish_sfx: AudioStream = null

@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var puzzle_reward: Pickup = $Key

var current_lever: Lever = null

func _ready():
    puzzle_reward.visible = false
    for lever in pull_order:
        lever.pulled.connect(_on_pulled)

func _reset_puzzle():
    for lever in pull_order:
        lever.reset_lever()
    current_lever = null
    audio_player.stream = wrong_sfx
    HELPERS.play_audio(audio_player)

func _finish_puzzle():
    audio_player.stream = finish_sfx
    HELPERS.play_audio(audio_player)
    puzzle_reward.visible = true
    puzzle_reward.allow_pickup(true)

func _on_pulled(lever: Lever):
    var prev_index = -1 if current_lever == null else pull_order.find(current_lever)
    var curr_index = pull_order.find(lever)
    audio_player.global_position = lever.global_position
    current_lever = lever

    if abs(curr_index - prev_index) != 1:
        _reset_puzzle()
        return
    if curr_index == pull_order.size() - 1:
        _finish_puzzle()
        return
    audio_player.stream = correct_sfx
    HELPERS.play_audio(audio_player)
extends Area2D

@export var scare_noise: AudioStream = null
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

func _ready():
    body_entered.connect(on_entered)
    audio_player.finished.connect(queue_free)
    audio_player.stream = scare_noise

func on_entered(body: Node2D):
    if body is not Player: return
    HELPERS.play_audio(audio_player)
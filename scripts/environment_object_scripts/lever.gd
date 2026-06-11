extends AnimatedSprite2D
class_name Lever

const up: String = "to_up"
const down: String = "to_down"

@onready var interactable: Interactable = $Interactable
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

signal pulled(this: Node2D)

var is_pulled: bool = false

func _ready():
    interactable.interacted.connect(_on_interacted)
    animation_finished.connect(_on_animation_finished)

func reset_lever():
    if !is_pulled: return
    animation = up
    play()
    HELPERS.play_audio(audio_player, 0.95, 1.05, -10)

func _on_interacted(_player: Player):
    if is_pulled: return
    animation = down
    play()
    HELPERS.play_audio(audio_player, 0.95, 1.05, -10)

func _on_animation_finished():
    is_pulled = !is_pulled
    if is_pulled: pulled.emit(self)
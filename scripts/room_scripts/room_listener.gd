extends Area2D
class_name RoomListener

signal player_entered(player: Player)
signal player_exited(player: Player)

var player_in_room: bool = false

func _ready():
    collision_layer = 0
    collision_mask = PHYS_LAYERS.PLAYER
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
    if body is not Player: return
    player_entered.emit(body as Player)
    player_in_room = true

func _on_body_exited(body: Node2D):
    if body is not Player: return
    player_exited.emit(body as Player)
    player_in_room = false
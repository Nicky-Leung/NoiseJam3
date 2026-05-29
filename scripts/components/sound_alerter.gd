extends Area2D
class_name SoundAlerter

@export var alerter_shape: Shape2D = null
@export var player: Player = null

@onready var hitbox: CollisionShape2D = $Hitbox
@onready var shape: Shape2D:
    get: return hitbox.shape

func _ready():
    hitbox.shape = alerter_shape if alerter_shape != null else hitbox.shape
    body_entered.connect(notify_enemy)

func enable(do_enable: bool):
    monitoring = do_enable

func notify_enemy(body: Node2D):
    if body is not Enemy: return

    # TODO: enemy should implement a function called alert(location: Vector2), different enemies will have their own implementation on what to do
    # or call it notify
    # enemy.alert(player, self)
    print("alerted " + str(body))
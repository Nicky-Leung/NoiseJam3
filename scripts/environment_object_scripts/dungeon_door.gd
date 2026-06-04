extends Interactable


@onready var door: AnimatedSprite2D = get_parent()
@onready var collision_shape: CollisionShape2D = get_parent().get_node("StaticBody2D/CollisionShape2D")

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func interact(player: Player) -> void:
	if not is_open:
		door.play("open")
	if is_open:
		door.play("close")
	player.hud.display_flavor_text("The door is locked. Maybe there's a switch nearby that opens it?")
	print("Interacted with door")

func _on_Door_animation_finished():
	if door.animation == "open":
		collision_shape.disabled = true
		is_open = true
	elif door.animation == "close":
		collision_shape.disabled = false
		is_open = false

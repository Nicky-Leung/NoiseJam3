extends Area2D

signal trap_triggered(angel: Node2D)

@export var stun_time: float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask = PHYS_LAYERS.ENEMY
	body_entered.connect(_on_angel_entered) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_angel_entered(body: Node2D) -> void:
	if body.has_method("trigger_stun"):
		emit_signal("trap_triggered", body)
		body.trigger_stun(stun_time)
		queue_free()
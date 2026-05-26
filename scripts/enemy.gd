extends CharacterBody2D

@export var target: Player
@export var SPEED:int = 100
@export var ACCELERATION: int = 20
@export var FRICTION: int = 400

@onready var nav_agent = $NavigationAgent2D
@onready var body = $Body


func _ready() -> void:
	nav_agent.path_desired_distance = 100.0
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 500.0
	set_movement_target()




func _physics_process(delta: float) -> void:
	set_movement_target()
	
	var direction :Vector2 = (nav_agent.get_next_path_position() - global_position).normalized()
	change_direction(direction.x)
	
	if not nav_agent.is_target_reached():
		if direction != Vector2.ZERO:
			velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move_and_slide()
	

func set_movement_target() -> void:
	await get_tree().physics_frame
	nav_agent.target_position = target.global_position
	
func change_direction(direction:float) -> void:
	if sign(direction) < 0:
		body.flip_h = false
	elif sign(direction) > 0:
		body.flip_h = true

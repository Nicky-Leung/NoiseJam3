extends CharacterBody2D
class_name Enemy

@export var SPEED:int = 100
@export var ACCELERATION: int = 20
@export var FRICTION: int = 400

@onready var nav_agent = $NavigationAgent2D
@onready var body = $Body


@onready var main = get_parent()
@onready var target: Player = main.get_node("Player")

@onready var flashlight: Node = target.get_node("Flashlight")

@onready var is_in_light: bool = false

func _ready() -> void:
	nav_agent.path_desired_distance = 100.0
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 500.0
	set_movement_target()
	flashlight.coverage_changed.connect(_on_flashlight_coverage_changed)


func _physics_process(delta: float) -> void:
	set_movement_target()

	if is_in_light:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		move_and_slide()
		return

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

func _on_flashlight_coverage_changed(is_active: bool, center: Vector2, radius: float, bounds: Rect2) -> void:
	if is_active and bounds.has_point(global_position):
		if global_position.distance_squared_to(center) <= radius * radius:
			is_in_light = true
	else:
		is_in_light = false

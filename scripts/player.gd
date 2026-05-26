extends CharacterBody2D

# Components
@onready var flashlight = $Flashlight
@onready var sprite = $Sprite
@onready var interact_ray = $InteractRay
@onready var hud = $Overlay/Hud

# Player settings
@export var walk_speed: int = 100
@export var sprint_multiplier = 1.5
@export var backward_speed: int = 75
@export var turn_rate: float = 7.5

# Runtime variables
var is_sprinting: bool = false
var input_vector: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if velocity.length() > 0:
		sprite.play("move")
	else:
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	# calculate turning direction
	var new_direction = facing_direction.lerp(global_position.direction_to(get_global_mouse_position()), turn_rate * delta)
	rotation = new_direction.angle()
	facing_direction = new_direction

	# calculate speed
	var speed = 0
	if facing_direction.dot(input_vector) >= 0:
		speed = walk_speed
	else:
		speed = backward_speed
	if is_sprinting:
		speed *= sprint_multiplier

	velocity = input_vector * speed
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is not InputEventKey && event is not InputEventMouseButton:
		return

	input_vector = Input.get_vector(INPUTS.LEFT, INPUTS.RIGHT, INPUTS.UP, INPUTS.DOWN)
	is_sprinting = Input.is_action_pressed(INPUTS.SPRINT)

	if Input.is_action_just_pressed(INPUTS.TOGGLE_LIGHT):
		flashlight.toggle()

	if Input.is_action_just_pressed(INPUTS.INTERACT) && interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if collider.has_method("interact"):
			collider.interact(self)

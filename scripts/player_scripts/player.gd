extends CharacterBody2D
class_name Player

# Signals
signal player_died(killer: Enemy)


# Components
@onready var flashlight = $Flashlight
@onready var sprite = $Sprite
@onready var interact_ray = $InteractRay
@onready var hud = $Overlay/Hud
@onready var footsteps = $Footsteps
@onready var i_frame = $IFrameTimer
@onready var hurtSFX = $HurtSFX

@onready var trap_scene : PackedScene = preload("res://scenes/environment_objects/trap.tscn")

# Player settings
@export var max_health = 50
@export var walk_speed: int = 100
@export var sprint_multiplier = 1.5
@export var backward_speed: int = 75
@export var turn_rate: float = 7.5

# Runtime variables
var health: int = max_health
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
	footsteps.play_steps(velocity.length())
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
		if collider is Interactable:
			collider.interact(self)
	if Input.is_action_just_pressed(INPUTS.PLACE_OBJECT):
		place_trap()

func heal(amount: int):
	health = min(max_health, health + amount)

func damage(amount: int): # called for environmental hazards
	health -= amount
	if health <= 0: player_died.emit(null)

func place_trap():
	var trap = trap_scene.instantiate()
	trap.global_position = global_position + facing_direction * 16
	get_parent().add_child(trap)
func attack(amount: int, attacker: Enemy): # called for enemy attacks
	if i_frame.time_left > 0 || health <= 0: return

	i_frame.start()
	HELPERS.play_audio(hurtSFX, 0.8, 0.9)

	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, i_frame.wait_time / 2)
	tween.tween_property(self, "modulate", Color.WHITE, i_frame.wait_time / 3)
	tween.play()

	health -= amount
	if health <= 0:
		player_died.emit(attacker)
		print("player died to " + str(attacker))
		return
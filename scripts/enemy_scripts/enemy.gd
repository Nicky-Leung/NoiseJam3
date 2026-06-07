extends CharacterBody2D
class_name Enemy

enum State {
	CHASE, # chasing player
	PATROL, # following a patrol path
	SCOUT, # moving towards a point outside of patrol path
	RETURN, # moving back to point on patrol path
	IDLE # doing nothing (not moving)
}

# components
@export var player: Player = null # if an enemy needs a player reference on start
@export var nav_agent: NavigationAgent2D = null
@export var animated_sprite: AnimatedSprite2D = null
@export var patrol_path: PathFollow2D = null # add if enemy has a path to patrol

# start state
@export var collides_with_others: bool = false # check if enemy needs to collider with other enemies
@export var is_active: bool = false # set it to true in editor if enemy should immediately work on scene load
@export var frames_per_nav_check = 60

# stats
@export var attack_damage: int = 10
@export var turn_rate: float = 10
@export var acceleration: int = 20
@export var base_speed: int = 100

# running variables
var ai_state: State = State.IDLE # state for checks, up to subclasses to incorporate
var nav_check_stagger = 0 # stagger so not all nav agents check in the same frame
var in_light: bool = false
var face_direction: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO
var chase_target: Player = null # for chasing (set this to start chasing)

func _ready():
	collision_mask = PHYS_LAYERS.TERRAIN + PHYS_LAYERS.PLAYER + PHYS_LAYERS.NO_OCCLUSION_TERRAIN
	collision_layer = PHYS_LAYERS.ENEMY
	if collides_with_others: collision_mask += PHYS_LAYERS.ENEMY
	nav_check_stagger = randi() % frames_per_nav_check
	z_index = 1
	if patrol_path != null:
		global_position = patrol_path.global_position
		call_deferred("reparent", patrol_path)

func _process(delta):
	# hide enemy if they aren't in light
	var target_alpha = 1 if in_light else 0
	modulate.a = move_toward(modulate.a, target_alpha, delta * 25)
	in_light = false

func toggle_active(enable: bool) -> void:
	is_active = enable

func alert_sound(_alerter: Node2D) -> void: # expected to override in children class
	pass

func alert_visual(_alerter: Node2D) -> void: # expected to override in children class
	in_light = true

func can_check_nav() -> bool:
	return (Engine.get_physics_frames() + nav_check_stagger) % frames_per_nav_check

func chase(delta: float) -> bool: # default chase behavior implementation subclasses can use
	move_and_slide() # move based on previous frame values
	turn_process(delta)

	if chase_target == null: return false
	nav_agent.target_position = chase_target.global_position
	move_direction = global_position.direction_to(nav_agent.get_next_path_position())

	if !nav_agent.is_target_reached():
		velocity = velocity.lerp(move_direction * base_speed, acceleration * delta)
	return nav_agent.is_target_reached() || !nav_agent.is_target_reachable()


func move_to(delta: float, target_pos: Vector2) -> bool:
	move_and_slide()
	turn_process(delta)

	if !can_check_nav(): return false
	nav_agent.target_position = target_pos
	move_direction = global_position.direction_to(nav_agent.get_next_path_position())

	if !nav_agent.is_target_reached():
		velocity = velocity.lerp(move_direction * base_speed, acceleration * delta)
	return nav_agent.is_target_reached() || !nav_agent.is_target_reachable()

func turn_process(delta):
	var new_direction = face_direction.lerp(move_direction, turn_rate * delta)
	global_rotation = new_direction.angle()
	face_direction = new_direction

func patrol(delta: float) -> void: # assumes pathfollow is not null
	patrol_path.progress += delta * base_speed
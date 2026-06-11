extends Enemy
class_name Angel

@export var speed: int = 100
@export var friction: int = 400
@onready var vision: EnemyVision = $VisionCone
@onready var reset_timer = $ResetTimer
@onready var idle_timer = $IdleTimer
@onready var chase_timer = $ChaseTimer

@onready var body = $Body
@onready var main = get_parent()
@onready var attack_ray: RayCast2D = $AttackRay

# @onready var flashlight: Node = target.get_node("Flashlight")

@onready var is_in_light: bool = false

@onready var is_stunned: bool = false
@export var possible_spawn_points: Array[Vector2] = []
var spawn_position: Vector2

@export var nav_region: NavigationRegion2D = null

var scout_position: Vector2 = Vector2.ZERO


func _ready() -> void:

	collision_mask = PHYS_LAYERS.TERRAIN + PHYS_LAYERS.PLAYER
	collision_layer = PHYS_LAYERS.ENEMY

	# randomize spawn position
	# spawn_position = possible_spawn_points[randi() % possible_spawn_points.size()]
	# print("Angel spawned at: ", spawn_position)
	# global_position = spawn_position

	nav_agent.path_desired_distance = 100.0
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 500.0
	vision.body_in_view.connect(on_view)
	vision.body_out_of_view.connect(_on_body_out_of_view)
	chase_target = player
	ai_state = State.IDLE
	nav_agent.target_position = find_nearest_patrol_point()

	# set_movement_target()
	
	
	
	# flashlight.coverage_changed.connect(_on_flashlight_coverage_changed)

func _process(delta):
	super(delta)
  


func _physics_process(delta: float) -> void:


	if ai_state == State.CHASE:
		chase(delta)
		try_damage_player()

	if ai_state == State.IDLE:
	
		move_to(delta, nav_agent.get_next_path_position())
	
		if nav_agent.is_target_reached():
			ai_state = State.PATROL
			patrol_path.progress = patrol_path.get_parent().curve.get_closest_offset(to_local(global_position))
	if ai_state == State.PATROL:
		print("Angel is patrolling.")
		patrol(delta)
		# rotation = move_toward(rotation, 0, delta * turn_rate)
		

	# elif ai_state == State.SCOUT:
	# 	nav_agent.target_desired_distance = 50
	# 	var reached = move_to(delta, scout_position)

	
func alert_sound(alerter: Node2D) -> void:
	ai_state = State.SCOUT
	scout_position = alerter.global_position + alerter.global_position.direction_to(global_position) * 50 # offset from player by tiny bit
	reset_timer.stop()
	idle_timer.stop()

func find_nearest_patrol_point() -> Vector2:
	var nearest_point = patrol_path.get_parent().curve.get_closest_point(global_position)
	return nearest_point


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

func trigger_stun(stun_time: float) -> void:
	is_stunned = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(stun_time).timeout
	is_stunned = false


func on_view(player: Player) -> void:
	if ai_state != State.CHASE:
		ai_state = State.CHASE
		# print("Angel spotted player, starting chase!")
		chase_target = player
	chase_timer.start()

func _on_body_out_of_view(player: Player) -> void:
	pass


func _on_chase_timer_timeout() -> void:
	chase_timer.stop()
	print("Angel lost sight of player, stopping chase.")
	nav_agent.target_position = find_nearest_patrol_point()
	ai_state = State.IDLE


func try_damage_player():
	var collider = attack_ray.get_collider()
	if collider is not Player: return
	(collider as Player).attack(attack_damage, self)

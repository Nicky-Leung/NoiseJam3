extends Enemy
class_name Angel

@export var speed: int = 100
@export var friction: int = 400

@onready var vision: EnemyVision = $VisionCone
@onready var reset_timer = $ResetTimer
@onready var sprite: AnimatedSprite2D = $Body

@onready var body = $Body
@onready var attack_ray: RayCast2D = $AttackRay
@onready var is_in_light: bool = false
@onready var is_stunned: bool = false

var spawn_position: Vector2
var scout_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	super()
	vision.body_in_view.connect(on_view)
	vision.body_out_of_view.connect(_on_body_out_of_view)
	reset_timer.timeout.connect(_on_reset_timeout)
	global_position = patrol_path.global_position
	ai_state = State.PATROL

func _physics_process(delta: float) -> void:
	if is_stunned: return

	if ai_state == State.CHASE:
		nav_agent.target_desired_distance = 5
		chase(delta)
		try_damage_player()

	elif ai_state == State.PATROL:
		patrol(delta)
		body.rotation = -global_rotation

	elif ai_state == State.SCOUT:
		nav_agent.target_desired_distance = 50
		var reached = move_to(delta, scout_position)
		if reached:
			reset_timer.start()
			ai_state = State.IDLE

	elif ai_state == State.IDLE:
		if chase_target:
			global_rotation = global_position.direction_to(chase_target.global_position).angle()
			body.rotation = -global_rotation

func alert_sound(alerter: Node2D) -> void:
	ai_state = State.SCOUT
	scout_position = alerter.global_position + alerter.global_position.direction_to(global_position) * 50 # offset from player by tiny bit
	reset_timer.stop()

func alert_visual(alerter: Node2D) -> void:
	super(alerter)
	if alerter is not Player: return
	on_view(alerter as Player)

func trigger_stun(stun_time: float) -> void:
	is_stunned = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(stun_time).timeout
	is_stunned = false

func turn_process(delta):
	super(delta)
	body.rotation = -global_rotation
	var direction = get_real_velocity().x
	if direction > 0: sprite.flip_h = true
	elif direction < 0: sprite.flip_h = false

func on_view(seen_player: Player) -> void:
	if ai_state == State.CHASE: return
	ai_state = State.CHASE
	chase_target = seen_player
	reset_timer.stop()

func _on_body_out_of_view() -> void:
	if ai_state != State.CHASE: return
	if reset_timer.time_left == 0: reset_timer.start()
	ai_state = State.IDLE
	# play screech noise here

func _on_reset_timeout() -> void:
	# play teleport sound effect
	global_position = patrol_path.global_position
	ai_state = State.PATROL

func try_damage_player():
	var collider = attack_ray.get_collider()
	if collider is not Player: return
	if (collider as Player).attack(attack_damage, self):
		# play sound effect of damaging player
		pass

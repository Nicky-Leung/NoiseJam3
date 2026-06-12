extends Enemy
class_name Angel

@export var teleport_sounds: Array[AudioStream] = []
@export var ambience_sounds: Array[AudioStream] = []

@onready var footsteps = $Sounds/Footsteps
@onready var teleport_audio = $Sounds/Teleport
@onready var ambience_audio = $Sounds/Ambience
@onready var screech_audio = $Sounds/Screech
@onready var vision: EnemyVision = $VisionCone
@onready var reset_timer = $ResetTimer
@onready var sprite: AnimatedSprite2D = $Body
@onready var attack_ray: RayCast2D = $AttackRay
@onready var is_in_light: bool = false
@onready var is_stunned: bool = false

var spawn_position: Vector2
var scout_position: Vector2 = Vector2.ZERO
var is_first_encounter: bool = true
var is_chasing: bool:
	get: return ai_state == State.CHASE

func _ready() -> void:
	super()
	collision_mask -= PHYS_LAYERS.NO_OCCLUSION_TERRAIN
	vision.body_in_view.connect(on_view)
	vision.body_out_of_view.connect(_on_body_out_of_view)
	reset_timer.timeout.connect(_on_reset_timeout)
	global_position = patrol_path.global_position
	ai_state = State.PATROL

func _physics_process(delta: float) -> void:
	if is_stunned || !is_active: return

	if ai_state == State.CHASE:
		nav_agent.target_desired_distance = 5
		chase(delta)
		try_damage_player()
		footsteps.play_steps(velocity.length(), 0.5, 0.8, 1.2)

	elif ai_state == State.PATROL:
		patrol(delta)
		sprite.rotation = -global_rotation
		footsteps.play_steps(base_speed, 0.5, 0.8, 1.2)

	elif ai_state == State.SCOUT:
		nav_agent.target_desired_distance = 50
		var reached = move_to(delta, scout_position)
		if reached || get_real_velocity().length_squared() < 25:
			reset_timer.start()
			ai_state = State.IDLE

	elif ai_state == State.IDLE:
		if chase_target:
			global_rotation = global_position.direction_to(chase_target.global_position).angle()
			sprite.rotation = -global_rotation

	if randi() % 10000 == 0 && !ambience_audio.playing:
		ambience_audio.stream = ambience_sounds[randi() % ambience_sounds.size()]
		HELPERS.play_audio(ambience_audio)

func alert_sound(alerter: Node2D) -> void:
	ai_state = State.SCOUT
	scout_position = alerter.global_position + alerter.global_position.direction_to(global_position) * 50 # offset from player by tiny bit
	reset_timer.stop()

func alert_visual(alerter: Node2D) -> void:
	super(alerter)
	if alerter is not Player: return
	if global_position.distance_to(alerter.global_position) > 300: return
	on_view(alerter as Player)

func trigger_stun(stun_time: float) -> void:
	is_stunned = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(stun_time).timeout
	is_stunned = false

func turn_process(delta):
	super(delta)
	sprite.rotation = -global_rotation
	var direction = get_real_velocity().x
	if direction > 0: sprite.flip_h = true
	elif direction < 0: sprite.flip_h = false

func on_view(seen_player: Player) -> void:
	if ai_state == State.CHASE: return
	ai_state = State.CHASE
	chase_target = seen_player
	reset_timer.stop()
	if is_first_encounter:
		HELPERS.play_audio(screech_audio, 1.67, 1.67, -10)
		is_first_encounter = false

func _on_body_out_of_view() -> void:
	if ai_state != State.CHASE: return
	if reset_timer.time_left == 0: reset_timer.start()
	ai_state = State.IDLE

func _on_reset_timeout() -> void:
	global_position = patrol_path.global_position
	global_rotation = patrol_path.global_rotation
	sprite.rotation = -global_rotation
	ai_state = State.PATROL
	teleport_audio.stream = teleport_sounds[randi() % teleport_sounds.size()]
	is_first_encounter = true
	HELPERS.play_audio(teleport_audio)

func try_damage_player():
	var collider = attack_ray.get_collider()
	if collider is not Player: return
	(collider as Player).attack(attack_damage, self)

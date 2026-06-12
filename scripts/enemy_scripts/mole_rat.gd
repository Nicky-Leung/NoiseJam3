extends Enemy

# Starting variables
@export var attention_time: float = 5

# Components
@onready var vision: EnemyVision = $VisionCone
@onready var reset_timer = $ResetTimer
@onready var idle_timer = $IdleTimer
@onready var footsteps = $Footsteps
@onready var squeak = $Squeak
@onready var sprite = $Sprite

# Runtime variables
var scout_position: Vector2 = Vector2.ZERO
var idle_turn_angle: float = 0
var idle_move_frames: int = 0
var doing_idle_movement: bool = false

func _ready():
	super()
	ai_state = State.PATROL
	sprite.animation = "move"
	reset_timer.wait_time = attention_time
	vision.body_in_view.connect(on_view)
	reset_timer.timeout.connect(on_reset_timeout)
	idle_timer.timeout.connect(on_idle_timeout)
	sprite.animation_finished.connect(_on_animation_finished)
	idle_timer.wait_time = randi() % 11 + 10
	if !is_active: idle_timer.stop()

func _process(delta):
	super(delta)
	if get_real_velocity().length_squared() > 5 || ai_state == State.PATROL:
		var fps: float = 12.0 if ai_state == State.PATROL else 12 * get_real_velocity().length_squared() / base_speed ** 2
		sprite.sprite_frames.set_animation_speed("move", fps)
		sprite.play()
	elif velocity.length_squared() < 5 || !is_active:
		sprite.pause()

func _physics_process(delta):
	if !is_active: return

	if ai_state == State.PATROL:
		patrol(delta)
		rotation = move_toward(rotation, 0, delta * turn_rate)
		footsteps.play_steps(base_speed)

	elif ai_state == State.IDLE: # create random movement to appear like scouting nearby
		if !doing_idle_movement:
			if randi() % 2 == 0: idle_turn_angle = randf() * PI - PI / 4
			else: idle_move_frames = randi() % 40 + 25
			doing_idle_movement = true
		else:
			if idle_move_frames > 0: move_forwards()
			else: look_at_idle_angle(delta)
			footsteps.play_steps(velocity.length())

	elif ai_state == State.SCOUT:
		nav_agent.target_desired_distance = 50
		var reached = move_to(delta, scout_position)
		footsteps.play_steps(velocity.length())
		if reached:
			ai_state = State.IDLE
			reset_timer.start()

	elif ai_state == State.RETURN:
		nav_agent.target_desired_distance = 1
		var reached = move_to(delta, patrol_path.global_position)
		footsteps.play_steps(velocity.length())
		if reached:
			ai_state = State.PATROL
			global_position = patrol_path.global_position
			idle_timer.start()

	if randi() % 10000 == 0 && !squeak.playing: HELPERS.play_audio(squeak, 0.03, 0.1)

func toggle_active(enable: bool) -> void:
	super(enable)
	if is_active: idle_timer.start()
	else: idle_timer.stop()

func alert_sound(alerter: Node2D) -> void:
	ai_state = State.SCOUT
	scout_position = alerter.global_position + alerter.global_position.direction_to(global_position) * 50 # offset from player by tiny bit
	reset_timer.stop()
	idle_timer.stop()

func move_forwards():
	velocity = Vector2.from_angle(global_rotation) * randf() * base_speed
	move_and_slide()
	idle_move_frames -= 1
	doing_idle_movement = idle_move_frames > 0

func look_at_idle_angle(delta: float):
	var new_direction = face_direction.lerp(Vector2.from_angle(idle_turn_angle), turn_rate * delta)
	global_rotation = new_direction.angle()
	face_direction = new_direction
	doing_idle_movement = abs(global_rotation - idle_turn_angle) > 0.01

func reset_rat():
	patrol_path.progress = 0
	global_position = patrol_path.global_position

func on_view(seen_player: Player):
	if !is_active: return
	if seen_player.velocity.length() > 0.1 || in_light:
		if seen_player.attack(attack_damage, self): sprite.animation = "attack"

func on_idle_timeout():
	ai_state = State.IDLE
	idle_timer.wait_time = randi() % 11 + 10
	reset_timer.start()

func on_reset_timeout():
	ai_state = State.RETURN

func _on_animation_finished():
	if sprite.animation != "attack": return
	sprite.animation = "move"
extends Enemy
class_name Titania

@onready var attack_ray: RayCast2D = $AttackRay
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var weeping_sound: AudioStreamPlayer2D = $Sounds/WeepingSound
@onready var attack_sound: AudioStreamPlayer2D = $Sounds/Attack
@onready var footsteps = $Sounds/Footsteps

var is_moving_away_from_player: bool = false
var paused_position: float = 0.0

func _ready():
	super()
	sprite.animation = "move"
	sprite.animation_finished.connect(_on_animation_finished)

func _process(delta):
	super(delta)
	if ai_state == State.PATROL || velocity.length_squared() > 5:
		sprite.play()
	elif velocity.length_squared() < 5 || !is_active:
		sprite.pause()

func _physics_process(delta: float) -> void:
	if !is_active: return
	if ai_state == State.PATROL:
		patrol(delta)
		rotation = move_toward(rotation, 0, delta * turn_rate)
		footsteps.play_steps(base_speed)

	if patrol_path.progress_ratio >= 0.95:
		ai_state = State.CHASE
		chase_target = player

	if ai_state != State.CHASE: return
	
	footsteps.play_steps(get_real_velocity().length())
	if in_light:
		move_away_from_player(delta)
		if !is_moving_away_from_player:
			change_moving_away_from_player(true)
	else:
		chase(delta)
		try_damage_player()
		change_moving_away_from_player(false)

func toggle_active(enable: bool) -> void:
	super(enable)
	ai_state = State.IDLE

func _on_animation_finished():
	if sprite.animation != "attack": return
	sprite.animation = "move"

func reset_patrol_path():
	var current_pos = global_position
	patrol_path.progress = 0
	global_position = current_pos

func try_damage_player():
	var collider = attack_ray.get_collider()
	if collider is not Player: return
	if (collider as Player).attack(attack_damage, self):
		sprite.animation = "attack"
		HELPERS.play_audio(attack_sound, 0.9, 1.1)

func change_moving_away_from_player(is_moving_away: bool) -> void:
	if is_moving_away:
		is_moving_away_from_player = true
		HELPERS.play_audio_from_point(weeping_sound, paused_position)
	else:
		is_moving_away_from_player = false
		if weeping_sound.get_playback_position() > 0:
			paused_position = weeping_sound.get_playback_position()
		weeping_sound.stop()

func move_away_from_player(delta: float) -> bool:
	if chase_target == null:
		return false
	var away_direction = global_position.direction_to(chase_target.global_position) * -1
	var distances = [80]
	var angles := [0.0, deg_to_rad(50), deg_to_rad(-50),  deg_to_rad(100), deg_to_rad(-100)]

	for distance in distances:
		for angle in angles:
			var candidate_direction = away_direction.rotated(angle)
			var candidate_position = global_position + candidate_direction * distance

			nav_agent.target_position = candidate_position
			if nav_agent.is_target_reachable():
				return move_to(delta, candidate_position)
	velocity = velocity.lerp(away_direction * base_speed, acceleration * delta)
	move_and_slide()
	turn_process(delta)
	return false

func start_patrol_phase() -> void:
	ai_state = State.PATROL
	patrol_path.progress = 0
	global_position = patrol_path.global_position
	chase_target = null

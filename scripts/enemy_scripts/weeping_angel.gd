extends Enemy

@onready var footsteps = $Footsteps
@onready var attack_ray: RayCast2D = $AttackRay

func _ready():
	super()
	chase_target = player
	ai_state = State.CHASE

func _process(delta):
	var target_alpha = 1 if in_light || !hide_enemy else 0
	modulate.a = move_toward(modulate.a, target_alpha, delta * 60)

func _physics_process(delta):
	if !is_active || ai_state != State.CHASE: return

	chase(delta)
	try_damage_player()
	if get_real_velocity().length() < 1: return
	footsteps.play_steps(velocity.length() * 2, 0.1, 1.1, 1.2)

func alert_visual(alerter: Node2D) -> void:
	super(alerter)
	ai_state = State.IDLE

func alert_no_visual() -> void:
	super()
	ai_state = State.CHASE

func try_damage_player():
	var collider = attack_ray.get_collider()
	if collider is not Player: return
	(collider as Player).attack(attack_damage, self)

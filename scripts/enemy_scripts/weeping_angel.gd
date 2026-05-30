extends Enemy

@onready var footsteps = $Footsteps
@onready var attack_ray: RayCast2D = $AttackRay

func _ready():
    super()
    chase_target = player

func _physics_process(delta):
    if !is_active || in_light: return

    chase(delta)
    try_damage_player()
    footsteps.play_steps(velocity.length() * 2, 0.1, 1.1, 1.2)

func alert_visual(alerter: Node2D) -> void:
    super(alerter)

func try_damage_player():
    var collider = attack_ray.get_collider()
    if collider is not Player: return
    (collider as Player).attack(attack_damage, self)
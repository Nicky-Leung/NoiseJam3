extends Enemy

@onready var footsteps = $Footsteps
@onready var attack_ray: RayCast2D = $AttackRay

func _ready():
    super()
    chase_target = player

func _physics_process(delta):
    if !is_active || in_light: return
    chase(delta)
    footsteps.play_steps(velocity.length() * 2)

func alert_visual(alerter: Node2D) -> void:
    super(alerter)
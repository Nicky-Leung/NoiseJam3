extends Enemy

@onready var attack_ray: RayCast2D = $AttackRay

func alert_visual(alerter: Node2D) -> void:
    super(alerter)
    # implement mechanics later
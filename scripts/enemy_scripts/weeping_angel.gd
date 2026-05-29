extends Enemy

@onready var attack_ray: RayCast2D = $AttackRay

func alert_visual(alerter: Node2D) -> void:
    print("this thing has been spotted: " + name)
    # implement mechanics later
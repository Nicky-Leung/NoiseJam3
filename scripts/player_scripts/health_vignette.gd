extends TextureRect

@export var player: Player = null

const pulse_amount = 0.05
var min_radius: float = 0.5
var pulse_speed: float = 10
var theta: float = 0

func _ready():
    material.set_shader_parameter("radius", 1)

func _process(delta):
    if player == null: return # player not initialized yet
    if theta > 2 * PI: theta = 0
    else: theta += delta

    var radius = max(player.health * 1.0 / player.max_health, min_radius)
    print(radius)
    radius += pulse_amount * sin(theta * pulse_speed)
    material.set_shader_parameter("radius", min(radius, 1))
    print(material.get_shader_parameter("radius"))
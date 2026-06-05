extends Enemy

# Starting variables
@export var attention_time: float = 5

# Components
@onready var vision: EnemyVision = $VisionCone
@onready var reset_timer = $ResetTimer
@onready var footsteps = $Footsteps

# Runtime variables
var scout_position: Vector2 = Vector2.ZERO
var last_patrol_position: Vector2 = Vector2.ZERO

func _ready():
    super()
    ai_state = State.PATROL
    reset_timer.wait_time = attention_time
    reset_timer.timeout.connect(on_timeout)

func _process(_delta):
    pass

func _physics_process(delta):
    if !is_active: return

    if ai_state == State.PATROL:
        patrol(delta)
        last_patrol_position = global_position
        rotation = move_toward(rotation, 0, delta * turn_rate)
        return

    elif ai_state == State.SCOUT:
        var reached = move_to(delta, scout_position)
        if reached:
            ai_state = State.IDLE
            reset_timer.start()

    elif ai_state == State.RETURN:
        var reached = move_to(delta, last_patrol_position)
        if reached: ai_state = State.PATROL

func alert_sound(alerter: Node2D) -> void:
    ai_state = State.SCOUT
    reset_timer.stop()
    scout_position = alerter.global_position

func on_in_view(player: Player):
    pass

func on_timeout():
    ai_state = State.RETURN
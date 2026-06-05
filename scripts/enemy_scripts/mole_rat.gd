extends Enemy

func _ready():
    super()
    ai_state = State.PATROL

func _process(_delta):
    pass

func _physics_process(delta):
    if !is_active: return
    if ai_state == State.PATROL:
        patrol(delta)
        return
extends Node2D

@onready var censor_bar = $CensorBar
@onready var interactable = $Interactable

var is_censored: bool = true

# need to see later who manages the sequence to uncensor when sufficient progress is made
func _ready():
    # probably put this in it's own file later? determine later
    interactable.update_desc("You're not allowed to see that")

func uncensor(do_censor: bool = false):
    censor_bar.visible = do_censor
    if do_censor: interactable.update_desc("You're not allowed to see that")
    else: interactable.update_desc("Are you proud of yourself?")
extends Node2D

@onready var censor_bar = $CensorBar
@onready var interactable = $Interactable

var is_censored: bool = true

func _ready():
    interactable.interacted.connect(_on_interact)
    interactable.update_desc("You're not allowed to see that")
    uncensor(false)

func uncensor(do_censor: bool = false):
    censor_bar.visible = do_censor
    is_censored = false
    if do_censor: interactable.update_desc("You're not allowed to see that")
    else: interactable.update_desc("Are you proud of yourself?")

func _on_interact(player: Player):
    if is_censored:
        player.hud.display_flavor_text(interactable.description)
        return
    # emit sequence here
    player.hud.display_flavor_text(interactable.description)
    print("Game ended wow.")

extends Node2D

@onready var censor_bar = $CensorBar
@onready var interactable = $Interactable

signal uncensored_interacted

var is_censored: bool = true
var second_interact: bool = false

func _ready():
    interactable.interacted.connect(_on_interact)
    interactable.update_desc("You're not allowed to see that")

func uncensor(do_censor: bool = false):
    censor_bar.visible = do_censor
    is_censored = false
    if do_censor: interactable.update_desc("You're not allowed to see that")
    else: interactable.update_desc("Begin the cycle anew?")

func _on_interact(player: Player):
    if is_censored:
        player.hud.display_flavor_text(interactable.description)
        return
    if !second_interact:
        player.hud.display_flavor_text(interactable.description)
        second_interact = true
        return
    uncensored_interacted.emit()

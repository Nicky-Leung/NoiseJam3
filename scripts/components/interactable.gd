extends Area2D

enum Type {
    DESCRIPTION, # flavor text description
    SIGNALER, # anything more complicated (i.e. picking up item, opening something that needs a menu, etc.)
}

@onready var hitbox: CollisionShape2D = $Hitbox
@export var interact_type: Type = Type.DESCRIPTION
@export var parent_collider: CollisionShape2D = null
@export var description: String = ""

signal interacted

func _ready():
    if parent_collider == null:
        printerr("The parent CollisionShape2D must be referenced in the Interactable, a default square will be used until a parent shape is referenced")
        return
    hitbox.shape = parent_collider.shape

func update_desc(new_desc: String):
    description = new_desc

func interact(player: CharacterBody2D):
    if interact_type == Type.SIGNALER:
        print("this thing just emitted a signal called " + str(interacted)) # remove later when something actually needs to listen to the emit
        interacted.emit()
    elif interact_type == Type.DESCRIPTION:
        player.hud.display_flavor_text(description) # assumes correct usage (player has accessible hud component)
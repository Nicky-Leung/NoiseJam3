extends Area2D
class_name Interactable

enum Type {
    DESCRIPTION, # flavor text description
    SIGNALER, # anything more complicated (i.e. picking up item, opening something that needs a menu, etc.)
}

@onready var hitbox: CollisionShape2D = $Hitbox
@export var interact_type: Type = Type.DESCRIPTION
@export var parent_collider: CollisionShape2D = null
@export var description: String = ""

signal interacted(player: Player)

func _ready():
    if parent_collider == null:
        printerr("The parent CollisionShape2D must be referenced in the Interactable, a default square will be used until a parent shape is referenced")
        return
    hitbox.shape = parent_collider.shape
    hitbox.global_position = parent_collider.global_position
    monitoring = false

func update_desc(new_desc: String):
    description = new_desc

func enable(do_enable):
    set_deferred("disabled", !do_enable)

func interact(player: Player):
    if interact_type == Type.SIGNALER:
        interacted.emit(player)
    elif interact_type == Type.DESCRIPTION:
        player.hud.display_flavor_text(description)
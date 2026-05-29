extends CharacterBody2D
class_name Enemy

# components
@export var nav_agent: NavigationAgent2D = null
@export var animated_sprite: AnimatedSprite2D = null

# stats
@export var is_active: bool = false # set it to true in editor if enemy should immediately work on scene load
@export var acceleration: int = 20
@export var base_speed: int = 100
@export var friction: int = 400

func _ready():
	collision_mask = PHYS_LAYERS.TERRAIN + PHYS_LAYERS.PLAYER
	collision_layer = PHYS_LAYERS.ENEMY

func toggle_active(enable: bool) -> void:
	is_active = enable

func alert_sound(_alerter: Node2D) -> void: # expected to override in children class
	pass

func alert_visual(_alerter: Node2D) -> void: # expected to override in children class
	pass
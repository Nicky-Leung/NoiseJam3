extends Node2D
class_name Pickup

# Add into this when new pickables are added
enum Item {
	BATTERY,
	MEDKIT,
	TRAP,
	FLASHLIGHT, # This should only ever be in the starting room
	KEY_ITEM # i.e. pickups to solve puzzles
}

@export var key_item_name: String = "" ## Only fill for key items
@export var item: Item = Item.BATTERY
@export var item_sprite: Texture2D = null
@export var can_pickup: bool = true
@export var tutorial: bool = false # whether or not this pickup should trigger the tutorial when picked up


@onready var sprite: TextureRect = $Sprite
@onready var interactable: Interactable = $Interactable
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer



func _ready():
	sprite.texture = item_sprite
	interactable.interacted.connect(on_interacted)
	allow_pickup(can_pickup)

func allow_pickup(allow: bool):
	interactable.enable(allow)

func on_interacted(player: Player):
	var was_added_to_inv = false
	if item == Item.BATTERY: was_added_to_inv = player.inventory.try_change_battery(true)
	elif item == Item.MEDKIT: was_added_to_inv = player.inventory.try_change_medkit(true)
	elif item == Item.TRAP: was_added_to_inv = player.inventory.try_change_trap(true)
	elif item == Item.KEY_ITEM: was_added_to_inv = player.inventory.add_key_item(key_item_name, item_sprite)
	elif item == Item.FLASHLIGHT:
		player.has_flashlight = true
		was_added_to_inv = true
		player.flashlight.toggle()

	if was_added_to_inv:
		visible = false
		interactable.enable(false)
		HELPERS.play_audio(audio_player, 0.9, 1.1, 10)

		# debate if just want to hide it, or actually delete it
		var delay = create_tween()
		delay.tween_interval(audio_player.stream.get_length())
		delay.tween_callback(queue_free)
	if tutorial: 
		if item == Item.BATTERY:
			player.show_tutorial("battery", "Press B to open your inventory and E to use")
		elif item == Item.MEDKIT:
			player.show_tutorial("medkit", "Press B to open your inventory and E to use")
		elif item ==Item.FLASHLIGHT:
			player.show_tutorial("flashlight", "Right Click the flashlight to toggle it on/off.")
	else:
		# probably put some UI saying inventory is full, for now just print it
		print("Cannot add " + str(Item.keys()[item]) + " because inventory is full")

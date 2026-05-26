extends Label

@export var scroll_time: float = 0.5
@export var linger_time: float = 3

var tween

func _ready():
    text = ""

func scroll_text(desc: String):
    if text == desc: # don't do anything if interacting with same object
        return

    if tween: # stop previous text scroll if interacting with new object
        tween.kill()
    text = desc
    visible_ratio = 0

    tween = create_tween()
    tween.tween_property(self, "visible_ratio", 1, scroll_time)
    tween.tween_interval(linger_time)
    tween.tween_callback(func(): text = "")
    tween.play()
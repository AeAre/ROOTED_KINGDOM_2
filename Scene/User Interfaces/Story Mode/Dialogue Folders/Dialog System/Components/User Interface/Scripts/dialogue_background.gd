extends Control

@onready var background_node = $Background

var background_options = [
	"Nothingness",
	"Rolling_Plains"
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_dialogue_background(select: String):
	if select == "Nothingness":
		background_node.texture = preload("res://Asset/User Interface/%Storymode%/black_background.jpg")
	elif select == "Rolling_Plains":
		background_node.texture = preload("res://Asset/User Interface/%Storymode%/Rollings Plains.jpg")

func check_if_background_isnot_empty():
	if background_node.texture != null:
		return true
# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

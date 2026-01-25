extends Button

@export var chp_title: String
@export var chp_number: int
@export var chp_img: Texture
@export var chp_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Title.text = str(chp_title)
	$"Chapter Number".text = "Chapter " + str(chp_number)
	$TextureRect.texture = chp_img


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

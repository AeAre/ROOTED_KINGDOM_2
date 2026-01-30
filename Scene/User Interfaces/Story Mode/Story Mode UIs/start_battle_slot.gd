extends Button

# DOCUMENTION
# Panel's Mouse > Filter is set to ignore                                        

@export var title: String
@export var image: Texture
@export_enum("Story Mode", "Tower Mode") var mode
@export var availability: bool

@onready var CURRENT_STAGE_LEVEL = $"Current Stage-Level"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Title.text = title
	$Image.texture = image
	if mode == 0:
		CURRENT_STAGE_LEVEL.text = "Current Stage " + " - "
	elif mode == 1:
		CURRENT_STAGE_LEVEL.text = "Current Tower Level: Level "
	else:
		print("mode is null")
	
	# THIS DECIDEDS IF THE BUTTON IS CLICKABLE OR NOT
	if availability:
		$"Availability Label".visible = false
	else:
		$"Availability Label".visible = true
		$".".disabled = true

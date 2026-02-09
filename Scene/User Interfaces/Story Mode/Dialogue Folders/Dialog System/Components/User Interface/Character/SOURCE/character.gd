extends Control

@onready var Reactions = $Reactions
@onready var Character = $"."
@onready var PropertyAnim = $PropertyAnimation

# THIS IS HOW THIS WOULD WORK
# EACH ANIMATION WILL BE CALLED IN DIALOGUE SYSTEM PROGRAM
# EACH ANIMATION ARE CALLED IN THE SAME MANNER, MEANING THE NAMING CONVENTION
# MUST BE CONSISTENT ACROSS ALL ANIMATIONS

# PROPERTY ANIMATION IS THERE JUST IN CASE IT IS REQUIRES; BECAUSE IT IS REQUIRED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Reactions.sprite_frames = preload("res://Asset/Backgrounds/background 1.jpg")
	pass # Replace with function body.
	
# REACTIONS

func idle(): # DEFAULT
	Reactions.play("default")
	
func happy():
	Reactions.play("happy")

func mad():
	Reactions.play("mad")

# PROPERTY ANIMATIONS

func slide(towards: String):
	if towards.to_lower() == "center":
		PropertyAnim.play("slide_to_center")
	elif towards.to_lower() == "left":
		PropertyAnim.play("slide_to_center")
	elif towards.to_lower() == "right":
		PropertyAnim.play("slide_to_center")
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

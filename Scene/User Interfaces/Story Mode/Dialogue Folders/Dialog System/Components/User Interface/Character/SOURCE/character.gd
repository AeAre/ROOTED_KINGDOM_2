extends Control

@onready var Reactions = $Reactions
@onready var Character = $"."
@onready var PropertyAnim = $PropertyAnimations

enum property_fx {
	Left,
	Right,
	Center,
	Fade_In,
	Fade_Out
}
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
# Slide
func slide(towards: property_fx):
	if towards == property_fx.Center:
		if Character.position > 400:
			PropertyAnim.play("slide_to_center_from_left")
		elif Character.position < 400:
			PropertyAnim.play("slide_to_center_from_right")
	elif towards == property_fx.Left:
		PropertyAnim.play("slide_to_left")
	elif towards == property_fx.Right:
		PropertyAnim.play("slide_to_right")
# Fade
func fade(value: property_fx):
	if value == property_fx.Fade_In:
		PropertyAnim.play("fade_in")
	elif value == property_fx.Fade_Out:
		PropertyAnim.play("fade_out")
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

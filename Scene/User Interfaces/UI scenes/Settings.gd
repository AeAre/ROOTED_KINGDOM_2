extends Control

@onready var cheat_input = $VBoxContainer/CheatInput
@onready var redeem_btn = $VBoxContainer/RedeemButton
@onready var feedback_lbl = $VBoxContainer/FeedbackLabel
@onready var volume_slider = $"User Interface/Options/VBoxContainer/Volume Slider"
@onready var fullscreen_check = $"User Interface/Options/VBoxContainer/Fullscreen Check"

var volume:= 50.0 # Boolean

var window_id = DisplayServer.MAIN_WINDOW_ID
var window_mode = DisplayServer.window_get_mode(window_id)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	redeem_btn.pressed.connect(_on_redeem_pressed)
	volume_slider.value = volume
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen_check.button_pressed = true

# --- 1. REDEEM CODE LOGIC ---
func _on_redeem_pressed():
	var code = cheat_input.text.to_upper() 
	var result = Global.try_redeem_code(code)

	feedback_lbl.text = result
	cheat_input.text = ""


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	volume = value

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on == true and window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, window_id)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, window_id)


func _on_option_button_item_selected(index: int) -> void:
	var new_size: Vector2i
	
	match index:
		0:
			new_size = Vector2i(1920, 1080)
		1:
			new_size = Vector2i(1600, 900)
		2:
			new_size = Vector2i(1280, 720)
	
	# Actually resize the window
	DisplayServer.window_set_size(new_size, window_id)



			

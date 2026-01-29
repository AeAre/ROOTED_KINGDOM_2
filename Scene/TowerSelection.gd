extends Control

@onready var desc_label = $DescriptionPanel/Label
@onready var container = $ScrollContainer/VBox # Reference to container

var selected_floor = 1

# --- ICON PATHS ---
const GEM_ICON_PATH = "res://Asset/Backgrounds/gem_1.webp"
const CRYSTAL_ICON_PATH = "res://Asset/Backgrounds/gem_3.webp"

func _ready():
	# 1. SETUP BUTTONS
	# We use a helper function to keep code clean and apply locking logic
	setup_floor_button(1, "Floor 1: One Grunt")
	setup_floor_button(2, "Floor 2: Two Grunts")
	setup_floor_button(3, "Floor 3: The Trio")
	setup_floor_button(4, "Floor 4: The four enemies")
	setup_floor_button(5, "Floor 5: The benevolent") # Added missing floor 5
	setup_floor_button(6, "Floor 6: The benevolent")
	setup_floor_button(7, "Floor 7: The benevolent")
	setup_floor_button(8, "Floor 8: The benevolent")
	setup_floor_button(9, "Floor 9: The benevolent")
	setup_floor_button(10, "Floor 10: The benevolent")

	# 2. START BUTTON SETUP
	$StartBattleButton.text = "Choose Characters"
	$StartBattleButton.pressed.connect(_on_choose_characters_pressed)
	
	# Default selection
	_on_floor_selected(1, "Floor 1: One Grunt")

func setup_floor_button(floor_num: int, desc: String):
	var btn_name = "Floor" + str(floor_num)
	if not container.has_node(btn_name):
		return

	var btn = container.get_node(btn_name) as BaseButton
	
	# --- LOCKING LOGIC ---
	var is_unlocked = false
	
	if floor_num == 1:
		is_unlocked = true
	else:
		# Floor 2 unlocks if Floor 1 is in the array
		if Global.floors_cleared.has(floor_num - 1):
			is_unlocked = true

	# Apply Visuals and State
	if is_unlocked:
		btn.disabled = false
		btn.modulate = Color(1, 1, 1) # Bright
		
		# Disconnect old signals to prevent double-firing
		if btn.pressed.is_connected(_on_floor_selected):
			btn.pressed.disconnect(_on_floor_selected)
			
		btn.pressed.connect(_on_floor_selected.bind(floor_num, desc))
	else:
		btn.disabled = true
		btn.modulate = Color(0.2, 0.2, 0.2) # Darkened
		# If it's locked, make sure it does nothing when clicked
		if btn.pressed.is_connected(_on_floor_selected):
			btn.pressed.disconnect(_on_floor_selected)

	print("Floor ", floor_num, " is_unlocked: ", is_unlocked) # DEBUG LINE

func _on_floor_selected(floor_num: int, description: String):
	selected_floor = floor_num
	Global.current_tower_floor = floor_num
	
	# 1. Get the reward data from Global
	var reward = Global.floor_rewards.get(floor_num, {"small": 0, "crystal": 0})
	
	# 2. Build the Text with Icons
	var text = "[b]" + description + "[/b]\n\n"
	text += "Rewards:\n"
	
	if reward["small"] > 0:
		text += "[img=25]%s[/img] %d   " % [GEM_ICON_PATH, reward["small"]]
		
	if reward["crystal"] > 0:
		text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
	
	# 3. Update the Label
	desc_label.text = text

func _on_choose_characters_pressed():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

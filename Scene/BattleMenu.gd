extends CanvasLayer

@onready var title_label = $Panel/VBoxContainer/Title
@onready var action_btn = $Panel/VBoxContainer/ActionButton
@onready var quit_btn = $Panel/VBoxContainer/QuitButton
@onready var reward_label = $Panel/VBoxContainer/RewardLabel # New Node!

# --- ICON PATHS (UPDATE THESE!) ---
const GEM_ICON_PATH = "res://Asset/Backgrounds/gem_1.webp"
const CRYSTAL_ICON_PATH = "res://Asset/Backgrounds/gem_3.webp"

func _ready():
	hide()

func show_pause_menu():
	title_label.text = "PAUSED"
	title_label.show()
	reward_label.hide() # Hide rewards in pause menu
	action_btn.text = "Resume"
	show()
	get_tree().paused = true

func show_victory_menu():
	title_label.text = "VICTORY!"
	title_label.show()
	action_btn.text = "Next Floor"
	
	# 1. Get the reward data BEFORE we leave the floor
	var reward = Global.floor_rewards.get(Global.current_tower_floor, {"small": 0, "crystal": 0})
	
	# 2. Grant the reward (Logic)
	Global.grant_floor_reward(Global.current_tower_floor)
	Global.mark_floor_cleared(Global.current_tower_floor)
	
	# 3. Display the reward (Visuals)
	reward_label.show()
	reward_label.bbcode_enabled = true
	
	var txt = "[center]Rewards:[/center]\n[center]"
	if reward["small"] > 0:
		txt += "[img=30]%s[/img] +%d  " % [GEM_ICON_PATH, reward["small"]]
	if reward["crystal"] > 0:
		txt += "[img=30]%s[/img] +%d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
	txt += "[/center]"
	
	reward_label.text = txt
	
	show()
	get_tree().paused = true

func show_loss_menu():
	title_label.text = "YOU LOST"
	title_label.show()
	reward_label.hide() # No rewards for losers!
	action_btn.text = "Try Again"
	show()
	get_tree().paused = true

func _on_action_button_pressed():
	if action_btn.text == "Next Floor":
		get_tree().paused = false 
		Global.current_tower_floor += 1
		hide()
		# Check if next floor exists, otherwise maybe go back to menu?
		if Global.current_tower_floor <= 10: # Updated to 10 based on your list
			get_tree().reload_current_scene()
		else:
			# Tower Complete! Go back to selection
			get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
	
	elif action_btn.text == "Try Again":
		get_tree().paused = false 
		hide()
		get_tree().reload_current_scene()
		
	else:
		# Resume
		get_tree().paused = false 
		hide()

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
	hide()

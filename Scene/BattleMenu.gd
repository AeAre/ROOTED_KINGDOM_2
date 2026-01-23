# BattleMenu.gd
extends CanvasLayer

@onready var title_label = $Panel/VBoxContainer/Title
@onready var action_btn = $Panel/VBoxContainer/ActionButton
@onready var quit_btn = $Panel/VBoxContainer/QuitButton

func _ready():
	hide() # Ensure it's hidden on start

func show_pause_menu():
	title_label.text = "PAUSED"
	title_label.show() # Make sure it's visible
	action_btn.text = "Resume"
	show()
	get_tree().paused = true # This freezes the background!

func show_victory_menu():
	title_label.text = "VICTORY!"
	title_label.show()
	action_btn.text = "Next Floor"
	show()
	get_tree().paused = true

func show_loss_menu():
	title_label.text = "YOU LOST"
	title_label.show()
	action_btn.text = "Try Again" # This will reload the current floor
	show()
	get_tree().paused = true
	
func _on_action_button_pressed():
	if action_btn.text == "Next Floor":
		get_tree().paused = false 
		Global.current_tower_floor += 1
		hide()
		if Global.current_tower_floor <= 5:
			get_tree().reload_current_scene()

	
	elif action_btn.text == "Try Again":
		get_tree().paused = false # Ensure no hidden spaces here
		hide() # Make the menu disappear
		get_tree().reload_current_scene()
		
	else:
		# This is the "Resume" logic
		get_tree().paused = false 
		hide()

func _on_quit_button_pressed():
	get_tree().paused = false # ALWAYS unpause before changing scenes
	get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
	hide()

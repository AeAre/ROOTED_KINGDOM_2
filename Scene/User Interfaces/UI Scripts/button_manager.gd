extends Control

@onready var small_gem_label = $"../MarginContainer/HBoxContainer/SmallGemHolder/SmallGemLabel"
@onready var crystal_label = $"../MarginContainer/HBoxContainer/CrystalGemHolder/CrystalLabel"

func _ready() -> void:
	update_currency_ui()
	
	
func update_currency_ui():
	# Display the values from Global
	small_gem_label.text = str(Global.small_gems)
	crystal_label.text = str(Global.crystal_gems)

func _on_start_battle_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")


func _on_inventory_and_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/CardUpgradeUI.tscn")


func _on_characters_pressed() -> void:
	Global.from_tower_mode = false # Just looking at characters
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/tutorial.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

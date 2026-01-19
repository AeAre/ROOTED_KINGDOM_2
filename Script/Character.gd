extends Node2D
class_name BattleCharacter
# This script lives on every character (Beatrix, Charlotte, Enemy)

@export var char_name: String = ""
@export var is_enemy: bool = false

var current_health: int = 100
var current_shield: int = 0
var action_meter: float = 0.0 # This fills up from 0 to 100

var is_stunned: bool = false # NEW: Tracks if the character skips a turn

# These must exist as children inside each character node!
@onready var hp_bar = $HealthBar
@onready var shield_label = $ShieldLabel

# Add this function to handle healing
func heal(amount: int):
	current_health = min(100, current_health + amount)
	update_ui()
	
func _ready():
	hp_bar.max_value = 100
	hp_bar.value = current_health
	shield_label.text = "Shield: 0"

func take_damage(amount: int):
	# 1. Determine how much damage hits the health after the shield absorbs what it can
	
	var damage_to_hp = amount
	
	if current_shield > 0:
		if current_shield >= amount:
			# Shield absorbs everything
			current_shield -= amount
			damage_to_hp = 0
		else:
			# Shield breaks; some damage still goes to HP
			damage_to_hp = amount - current_shield
			current_shield = 0
	
	# 2. Apply remaining damage to health
	current_health -= damage_to_hp
	# 3. Trigger visual feedback and UI updates
	update_ui()
	
	# 4. Check for death
	if current_health <= 0:
		current_health = 0
		die()

func update_ui():
	hp_bar.value = current_health
	shield_label.text = "Shield: " + str(current_shield)

func die():
	print(char_name + " has been defeated!")
	
	# 1. Disable any buttons or interaction
	# If this is a hero, you might want to stop them from being targeted
	
	# 2. Visual Feedback: Fade out using a Tween
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5) # Fades opacity to 0 over 0.5 seconds
	
	# 3. Remove from the game tree once the fade is done
	tween.tween_callback(queue_free)

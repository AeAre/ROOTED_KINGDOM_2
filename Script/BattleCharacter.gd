extends Node2D
class_name BattleCharacter

@export var char_name: String = ""
@export var is_enemy: bool = false
@onready var sprite_2d = $Sprite2D
@export var target_height: float = 350.0 # Adjust this number to fit your scene

var current_health: int = 100
var current_shield: int = 0
var action_meter: float = 0.0 # This fills up from 0 to 100

var is_stunned: bool = false # NEW: Tracks if the character skips a turn
var max_health: int
var base_damage: int
# These must exist as children inside each character node!
@onready var sprite = $Sprite2D
@onready var hp_bar = $HealthBar
@onready var shield_label = $ShieldLabel

func setup_character(data: CharacterData):
	if data == null: 
		hide() # Hide dummy if no hero was selected for this slot
		return
		
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	
	# Update the Visuals
	if sprite:
		sprite.texture = data.character_sprite
		var texture_size = sprite_2d.texture.get_size()
		var scale_factor = target_height / texture_size.y
		
		sprite_2d.scale = Vector2(scale_factor, scale_factor)
	show()
	print("Initialized: ", char_name)
	
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
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5) # Fades opacity to 0 over 0.5 seconds
	
	# 3. Remove from the game tree once the fade is done
	tween.tween_callback(queue_free)
	
func setup(data: CharacterData):
	char_name = data.name
	current_health = data.max_health
	hp_bar.max_value = data.max_health # Set bar max based on resource
	
	# Set the picture from the resource
	if has_node("Sprite"):
		$Sprite.texture = data.character_illustration
	
	update_ui()

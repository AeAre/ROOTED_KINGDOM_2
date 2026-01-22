# Enemy.gd
extends BattleCharacter

@export var base_shield: int = 10  # renamed to be clear

func _ready():
	# Give the enemy its starting shield value (so take_damage uses it)
	current_shield = base_shield
	update_ui()

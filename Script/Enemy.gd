# Enemy.gd
extends BattleCharacter

func setup_enemy(data: EnemyData):
	if data == null:
		hide()
		return
		
	# 1. Assign Stats from Resource
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	current_shield = data.base_shield
	
	# 2. Update Visuals
	if sprite_2d and data.enemy_sprite:
		sprite_2d.texture = data.enemy_sprite
		
		# --- FIX 1: DIRECTION ---
		# This flips the sprite horizontally so they face the player
		sprite_2d.flip_h = true 
		
		# --- FIX 2: SIZE ---
		# We use the Target Height variable. 
		# If they are too big, we will change this number in the Inspector!
		var texture_size = sprite_2d.texture.get_size()
		var scale_factor = target_height / texture_size.y
		sprite_2d.scale = Vector2(scale_factor, scale_factor)
	
	update_ui()
	show()

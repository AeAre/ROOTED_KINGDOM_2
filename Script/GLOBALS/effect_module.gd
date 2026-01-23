extends Character_Attributes

# -- Infliction
func Damage(_target: Character_Attributes, value: float): # Deals Damage
	_target.health -= value

func Defense(_target: Character_Attributes, value: float): # Gives Defense
	_target.defense += value

# -- Effects --
# Buff
# Haste - increases the target's speed by a percentage
func Haste(_target: Character_Attributes, _percentage: float):
	_target.speed += (_target.speed * _percentage)
	
# Protect - increases the target's defense by a percentage
func Protect(_target: Character_Attributes, _percentage: float):
	_target.defense += (_target.defense * _percentage)

# Strength - increases the target's damage by a percentage
func Strength(_target: Character_Attributes, _percentage: float):
	_target.Cards_Damage += (int(float(_target.Cards_Damage) * _percentage))
	
# Regenerate - increases the target's health by a percentage
func Regenerate(_target: Character_Attributes, _percentage: float):
	_target.health += (_target.health * _percentage)

# Evade - disregards every attack and debuffs on the target
func Evade(_target: Character_Attributes):
	pass

# Hide -  exempts the target from being chosen as a target
# Cleanse - removes all of target's debuffs

# Debuffs:
# Stun - target will be unable to attack for the current round


# Poison - target losses a percentage of their current health each turn
func Poison(_target: Character_Attributes, _percentage: float):
	_target.health -= (_target.current_health * _percentage)
	
# Bleed - target losses a percentage of their max health each turn
func Bleed(_target: Character_Attributes, _percentage: float):
	_target.health -= (_target.health * _percentage)
	
# Flame - target losses a percentage of their max health each turn, ignoring defense
func Flame(_target: Character_Attributes, _percentage: float):
	_target.health -= (_target.health * _percentage)
	
# Slow - target slows down; losing a percentage speed
func Slow(_target: Character_Attributes, _percentage: float):
	_target.speed -= (_target.speed * _percentage)
	
# Goad - target will be a target priority by all enemies

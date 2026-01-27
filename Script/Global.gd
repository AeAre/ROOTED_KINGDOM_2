extends Node

var player_name: String = ""
const SAVE_PATH = "user://player_data.save"

# --- EXISTING VARIABLES ---
var current_tower_floor: int = 1
var floors_cleared: Array = [] 
var selected_team: Array[CharacterData] = []
var player_team: Array = []

# --- NEW: UPGRADE SYSTEM VARIABLES ---
var upgrade_materials: int = 500
var card_levels: Dictionary = {}
var small_gems: int = 5000
var crystal_gems: int = 100

var unlocked_heroes: Array[String] = ["Hero"] # Start with your default hero name here

var from_tower_mode: bool = false

func _ready() -> void:
	load_data()
	# pass
	# reset_player_data()
	
var floor_rewards = {
	1: { "small": 100, "crystal": 0 },
	2: { "small": 150, "crystal": 0 },
	3: { "small": 200, "crystal": 1 }, 
	4: { "small": 250, "crystal": 1 },
	5: { "small": 500, "crystal": 1 },
	6: { "small": 100, "crystal": 1 },
	7: { "small": 150, "crystal": 1 },
	8: { "small": 200, "crystal": 1 },
	9: { "small": 250, "crystal": 1 },
	10: { "small": 1000, "crystal": 5 },
	# Add more floors here...
}

func add_to_team(data: CharacterData):
	selected_team.append(data)
		
func clear_team():
	selected_team.clear()
	
func mark_floor_cleared(floor_num: int):
	if not floors_cleared.has(floor_num):
		floors_cleared.append(floor_num)
	save_data()
	
func get_card_damage(data: CardData) -> int:
	# If the card isn't in our dictionary yet, it's level 0 (Base stats)
	var lvl = card_levels.get(data.card_name, 0)
	return data.damage + (data.damage_growth * lvl)

# 2. Get Shield based on Level
func get_card_shield(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.shield + (data.shield_growth * lvl)

# 3. Get Heal based on Level
func get_card_heal(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.heal_amount + (data.heal_growth * lvl)

func get_card_mana(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.mana_gain + (data.mana_gain * lvl)
	
# 4. Get the Current Level Number (For UI)
func get_card_level_number(data: CardData) -> int:
	# Returns 1, 2, 3... instead of 0, 1, 2...
	save_data()
	return card_levels.get(data.card_name, 0) + 1 
	
# 5. The Upgrade Action
func attempt_upgrade(data: CardData) -> bool:
	if small_gems >= data.upgrade_cost:
		# 1. Deduct Cost
		small_gems -= data.upgrade_cost
		save_data()
		# 2. Increase Level
		if not card_levels.has(data.card_name):
			card_levels[data.card_name] = 0
		
		card_levels[data.card_name] += 1
		return true
	else:
		print("Not enough Small Gems!")
		return false
	

func grant_floor_reward(floor_num: int):
	if floor_rewards.has(floor_num):
		var reward = floor_rewards[floor_num]
		small_gems += reward["small"]
		crystal_gems += reward["crystal"]
		print("Victory! Gained: ", reward["small"], " Gems and ", reward["crystal"], " Crystals")
	save_data()



func try_redeem_code(code: String) -> String:
	
	match code:
		"RICH":
			small_gems += 5000
			crystal_gems += 50
			save_data()
			return "Success! +5000 Gems\n+50 Crystals"
		"POOR":
			small_gems = 0
			crystal_gems = 0
			save_data()
			return "Wallet Empty..."
		_:
			return "Invalid Code"
	
func is_hero_unlocked(hero_name: String) -> bool:
	return unlocked_heroes.has(hero_name)

func unlock_hero(hero_name: String):
	if not unlocked_heroes.has(hero_name):
		unlocked_heroes.append(hero_name)
	save_data()
	
func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"player_name": player_name,
		"small_gems": small_gems,
		"crystal_gems": crystal_gems
		# Add other variables you want to save here
	}
	file.store_var(data)
	
	
func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		player_name = data.get("player_name", "")
		small_gems = data.get("small_gems", 5000)
		crystal_gems = data.get("crystal_gems", 100)
	
func reset_player_data():
	player_name = ""
	small_gems = 5000
	crystal_gems = 100
	# Delete the physical file from your computer
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("Data Reset! Restart the game to see the Name Scene.")

extends Node

# New variables for the Tower
var current_tower_floor: int = 1
var floors_cleared: Array = [] # e.g., [1, 2] means floors 1 and 2 are done
var selected_team: Array[CharacterData] = []
var player_team: Array = []

func add_to_team(data: CharacterData):
	if selected_team.size() < 3:
		selected_team.append(data)
		
func clear_team():
	selected_team.clear()

func mark_floor_cleared(floor_num: int):
	if not floors_cleared.has(floor_num):
		floors_cleared.append(floor_num)

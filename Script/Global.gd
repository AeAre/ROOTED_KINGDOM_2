extends Node


var selected_team: Array[CharacterData] = []

func add_to_team(data: CharacterData):
	if selected_team.size() < 3:
		selected_team.append(data)
		
func clear_team():
	selected_team.clear()

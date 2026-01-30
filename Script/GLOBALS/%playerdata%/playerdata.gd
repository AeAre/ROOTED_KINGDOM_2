extends Node

var _JSON_file = preload("res://Script/GLOBALS/%playerdata%/PLAYERDATA.json")
var json_as_text
var _PLAYER_DATA_PARSE
var _PLAYER_DATA

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if _JSON_file != "":
		_load_JSON()

func _load_JSON():
	json_as_text = FileAccess.get_file_as_string(_JSON_file)
	_PLAYER_DATA_PARSE = JSON.parse_string(json_as_text)
	if _PLAYER_DATA_PARSE == null:
		print("ERROR: JSON failed to parse. Check for typos/missing commas in the file.")
		return
		
	_PLAYER_DATA = _PLAYER_DATA_PARSE.get("PlayerData", {})
	#Dialogue_speaker = Dialogue_access[0]
	#Dialogue_array = Dialogue_speaker.keys()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

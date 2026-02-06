extends Node

# This program is just a temporary saving file for Story Mode

var _CURRENTLY_PLAYING_CHAPTER:= -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func reset_chapter_I_browse():
	if _CURRENTLY_PLAYING_CHAPTER > -1:
		_CURRENTLY_PLAYING_CHAPTER = -1
		print("Current Chapter: " + str(_CURRENTLY_PLAYING_CHAPTER))
		
func declare_chapter(value: int):
	if _CURRENTLY_PLAYING_CHAPTER == -1:
		_CURRENTLY_PLAYING_CHAPTER = value
		print("Current Chapter: " + str(_CURRENTLY_PLAYING_CHAPTER))

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

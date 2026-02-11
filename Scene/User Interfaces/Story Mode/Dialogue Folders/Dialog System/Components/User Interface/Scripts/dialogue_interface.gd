extends Control

@onready var Dialogue_ui = $"MarginContainer/Control/Dialogue Panel Container/Dialogue"
@onready var Dialogue_speaker =$"MarginContainer/Control/Speaker PanelContainer/Speakername"
@onready var dialogue_panel = $"MarginContainer/Control/Dialogue Panel Container"
@onready var speaker_panel = $"MarginContainer/Control/Speaker PanelContainer"

var animate_text:= true
var animation_speed:= 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogue_ui.visible_ratio = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animate_text:
		if Dialogue_ui.visible_ratio < 1.0:
			Dialogue_ui.visible_ratio += (1.0/Dialogue_ui.text.length()) * (animation_speed * delta)
		else:
			animate_text = false

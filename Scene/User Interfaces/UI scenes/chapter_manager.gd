extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

func _on_stage_1_1_pressed() -> void:
	$Panel.visible = true
	$Panel/Title.text = "Stage 1-1"
	$Panel/Play_Attack.text = "Play"

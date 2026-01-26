extends Control

@export var Stage: PackedScene
@export var Stage_number: String
@export var Stage_img: Texture
@export_enum("Story", "Battle") var Scene_type: String
@export var Objective: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Stage Button".text = Stage_number
	$"Stage Slot bg".texture = Stage_img
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_stage_button_pressed() -> void:
	$"../../Stage Confimation".visible = true
	$"../../Stage Confimation/Panel/Stage Title".text = Stage_number
	
	if Objective != null:
		if Scene_type == "Story":
			$"../../Stage Confimation/Panel/Objective".visible = false
		elif Scene_type == "Battle":
			$"../../Stage Confimation/Panel/Objective".visible = true
			$"../../Stage Confimation/Panel/Objective".text = Objective
			

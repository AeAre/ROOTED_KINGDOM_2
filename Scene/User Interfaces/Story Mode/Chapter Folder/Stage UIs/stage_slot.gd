extends Control

@export var Stage: PackedScene
@export var Stage_number: String
@export var Stage_img: Texture
@export_enum("Story", "Battle") var Scene_type: String
@export var Objective: String

@onready var stage_confirm = $"../../../../Stage Confimation"
@onready var stage_image = $"Interface/Stage Image"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Interface/Stage Button".text = Stage_number
	stage_image.img.texture = Stage_img
	# $"Stage Slot bg".texture = Stage_img
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_stage_button_pressed() -> void:
	stage_confirm.visible = true
	stage_confirm.title.text = "Stage " + Stage_number
	stage_confirm.image.texture = Stage_img
	if Stage != null:
		stage_confirm.stage_scene = Stage
	else:
		stage_confirm.stage_scene = null	
	
	if Objective != null:
		if Scene_type == "Story":
			stage_confirm.objective.visible = false
		elif Scene_type == "Battle":
			stage_confirm.objective.visible = true
			stage_confirm.objective.text = Objective
	else:
		stage_confirm.objective.visible = false
			

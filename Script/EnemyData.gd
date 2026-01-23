# EnemyData.gd
extends Resource
class_name EnemyData

@export var name: String = "Enemy"
@export var enemy_sprite: Texture2D
@export_group("Stats")
@export var max_health: int = 100
@export var base_damage: int = 10
@export var base_shield: int = 0

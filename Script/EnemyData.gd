extends Resource
class_name EnemyData

@export var name: String = "Enemy"
@export var idle_animation: SpriteFrames 

@export_group("Stats")
@export var max_health: int = 100
@export var base_damage: int = 10
@export var base_shield: int = 0

@export_group("Combat Rules")
@export var min_crit_chance: int = 5
@export var max_crit_chance: int = 30
@export var is_aoe: bool = false
@export var aoe_targets: int = 1
@export var attack_sound_1: AudioStream

@export_subgroup("Secondary Attack Settings")
@export var secondary_attack_chance: float = 0.2 
@export var secondary_is_aoe: bool = false  
@export var secondary_aoe_targets: int = 3
@export var secondary_damage_mult: float = 1.5
@export var attack_sound_2: AudioStream

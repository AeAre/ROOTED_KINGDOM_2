extends Resource
class_name CharacterData

@export var name: String = "Hero"
@export var character_sprite: Texture2D
@export var character_illustration: Texture2D

@export_group("Stats")
@export var max_health: int = 100
@export var base_shield: int = 0

@export_group("Deck")
@export var unique_card: CardData
@export var common_cards: Array[CardData]

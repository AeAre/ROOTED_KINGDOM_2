extends Node2D

@export var floor_1_enemies: Array[EnemyData] = []
@export var floor_2_enemies: Array[EnemyData] = []
@export var floor_3_enemies: Array[EnemyData] = []
@export var floor_4_enemies: Array[EnemyData] = []
@export var floor_5_enemies: Array[EnemyData] = []
@export var floor_6_enemies: Array[EnemyData] = []
@export var floor_7_enemies: Array[EnemyData] = []
@export var floor_8_enemies: Array[EnemyData] = []
@export var floor_9_enemies: Array[EnemyData] = []
@export var floor_10_enemies: Array[EnemyData] = []
# --- 1. NODE LINKS ---
@onready var slot_container = %CardSlots
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand
@onready var mana_label = $CanvasLayer/EnergyLabel

@onready var global_info_button = $CanvasLayer/GlobalInfoButton
var is_info_mode_on: bool = false

var mana_popup_scene = preload("res://Scene/ManaPopup.tscn") 
var card_scene = preload("res://Scene/CardUI.tscn")

var is_processing_turn: bool = false
var turn_order: Array = []
var current_turn_index: int = 0
var active_character: BattleCharacter = null
var is_battle_paused: bool = false

# The Deck System
var deck: Array = []
var discard_pile: Array = []
var hand_size: int = 6
var round_number: int = 1

# --- MANA SYSTEM UPDATES ---
var max_mana: int = 20     # Hard Cap
var current_mana: int = 4  # Starting Mana
var mana_regen: int = 4

# Card Slots
var slotted_cards: Array = [] 
var max_slots: int = 3


var phases: Array = ["player", "enemy"]
var current_phase_index: int = 0

# Sound effects
@onready var sfx_player = $CanvasLayer/SFXPlayer
@onready var bgm_player = $CanvasLayer/BGMPlayer

var battle_themes: Array[String] = [
	"res://Asset/Sound effects/background effect1.mp3",
	"res://Asset/Sound effects/background effect2.mp3"
]

func _ready():
	# --- NEW: Clear editor placeholders ---
	for child in hand_container.get_children():
		child.queue_free()
	
	# Wait a tiny bit for the engine to remove them from the count
	await get_tree().process_frame 
	
	var btn = get_node_or_null("CanvasLayer/GlobalInfoButton")
	if btn:
		if not btn.pressed.is_connected(_on_global_info_button_pressed):
			btn.pressed.connect(_on_global_info_button_pressed)
	else:
		print("WARNING: 'GlobalInfoButton' not found in Battlefield Scene")
	
	if Global.current_tower_floor == 10:
		bgm_player.stream = load("res://Asset/Sound effects/background effect3.mp3")
	else:
		# --- RANDOM BGM LOGIC ---
		var random_track_path = battle_themes.pick_random()
		bgm_player.stream = load(random_track_path)
	
	# Play the selected track
	bgm_player.play()
			
	# --- Existing Setup ---
	setup_player_team()
	build_deck_from_team()
	setup_tower_enemies()
	update_mana_ui()
	start_current_phase()
	
func setup_player_team():
	var heroes_in_scene = player_team.get_children() # Dummy1, Dummy2, Dummy3
	
	for i in range(heroes_in_scene.size()):
		var character_node = heroes_in_scene[i]
		
		# If we have a selected hero for this slot index
		if i < Global.selected_team.size():
			var data = Global.selected_team[i]
			character_node.setup_character(data)
		else:
			# If you selected only 1 or 2 heroes, hide the extra dummies
			character_node.queue_free()
			
# --- NEW FUNCTION: DYNAMIC DECK ---
func build_deck_from_team():
	deck.clear()
	# Change 'Global.player_team' to 'Global.selected_team'
	for data in Global.selected_team:
		if data.unique_card:
			deck.append(data.unique_card)
		
		for card in data.common_cards:
			deck.append(card)
	
	deck.shuffle()
	
# --- 3. THE CORE LOOP ---
func _process(_delta: float):
	# If the battle is paused (someone is taking a turn), do nothing
	if is_battle_paused:
		return
	

# --- 4. TURN LOGIC ---
func start_current_phase():
	var phase = phases[current_phase_index]
	
	if phase == "player":
		if current_phase_index == 0:
			var old_mana = current_mana
			current_mana = min(current_mana + mana_regen, max_mana)
			
			# Calculate how much we actually gained (in case of cap)
			var actual_gain = current_mana - old_mana
			if actual_gain > 0:
				spawn_mana_popup(actual_gain)
		
		# Highlight heroes
		for hero in player_team.get_children():
			hero.modulate = Color(1.2, 1.2, 1.2)
			
		spawn_cards() 
		update_mana_ui()
		
	elif phase == "enemy":
		# Dim heroes
		for hero in player_team.get_children():
			hero.modulate = Color(0.5, 0.5, 0.5)
		
		await get_tree().create_timer(1.0).timeout
		execute_enemy_ai()

func execute_enemy_ai():
	for enemy in get_alive_enemies():
		var alive_heroes = get_alive_players()
		if alive_heroes.is_empty():
			break
		
		# --- 1. Calculate Damage & Crit ---
		var damage_to_deal = enemy.base_damage
		var is_crit = false
		
		# Roll for Crit (0-100)
		if randi() % 100 < enemy.critical_chance:
			is_crit = true
			damage_to_deal = int(damage_to_deal * 1.5) # 1.5x Damage for Crit
			print("CRITICAL HIT by " + enemy.char_name + "!")

		# --- 2. Handle Target Selection (AOE vs Single) ---
		var targets_to_hit = []
		
		if enemy.is_aoe:
			# AOE: Get multiple random heroes
			alive_heroes.shuffle()
			var hit_count = min(enemy.max_aoe_targets, alive_heroes.size())
			for i in range(hit_count):
				targets_to_hit.append(alive_heroes[i])
		else:
			# Single Target
			targets_to_hit.append(alive_heroes.pick_random())

		# --- 3. Apply Damage ---
		for target in targets_to_hit:
			# Pass the 'is_crit' flag to the character
			target.take_damage(damage_to_deal, is_crit)
			print(enemy.char_name + " dealt " + str(damage_to_deal) + " to " + target.char_name)

		await get_tree().create_timer(0.8).timeout
	
	check_battle_status()
	if not get_alive_players().is_empty():
		end_current_phase()


# --- 3. THE 5-CARD DRAW SYSTEM ---
func spawn_cards():
	# 1. Count how many cards are currently in the hand
	var current_cards_in_hand = hand_container.get_child_count()
	
	# 2. Calculate how many we need to draw to reach the limit (6)
	var cards_to_draw = hand_size - current_cards_in_hand
	
	print("Hand has " + str(current_cards_in_hand) + " cards. Drawing " + str(cards_to_draw) + " new cards.")
	
	# If hand is already full (or overfilled), stop here
	if cards_to_draw <= 0:
		update_mana_ui()
		return

	# 3. Draw exactly the needed amount
	for i in range(cards_to_draw):
		# If deck is empty, try to reshuffle
		if deck.is_empty():
			reshuffle_discard_into_deck()
		
		# If we have cards (either naturally or after reshuffle), draw one
		if not deck.is_empty():
			create_card_instance(deck.pop_front())
			# Optional: Add a tiny delay between draws for a cool visual effect
			await get_tree().create_timer(0.1).timeout
	
	# 4. Refresh UI to ensure new cards have correct mana dimming
	update_mana_ui()

func create_card_instance(data: CardData):
	var new_card = card_scene.instantiate()
	hand_container.add_child(new_card)
	new_card.setup(data)
	
	if new_card.has_method("toggle_info_capability"):
		new_card.toggle_info_capability(true)
	# Connect the button click
	new_card.get_node("VBoxContainer/PlayButton").pressed.connect(_on_card_played.bind(data, new_card))

func end_current_phase():
	check_battle_status()
	current_phase_index += 1
	
	# If the enemy just finished, go back to player and increase max energy
	if current_phase_index >= phases.size():
		current_phase_index = 0
		advance_round()
	
	start_current_phase()

func _on_card_played(data: CardData, card_node: Node):
	if phases[current_phase_index] != "player": return
	if slotted_cards.size() >= max_slots: return 
	if current_mana < data.mana_cost: return

	# 1. Deduct Mana
	current_mana -= data.mana_cost
	
	# --- NEW FIX: Force description OFF before moving ---
	if card_node.has_method("set_description_visible"):
		card_node.set_description_visible(false)
	# ----------------------------------------------------
	
	# 2. Add to Slot Logic
	slotted_cards.append(data)
	
	# 3. Move Visuals to Slot
	card_node.get_parent().remove_child(card_node)
	slot_container.add_child(card_node)
	
	# 4. SWAP SIGNAL: Change button from "Play" to "Return"
	var btn = card_node.get_node("VBoxContainer/PlayButton")
	
	if btn.pressed.is_connected(_on_card_played):
		btn.pressed.disconnect(_on_card_played)
	
	btn.pressed.connect(return_card_to_hand.bind(data, card_node))
	
	btn.text = "Return"
	btn.disabled = false 
	card_node.modulate = Color(1, 1, 1) 
	
	update_mana_ui()
	
func return_card_to_hand(data: CardData, card_node: Node):
	# Safety: Don't allow undo if we are already fighting
	if is_processing_turn: return
	
	# 1. Refund Mana
	current_mana += data.mana_cost
	# (Optional: Cap it again if needed, but usually refund allows overflow or exact return)
	current_mana = min(current_mana, max_mana)

	# 2. Remove from Slot Logic
	slotted_cards.erase(data)
	
	# 3. Move Visuals back to Hand
	card_node.get_parent().remove_child(card_node)
	hand_container.add_child(card_node)
	
	
	# 4. SWAP SIGNAL: Change button from "Return" to "Play"
	var btn = card_node.get_node("VBoxContainer/PlayButton")
	
	if btn.pressed.is_connected(return_card_to_hand):
		btn.pressed.disconnect(return_card_to_hand)
		
	btn.pressed.connect(_on_card_played.bind(data, card_node))
	
	# Visual Reset
	btn.text = "Play"
	
	update_mana_ui()
		
# --- 2. THE TURN PROGRESSION ---
func _on_end_turn_button_pressed():
	# 1. SAFETY GATES
	if is_processing_turn: return # Stop spamming!
	if phases[current_phase_index] != "player": return
	
	is_processing_turn = true # Lock the turn
	
	# Disable the button visually if you have a reference to it
	# $CanvasLayer/EndTurnButton.disabled = true 

	# 2. Play the cards
	await execute_slotted_actions()
	
	# 3. Move to Enemy Phase
	end_current_phase()
	
	# 4. Unlock after the whole sequence (including enemy AI) is done
	is_processing_turn = false
	# $CanvasLayer/EndTurnButton.disabled = false

func update_mana_ui():
	if mana_label:
		mana_label.text = "Mana: " + str(current_mana) + "/" + str(max_mana)
	
	var is_player_phase = phases[current_phase_index] == "player"

	for card in hand_container.get_children():
		if "card_data" in card and card.card_data != null:
			var cost = card.card_data.mana_cost
			var btn = card.get_node("VBoxContainer/PlayButton")
			var content = card.get_node("VBoxContainer") # The visual content
			
			if not is_player_phase or cost > current_mana:
				btn.disabled = true
				# We dim the VBoxContainer ONLY
				content.modulate = Color(0.4, 0.4, 0.4) 
			else:
				btn.disabled = false
				content.modulate = Color(1, 1, 1)

	# Slotted cards should always be bright
	for card in slot_container.get_children():
		card.modulate = Color(1, 1, 1)
		var btn = card.get_node("VBoxContainer/PlayButton")
		var content = card.get_node("VBoxContainer")
		content.modulate = Color(1, 1, 1)
		btn.disabled = false


func reshuffle_discard_into_deck():
	if discard_pile.is_empty():
		print("WARNING: No cards left in deck OR discard pile!")
		return
		
	print("--- Reshuffling Discard Pile into Deck ---")
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()
	
func highlight_active_character():
	for character in turn_order:
		if character == active_character:
			character.modulate = Color(1.2, 1.2, 1.2) # Brighten
			character.scale = Vector2(1.1, 1.1) # Slightly larger
		else:
			character.modulate = Color(0.5, 0.5, 0.5) # Dim
			character.scale = Vector2(1.0, 1.0) # Normal size

func advance_round():
	round_number += 1

func execute_slotted_actions():
	is_processing_turn = true
	
	for data in slotted_cards:
		# --- BEAT 1: THE SOUND & ANTICIPATION ---
		# Play the sound immediately when the card "activates"
		if data.sound_effect and sfx_player:
			sfx_player.stream = data.sound_effect
			sfx_player.pitch_scale = randf_range(0.95, 1.05) 
			sfx_player.play()
		
		# Give the player 0.15 seconds to hear the start of the sound 
		# before the damage numbers pop up. This feels more natural.
		await get_tree().create_timer(0.15).timeout

		# --- BEAT 2: THE IMPACT (STAT LOGIC) ---
		# This is where the health bars actually move
		
		# 1. Damage
		if data.damage > 0:
			var targets = get_targets_for_action(data.is_aoe, data.aoe_targets)
			if not targets.is_empty():
				var final_damage = Global.get_card_damage(data)
				var is_crit = randi() % 100 < data.critical_chance
				if is_crit: final_damage = int(final_damage * 1.5)
				
				for target in targets:
					target.take_damage(final_damage, is_crit)

		# 2. Shield
		if data.shield > 0:
			var targets = get_alive_players()
			if not targets.is_empty():
				var final_shield = Global.get_card_shield(data)
				if data.is_aoe:
					var hits = min(data.aoe_targets, targets.size())
					for i in range(hits):
						targets[i].add_shield(final_shield)
				else:
					targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					targets[0].add_shield(final_shield)
					
		# 3. Mana
		if data.mana_gain > 0:
			var gain = Global.get_card_mana(data)
			current_mana = min(current_mana + gain, max_mana)
			spawn_mana_popup(gain)
			update_mana_ui()
			
		# 4. Heal
		if data.heal_amount > 0:
			var targets = get_alive_players()
			if not targets.is_empty():
				var final_heal = Global.get_card_heal(data)
				if data.is_aoe:
					var hits = min(data.aoe_targets, targets.size())
					for i in range(hits):
						targets[i].heal(final_heal)
				else:
					targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					targets[0].heal(final_heal)

		# --- BEAT 3: RECOVERY ---
		# We wait for the "Impact" animations (like damage popups) to finish
		# and for the sound to reach its tail end.
		# 0.6 seconds is usually the "sweet spot" for card games.
		discard_pile.append(data)
		await get_tree().create_timer(1).timeout

	# --- FINAL CLEANUP ---
	# Only clear the visual cards AFTER all actions are done
	for child in slot_container.get_children():
		# Optional: Add a small fade-out tween here later for extra polish!
		child.queue_free()
		
	slotted_cards.clear()
	check_battle_status()


func _on_restart_button_pressed():
	get_tree().reload_current_scene()


func get_alive_enemies() -> Array:
	var alive = []
	for enemy in enemy_team.get_children():
		if is_instance_valid(enemy) and enemy.current_health > 0:
			alive.append(enemy)
	return alive

func setup_tower_enemies():
	var enemy_nodes = enemy_team.get_children()
	var selected_floor_data: Array[EnemyData] = []
	
	match Global.current_tower_floor:
		1: selected_floor_data = floor_1_enemies
		2: selected_floor_data = floor_2_enemies
		3: selected_floor_data = floor_3_enemies
		4: selected_floor_data = floor_4_enemies
		5: selected_floor_data = floor_5_enemies
		6: selected_floor_data = floor_6_enemies
		7: selected_floor_data = floor_7_enemies
		8: selected_floor_data = floor_8_enemies
		9: selected_floor_data = floor_9_enemies
		10: selected_floor_data = floor_10_enemies

		
	for node in enemy_nodes:
		node.hide()
		node.current_health = 0 # Ensure hidden ones are "dead" for the logic

	for i in range(selected_floor_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_floor_data[i]
			enemy_nodes[i].setup_enemy(enemy_resource)
			enemy_nodes[i].show() # Explicitly show the 4th dummy
	
	for i in range(selected_floor_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_floor_data[i]
			var enemy_node = enemy_nodes[i] # This is your "Dummy"
			
			enemy_node.setup_enemy(enemy_resource)
			enemy_node.show()
			
			# NEW: Connect the click signal to a function in BattleManager
			if not enemy_node.enemy_selected.is_connected(_on_enemy_clicked):
				enemy_node.enemy_selected.connect(_on_enemy_clicked)
				
func check_battle_status():
	# get_alive_enemies() already filters out dead/invalid units
	var alive_enemies = get_alive_enemies()
	var alive_players = get_alive_players()
	
	# 1. Check if Player Lost (All heroes dead)
	if alive_players.is_empty():
		print("Defeat! All heroes have fallen.")
		await get_tree().create_timer(1.0).timeout
		fade_out_music()
		GlobalMenu.show_loss_menu() # Trigger the loss UI
		return
		
	# Only trigger victory if there are NO alive enemies left
	if alive_enemies.is_empty():
		if Global.current_tower_floor > 0:
			print("Victory! All enemies defeated.")
			Global.mark_floor_cleared(Global.current_tower_floor) #
			fade_out_music()
			GlobalMenu.show_victory_menu() 
	
func get_alive_players() -> Array:
	var alive = []
	for hero in player_team.get_children():
		# Check if the hero node exists and has health > 0
		if is_instance_valid(hero) and hero.current_health > 0:
			alive.append(hero)
	return alive
	
func _on_menu_button_pressed() -> void:
	GlobalMenu.show_pause_menu()

func spawn_mana_popup(amount: int):
	if mana_label == null: return
	
	var popup = mana_popup_scene.instantiate()
	# Add it to the CanvasLayer so it stays on top of the UI
	$CanvasLayer.add_child(popup)
	
	# Position it right on top of the Mana Label
	popup.global_position = mana_label.global_position + Vector2(20, -20)
	popup.setup(amount)

func _on_global_info_button_pressed():
	is_info_mode_on = !is_info_mode_on
	
	# Update Button Text (Optional, remove if you don't want text changes)
	var btn = get_node_or_null("CanvasLayer/GlobalInfoButton")
	if btn:
		btn.text = "Hide Info" if is_info_mode_on else "Show Info"

	# SAFE LOOP: Only touches valid cards
	for card in hand_container.get_children():
		# Check if the card is valid and has the script attached
		if is_instance_valid(card) and card.has_method("set_description_visible"):
			card.set_description_visible(is_info_mode_on)

func _on_enemy_clicked(clicked_enemy):
	# 1. Unlock all enemies first
	for enemy in get_alive_enemies():
		enemy.set_target_lock(false)
	
	# 2. Lock the one we clicked
	clicked_enemy.set_target_lock(true)
	

func get_targets_for_action(is_aoe: bool, num_targets: int) -> Array:
	var alive_enemies = get_alive_enemies()
	var targets = []
	
	if alive_enemies.is_empty():
		return targets

	# Find if someone is locked
	var locked_enemy = null
	for e in alive_enemies:
		if e.is_locked_target:
			locked_enemy = e
			break
	
	if is_aoe:
		# If locked, they are target #1
		if locked_enemy:
			targets.append(locked_enemy)
		
		# Fill the rest with others
		for e in alive_enemies:
			if e != locked_enemy and targets.size() < num_targets:
				targets.append(e)
	else:
		# Single Target: Use locked enemy, or default to front (index 0)
		if locked_enemy:
			targets.append(locked_enemy)
		else:
			targets.append(alive_enemies[0])
			
	return targets
	
func fade_out_music():
	var tween = create_tween()
	# Fades volume down to -80 (silent) over 1.5 seconds
	tween.tween_property(bgm_player, "volume_db", -80.0, 1.5)
	tween.tween_callback(bgm_player.stop)

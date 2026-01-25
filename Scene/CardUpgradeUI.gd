extends Control

# --- 1. DATA SETUP ---
# Drag all your Card Resources (Slash.tres, Fireball.tres) here in the Inspector!
@export var all_cards_in_game: Array[CardData] = []

# UI References (Connect these unique names to your nodes if you use %UniqueName, 
# or just use $Path/To/Node)
@onready var material_label = $TopBar/MaterialLabel
@onready var grid_container = $MainLayout/ScrollContainer/GridContainer
@onready var details_panel = $DetailsPanel
@onready var card_name_label = $DetailsPanel/VBoxContainer/CardNameLabel
@onready var stats_label = $DetailsPanel/VBoxContainer/StatsLabel
@onready var cost_label = $DetailsPanel/VBoxContainer/CostLabel
@onready var upgrade_button = $DetailsPanel/VBoxContainer/UpgradeButton
@onready var card_image = $DetailsPanel/VBoxContainer/CardImage

@onready var dim_background = $DimBackground # The semi-transparent black rect

# Track what the player is currently looking at
var current_selected_card: CardData = null

func _ready():
	# 1. Update the currency display
	update_material_label()
	
	# 2. Clear dummy buttons in the grid (if any)
	for child in grid_container.get_children():
		child.queue_free()
		
	# 3. Create a button for every card in the game
	for data in all_cards_in_game:
		create_card_button(data)
	
	# 4. Hide details panel until a card is picked
	details_panel.visible = false
	dim_background.visible = false
# --- 2. SETUP THE GRID ---
func create_card_button(data: CardData):
	var card_btn = TextureButton.new()
	card_btn.texture_normal = data.card_image
	card_btn.ignore_texture_size = true
	card_btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	card_btn.custom_minimum_size = Vector2(140, 200)
	
	# --- ADD THE BLACK OUTLINE HERE ---
	var outline = ReferenceRect.new()
	# This makes the outline match the exact size of the card button
	outline.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Styling the line
	outline.border_color = Color.BLACK
	outline.border_width = 3.0 # Increase this for a thicker comic-book look
	outline.editor_only = false # IMPORTANT: Without this, it won't show in the game!
	
	# Make sure the outline is "mouse passive" so it doesn't block clicks
	outline.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	card_btn.add_child(outline)
	# ----------------------------------
	
	card_btn.pressed.connect(select_card.bind(data))
	grid_container.add_child(card_btn)

# --- 3. DISPLAY DETAILS (The Math Part) ---
func select_card(data: CardData):
	current_selected_card = data
	
	# Show the popup and the dark background
	details_panel.visible = true
	dim_background.visible = true
	
	card_name_label.text = data.card_name + " [Lv." + str(Global.get_card_level_number(data)) + "]"
	card_image.texture = data.card_image
	
	# Build Stats (Using RichText if your label supports it)
	var stats_text = ""
	if data.damage > 0:
		var cur = Global.get_card_damage(data)
		stats_text += "Damage: " + str(cur) + " -> [color=green]" + str(cur + data.damage_growth) + "[/color]\n"
	# ... (add shield and heal logic same as before)
	
	stats_label.text = stats_text
	cost_label.text = "Materials Needed: " + str(data.upgrade_cost)
	
	# Button check
	upgrade_button.disabled = Global.upgrade_materials < data.upgrade_cost

# --- 4. BUTTON SIGNALS ---
func _on_upgrade_button_pressed():
	if current_selected_card == null: return
	
	# Ask Global to do the math and deduction
	var success = Global.attempt_upgrade(current_selected_card)
	
	if success:
		# Refresh the UI to show new stats and new material count
		update_material_label()
		select_card(current_selected_card) # Re-select to update the numbers

func _on_back_button_pressed():
	# Go back to Main Menu (Change path if needed)
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/main_menu.tscn")

func update_material_label():
	material_label.text = "Materials: " + str(Global.upgrade_materials)


func _on_cancel_pressed() -> void:
	details_panel.visible = false
	dim_background.visible = false

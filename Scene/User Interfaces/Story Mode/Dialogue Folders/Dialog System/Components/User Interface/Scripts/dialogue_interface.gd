extends Control

@onready var Dialogue_ui: RichTextLabel = $"MarginContainer/Control/Dialogue Panel Container/MarginContainer/Dialogue"
@onready var Dialogue_speaker: Label = $"MarginContainer/Control/Speaker PanelContainer/MarginContainer/Speakername"
@onready var dialogue_panel = $"MarginContainer/Control/Dialogue Panel Container"
@onready var speaker_panel = $"MarginContainer/Control/Speaker PanelContainer"

@onready var speaker_margin_container = $"MarginContainer/Control/Speaker PanelContainer/MarginContainer"

var animate_text:= true
var animation_speed:= 30.0

# We store the original size so we can reset it before each calculation
var original_font_size: int = 0

func _ready() -> void:
	Dialogue_ui.visible_ratio = 0.0
	# Capture the starting size from the label settings
	if Dialogue_speaker.label_settings:
		# IMPORTANT: Duplicate the resource so changes don't affect other labels
		Dialogue_speaker.label_settings = Dialogue_speaker.label_settings.duplicate()
		original_font_size = Dialogue_speaker.label_settings.font_size

func _process(delta: float) -> void:
	if animate_text and Dialogue_ui.text.length() > 0:
		if Dialogue_ui.visible_ratio < 1.0:
			Dialogue_ui.visible_ratio += (1.0 / Dialogue_ui.text.length()) * (animation_speed * delta)
		else:
			animate_text = false

func shrink_text_to_fit(new_name: String = "") -> void:
	var label = Dialogue_speaker
	
	if not label.label_settings:
		return
	
	# 1. Reset to the original font size before measuring
	label.label_settings.font_size = original_font_size
	
	if not new_name.is_empty():
		label.text = new_name
	
	if label.text.is_empty():
		return
	
	# Wait for layout to settle
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Get the font resource to measure width
	var font = label.label_settings.font if label.label_settings.font else label.get_theme_font("font")
	
	# 3. Calculate dynamic padding from the MarginContainer constants
	# These constants (left and right) are what push the label inward
	var m_left = speaker_margin_container.get_theme_constant("margin_left")
	var m_right = speaker_margin_container.get_theme_constant("margin_right")
	var total_margins = m_left + m_right
	
	# 4. Determine the limit (Width of the speaker box minus its internal margins)
	var box_limit = speaker_panel.custom_minimum_size.x
	if box_limit <= 0:
		box_limit = speaker_panel.size.x
	
	# Subtract the left/right margins and a small safety buffer (4px) 
	# to ensure the text doesn't touch the very edge of the margin
	var effective_max_width = box_limit - total_margins - 4

	if effective_max_width <= 0: return

	# 5. Iterative Shrinking
	# We start at the original size and step down until it fits inside the margins.
	var current_size = original_font_size
	var text_width = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, current_size).x
	
	while text_width > effective_max_width and current_size > 6:
		# Reduce size by 1px steps for high precision
		current_size -= 1
		text_width = font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1, current_size).x
	
	# Apply the final size
	label.label_settings.font_size = current_size

func set_speaker_name(speaker_name: String) -> void:
	shrink_text_to_fit(speaker_name)

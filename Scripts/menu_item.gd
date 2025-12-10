extends Control

@onready var button = $Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_size(Vector2(250, 40))
	update_text("FILLER")
	update_font_size(25)

func update_size(new_size_vector : Vector2) -> void:
	button.set_size(new_size_vector)

func update_text(new_text : String) -> void:
	button.text = new_text

func update_font_size(new_size : int) -> void:
	button.add_theme_font_size_override("normal_font_size", new_size)

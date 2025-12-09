extends Control

@onready var text_item = $Text
@onready var bg = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_size(Vector2(250, 40))
	update_text("FILLER")
	update_font_size(25)

func update_size(new_size_vector : Vector2) -> void:
	text_item.set_size(new_size_vector)
	bg.set_size(new_size_vector)

func update_text(new_text : String) -> void:
	text_item.text = new_text

func update_font_size(new_size : int) -> void:
	text_item.add_theme_font_size_override("normal_font_size", new_size)

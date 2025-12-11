extends Control

@onready var button = $Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_size(new_size_vector : Vector2) -> void:
	button.set_size(new_size_vector)

func update_text(new_text : String) -> void:
	button.text = new_text

signal menu_item_picked(item_picked)

func _on_button_pressed() -> void:
	menu_item_picked.emit(button.text)

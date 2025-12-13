extends Control

@onready var button = $Button
@onready var num_item_label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_size(new_size_vector : Vector2) -> void:
	button.set_size(new_size_vector)
	num_item_label.set_size(new_size_vector)

func update_text(new_text : String) -> void:
	button.text = new_text

func update_num_items(new_num : int) -> void:
	if (new_num == 0):
		return
	num_item_label.text = str(new_num)

signal menu_item_picked(item_picked)

func _on_button_pressed() -> void:
	menu_item_picked.emit(button.text)

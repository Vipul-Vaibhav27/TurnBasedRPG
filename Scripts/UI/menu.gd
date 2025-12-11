extends Control

@onready var menu_container = $MenuContainer
@onready var menu_item = preload("res://Scenes/UI/menu_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Functions for getting and processing player actions

signal player_chose_item(item_name)

func button_pressed(button_name):
	# print("Player has pressed ", button_name)
	player_chose_item.emit(button_name)

# Functions for creating a menu

func create_menu(items : Variant, item_size : Vector2) -> void:
	delete_all_children(menu_container)

	for item in items:
		var item_button = menu_item.instantiate()
		menu_container.add_child(item_button)
		
		if (item_button.has_method("update_text")):
			item_button.update_text(item)
		else:
			printerr("No method to update text")

		if (item_button.has_method("update_size")):
			item_button.update_size(item_size)
		else:
			printerr("No method to update size")

		if (item_button.has_signal("menu_item_picked")):
			var pressed = button_pressed.bind()
			var err = item_button.menu_item_picked.connect(pressed)
			if (err != OK):
				printerr("Unable to connect. Error: ", error_string(err))
		else:
			printerr("No signal to notify menu item picked")

	menu_container.grab_focus()

func delete_all_children(node : Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

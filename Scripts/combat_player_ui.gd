extends Node2D

@onready var action_container = $ActionContainer
@onready var menu_item = preload("res://Scenes/menu_item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var action_file_path = "res://Data/player_skills.json"
	var actions = load_parse_json(action_file_path)
	
	create_menu(actions, Vector2(250,40), action_container)
	action_container.grab_focus()

# Functions for getting and processing player actions

func player_pressed_button(button_name):
	print("Player has pressed ", button_name)

# Functions for creating a menu

func create_menu(items : Variant, item_size : Vector2, menu_container : Container) -> void:
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
			var pressed = player_pressed_button.bind(item)
			var err = item_button.menu_item_picked.connect(pressed)
			if (err != OK):
				printerr("Unable to connect. Error: ", error_string(err))
		else:
			printerr("No signal to notify menu item picked")

func delete_all_children(node : Node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

# Functions for loading and parsing jsons

func load_parse_json(file_path : String) -> Variant:
	var json_string = load_file_contents(file_path)
	var json_parsed = parse_json(json_string)
	return json_parsed

func parse_json(json_string : String) -> Variant:
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if (error != OK):
		printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
	return json.data

func load_file_contents(file_path : String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var file_string = ""
	
	if (file == null):
		printerr("File Open Error: ", error_string(FileAccess.get_open_error()), " for File: ", file_path)
	else:
		file_string = file.get_as_text()
		file.close()

	return file_string
	

extends Node2D

@onready var action_container = $VBoxContainer
@onready var menu_item = preload("res://Scenes/menu_item_unused.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var action_file_path = "res://Data/player_skills.json"
	var actions = load_parse_json(action_file_path)
	
	for key in actions:
		var action_button = menu_item.instantiate()
		action_container.add_child(action_button)
	

func UI_loop():
	pass


func load_parse_json(file_path) -> Variant:
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
	

extends Node2D

@onready var action_menu = $Menu
@onready var battle_log = $CombatLog

var player_actions
var menu_walk_string = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var action_file_path = "res://Data/player_skills.json"
	player_actions = load_parse_json(action_file_path)
	
	if (action_menu.has_signal("player_chose_item")):
		var pressed = update_action.bind()
		var err = action_menu.player_chose_item.connect(pressed)
		if (err != OK):
			printerr("Unable to connect. Error: ", error_string(err))
	else:
		printerr("Combat UI: No signal to notify menu item picked")
	
	draw_action_menu()

# Handling input
func _unhandled_input(event):
	# TO_DO: FIND BETTER WAY OF HANDLING INPUT
	
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("ui_cancel"):
			
			var menu_walk = menu_walk_string.split("/")
			if (menu_walk.size() != 1):
				menu_walk.remove_at(menu_walk.size() - 1)
			menu_walk_string = "/".join(menu_walk)
			
			draw_action_menu()

# Function to draw and update action menu UI as per user 
func draw_action_menu():
	var menu_walk = menu_walk_string.split("/")
	var action_list = player_actions
	
	for action in menu_walk:
		if (action == ""):
			continue

		assert(action in action_list)
		
		# Player has taken action after going to the last node
		if (type_string(typeof(action_list[action])) == "float"):
			menu_walk_string = ""
			action_list = {}
			write_to_log("Player used " + action)
			break

		action_list = action_list[action]
	
	action_menu.create_menu(action_list, Vector2(250,40))

func update_action(action):
	menu_walk_string += ("/" + action)
	draw_action_menu()
	
# Function for updating battle log
func write_to_log(text : String):
	battle_log.text += text

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
	

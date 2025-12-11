extends Control

@onready var action_menu = $Menu
@onready var battle_log = $CombatLog

var player_actions = {
	"Moves" : {},
	"Change" : {},
	"Items" : {},
}

var menu_walk_string = ""

signal item_to_use(item)
signal change_to_pokemon(new_pokemon)
signal move_to_use(move)

signal write_to_log(text)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Items carried by player
	var item_file_path = "res://Data/player_items.json"
	var items = load_parse_json(item_file_path)["Items"]
	
	for item in items:
		if (items[item] != 0):
			player_actions["Items"][item] = int(items[item])
	player_actions["Items"]["Back"] = 0
	
	var err;
	# Signal inform item chosen by player
	if (action_menu.has_signal("player_chose_item")):
		err = action_menu.player_chose_item.connect(update_action.bind())
		if (err != OK):
			printerr("Unable to connect menu. Error: ", error_string(err))
	else:
		printerr("Combat UI: No signal to notify menu item picked")
	
	# Signal inform item to write to log
	err = write_to_log.connect(update_log.bind())
	if (err != OK):
		printerr("Unable to connect logger. Error: ", error_string(err))

# Function to draw and update action menu UI as per user 
func draw_action_menu():
	var menu_walk = menu_walk_string.split("/")
	print(menu_walk)
	var action_list = player_actions
	
	for action in menu_walk:
		if (action == ""):
			continue

		assert(action in action_list)
		
		# Player has taken action after going to the last node
		var action_type = type_string(typeof(action_list[action]))
		if (action_type == "int"):
			menu_walk_string = ""
			action_list = {}
			
			if ("Moves" in menu_walk):
				move_to_use.emit(action)
			elif ("Items" in menu_walk):
				item_to_use.emit(action)
			else:
				change_to_pokemon.emit(action)
			return

		action_list = action_list[action]

	action_menu.create_menu(action_list, Vector2(250,40))

func update_action(action):
	if (action == "Back"):
		var menu_walk = menu_walk_string.split("/")
		menu_walk.remove_at(menu_walk.size() - 1)
		menu_walk_string = "/".join(menu_walk)
		
	else:
		menu_walk_string += ("/" + action)
	draw_action_menu()

# Function for updating battle log
func update_log(text : String):
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

func _on_player_character_active_player_pokemon(pokemon: PokemonInstance) -> void:

	for move in pokemon.active_moves:
		if (move.current_pp != 0): # If no more moves exist, don't show them
			player_actions["Moves"][move.move_data.name] = move.current_pp
	player_actions["Moves"]["Back"] = 0

func _on_player_character_all_player_pokemon(pokemon_instances: Variant) -> void:
	for pokemon in pokemon_instances:
		player_actions["Change"][pokemon] = 0
	player_actions["Change"]["Back"] = 0

extends Control

@onready var action_menu = $Menu
@onready var battle_log = $CombatLog
@onready var select_sfx = $SelectSFX
@onready var result_display = $Label
@onready var result_sfx = $ResultSFX

var player_actions = {
	"Change" : {},
	"Items" : {},
	"Moves" : {},
}

var move_dict = {}

var menu_walk_string = ""

var pokemon_instances
var active_pokemon


signal item_to_use(item)
signal change_to_pokemon(new_pokemon)
signal move_to_use(move)

signal combat_start
signal combat_end

signal update_hp_on_pokemon_death

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_player_items()
	
	# Signal inform item chosen by player
	if (action_menu.has_signal("player_chose_item")):
		var err = action_menu.player_chose_item.connect(update_action.bind())
		if (err != OK):
			printerr("Unable to connect menu. Error: ", error_string(err))
	else:
		printerr("Combat UI: No signal to notify menu item picked")
		
	combat_start.emit()
	result_display.text = ""

# Function to draw and update action menu UI as per user 
func draw_action_menu():
	var menu_walk = menu_walk_string.split("/")
	var action_list = player_actions
	
	for action in menu_walk:
		if (action == ""):
			continue

		assert(action in action_list)

		# Player has taken action after going to the last node
		var action_data_type = type_string(typeof(action_list[action]))
		if (action_data_type == "int"):
			action_list = {}
			signal_action_by_player(menu_walk, action)
			break

		action_list = action_list[action]

	if (action_menu != null):
		action_menu.create_menu(action_list, Vector2(250,40))

func signal_action_by_player(menu_walk, action):
	if ("Moves" in menu_walk):
		assert(action in move_dict)
		move_to_use.emit(move_dict[action])
	elif ("Items" in menu_walk):
		player_actions["Items"]["Turn Pass"] -= 1
		item_to_use.emit(action)
	else:
		change_to_pokemon.emit(action)

func update_action(action):
	if (action == "Back"):
		var menu_walk = menu_walk_string.split("/")
		menu_walk.remove_at(menu_walk.size() - 1)
		menu_walk_string = "/".join(menu_walk)
	else:
		menu_walk_string += ("/" + action)
	select_sfx.play()
	draw_action_menu()

# Function for updating battle log
func update_log(text : String):
	battle_log.text += text
	battle_log.text += '\n'

# Functions for initialising and updating pokemon instances and active pokemon
func update_active_pokemon(pokemon : PokemonInstance) -> void:
	active_pokemon = pokemon
	update_player_moves()

func initialise_pokemon_instances(pokemons : Variant) -> void:
	pokemon_instances = pokemons
	update_player_pokemon()

# Functions which update the actions a player can take
func update_player_moves() -> void:
	player_actions["Moves"] = {}
	move_dict = {}

	for move in active_pokemon.active_moves:
		if (move.current_pp != 0): # If no more moves exist, don't show them
			player_actions["Moves"][move.move_data.name] = move.current_pp
			move_dict[move.move_data.name] = move
	player_actions["Moves"]["Back"] = 0

func update_player_pokemon() -> void:
	player_actions["Change"] = {}
	for pokemon in pokemon_instances:
		if (pokemon_instances[pokemon].current_hp <= 0):
			continue
		player_actions["Change"][pokemon] = 0
		
	if (len(player_actions["Change"]) == 0):
		# No pokemon left - Player defeated
		action_menu.queue_free()
		result_display.text = "DEFEAT"
		result_sfx.play()
		combat_end.emit()
		

	player_actions["Change"]["Back"] = 0

func update_player_items():
	# Items carried by player
	var items = {
		"Turn Pass" : 40,
	}
	
	player_actions["Items"] = {}
	for item in items:
		if (items[item] != 0):
			player_actions["Items"][item] = int(items[item])
	player_actions["Items"]["Back"] = 0

# Function to display combat UI on player turn

func player_turn_start() -> void:
	menu_walk_string = ""
	print("Player turn")
	if (not player_actions.has("Items")):
		update_player_items()
	update_player_moves()
	draw_action_menu()

# Function to change pokemon after death
func player_pokemon_death() -> void:
	menu_walk_string = ""
	#await get_tree().create_timer(2.0).timeout
	update_player_pokemon()
	player_actions.erase("Items")
	player_actions.erase("Moves")
	update_hp_on_pokemon_death.emit()
	draw_action_menu()

func player_victory() -> void:
	action_menu.queue_free()
	result_display.text = "VICTORY"
	result_sfx.play()
	combat_end.emit()

# Functions for loading and parsing jsons - unused

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

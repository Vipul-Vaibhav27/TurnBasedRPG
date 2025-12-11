extends Node2D

var player_pokemon_instances = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pokemon_file_path = "res://Data/player_enemies.json"
	var player_pokemon_list = load_parse_json(pokemon_file_path)["Player"]
	
	for pokemon in player_pokemon_list:
		var instance = PokemonInstance
		player_pokemon_list[pokemon]["name"]
		player_pokemon_instances[instance.name] = instance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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

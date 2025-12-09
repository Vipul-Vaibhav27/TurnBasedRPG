extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_player_actions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_player_actions():
	var json_string = load_json()
	print(json_string)

func load_json():
	var file_path = "res://Data/player_skills.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = ""
	
	if (file == null):
		printerr("Unable to open file at ", file_path, 
		". Error ", error_string(FileAccess.get_open_error()))
	else:
		json_string = file.get_as_text()
		file.close()

	return json_string
	

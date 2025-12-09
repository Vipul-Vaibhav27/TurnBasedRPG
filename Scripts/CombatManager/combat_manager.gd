extends Node

var combat_state = CS.CombatState.new() # Initialization

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Connect this function to signal emmitted by UI (Start Combat) button - It will fetch all player's pokemon
func load_pokemon() -> void:
	# TODO
	#combat_state.load_pokemon(p_pokemon_name, p_stats)
	pass
	
# Connect this function to signal emmitted by UI (When player inputs to change pokemon)
func change_pokemon(p_pokemon_name: String):
	combat_state.change_player(p_pokemon_name)

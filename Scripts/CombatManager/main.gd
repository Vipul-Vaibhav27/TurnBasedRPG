extends Node

var stat_map = {
	"HP": 0, "Attack": 1, "Defense": 2, "SpAtk": 3, "SpDef": 4, "Speed": 5, "State": 6 # Btw 1 means alive
}

class CombatState:
	"""
		Format of below dict ->
		player = {
			"Meowth": PackedInt32Array in order of [HP, Attack, Defense, SpAtk, SpDef, Speed, State(Dead?)]
			"Clefairy": Same,
		} 
	"""
	var player = {} # List of pokemons of player participating in combat(typically 6)
	var enemy = {} # List of pokemons of enemy
	
	var curr_player: String
	var curr_enemy: String
	
	func _init() -> void:
		pass
	
	func load_pokemon(p_pokemon_name: String, p_stats: PackedInt32Array) -> void:
		# Should be called at the start by player before starting combat for all 6 pokemons getting used in combat
		p_stats.resize(7)
		p_stats[6] = 1
		player[p_pokemon_name] = p_stats
	
	func duplicate() -> CombatState:
		# Make a clone of current object
		var obj = CombatState.new()
		obj.player = self.player.duplicate(true)
		obj.enemy = self.enemy.duplicate(true)
		obj.curr_player = self.curr_player
		obj.curr_enemy = self.curr_enemy
		return obj
		
	func change_player(p_pokemon_name: String):
		# Ran when player changes their pokemon
		assert(p_pokemon_name in self.player, "While changing pokemon in Player - " + p_pokemon_name + " doesn't exist!")
		
		curr_player = p_pokemon_name
	
	func change_enemy(p_pokemon_name: String):
		# Ran when enemy dies and if an enemy is left
		assert(p_pokemon_name in self.player, "While changing pokemon in Enemy - " + p_pokemon_name + " doesn't exist!")
		curr_enemy = p_pokemon_name


var combat_state = CombatState.new() # Initialization

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

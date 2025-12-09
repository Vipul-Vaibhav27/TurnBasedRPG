class_name CS
extends Node

const stat_map = {
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
		# Should be called at the start by CombatManager before every new combat
		p_stats.resize(7)
		p_stats[6] = 1
		self.player[p_pokemon_name] = p_stats
	
	func load_pokemon_enemy(p_pokemon_name: String, p_stats: PackedInt32Array) -> void:
		# Should be called at the start by CombatManager before every new combat
		p_stats.resize(7)
		p_stats[6] = 1
		self.enemy[p_pokemon_name] = p_stats
	
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
		assert(self.player[p_pokemon_name][6], "Pokemon Should be alive - Should be managed by Combat Manager to avoid this Scenario")
		
		curr_player = p_pokemon_name
	
	func change_enemy(p_pokemon_name: String):
		# Ran when enemy dies and if an enemy is left
		assert(p_pokemon_name in self.enemy, "While changing pokemon in Enemy - " + p_pokemon_name + " doesn't exist!")
		assert(self.enemy[p_pokemon_name][6], "Pokemon Should be alive - Should be managed by Combat Manager to avoid this Scenario")
		
		curr_enemy = p_pokemon_name
	
	func get_stat(is_player: bool, p_pokemon_name: String, p_stat_name: String):
		assert(p_stat_name in stat_map, "Maybe a typo in " + p_stat_name + "?")
		assert((p_pokemon_name in self.player) if is_player else (p_pokemon_name in self.enemy), "While accessing pokemon " + p_pokemon_name + " - This doesn't exist btw in " + "player" if is_player else "enemy")
		
		return self.player[p_pokemon_name][stat_map[p_stat_name]] if is_player else self.enemy[p_pokemon_name][stat_map[p_stat_name]]
	
	func set_stat_current(is_player: bool, p_stat_name: String, stat_value: int) -> void:
		# Sets value for current active pokemon
		assert(p_stat_name in stat_map, "Maybe a typo in " + p_stat_name + "?")
		
		if is_player:
			self.player[curr_player][stat_map[p_stat_name]] = stat_value
		else:
			self.enemy[curr_enemy][stat_map[p_stat_name]] = stat_value

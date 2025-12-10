class_name CS
extends Node

const stat_map = [ALIAS.HP, ALIAS.ATK, ALIAS.DEF, ALIAS.SPATK, ALIAS.SPDEF, ALIAS.SPD]

class CombatState:
	"""
		Format of below dict ->
		player = {
			"Meowth": PokemonInstance
			"Clefairy": PokemonInstance,
		} 
	"""
	var player = {} # List of pokemons of player participating in combat(typically 6)
	var enemy = {} # List of pokemons of enemy
	
	var curr_player: String = ""
	var curr_enemy: String = ""
	
	func _init() -> void:
		pass
	
	func load_pokemon(pokemon: PokemonInstance) -> void:
		# Should be called at the start by CombatManager before every new combat
		self.player[pokemon.species.name] = pokemon
	
	func load_pokemon_enemy(pokemon: PokemonInstance) -> void:
		# Should be called at the start by CombatManager before every new combat
		self.enemy[pokemon.species.name] = pokemon
	
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
		assert(self.player[p_pokemon_name].current_hp, "Pokemon Should be alive - Should be managed by Combat Manager to avoid this Scenario")
		
		curr_player = p_pokemon_name
	
	func change_enemy(p_pokemon_name: String):
		# Ran when enemy dies and if an enemy is left
		assert(p_pokemon_name in self.enemy, "While changing pokemon in Enemy - " + p_pokemon_name + " doesn't exist!")
		assert(self.enemy[p_pokemon_name].current_hp, "Pokemon Should be alive - Should be managed by Combat Manager to avoid this Scenario")
		
		curr_enemy = p_pokemon_name
	
	func get_attacker(is_player: bool) -> PokemonInstance:
		return self.player[curr_player] if is_player else self.enemy[curr_enemy]
	func get_defender(is_player: bool) -> PokemonInstance:
		return self.enemy[curr_enemy] if is_player else self.player[curr_player]
	
	func get_stat(is_player: bool, p_pokemon_name: String, p_stat_name: String):
		assert(p_stat_name in stat_map, "Maybe a typo in " + p_stat_name + "?")
		assert((p_pokemon_name in self.player) if is_player else (p_pokemon_name in self.enemy), "While accessing pokemon " + p_pokemon_name + " - This doesn't exist btw in " + "player" if is_player else "enemy")
		
		return self.player[p_pokemon_name].current_stats[p_stat_name] if is_player else self.enemy[p_pokemon_name].current_stats[p_stat_name]
	
	func get_stat_current(is_player: bool, p_stat_name: String):
		assert(p_stat_name in stat_map, "Maybe a typo in " + p_stat_name + "?")
		return self.player[curr_player].current_stats[p_stat_name] if is_player else self.enemy[curr_enemy].current_stats[p_stat_name]
	
	func set_stat_current(is_player: bool, p_stat_name: String, stat_value: int) -> void:
		# Sets value for current active pokemon
		assert(p_stat_name in stat_map, "Maybe a typo in " + p_stat_name + "?")
		
		if is_player:
			self.player[curr_player].current_stats[p_stat_name] = stat_value
		else:
			self.enemy[curr_enemy].current_stats[p_stat_name] = stat_value
	
	func heal(is_player: bool, amount: int):
		var poke: PokemonInstance = get_attacker(is_player)
		poke.current_hp += amount
		poke.current_hp = min(poke.current_hp, poke.current_stats[ALIAS.HP])
	
	func take_damage(is_player: bool, amount: int):
		# This means Player did the turn, so opposite will take damage
		var poke: PokemonInstance = get_defender(is_player)
		poke.current_hp -= amount
		poke.current_hp = max(0, poke.current_hp)

class_name PokemonSpecies extends Resource

@export var name: String
@export var types: Array[TypeChart.Type] # ["Fire", "Flying"]
@export var base_stats: Dictionary = {
	ALIAS.HP: 78, ALIAS.ATK: 84, ALIAS.DEF: 78, 
	ALIAS.SPATK: 109, ALIAS.SPDEF: 85, ALIAS.SPD: 100
}

# Example: {"def": 1} for Geodude, {"spd": 2} for Pidgeotto
@export var ev_yield: Dictionary = {
	ALIAS.HP: 0, ALIAS.ATK: 0, ALIAS.DEF: 0, 
	ALIAS.SPATK: 0, ALIAS.SPDEF: 0, ALIAS.SPD: 0
}

@export var xp_yield: int = 40 # Base XP reward

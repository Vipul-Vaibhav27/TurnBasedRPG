extends Node2D

var player_pokemon_instances = {}
var active_pokemon

signal all_player_pokemon(pokemon_instances)
signal active_player_pokemon(pokemon)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initalise_dummy_values()
	# Reciever combat manager for getting all pokemon
	all_player_pokemon.emit(player_pokemon_instances)
	# Reciever UI so that it knows pokemon moves
	active_player_pokemon.emit(active_pokemon)

func change_active_pokemon(new_pokemon : PokemonInstance) -> void:
	active_pokemon = new_pokemon
	active_player_pokemon.emit(active_pokemon)

func initalise_dummy_values() -> void:	
	var SPECIES_1 = PokemonSpecies.new()
	var POKEMON_1 = PokemonInstance.new(SPECIES_1, 1)
	var MOVE_1 = Move.new()
	var MOVE_2 = Move.new()
	MOVE_1.name = "m1"
	MOVE_2.name = "m2"
	
	POKEMON_1.learn_move(MOVE_1)
	POKEMON_1.learn_move(MOVE_2)
	
	var SPECIES_2 = PokemonSpecies.new()
	var POKEMON_2 = PokemonInstance.new(SPECIES_1, 2)
	var MOVE_3 = Move.new()
	var MOVE_4 = Move.new()
	MOVE_3.name = "m3"
	MOVE_4.name = "m4"
	
	POKEMON_2.learn_move(MOVE_3)
	POKEMON_2.learn_move(MOVE_4)
	
	
	player_pokemon_instances = {
		"Bulbasaur" : POKEMON_1,
		"Charmander" : POKEMON_2,
	}
	
	active_pokemon = POKEMON_1

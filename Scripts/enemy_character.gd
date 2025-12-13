extends Node2D

@onready var hp_bar = $EnemyHealthBar

var enemy_pokemon_instances = {}
var active_pokemon: PokemonInstance

signal all_enemy_pokemon(pokemon_instances)
signal all_enemy_pokemon_manager(pokemon_instances, active_name)
signal active_enemy_pokemon(pokemon)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initalise_dummy_values()
	# Reciever combat manager for getting all pokemon
	all_enemy_pokemon.emit(enemy_pokemon_instances)
	all_enemy_pokemon_manager.emit(enemy_pokemon_instances, active_pokemon.species.name)
	# Reciever UI so that it knows pokemon moves
	active_enemy_pokemon.emit(active_pokemon)

func change_active_pokemon(new_pokemon : PokemonInstance) -> void:
	active_pokemon = new_pokemon
	update_hp()
	active_enemy_pokemon.emit(active_pokemon)

func update_hp():
	var curr_hp = active_pokemon.current_hp
	var max_hp = active_pokemon.species.base_stats[ALIAS.HP]
	if (hp_bar == null):
		return
	print("ENEMY: ", curr_hp, " ", max_hp)
	hp_bar.update_hp(curr_hp, max_hp)

func initalise_dummy_values() -> void:	
	var SPECIES_1 = PokemonSpecies.new()
	SPECIES_1.name = "Bulbasaur2"
	SPECIES_1.types.assign([TypeChart.Type.GRASS, TypeChart.Type.POISON])
	var POKEMON_1 = PokemonInstance.new(SPECIES_1, 1)
	var MOVE_1 = Move.new()
	var MOVE_2 = Move.new()
	MOVE_1.name = "m1"
	MOVE_2.name = "m2"
	
	POKEMON_1.learn_move(MOVE_1)
	POKEMON_1.learn_move(MOVE_2)
	
	var SPECIES_2 = PokemonSpecies.new()
	SPECIES_2.name = "Charmander2"
	SPECIES_2.types.assign([TypeChart.Type.FIRE, TypeChart.Type.DRAGON])
	var POKEMON_2 = PokemonInstance.new(SPECIES_2, 2)
	var MOVE_3 = Move.new()
	var MOVE_4 = Move.new()
	MOVE_3.name = "m3"
	MOVE_4.name = "m4"
	
	POKEMON_2.learn_move(MOVE_3)
	POKEMON_2.learn_move(MOVE_4)
	
	
	enemy_pokemon_instances = {
		"Bulbasaur2" : POKEMON_1,
		"Charmander2" : POKEMON_2,
	}
	
	active_pokemon = POKEMON_1

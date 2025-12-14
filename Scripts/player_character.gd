extends Node2D

@export var poke_species_names: Array[String]
@export var poke_pet_names: Array[String]
@export var poke_levels: Array[int]
@export var poke_animations: Array[AnimatedSprite2D]
@export var poke_resources: Array[PokemonSpecies]
@export var move_resources: Array[Move]

@onready var hp_bar = $PlayerHealthBar

var player_pokemon_instances = {}
var active_pokemon: PokemonInstance

signal all_player_pokemon(pokemon_instances)
signal all_player_pokemon_manager(pokemon_instances, active_name)
signal active_player_pokemon(pokemon)

var anim_nodes: Dictionary[String, AnimatedSprite2D]
var pokemon_instances: Dictionary[String, PokemonInstance]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
		
	initalise_dummy_values()
	# Reciever combat manager for getting all pokemon
	anim_nodes[active_pokemon.species.name].visible = true
	anim_nodes[active_pokemon.species.name].play()
	all_player_pokemon.emit(player_pokemon_instances)
	all_player_pokemon_manager.emit(player_pokemon_instances, active_pokemon.name)
	# Reciever UI so that it knows pokemon moves
	active_player_pokemon.emit(active_pokemon)

func change_active_pokemon(new_pokemon : PokemonInstance) -> void:
	anim_nodes[active_pokemon.species.name].visible = false
	anim_nodes[active_pokemon.species.name].pause()
	active_pokemon = new_pokemon
	anim_nodes[active_pokemon.species.name].visible = true
	anim_nodes[active_pokemon.species.name].play()
	update_hp()
	active_player_pokemon.emit(active_pokemon)

# A rudimentary damage animation
func take_damage():
	for i in range(4):
		anim_nodes[active_pokemon.species.name].visible = not anim_nodes[active_pokemon.species.name].visible
		await get_tree().create_timer(0.25).timeout

func update_hp():
	var curr_hp = active_pokemon.current_hp
	var max_hp = active_pokemon.current_stats[ALIAS.HP]
	if (hp_bar == null):
		return
	hp_bar.update_hp(curr_hp, max_hp)

func initalise_dummy_values() -> void:
	var manual_load = load("res://Data/species/004_charmander.tres")
	
	print("Manual Load: ", manual_load)
	print("Is Resource? ", manual_load is Resource)
	print("Is PokemonSpecies? ", manual_load is PokemonSpecies)
	print(poke_species_names)
	print(poke_pet_names)
	print(poke_resources)
	print(poke_animations)
	print(move_resources)
	assert(poke_levels.size() == poke_pet_names.size())
	assert(poke_levels.size() == poke_species_names.size(), "Check your levels and specie names array in Inspector!")
	assert(move_resources.size() == 4 * poke_species_names.size(), "There must be 4 moves per pokemon!")
	assert(poke_animations.size() == poke_species_names.size(), "Check your animations and species names input in Inspector!")
	assert(poke_resources.size() == poke_species_names.size(), "Check your resources and species names input in Inspector!")
	
	# Filling dictionaries
	for i in range(poke_species_names.size()):
		var specie_name: String = poke_species_names[i]
		var pet_name: String = poke_pet_names[i]
		anim_nodes[specie_name] = poke_animations[i]
		
		var specie: PokemonSpecies = poke_resources[i]
		var instance = PokemonInstance.new(pet_name, specie, poke_levels[i])
		# Filling moves
		for j in range(i, i+4):
			var move: Move = move_resources[i].duplicate(true)
			instance.learn_move(move)
		
		pokemon_instances[instance.name] = instance
	
	active_pokemon = pokemon_instances[poke_pet_names[0]]

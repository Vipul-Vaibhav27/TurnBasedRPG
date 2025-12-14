extends Node2D

@export var poke_species_names: Array[String]
@export var poke_pet_names: Array[String]
@export var poke_levels: Array[int]
@export var poke_animations: Array[AnimatedSprite2D]
@export var poke_resource_paths: Array[String]
@export var move_resources: Array[Move]

@onready var hp_bar = $PlayerHealthBar
@onready var label = $Label

var active_pokemon: PokemonInstance

signal all_player_pokemon(pokemon_instances)
signal all_player_pokemon_manager(pokemon_instances, active_name)
signal active_player_pokemon(pokemon)

var anim_nodes: Dictionary[String, AnimatedSprite2D]
var pokemon_instances: Dictionary[String, PokemonInstance]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initalise_dummy_values()
	label.text = "Lvl "+str(active_pokemon.level)+"-"+active_pokemon.name
	# Reciever combat manager for getting all pokemon
	anim_nodes[active_pokemon.species.name].visible = true
	anim_nodes[active_pokemon.species.name].play()
	all_player_pokemon.emit(pokemon_instances)
	all_player_pokemon_manager.emit(pokemon_instances, active_pokemon.name)
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
	label.text = "Lvl "+str(active_pokemon.level)+"-"+active_pokemon.name

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
	assert(poke_levels.size() == poke_pet_names.size())
	assert(poke_levels.size() == poke_species_names.size(), "Check your levels and specie names array in Inspector!")
	assert(move_resources.size() == 4 * poke_species_names.size(), "There must be 4 moves per pokemon!")
	assert(poke_animations.size() == poke_species_names.size(), "Check your animations and species names input in Inspector!")
	assert(poke_resource_paths.size() == poke_species_names.size(), "Check your resource paths and species names input in Inspector!")
	
	# Filling dictionaries
	for i in range(poke_species_names.size()):
		var specie_name: String = poke_species_names[i]
		var pet_name: String = poke_pet_names[i]
		anim_nodes[specie_name] = poke_animations[i]
		
		var specie: PokemonSpecies = load(poke_resource_paths[i])
		if "SPD" in specie.base_stats:
			specie.base_stats[ALIAS.SPD] = specie.base_stats["SPD"]
			specie.base_stats.erase("SPD")
		var instance = PokemonInstance.new(pet_name, specie, poke_levels[i])
		# Filling moves
		for j in range(4*i, 4*(i+1)):
			var move: Move = move_resources[j].duplicate(true)
			instance.learn_move(move)
		
		pokemon_instances[instance.name] = instance
	
	active_pokemon = pokemon_instances[poke_pet_names[0]]

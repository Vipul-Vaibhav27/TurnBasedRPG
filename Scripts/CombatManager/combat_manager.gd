extends Node

var combat_state = CS.CombatState.new() # Initialization
var combat_initiated: bool = false
var turn: Turn

class Turn:
	var curr_turn = null # 0 for player, 1 for enemy
	func _init(player_spd: int, enemy_spd: int) -> void:
		curr_turn = 0 if player_spd >= enemy_spd else 1
	func next() -> void:
		curr_turn = 1 - curr_turn
	func is_player() -> bool:
		return curr_turn == 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Connect this function to signal emmitted by UI (Start Combat) button
func initiate_combat() -> void:
	# TODO: Load Player's pokemons and Enemy's pokemons into combat state and start turns
	combat_initiated = true
	
	assert(combat_state.curr_player != "", "Current Pokemon of Player hasn't been set!")
	assert(combat_state.curr_enemy != "", "Current Pokemon of Enemy hasn't been set!")
	
	var player_spd = combat_state.get_stat_current(true, ALIAS.SPD)
	var enemy_spd = combat_state.get_stat_current(true, ALIAS.SPD)
	turn = Turn.new(player_spd, enemy_spd)
	
# Connect this function to signal emmitted by UI (When player inputs to change pokemon)
func change_pokemon(p_pokemon_name: String):
	combat_state.change_player(p_pokemon_name)

func enemy_execution() -> void:
	# Enemy AI (lol)
	var hp = combat_state.get_stat_current(false, ALIAS.HP)
	var curr_hp = combat_state.get_stat_current(false, ALIAS.CURRHP)
	
	var thresh = 0.1
	
	# Implement BattleCalculator

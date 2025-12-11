extends Node

var combat_state = CS.CombatState.new() # Initialization
var combat_initiated: bool = false
var turn: Turn

# To separate different types of battle log
signal battle_log_choser_added(log: String) # Charmander chose FireBall.
signal battle_log_miss_added(log: String) # FireBall missed!
signal battle_log_critical_added(log: String) # Critical Hit!
signal battle_log_damage_added(log: String)	 # It dealt 12 damage to Charmander.
signal battle_log_heal_added(log: String) # Charmander healed 15 damage.

signal execute_player_turn

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

	if not turn.is_player():
		enemy_execution()
	else:
		execute_player_turn.emit()

# Connect this function to signal emmitted by UI (When player inputs to change pokemon)
func change_pokemon(p_pokemon_name: String):
	combat_state.change_player(p_pokemon_name)

# UI-SYSTEM should send their moves via this function
func player_execution(move_slot: PokemonInstance.MoveSlot):
	execute_turn(move_slot)

func execute_turn(move_slot: PokemonInstance.MoveSlot):
	var move = move_slot.move_data
	var is_player = turn.is_player()

	var attacker = combat_state.get_attacker(is_player)
	var defender = combat_state.get_defender(is_player)

	battle_log_choser_added.emit(attacker.species.name + " chose " + move.name + ".")

	# ---- Missing Chances
	if randi() % 100 > move.accuracy:
		battle_log_miss_added.emit(move.name + " missed!");
		turn.next()
		return

	# --- HANDLE Status Moves ---
	if move.category == Move.Category.STATUS:
		if move.heal_percent > 0.0:
			var amount = int(combat_state.get_stat_current(is_player, ALIAS.HP) * move.heal_percent)
			combat_state.heal(is_player, amount)
			battle_log_heal_added.emit(attacker.name + " healed " + str(amount) + " damage.")
			move_slot.current_pp -= 1
			turn.next()
			return

		# Handle other status moves
		turn.next()
		return

	# --- HANDLE Attacks (Physical/Special) ---
	var damage = DamageCalculator.calculate(attacker, defender, move, battle_log_critical_added)
	combat_state.take_damage(is_player, damage)

	battle_log_damage_added.emit("It dealt " + str(damage) + " to " + defender.species.name + ".")
	# --- HANDLE Drain Moves ---
	if move.is_drain and move.heal_percent > 0.0:
		# Drain heals based on DAMAGE dealt, not MAX HP
		var drain_amount = int(damage * move.heal_percent)
		combat_state.heal(is_player, drain_amount)
		battle_log_heal_added.emit(attacker.species.name + " healed " + str(drain_amount) + " damage.")

	move_slot.current_pp -= 1
	turn.next()

func enemy_execution() -> void:
	# Basic Enemy
	var hp = combat_state.get_stat_current(false, ALIAS.HP)
	var curr_hp = combat_state.get_stat_current(false, ALIAS.CURRHP)

	var heal_move_names = ["Recover", "Roost", "Giga Drain", "Absorb"]

	var thresh = 0.1
	var poke: PokemonInstance = combat_state.get_attacker(false)

	var atk_move_slots = []
	var heal_move_slots = []
	for moveslot in poke.active_moves:
		if moveslot.move_data.name not in heal_move_names:
			atk_move_slots.append(moveslot)
		else:
			heal_move_slots.append(moveslot)

	assert(atk_move_slots.size() != 0, "Wasteful of a pokemon - All heal moves")

	var rand_attack = randi() % atk_move_slots.size()
	if heal_move_slots.size() == 0 || curr_hp > thresh * hp:
		execute_turn(atk_move_slots[rand_attack])
		return

	var rand_heal = randi() % heal_move_slots.size()
	execute_turn(heal_move_slots[rand_heal])

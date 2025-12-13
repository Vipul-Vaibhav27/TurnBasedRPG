extends Node

var combat_state = CS.CombatState.new() # Initialization
var combat_initiated: bool = false
var turn: Turn

@export var combat_ui: Control
@export var player: Node2D
@export var enemy: Node2D
var ready_count = 0

@onready var hit_sfx = $HitSFX
@onready var death_sfx = $DeathSFX

# To separate different types of battle log
signal battle_log_choser_added(log: String) # Charmander chose FireBall.
signal battle_log_miss_added(log: String) # FireBall missed!
signal battle_log_critical_added(log: String) # Critical Hit!
signal battle_log_damage_added(log: String)	 # It dealt 12 damage to Charmander.
signal battle_log_heal_added(log: String) # Charmander healed 15 damage.

signal execute_player_turn
signal player_death
signal enemy_death
signal execute_enemy_turn

signal victory_signal

signal player_hit
signal enemy_hit

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
	combat_ui.connect("combat_start", ui_got_ready)
	combat_ui.connect("change_to_pokemon", change_pokemon)
	combat_ui.connect("move_to_use", player_execution)
	player.connect("all_player_pokemon_manager", get_player_pokes)
	enemy.connect("all_enemy_pokemon_manager", get_enemy_pokes)

func check_ready():
	ready_count += 1
	if ready_count >= 3:
		initiate_combat()
		ready_count = 0

func ui_got_ready():
	check_ready()

func get_player_pokes(pokemon_instances, active_name):
	combat_state.curr_player = active_name
	combat_state.player = pokemon_instances
	check_ready()

func get_enemy_pokes(pokemon_instances, active_name):
	combat_state.curr_enemy = active_name
	combat_state.enemy = pokemon_instances
	check_ready()

func initiate_combat() -> void:
	combat_initiated = true

	assert(combat_state.curr_player != "", "Current Pokemon of Player hasn't been set!")
	assert(combat_state.curr_enemy != "", "Current Pokemon of Enemy hasn't been set!")
	
	print(combat_state.curr_player)
	print(combat_state.player)
	print(combat_state.player[combat_state.curr_player].current_hp)
	print(combat_state.get_stat_current(true, ALIAS.HP))
	
	var player_spd = combat_state.get_stat_current(true, ALIAS.SPD)
	var enemy_spd = combat_state.get_stat_current(true, ALIAS.SPD)
	turn = Turn.new(player_spd, enemy_spd)
	
	battle_log_choser_added.emit("Player chose " + combat_state.curr_player + ".")
	battle_log_choser_added.emit("Enemy chose " + combat_state.curr_enemy + ".")
	if not turn.is_player():
		enemy_execution()
	else:
		execute_player_turn.emit()

func change_pokemon(p_pokemon_name: String):
	turn.next()
	combat_state.change_player(p_pokemon_name)
	player.change_active_pokemon(combat_state.player[p_pokemon_name])
	battle_log_choser_added.emit("Player chose " + combat_state.curr_player + ".")
	enemy_execution()

func use_item(item_name : String):
	turn.next()
	enemy_execution()


func check_death(poke: PokemonInstance) -> bool:
	return poke.current_hp == 0

func player_execution(move_slot: PokemonInstance.MoveSlot):
	execute_turn(move_slot)
	enemy_execution()

func execute_turn(move_slot: PokemonInstance.MoveSlot) -> bool:
	var move = move_slot.move_data
	var is_player = turn.is_player()

	var attacker = combat_state.get_attacker(is_player)
	var defender = combat_state.get_defender(is_player)

	battle_log_choser_added.emit(attacker.species.name + " chose " + move.name + ".")

	# ---- Missing Chances
	if randi() % 100 > move.accuracy:
		battle_log_miss_added.emit(move.name + " missed!");
		turn.next()
		return false

	# --- HANDLE Status Moves ---
	if move.category == Move.Category.STATUS:
		if move.heal_percent > 0.0:
			var amount = int(combat_state.get_stat_current(is_player, ALIAS.HP) * move.heal_percent)
			combat_state.heal(is_player, amount)
			battle_log_heal_added.emit(attacker.name + " healed " + str(amount) + " damage.")
			move_slot.current_pp -= 1
			turn.next()
			return false

		# Handle other status moves
		turn.next()
		return false

	hit_sfx.play() # Play hit sound if move hits enemy	
	
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
	var player_dead = false
	if check_death(defender):
		death_sfx.play() # Play death sound if enemy dies
		if is_player:
			enemy_death.emit()
			battle_log_critical_added.emit("Enemy's " + combat_state.curr_enemy + " is dead!")
			change_enemy()
		else:
			battle_log_critical_added.emit("Player's " + combat_state.curr_player + " is dead!")
			#await get_tree().create_timer(2.0).timeout
			player_death.emit()
			player_dead = true
	else:
		# No death - show hit animation
		if (is_player):
			enemy_hit.emit()
		else:
			player_hit.emit()
		#await get_tree().create_timer(1).timeout
	
	turn.next()
	return player_dead

func change_enemy() -> void:
	combat_state.enemy.erase(combat_state.curr_enemy)
	
	if combat_state.enemy.size() == 0:
		victory_signal.emit()
		combat_state.curr_enemy = ""
	else:
		var pokes = combat_state.enemy.keys()
		combat_state.curr_enemy = pokes[randi() % pokes.size()]
		enemy.change_active_pokemon(combat_state.enemy[combat_state.curr_enemy])
		battle_log_choser_added.emit("Enemy chose " + combat_state.curr_enemy + ".")

func enemy_execution() -> void:
	# Basic Enemy
	execute_enemy_turn.emit()
	await get_tree().create_timer(2.0).timeout
	var hp = combat_state.get_stat_current(false, ALIAS.HP)
	var curr_hp = combat_state.get_attacker(false).current_hp

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
		if !execute_turn(atk_move_slots[rand_attack]) && combat_state.curr_enemy != "":
			execute_player_turn.emit()
		return

	var rand_heal = randi() % heal_move_slots.size()
	execute_turn(heal_move_slots[rand_heal])
	
	if combat_state.curr_enemy != "":
		execute_player_turn.emit()

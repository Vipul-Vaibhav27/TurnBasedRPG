class_name PokemonInstance

# --- Data ---
var species: PokemonSpecies
var level: int = 1
var nature_multiplier: Dictionary = {ALIAS.ATK: 1.1, ALIAS.SPATK: 0.9} # Example: Adamant

var ivs: Dictionary = {} 
var evs: Dictionary = {}
var current_stats: Dictionary = {} # The final calculated values
var current_hp: int

const MAX_IV = 31
const MAX_EV_PER_STAT = 252
const MAX_EV_TOTAL = 510

const STAT_KEYS = [ALIAS.HP, ALIAS.ATK, ALIAS.DEF, ALIAS.SPATK, ALIAS.SPDEF, ALIAS.SPD]

func _init(p_species: PokemonSpecies, p_level: int):
	species = p_species
	level = p_level
	
	# Initialize
	for key in STAT_KEYS:
		evs[key] = 0
		ivs[key] = randi_range(0, MAX_IV) # Randomize "Genes" (0-31)
	
	recalculate_stats()
	current_hp = current_stats[ALIAS.HP] # Heal to full on create

# --- The Core Math ---
func recalculate_stats():
	for key in STAT_KEYS:
		if key == ALIAS.HP:
			current_stats[key] = _calc_hp(key)
		else:
			current_stats[key] = _calc_stat(key)

func _calc_hp(stat: String) -> int:
	var base = species.base_stats[stat]
	var iv = ivs[stat]
	var ev = evs[stat]
	
	# Formula: ((2 * Base + IV + (EV/4)) * Level / 100) + Level + 10
	var core = (2 * base + iv + (ev / 4))
	var result = int((core * level) / 100.0) + level + 10
	return result

func _calc_stat(stat: String) -> int:
	var base = species.base_stats[stat]
	var iv = ivs[stat]
	var ev = evs[stat]
	
	# Formula: (((2 * Base + IV + (EV/4)) * Level / 100) + 5) * Nature
	var core = (2 * base + iv + (ev / 4))
	var result = int((core * level) / 100.0) + 5
	
	# Apply Nature Multiplier (1.1, 0.9, or 1.0)
	if nature_multiplier.has(stat):
		result = int(result * nature_multiplier[stat])
		
	return result

# --- Training Logic ---
func gain_ev(stat: String, amount: int):
	var total_evs = 0
	for key in evs: 
		total_evs += evs[key]
	
	if total_evs >= MAX_EV_TOTAL:
		print("EVs are fully maxed out!")
		return

	var current_val = evs[stat]
	var space_left = MAX_EV_PER_STAT - current_val
	
	var actual_add = min(amount, space_left)
	
	actual_add = min(actual_add, MAX_EV_TOTAL - total_evs)
	
	if actual_add > 0:
		evs[stat] += actual_add
		recalculate_stats()
		print("Gained %s EVs in %s" % [actual_add, stat])

"""
--------- MOVES ------------------
"""

class MoveSlot:
	var move_data: Move
	var current_pp: int
	
	func _init(m: Move):
		move_data = m
		current_pp = m.max_pp

var active_moves: Array[MoveSlot] = []

func learn_move(new_move: Move):
	if active_moves.size() < 4:
		active_moves.append(MoveSlot.new(new_move))
	else:
		# Logic to replace an old move
		print("Moveset full! Need to forget a move")

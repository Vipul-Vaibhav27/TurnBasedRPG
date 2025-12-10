class_name DamageCalculator

static func calculate(attacker: PokemonInstance, defender: PokemonInstance, move: Move) -> int:
	# --- Step 0: Status Moves do 0 damage ---
	if move.category == Move.Category.STATUS:
		return 0

	# --- Step 1: Select Offense/Defense Stats ---
	# Physical moves use ATK vs DEF. Special moves use SP_ATK vs SP_DEF.
	var attack_stat = 0
	var defense_stat = 0
	
	if move.category == Move.Category.PHYSICAL:
		attack_stat = attacker.current_stats[ALIAS.ATK]
		defense_stat = defender.current_stats[ALIAS.DEF]
	elif move.category == Move.Category.SPECIAL:
		attack_stat = attacker.current_stats[ALIAS.SPATK]
		defense_stat = defender.current_stats[ALIAS.SPDEF]

	# --- Step 2: The Core Formula ---
	# ((2 * Level / 5 + 2) * Power * A / D) / 50 + 2
	var level_factor = (2 * attacker.level) / 5.0 + 2
	var raw_damage = (level_factor * move.power * (float(attack_stat) / defense_stat)) / 50.0 + 2

	# --- Step 3: Apply Modifiers ---
	var multiplier = 1.0

	# A. STAB (Same Type Attack Bonus)
	# If a Fire Pokemon uses a Fire move -> 1.5x damage
	if move.type in attacker.species.types:
		multiplier *= 1.5

	# B. Type Effectiveness (Super Effective / Not Very Effective)
	var type_mult = TypeChart.get_effectiveness(move.type, defender.species.types)
	multiplier *= type_mult
	
	# C. Random Variance (0.85 to 1.0)
	multiplier *= randf_range(0.85, 1.0)

	# D. Critical Hit (1/16 chance -> 1.5x)
	if randf() < 0.0625:
		print("Critical Hit!")
		multiplier *= 1.5

	# --- Step 4: Final Result ---
	return int(raw_damage * multiplier)

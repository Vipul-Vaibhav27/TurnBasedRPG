class_name TypeChart

enum Type { NORMAL, FIRE, WATER, ELECTRIC, GRASS, ICE, FIGHTING, POISON, GROUND, FLYING,
PSYCHIC, BUG, ROCK, GHOST, DRAGON, DARK, STEEL, FAIRY }

# Simple lookup table: [Attacker][Defender] = Multiplier
const CHART = {
	Type.FIRE: {
		Type.GRASS: 2.0,
		Type.WATER: 0.5,
		Type.FIRE: 0.5
	},
	Type.WATER: {
		Type.FIRE: 2.0,
		Type.GRASS: 0.5,
		Type.WATER: 0.5
	}
	# full in rest
}

static func get_effectiveness(attack_type: int, defender_types: Array) -> float:
	var total_mult = 1.0
	
	if CHART.has(attack_type):
		# Check against every type the defender has (Dual types like Fire/Flying)
		for def_type in defender_types:
			if CHART[attack_type].has(def_type):
				total_mult *= CHART[attack_type][def_type]
	
	return total_mult

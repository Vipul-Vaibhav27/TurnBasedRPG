class_name TypeChart

enum Type { NORMAL, FIRE, WATER, ELECTRIC, GRASS, ICE, FIGHTING, POISON, GROUND, FLYING,
PSYCHIC, BUG, ROCK, GHOST, DRAGON, DARK, STEEL, FAIRY }

# Simple lookup table: [Attacker][Defender] = Multiplier
const CHART = {
	Type.NORMAL: {
		Type.ROCK: 0.5,
		Type.GHOST: 0,
		Type.STEEL: 0.5
	},
	Type.FIRE: {
		Type.FIRE: 0.5,
		Type.WATER: 0.5,
		Type.GRASS: 2.0,
		Type.ICE: 2.0,
		Type.BUG: 2.0,
		Type.ROCK: 0.5,
		Type.DRAGON: 0.5,
		Type.STEEL: 2.0
	},
	Type.WATER: {
		Type.FIRE: 2.0,
		Type.WATER: 0.5,
		Type.GRASS: 0.5,
		Type.GROUND: 2.0,
		Type.ROCK: 2.0,
		Type.DRAGON: 0.5,
	},
	Type.ELECTRIC: {
		Type.WATER: 2.0,
		Type.ELECTRIC: 0.5,
		Type.GRASS: 0.5,
		Type.GROUND: 0,
		Type.FLYING: 2.0,
		Type.DRAGON: 0.5,
	},
	Type.GRASS: {
		Type.FIRE: 0.5,
		Type.WATER: 2.0,
		Type.GRASS: 0.5,
		Type.POISON: 0.5,
		Type.GROUND: 2.0,
		Type.FLYING: 0.5,
		Type.BUG: 0.5,
		Type.ROCK: 2.0,
		Type.DRAGON: 0.5,
		Type.STEEL: 0.5,
	},
	Type.ICE: {
		Type.FIRE: 0.5,
		Type.WATER: 0.5,
		Type.GRASS: 2.0,
		Type.ICE: 0.5,
		Type.GROUND: 2.0,
		Type.FLYING: 2.0,
		Type.DRAGON: 2.0,
		Type.STEEL: 0.5,
	},
	Type.FIGHTING: {
		Type.NORMAL: 2.0,
		Type.ICE: 2.0,
		Type.POISON: 0.5,
		Type.FLYING: 0.5,
		Type.PSYCHIC: 0.5,
		Type.BUG: 0.5,
		Type.ROCK: 2.0,
		Type.GHOST: 0,
		Type.DARK: 2.0,
		Type.STEEL: 2.0,
		Type.FAIRY: 0.5,
	},
	Type.POISON: {
		Type.GRASS: 2.0,
		Type.POISON: 0.5,
		Type.GROUND: 0.5,
		Type.ROCK: 0.5,
		Type.GHOST: 0.5,
		Type.STEEL: 0,
		Type.FAIRY: 2.0,
	},
	Type.GROUND: {
		Type.FIRE: 2.0,
		Type.ELECTRIC: 2.0,
		Type.GRASS: 0.5,
		Type.POISON: 2.0,
		Type.FLYING: 0,
		Type.BUG: 0.5,
		Type.ROCK: 2.0,
		Type.STEEL: 2.0,
	},
	Type.FLYING: {
		Type.ELECTRIC: 0.5,
		Type.GRASS: 2.0,
		Type.FIGHTING: 2.0,
		Type.BUG: 2.0,
		Type.ROCK: 0.5,
		Type.STEEL: 0.5,
	},
	Type.PSYCHIC: {
		Type.FIGHTING: 2.0,
		Type.POISON: 2.0,
		Type.PSYCHIC: 0.5,
		Type.DARK: 0,
		Type.STEEL: 0.5,
	},
	Type.BUG: {
		Type.FIRE: 0.5,
		Type.GRASS: 2.0,
		Type.FIGHTING: 0.5,
		Type.POISON: 0.5,
		Type.FLYING: 0.5,
		Type.PSYCHIC: 2.0,
		Type.GHOST: 0.5,
		Type.DARK: 2.0,
		Type.STEEL: 0.5,
		Type.FAIRY: 0.5,
	},
	Type.ROCK: {
		Type.FIRE: 2.0,
		Type.ICE: 2.0,
		Type.FIGHTING: 0.5,
		Type.GROUND: 0.5,
		Type.FLYING: 2.0,
		Type.BUG: 2.0,
		Type.STEEL: 0.5,
	},
	Type.GHOST: {
		Type.NORMAL: 0,
		Type.PSYCHIC: 2.0,
		Type.GHOST: 2.0,
		Type.DARK: 0.5,
	},
	Type.DRAGON: {
		Type.DRAGON: 2.0,
		Type.STEEL: 0.5,
		Type.FAIRY: 0,
	},
	Type.DARK: {
		Type.FIGHTING: 0.5,
		Type.PSYCHIC: 2.0,
		Type.GHOST: 2.0,
		Type.DARK: 0.5,
		Type.FAIRY: 0.5,
	},
	Type.STEEL: {
		Type.FIRE: 0.5,
		Type.WATER: 0.5,
		Type.ELECTRIC: 0.5,
		Type.ICE: 2.0,
		Type.ROCK: 2.0,
		Type.STEEL: 0.5,
		Type.FAIRY: 2.0,
	},
	Type.FAIRY: {
		Type.FIRE: 0.5,
		Type.FIGHTING: 2.0,
		Type.POISON: 0.5,
		Type.DRAGON: 2.0,
		Type.DARK: 2.0,
		Type.STEEL: 0.5,
	},
}

static func get_effectiveness(attack_type: int, defender_types: Array) -> float:
	var total_mult = 1.0

	if CHART.has(attack_type):
		# Check against every type the defender has (Dual types like Fire/Flying)
		for def_type in defender_types:
			if CHART[attack_type].has(def_type):
				total_mult *= CHART[attack_type][def_type]

	return total_mult

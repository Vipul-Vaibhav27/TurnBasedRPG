class_name Move extends Resource

enum Category { PHYSICAL, SPECIAL, STATUS }

@export var name: String = "Tackle"
@export var type: TypeChart.Type = TypeChart.Type.NORMAL
@export var category: Category = Category.PHYSICAL

@export var power: int = 40      # How hard it hits (e.g., 40 for Tackle, 110 for Hydro Pump)
@export var accuracy: int = 100  # Percentage chance to hit (100 = always hits)
@export var max_pp: int = 35     # How many times it can be used
@export var priority: int = 0    # 0 is standard. +1 is Quick Attack.

# New Flags for Healing
@export_group("Healing Logic")
@export var heal_percent: float = 0.0  # 0.5 = Heals 50% of Max HP
@export var is_drain: bool = false     # If true, heals based on damage dealt (Giga Drain)

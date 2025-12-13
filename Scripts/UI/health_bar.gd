extends Control

@onready var hp_progress_bar = $TextureProgressBar

func update_hp(curr_hp, max_hp) -> void:
	hp_progress_bar.value = (curr_hp/max_hp) * hp_progress_bar.max_value

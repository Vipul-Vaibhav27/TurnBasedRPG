import requests
import os
import re

# --- CONFIGURATION ---
OUTPUT_DIR = "pokemon_data/species/" # The internal path in your Godot project
SAVE_DIR = "Data/species" # Where files save on your computer right now
POKEMON_COUNT = 151  # Gen 1

# Map PokeAPI type strings to your Godot Enum integers
# Based on the order: Normal, Fire, Water, Electric, Grass, Ice, Fighting, Poison, Ground,
# Flying, Psychic, Bug, Rock, Ghost, Dragon, Dark, Steel, Fairy
TYPE_MAP = {
    "normal": 0, "fire": 1, "water": 2, "electric": 3, "grass": 4, "ice": 5,
    "fighting": 6, "poison": 7, "ground": 8, "flying": 9, "psychic": 10,
    "bug": 11, "rock": 12, "ghost": 13, "dragon": 14, "dark": 15,
    "steel": 16, "fairy": 17
}

# Map PokeAPI stats to your ALIAS keys (assuming they are Strings for the Resource)
# If ALIAS is an Enum, we'd need to output integers here instead.
# For now, I'm using string keys to be safe and human-readable.
STAT_MAP = {
    "hp": "HP",
    "attack": "Attack",
    "defense": "Defense",
    "special-attack": "SpAtk",
    "special-defense": "SpDef",
    "speed": "SPD"
}

# --- ENSURE DIRECTORY EXISTS ---
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

def fetch_and_generate():
    print(f"Fetching {POKEMON_COUNT} Pokemon...")

    for i in range(1, POKEMON_COUNT + 1):
        try:
            # 1. Fetch Data
            response = requests.get(f"https://pokeapi.co/api/v2/pokemon/{i}")
            if response.status_code != 200:
                print(f"Failed to fetch ID {i}")
                continue

            data = response.json()
            name = data['name'].capitalize()

            # 2. Process Types
            # Converts ["fire", "flying"] -> [1, 9]
            types_int_list = []
            for t in data['types']:
                t_name = t['type']['name']
                if t_name in TYPE_MAP:
                    types_int_list.append(str(TYPE_MAP[t_name]))

            # Format as Godot Array: [1, 9]
            types_string = f"[{', '.join(types_int_list)}]"

            # 3. Process Stats & EVs
            base_stats = {}
            ev_yields = {}

            for s in data['stats']:
                stat_name = s['stat']['name'] # e.g., "special-attack"
                base_val = s['base_stat']
                effort_val = s['effort']

                # Map to your internal keys (e.g., "sp_atk")
                if stat_name in STAT_MAP:
                    key = STAT_MAP[stat_name]
                    base_stats[key] = base_val
                    ev_yields[key] = effort_val

            # Helper to format dict to GDScript string
            def dict_to_str(d):
                items = [f'"{k}": {v}' for k, v in d.items()]
                return "{\n" + ", ".join(items) + "\n}"

            # 4. Generate the .tres Content
            # Note: The script_class="PokemonSpecies" must match your class_name in Godot
            tres_content = f"""[gd_resource type="Resource" script_class="PokemonSpecies" load_steps=2 format=3]

[ext_resource type="Script" path="res://Scripts/Pokemon/pokemon_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
name = "{name}"
types = {types_string}
base_stats = {dict_to_str(base_stats)}
ev_yield = {dict_to_str(ev_yields)}
xp_yield = {data['base_experience']}
"""

            # 5. Save File
            filename = f"{i:03d}_{name.lower()}.tres"
            filepath = os.path.join(SAVE_DIR, filename)

            with open(filepath, "w") as f:
                f.write(tres_content)

            print(f"Saved {filename}")

        except Exception as e:
            print(f"Error processing ID {i}: {e}")

if __name__ == "__main__":
    fetch_and_generate()

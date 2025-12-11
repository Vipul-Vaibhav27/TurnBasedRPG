import requests
import os

# --- CONFIGURATION ---
# Where the .tres files will be saved on your computer
SAVE_DIR = "Data/moves"
# The internal Godot path to your move script
SCRIPT_PATH = "res://Scripts/Pokemon/move_data.gd"

# How many moves to fetch? (Gen 1 has 165 moves)
# Set to a higher number (e.g., 800) to get modern moves
MOVE_COUNT = 165

# Map PokeAPI type strings to your Godot Enum Integers
# (Must match the same order as your PokemonSpecies map)
TYPE_MAP = {
    "normal": 0, "fire": 1, "water": 2, "electric": 3, "grass": 4, "ice": 5,
    "fighting": 6, "poison": 7, "ground": 8, "flying": 9, "psychic": 10,
    "bug": 11, "rock": 12, "ghost": 13, "dragon": 14, "dark": 15,
    "steel": 16, "fairy": 17
}

# Map PokeAPI damage_class to your Category Enum
# enum Category { PHYSICAL, SPECIAL, STATUS }
CATEGORY_MAP = {
    "physical": 0,
    "special": 1,
    "status": 2
}

# --- ENSURE DIRECTORY EXISTS ---
if not os.path.exists(SAVE_DIR):
    os.makedirs(SAVE_DIR)

def get_heal_data(meta, move_name):
    """
    Helper to guess healing flags.
    PokeAPI stores this in 'meta' -> 'healing' (0 to 100).
    """
    heal_percent = 0.0
    is_drain = False

    if meta:
        # Check for Drain (category 10 in PokeAPI meta is 'drain')
        if meta.get('category', {}).get('name') == 'damage+heal':
            is_drain = True
            # Drain usually heals 50% of damage, but PokeAPI data varies here.
            # We default to 0.5 for drain moves if flagged.
            heal_percent = 0.5

        # Check for Pure Healing (Recover, Softboiled)
        elif meta.get('category', {}).get('name') == 'heal':
            # PokeAPI 'healing' field is 0-100 (e.g., 50)
            healing_val = meta.get('healing', 0)
            if healing_val > 0:
                heal_percent = float(healing_val) / 100.0

    return heal_percent, is_drain

def fetch_and_generate_moves():
    print(f"Fetching {MOVE_COUNT} Moves...")

    for i in range(1, MOVE_COUNT + 1):
        try:
            # 1. Fetch Data
            response = requests.get(f"https://pokeapi.co/api/v2/move/{i}")
            if response.status_code != 200:
                print(f"Failed to fetch Move ID {i}")
                continue

            data = response.json()

            # 2. Extract Basic Data
            # Names in API are dicts with languages, index 7 is usually English,
            # but 'name' key is the ID-name (e.g. "mega-punch"). We use that or format it.
            # Let's use the clean English name if available.
            move_name = "Unknown"
            for n in data['names']:
                if n['language']['name'] == 'en':
                    move_name = n['name']
                    break

            # 3. Map Enums
            type_str = data['type']['name']
            type_int = TYPE_MAP.get(type_str, 0) # Default Normal

            cat_str = data['damage_class']['name']
            cat_int = CATEGORY_MAP.get(cat_str, 0) # Default Physical

            # 4. Extract Stats (Handle Nulls for Status moves)
            power = data['power'] if data['power'] is not None else 0
            accuracy = data['accuracy'] if data['accuracy'] is not None else 100
            pp = data['pp'] if data['pp'] is not None else 0
            priority = data['priority'] if data['priority'] is not None else 0

            # 5. Determine Healing Logic
            meta = data.get('meta')
            heal_percent, is_drain = get_heal_data(meta, data['name'])

            # 6. Generate .tres Content
            tres_content = f"""[gd_resource type="Resource" script_class="Move" load_steps=2 format=3]

[ext_resource type="Script" path="{SCRIPT_PATH}" id="1_script"]

[resource]
script = ExtResource("1_script")
name = "{move_name}"
type = {type_int}
category = {cat_int}
power = {power}
accuracy = {accuracy}
max_pp = {pp}
priority = {priority}
heal_percent = {heal_percent}
is_drain = {"true" if is_drain else "false"}
"""

            # 7. Save File (using ID to make loading easy: 001.tres)
            filename = f"{i:03d}.tres"
            filepath = os.path.join(SAVE_DIR, filename)

            with open(filepath, "w") as f:
                f.write(tres_content)

            print(f"Saved {filename} ({move_name})")

        except Exception as e:
            print(f"Error processing Move ID {i}: {e}")

if __name__ == "__main__":
    fetch_and_generate_moves()

import json
import os

def rgb_to_hex(r, g, b):
    return f"#{r:02x}{g:02x}{b:02x}"

def parse_country_data(countries_folder, countrycolor_folder):
    countries = {}
    for filename in os.listdir(countries_folder):
        if filename.endswith(".txt"):
            country_alias = filename.split('-')[0]
            country_name = filename.split('-')[1].replace('.txt', '')
            with open(os.path.join(countries_folder, filename), 'r', encoding='utf-8-sig') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("capital"):
                        capital_state_id = line.strip().split(' = ')[1].split(' #')[0]
                countries[country_alias] = {"name": country_name, "capital": capital_state_id, "states": []}

    for filename in os.listdir(countrycolor_folder):
        if filename.endswith(".txt"):
            country_name = filename.replace('.txt', '')
            with open(os.path.join(countrycolor_folder, filename), 'r', encoding='utf-8-sig') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("color"):
                        color_values = line.split('{')[1].split('}')[0].strip().split()
                        r, g, b = int(color_values[0]), int(color_values[1]), int(color_values[2])
                        hex_color = rgb_to_hex(r, g, b)
                        for country_alias, country_data in countries.items():
                            if country_data["name"] == country_name:
                                country_data["color"] = hex_color
    return countries

countries = parse_country_data('countries', 'countrycolor')
with open('countries.json', 'w') as outfile:
    json.dump(countries, outfile, indent=4)

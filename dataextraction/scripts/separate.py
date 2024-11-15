import json
import os

def rgb_to_hex(r, g, b):
    return f"#{r:02x}{g:02x}{b:02x}"

with open('all.json', 'r') as infile:
    data = json.load(infile)

countries_with_provinces = {}
state_to_province = []

for country_alias, country_data in data.items():
    provinces = []
    for state in country_data['states']:
        state_provinces = state['provinces']
        provinces.extend(state_provinces)
        state_info = {
            "state_id": state["name"],
            "provinces": state_provinces
        }
        state_to_province.append(state_info)

    color_detected = 'color' in country_data
    if not color_detected:
        print(f"Color not found for country: {country_data['name']}")
        r, g, b = map(int, input("Enter RGB values separated by space: ").split())
        hex_color = rgb_to_hex(r, g, b)
    else:
        hex_color = country_data['color']

    countries_with_provinces[country_alias] = {
        "name": country_data['name'],
        "capital": country_data['capital'],
        "provinces": provinces,
        "color": hex_color
    }

with open('countries_with_provinces.json', 'w') as outfile:
    json.dump(countries_with_provinces, outfile, indent=4)

with open('state_to_province.json', 'w') as outfile:
    json.dump(state_to_province, outfile, indent=4)

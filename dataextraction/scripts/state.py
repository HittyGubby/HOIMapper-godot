import json
import os

with open('countries.json', 'r') as infile:
    countries = json.load(infile)

def parse_state_data(states_folder, countries):
    for filename in os.listdir(states_folder):
        if filename.endswith(".txt"):
            state_id = filename.split('-')[0]
            state_name = filename.split('-')[1].replace('.txt', '').strip()
            with open(os.path.join(states_folder, filename), 'r') as f:
                state_info = {"name": state_name, "provinces": []}
                for line in f:
                    line = line.strip()
                    if line.startswith("id"):
                        state_info["id"] = line.split('=')[1]
                    if line.startswith("owner"):
                        owner = line.split(" = ")[1].strip()
                        if owner in countries:
                            countries[owner]["states"].append(state_info)
                    if line.startswith("provinces"):
                        province_line = next(f).strip()
                        province_ids = province_line.split(' ')
                        state_info["provinces"].extend(province_ids)
    return countries

updated_countries = parse_state_data('states', countries)

with open('all.json', 'w') as outfile:
    json.dump(updated_countries, outfile, indent=4)

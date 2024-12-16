import json
import os

with open('all.json', 'r') as infile:
    countries = json.load(infile)
with open('compact.json', 'w') as outfile:
    json.dump(countries, outfile)

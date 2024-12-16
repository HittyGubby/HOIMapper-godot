import json
import xml.etree.ElementTree as ET

def parse_svg(svg_file):
    tree = ET.parse(svg_file)
    root = tree.getroot()
    provinces = {}
    for element in root.findall('{http://www.w3.org/2000/svg}polygon'):
        province_id = element.attrib['id']
        points = element.attrib['points']
        points_list = [list(map(float, p.split(','))) for p in points.split()]
        if province_id not in provinces:
            provinces[province_id] = []
        provinces[province_id].append(points_list)
    return provinces

svg_data = parse_svg('provinces_map.svg')

with open('provinces_data.json', 'w') as outfile:
    json.dump(svg_data, outfile)

print("done")

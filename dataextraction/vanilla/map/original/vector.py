import cv2
import numpy as np
import csv
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor

def parse_province_data(province_csv):
    provinces = {}
    with open(province_csv, mode='r') as file:
        reader = csv.reader(file, delimiter='\t')
        for row in reader:
            if row[4] == "land":
                province_id, r, g, b = row[0], int(row[1]), int(row[2]), int(row[3])
                provinces[province_id] = {"color": (b, g, r)}
    return provinces

provinces = parse_province_data('definition.csv')
workers=4
bitmap_image = cv2.imread('provinces.bmp')
h, w = bitmap_image.shape[:2]

def process_province(province_id, data, bitmap_image):
    b, g, r = data['color']
    mask = cv2.inRange(bitmap_image, np.array([b, g, r]), np.array([b, g, r]))
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    polygons = []
    for contour in contours:
        poly_pts = contour.reshape((-1, 2))
        polygons.append((province_id, poly_pts))
    return polygons

def find_provinces(bitmap_image, provinces):
    labeled_provinces = {}
    total_provinces = len(provinces)
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = []
        for province_id, data in provinces.items():
            futures.append(executor.submit(process_province, province_id, data, bitmap_image))
        for i, future in enumerate(futures, start=1):
            for province_id, poly_pts in future.result():
                if province_id not in labeled_provinces:
                    labeled_provinces[province_id] = []
                labeled_provinces[province_id].append(poly_pts)
            if i % 1000 == 0:
                print(f"Processed {i}/{total_provinces}")
    return labeled_provinces
labeled_provinces = find_provinces(bitmap_image, provinces)

svg = ET.Element('svg', xmlns="http://www.w3.org/2000/svg", version="1.1", width=str(w), height=str(h))
for province_id, polygons in labeled_provinces.items():
    for polygon in polygons:
        points_str = " ".join([f"{x},{y}" for x, y in polygon])
        ET.SubElement(svg, 'polygon', id=province_id, points=points_str, stroke="black", fill="none")

tree = ET.ElementTree(svg)
tree.write('provinces_map.svg')

print("Generated!")

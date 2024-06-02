#!/usr/bin/env Python

import geopandas as gpd
import pandas as pd
from shapely.geometry import box

##-----------------------------------------------------------------##
# Read canary islands SHP files
canary_islands = gpd.read_file("data/islands_shp/municipios.shp")
pne = gpd.read_file("data/islands_shp/eennpp.shp")
zec = gpd.read_file("data/islands_shp/IC_n2000_ZECZonificacion.shp")
##-----------------------------------------------------------------##

##-----------------------------------------------------------------##
# Create Gran Canaria SHPs
gc_muni = canary_islands[canary_islands["isla"] == "GRAN CANARIA"]
gc_pne = pne[pne["codigo"].str.startswith("C")]
gc_zec = zec[zec["ISLA"] == "GRAN CANARIA"]

# Fix Gran Canaria Protected Natural Spaces
gc_filter1 = gc_pne[gc_pne["codigo"].isin(["C-01", "C-21", "C-20", "C-14",
                                           "C-15", "C-02", "C-05", "C-04"])] 

gc_filter2 = gpd.overlay(gc_pne, gc_filter1, how="difference")

gc_pne_processed = pd.concat([gc_filter1, gc_filter2], ignore_index=True)

##-----------------------------------------------------------------##
# Create a grid of 50 x 50 meter squares over gc_muni for the protected species
# Assuming the CRS is in meters (e.g., UTM) 

# Get the bounds of the gc_muni
minx, miny, maxx, maxy = gc_muni.total_bounds

# Generate a list of boxes
boxes = []
x = minx
while x < maxx:
    y = miny
    while y < maxy:
        boxes.append(box(x, y, x + 500, y + 500))
        y += 500
    x += 500

# Create a GeoDataFrame from the list of boxes
grid = gpd.GeoDataFrame({'geometry': boxes}, crs=gc_muni.crs)
#grid.plot(edgecolor="black")
#import matplotlib.pyplot as plt
#plt.show()

##-----------------------------------------------------------------##
# Write the new Gran Canaria SHP files 
gc_muni.to_file("data/gran_canaria_shp/gc_muni.shp")
gc_pne_processed.to_file("data/gran_canaria_shp/gc_pne.shp")
gc_zec.to_file("data/gran_canaria_shp/gc_zec.shp")
grid.to_file("data/gran_canaria_shp/gc_grid_empty.shp")
##-----------------------------------------------------------------##
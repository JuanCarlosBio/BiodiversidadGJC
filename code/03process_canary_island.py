#!/usr/bin/env Python

import geopandas as gpd
import pandas as pd

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

##-----------------------------------------------------------------##
# Write the new Gran Canaria SHP files 
gc_muni.to_file("data/gran_canaria_shp/gc_muni.shp")
gc_pne_processed.to_file("data/gran_canaria_shp/gc_pne.shp")
gc_zec.to_file("data/gran_canaria_shp/gc_zec.shp")
##-----------------------------------------------------------------##
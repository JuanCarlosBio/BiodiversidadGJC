#!/usr/bin/env Python

import geopandas as gpd

canary_islands = gpd.read_file("data/islands_shp/municipios.shp")
pne = gpd.read_file("data/islands_shp/eennpp.shp")

gc_muni = canary_islands[canary_islands["isla"] == "GRAN CANARIA"]
gc_pne = pne[pne["codigo"].str.startswith("C")]

gc_muni.to_file("data/gran_canaria_shp/gc_muni.shp")
gc_pne.to_file("data/gran_canaria_shp/gc_pne.shp")

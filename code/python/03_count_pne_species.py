#!/usr/bin/env python

import geopandas as gpd
import pandas as pd
from shapely.geometry import Point

df_plantae = pd.read_csv("data/coord_plantae.tsv", delimiter="\t")
df_plantae = df_plantae[df_plantae["category"] != "Especie protegida"]

gc_pne = gpd.read_file("data/gran_canaria_shp/gc_pne.shp").to_crs(4326)

geometry_plantae = [
    Point(xy) for xy in zip(df_plantae['longitude'], 
                            df_plantae['latitude'])
    ]

plantae_points = gpd.GeoDataFrame(df_plantae, geometry=geometry_plantae)

plantae_points.set_crs(epsg=4326, inplace=True)

plantae_plus_pne = gpd.overlay(plantae_points, gc_pne, how="intersection")

plantae_data = pd.DataFrame(
    plantae_plus_pne[["codigo", "category", "id_biota"]]
    ).groupby(
        ["codigo", "category", "id_biota"]
        ).size(
            ).reset_index(
                name = "n"
                ).groupby(
                    ["codigo", "category"]
                    ).size(
                        ).reset_index(
                            name = "n"
                            ) 

plantae_data.to_csv("data/temp_species.csv", index=False)
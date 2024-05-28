import geopandas as gpd
import pandas as pd
from shapely.geometry import Point

df_plantae = pd.read_csv("data/coord_plantae.tsv", delimiter="\t")
gc_grid_empty = gpd.read_file("data/gran_canaria_shp/gc_grid_empty.shp").to_crs(epsg = 4326)

# Create a geometry column from the latitude and longitude
geometry = [Point(xy) for xy in zip(df_plantae['longitude'], df_plantae['latitude'])]

# Create a GeoDataFrame
species_points = gpd.GeoDataFrame(df_plantae, geometry=geometry)

# Set the coordinate reference system (CRS) to WGS84 (EPSG:4326)
species_points.set_crs(epsg=4326, inplace=True)

gdf_area_species = gpd.sjoin(gc_grid_empty, species_points, how='left', predicate='contains').dropna(subset=['index_right'])

gdf_area_protectd_species = gdf_area_species[gdf_area_species["category"] == "Especie protegida"]

gdf_area_protectd_species.to_file("data/gran_canaria_shp/protected_species_layer.shp")

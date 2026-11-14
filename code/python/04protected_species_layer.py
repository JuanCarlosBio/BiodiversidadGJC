import geopandas as gpd
import pandas as pd
from shapely.geometry import Point

## Load the data
df_species = pd.read_csv("data/species/processed/coord_species.tsv", delimiter="\t")

gc_grid_empty = (
    gpd.read_file("data/gran_canaria_shp/gc_grid_empty.shp")
      .to_crs(epsg = 4326)
  )

gc_pne = (
    gpd.read_file("data/gran_canaria_shp/gc_pne.shp")
      .to_crs(4326)
  )

# Create a geometry column from the latitude and longitude
geometry = [
    Point(xy) for xy in zip(df_species['longitude'], df_species['latitude'])
  ]

# Create a GeoDataFrame
species_points = gpd.GeoDataFrame(df_species, geometry=geometry)

# Set the coordinate reference system (CRS) to WGS84 (EPSG:4326)
species_points.set_crs(epsg=4326, inplace=True)

gdf_area_species = (
  gpd.sjoin(gc_grid_empty, 
            species_points, 
            how='left', 
            predicate='contains')
    .dropna(subset=['index_right']))

gdf_area_protectd_species = gdf_area_species[
  gdf_area_species["category"] == "Especie protegida"
  ]

species_plus_pne = gpd.overlay(species_points, gc_pne, how="intersection")
species_data = (
    pd.DataFrame(species_plus_pne[["codigo", "category", "id_biota"]])
      .groupby(["codigo", "category", "id_biota"])
      .size().reset_index(name = "n")
      .groupby(["codigo", "category"])
      .size()
      .reset_index(name = "n")
  ) 

gdf_area_protectd_species.to_file("data/gran_canaria_shp/protected_species_layer.shp")
species_data.to_csv("data/gran_canaria_shp/processed/temp_protected_species.csv", index=False) 
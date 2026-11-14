#!/usr/bin/env Python

import geopandas as gpd
import pandas as pd
from shapely.geometry import box

def main():
    
    ##-----------------------------------------------------------------##
    ## Cargar los archivos SHP de las islas canarias de IDECanarias
    canary_islands = gpd.read_file("data/islands_shp/municipios.shp")
    pne = gpd.read_file("data/islands_shp/eennpp.shp")
    zec = gpd.read_file("data/islands_shp/IC_n2000_ZECZonificacion.shp")
    ##-----------------------------------------------------------------##

    ##-----------------------------------------------------------------##
    ## Procesar los datos para obtener SHPs específicos de Gran Canaria
    gc_muni = canary_islands[canary_islands["isla"].isin(["GRAN CANARIA", 
                                                          "TENERIFE", 
                                                          "FUERTEVENTURA", 
                                                          "LANZAROTE"])]
    gc_pne = pne[pne["codigo"].str.contains(r"^[CTFL]")]
    gc_zec = zec[zec["ISLA"].isin(["GRAN CANARIA", 
                                   "TENERIFE", 
                                   "FUERTEVENTURA", 
                                   "LANZAROTE"])]

    ## Arrglar el archivo de Espacios Naturales de Gran Canaria
    gc_filter1 = gc_pne[gc_pne["codigo"].isin([
        "C-01", "C-21", "C-20", "C-14",
        "C-15", "C-02", "C-05", "C-04",
        "T-24", "T-1", "T-2", "T-4", "T-10",
        "L-00", "L-07"
    ])] 

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
    ## Guardar los archivos SHP de Gran Canaria procesados en una carpeta llamada "gran_canaria_shp"
    gc_muni.to_file("data/gran_canaria_shp/gc_muni.shp")
    gc_pne_processed.to_file("data/gran_canaria_shp/gc_pne.shp")
    grid.to_file("data/gran_canaria_shp/gc_grid_empty.shp")
    gc_zec.to_file("data/gran_canaria_shp/gc_zec.shp")
    ##-----------------------------------------------------------------##

    return print(">>> Prosado de Islas Canarias a Gran Canaria terminado")

if __name__ == "__main__":
    main()

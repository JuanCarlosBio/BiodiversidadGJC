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
    gc_muni = canary_islands[canary_islands["isla"].isin(["GRAN CANARIA", "TENERIFE"])]
    gc_pne = pne[pne["codigo"].str.contains(r"^[CT]")]
    gc_zec = zec[zec["ISLA"].isin(["GRAN CANARIA", "TENERIFE"])]

    ## Arrglar el archivo de Espacios Naturales de Gran Canaria
    gc_filter1 = gc_pne[gc_pne["codigo"].isin(["C-01", "C-21", "C-20", "C-14",
                                           "C-15", "C-02", "C-05", "C-04",
                                           "T-12", "T-0", "T-35", "T-29"])] 

    gc_filter2 = gpd.overlay(gc_pne, gc_filter1, how="difference")

    gc_pne_processed = pd.concat([gc_filter1, gc_filter2], ignore_index=True)

    ##-----------------------------------------------------------------##
    # Write the new Gran Canaria SHP files 
    ## Guardar los archivos SHP de Gran Canaria procesados en una carpeta llamada "gran_canaria_shp"
    gc_muni.to_file("data/gran_canaria_shp/gc_muni.shp")
    gc_pne_processed.to_file("data/gran_canaria_shp/gc_pne.shp")
    gc_zec.to_file("data/gran_canaria_shp/gc_zec.shp")
    ##-----------------------------------------------------------------##

    return print(">>> Prosado de Islas Canarias a Gran Canaria terminado")

if __name__ == "__main__":
    main()

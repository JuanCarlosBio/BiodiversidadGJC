#!/usr/bin/env Rscript

library(sf)

jardin_kml <- read_sf("data/jardin_botanico.kml")
st_write(jardin_kml, "data/gran_canaria_shp/jardin_botanico.shp")

library(tidyverse)
library(sf)
library(glue)

sf_pe <- read_sf("data/gran_canaria_shp/protected_species_layer.shp") %>%
    filter(!(str_detect(specie, "PEXTINCION"))) %>%
    mutate(longitude = NA,
           latitude = NA) %>%
    st_write("data/gran_canaria_shp/processed/protected_species_layer.shp", append=FALSE)
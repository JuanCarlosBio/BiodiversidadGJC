#!/usr/bin/env Rscript

## Load the libraries
suppressMessages(suppressWarnings({
    library(leaflet)
    library(sf)
    library(tidyverse)
    library(geojsonio)
    library(leaflet.extras)
    library(glue)
    library(crosstalk)
}))

url_biota <- "https://www.biodiversidadcanarias.es/biota/especie/"
url_pne_info <- "https://descargas.grancanaria.com/jardincanario/ESPACIOS%20NATURALES%20PROTEGIDOS%20DE%20GRAN%20CANARIA/" 

## Load the data
# Url for finding the species in biota https://www.biodiversidadcanarias.es/biota/

f_species <- function(data){
    df_speices <- read_tsv(glue("data/{data}")) |>
        mutate(family = str_to_title(family),
            order = str_to_title(order),
            class = str_to_title(class), 
            division = str_to_title(division),
            date = lubridate::dmy(gpsdatetime)) 

    return(df_speices)
}

## Information of the protected natural spaces
pne_info <- system("python code/python/03protected_natural_spaces_info.py | grep ^C-", intern = T)
df_pne_info <- data.frame(info = pne_info)
df_pne_processed <- df_pne_info |> 
  mutate(codigo = str_remove(info, "%.*"),
         codigo = str_replace(codigo, "^C-(\\d)$", "C-0\\1"))

enp_map <- read_sf("data/gran_canaria_shp/gc_pne.shp") %>%
  st_transform(map, crs = 4326) %>%
  mutate(categoria = factor(categoria,
                            levels = c("Monumento Natural", 
                                       "Paisaje Protegido",
                                       "Parque Natural", 
                                       "Parque Rural", 
                                       "Reserva Natural Especial",
                                       "Reserva Natural Integral", 
                                       "Sitio de Interés Científico"))) %>%
  inner_join(., df_pne_processed, by="codigo") 

protected_species <- read_sf("data/protected_species/protected_species_layer.shp") |>
  group_by(specie, name, id_biota, geometry) |> 
  summarise(n = n()) |>  
  ungroup() |>
  group_by(geometry) |>
  summarise(species = paste0(glue("<i><a href='https://www.biodiversidadcanarias.es/biota/especie/{id_biota}'>{specie}</i></a> ({name})"), collapse = "<br>> "),
            n = n())

zec_map <- read_sf("data/gran_canaria_shp/gc_zec.shp") |> 
  rename_all(tolower) |>
  st_transform(map, crs = 4326) 

jardin_botanico <- read_sf("data/gran_canaria_shp/jardin_botanico.shp")

## Create the color palettes for the layers
pal_pne <- colorFactor(
  palette = c("#004078", "#80a0bd", "#f78000", "#e60000", "#00913f", "#034a31", "#BADBCA"),
  domain = enp_map$categoria
)
